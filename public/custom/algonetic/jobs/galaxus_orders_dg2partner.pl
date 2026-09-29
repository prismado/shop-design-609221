#!/usr/bin/perl -w
use strict;

use ScreenPoint::Core;
use ScreenPoint::Auctionline;
use ScreenPoint::M; # -- Pseudo Mason object
use Crypt::Lite;
use Getopt::Long;
use DBI;

use warnings;
use Net::SFTP::Foreign;
use File::Basename;

my @getopt_args = (
	'h',		# help
	'JOBID=s',	# Assigned Job-ID
	'db=s',		# MySQL Shop Database
	'remote_host=s',# Remote host
	'remote_user=s',# Remote user
	'remote_pass=s',# Remote user password
	'remote_path=s',# Remote directory
	'debug' ,	# (Optional) debug mode for devel support
	'quiet=s' ,	# (Optional) Silent mode
	'help' ,	#
	'v',		# Verbose mode
);

my %Options;
Getopt::Long::config("noignorecase", "bundling");
&Usage('Parameters') unless GetOptions(\%Options, @getopt_args);
&Usage('Help') if $Options{help};
$Options{JOBID} += 0;
$Options{remote_host} ||= 'ftp.digitecgalaxus.ch';
$Options{remote_user} ||= 'ssg';
$Options{remote_path} ||= '/OrderData/Test/dg2partner';

$ENV{db_name} = $Options{db} || 'zzshopd';
my $crypt = Crypt::Lite->new(encoding=>'hex8');
open(P, "/root/bin/data/$ENV{db_name}/pwe.txt") or print STDERR "ERR $!\n";
my $pwe = <P>; chomp $pwe;
close(P);
$ENV{db_pass} = $crypt->decrypt($pwe, $ENV{db_name});

my $m = ScreenPoint::M->new();
my $C = ScreenPoint::Core->new( undef, $m, '', 'shell' );
my $A = ScreenPoint::Auctionline->new($C);

print $C->now(12), " - Start\n" if $Options{debug};

$C->log(msg=>"<b>== Start SFTP Transfer ==</b> $Options{remote_user} @ $Options{remote_host}: $Options{remote_path}, Job-ID $Options{JOBID}",
	service=>'galaxus_orders_dg2partner');

my $host       = 'ftp.digitecgalaxus.ch'; # SFTP-Serveradresse
my $user       = $Options{remote_user};   # SFTP-Benutzername
my $password   = $Options{remote_pass};
my $remote_dir = $Options{remote_path};
my $local_file = "/var/www/html/_systex/data/import/edi";

$SIG{ALRM} = \&alarm_handler; # -- 04Jul2025
alarm 90;

open(my $orig_stderr, ">&", STDERR); # Behalte eine Kopie des originalen STDERR
open(STDERR, '>', '/dev/null'); # Leite STDERR nach /dev/null um

print $C->now(12), " - Connecting to $host ...\n" if $Options{debug};

my $sftp = Net::SFTP::Foreign->new(
    host     => $host,
    user     => $user,
    password => $password,
    more     => [-o => "StrictHostKeyChecking=no"], # Optional: deaktiviert die Überprüfung des Host-Schlüssels
);

open(STDERR, ">&", $orig_stderr); # -- Restore original STDERR

# Prüfe, ob die Verbindung erfolgreich war
$sftp->error and die "Verbindung zum SFTP-Server fehlgeschlagen: " . $sftp->error;

my $ls = $sftp->ls($remote_dir) or die "Konnte das Verzeichnis nicht auflisten: " . $sftp->error;

print $C->now(12), " - Connected to $host\n" if $Options{debug};

my $f_count = my $count_new = 0;
foreach my $entry (@$ls) {
	my $remote_file = $entry->{filename};
	next if $remote_file =~ /^\./;

	my $edi_order_no = my $partner_id = 0;
	if ($remote_file =~ /^GORDP_(\d{8})_(\d+)\.xml$/) {
		$partner_id   = $1;
		$edi_order_no = $2;
	}
	else {
		$edi_order_no ||= -99;
	}
	my ($known2, $already_cr, $known_order_id) = @{$C->query(
		"SELECT id, created_at, order_id FROM orders_status WHERE status_id=226 AND xval like '%$edi_order_no%' limit 1")};

	print $C->now(12), " - Remote file: $remote_file: Known: $known2\n" if $Options{debug};

	if ($known2) {
		print $C->now(12), " - Already created as Order-ID $known_order_id\n" if $Options{debug};
		if ($partner_id) {
			unless ($C->get_workval("warned_$known_order_id\_407221_97")) {
			$C->log(msg=>"NOTE W407192-87: *** EDI Order $edi_order_no ($partner_id) already processed as O-ID $known_order_id at $already_cr!",
				service=>'galaxus_orders_dg2partner');
				$C->set_workval("warned_$known_order_id\_407221_97", 1);
			}
			else {
				$C->log(msg=>"N407221-101: Already warned about Order-ID $known_order_id", importance=>3, service=>'galaxus_orders_dg2partner');
			}
		}
		else {
			$C->log(msg=>"WARN W407201-95: *** $remote_file -- Order-ID $known_order_id", importance=>1, service=>'galaxus_orders_dg2partner');
		}
	}
	else {
		$C->log(msg=>"[ Remote File ] - $remote_file (NEW!)", service=>'galaxus_orders_dg2partner');
		$sftp->get("$remote_dir/$remote_file", "$C->{CONFIG}->{DOCUMENT_ROOT}/_systex/data/import/edi/$remote_file")
			or die "Download fehlgeschlagen: " . $sftp->error;
		my $edi = $C->parse_edi_xml(xml_path=>"$C->{CONFIG}->{DOCUMENT_ROOT}/_systex/data/import/edi/$remote_file", debug=>0);
		foreach (sort keys %{ $edi->{customer} }) {
			next unless length( $edi->{customer}->{$_} );
			$C->log(msg=>"[ EDI Customer ] - $_ = $edi->{customer}->{$_}", service=>'galaxus_orders_dg2partner');
		}
		$C->log(msg=>qq~N405301-116: New EDI Order # $edi->{dta}->{ORDER_ID} $edi->{customer}->{cust_email}
				$edi->{customer}->{cust_name} $edi->{customer}->{cust_surname}~, service=>'galaxus_orders_dg2partner');
		my $ord = &create_local_order(edi=>$edi, remote_file=>$remote_file);

		if ($ord->{rc}) {
			if ($ord->{rc} == 2) {
				$C->log(msg=>"N407201-115: RC $ord->{rc} EDI Order already processed", service=>'galaxus_orders_dg2partner');
			}
			else {
				$C->log(msg=>"Error E406030-101: RC $ord->{rc} Order _not_ created via EDI # $edi_order_no",
					importance=>1, service=>'galaxus_orders_dg2partner');
			}
		}
		else {
			$C->log(msg=>qq~N405301-103: O-ID $ord->{order_id} created via EDI $edi->{dta}->{ORDER_ID}:
				$edi->{customer}->{cust_name} $edi->{customer}->{cust_surname}~, service=>'galaxus_orders_dg2partner');
			my $edi_order_id = $edi->{dta}->{ORDER_ID} + 0;
			(my $rdir_to = $Options{remote_path}) =~ s/dg2partner/partner2dg/;

			# ZZ $sftp->put($ord->{order_response_path}, "$rdir_to/GORDR_10391065_$edi_order_id\.xml") or die "Upload fehlgeschlagen: " . $sftp->error;
			my $ftpres = $C->ftp(
				host=>$host, local_file=>$ord->{order_response_path}, password=>$Options{remote_pass}, remote_dir=>$rdir_to,
				debug=>$Options{debug} ? 1 : 0
			); # -- 04Feb2025

			unless ($ftpres->{rc}) {
				$A->set_order_status($ord->{order_id}, 225, 'Order Response transferred', 'galaxus_orders_dg2partner');
				$C->log(msg=>"Order Response transferred: $ord->{order_response_path} / GORDR_10391065_$edi_order_id\.xml",
					service=>'galaxus_orders_dg2partner');
				$C->log(msg=>"N504301: $remote_dir/$remote_file can be deleted from s-ftp server", service=>'galaxus_orders_dg2partner');
				my $rc_clean = 0;
				$sftp->remove("$remote_dir/$remote_file") or ($rc_clean = 1);
				$C->log(msg=>"N505091: $remote_dir/$remote_file removed, rc $rc_clean, Order-ID $ord->{order_id}, EDI # $edi->{dta}->{ORDER_ID}",
					service=>'galaxus_orders_dg2partner');
			}
		}

		$count_new++;
		$C->set_workval("edi_order_$remote_file", $C->now(1));
	}
	$f_count++;
}

$C->log(msg=>"$f_count Orders identified / $count_new new - Job completed", service=>'galaxus_orders_dg2partner');

# =========================================================================================================
sub create_local_order (%) {
	my %args = @_;
	my $ediparse = $args{edi};

	my %rdata = ();
	   $rdata{rc} = 0; # -- 0=ok, 1=prod not found, 2=already processed, 3=could not create order

	my ($known_id, $already_cr, $known_order_id) = @{$C->query(
		"SELECT id, created_at, order_id FROM orders_status WHERE status_id=226 AND xval like '%$ediparse->{dta}->{ORDER_ID}%' limit 1")};

	if ($known_id) {
		$rdata{rc} = 2;
		$C->log(msg=>"WARN W407201-143: EDI Order $ediparse->{dta}->{ORDER_ID} - already processed ($known_id) as Order-ID $known_order_id",
			service=>'galaxus_orders_dg2partner', importance=>1);
		return \%rdata;
	}

	$ediparse->{customer}->{cust_email} = "no-reply\-$$\@eshop.pub"; # -- 27Aug2026

	my ($rc_cr, $msg_cr) = $A->create_user( $ediparse->{customer} );

	my $uid_exists = $C->query("select id from users where uname='$ediparse->{customer}->{uname}'")->[0];
	my $temp_sid   = $C->newSID();

	my $uid_create_user = $A->{uid} // 0;
	print $C->now(12), " - UID $uid_create_user vs $uid_exists $msg_cr\n" if $Options{debug};

	if ($rc_cr) {
		$C->log(msg=>"N507191: Could not create user: $rc_cr $msg_cr, UID $uid_exists $ediparse->{customer}->{uname}",
			importance=>2, service=>'galaxus_orders_dg2partner');
		$A->set_address_by_id(
			$uid_exists, 2,
			{
				firstname => $ediparse->{customer}->{cust_d_add_name},
				lastname  => $ediparse->{customer}->{cust_d_add_surname},
				gender    => 1,
				street    => $ediparse->{customer}->{cust_d_add_street},
				zip       => $ediparse->{customer}->{cust_d_add_zip},
				city      => $ediparse->{customer}->{cust_d_add_city},
				phone     => $ediparse->{customer}->{cust_d_add_phone},
				company   => $ediparse->{customer}->{cust_d_add_company}
			}
		);
	}
	else {
		print $C->now(12), " - N608271-223: New user created: UID $uid_create_user\n" if $Options{debug};
		my $random_number = int(rand(9_999)) + 1;
		$C->{dbh}->do("update users set email='NoReply.edi-cust-$uid_create_user\-$random_number\@eshop.pub' where id=$uid_create_user");
		# XXX $C->{dbh}->do("update users set email='edi-cust-$uid_create_user\-$random_number\@eshop.pub' where id=$uid_create_user");
	}

	my @TEMPXX = my @order_err = ();
	foreach my $itm (@{ $ediparse->{items} } ) {
		my $prdinf = $A->get_product_v2( id=>$itm->{prod_id}, public=>1 ); # -- 09Jan2025

		my %dummy = ( prod_id => $itm->{prod_id}, qty=>$itm->{qty} );
		my $exists = $C->query("select id from products where id=$itm->{prod_id}")->[0];
		if ($exists) {
			$C->log(msg=>"[ create_local_order ] - To Basket: $itm->{qty} x Prod-ID $itm->{prod_id} / Stock Count $prdinf->{count_product}",
				service=>'galaxus_orders_dg2partner');
			if ($itm->{qty} > $prdinf->{count_product}) {
				$C->log(msg=>"WARN W501092-184: EDI # $ediparse->{dta}->{ORDER_ID}: Prod-ID $itm->{prod_id} out of stock",
					importance=>1, service=>'galaxus_orders_dg2partner');
				push(@order_err, "Error E501092: $itm->{qty} x Prod-ID $itm->{prod_id} requested");
				%dummy = ( prod_id => $itm->{prod_id}, qty=>0 );
			}
		}
		else {
			$C->log(msg=>"Error E406030-139: $itm->{qty} x Prod-ID $itm->{prod_id}: Product not found",
				importance=>1, service=>'galaxus_orders_dg2partner');
			$rdata{rc} = 1;
		}
		push(@TEMPXX, \%dummy);
	}
	my $bask = $A->fill_virtual_basket(ids=>\@TEMPXX, sid=>$temp_sid);

	my $cr_ord = $A->create_order(
		sid     => $temp_sid,
		uid     => $uid_exists,
		remarks => "***** GALAXUS Order # $ediparse->{dta}->{ORDER_ID} $args{remote_file} *****",
		attach  => { inpt=>$args{remote_file}, order_id=>$ediparse->{dta}->{ORDER_ID}, cust_order_ref=>$ediparse->{dta}->{CUSTOMER_ORDER_REFERENCE} }
	);

	foreach (sort keys %{ $cr_ord }) {
		next if /^attach$/;
		$C->log(msg=>"[ create_order ] - $_ = $cr_ord->{$_}", service=>'galaxus_orders_dg2partner');
	}

	if ($cr_ord->{order_id} < 1) {
		$rdata{rc} = 3;
		return \%rdata;
	}

	$A->set_order_status($cr_ord->{order_id}, 226, "EDI Order Nr. \{\{$ediparse->{dta}->{ORDER_ID}\}\}", 'galaxus_orders_dg2partner');

	if (@order_err) {
		foreach (@order_err) {
			$A->set_order_status($cr_ord->{order_id}, 800, $_);
		}
		$rdata{rc} = 4; # -- 09Jan2025
		return \%rdata;
	}

	my $edi = $A->get_order_edi( id=>$cr_ord->{order_id}, edi_order_id=>99999999, debug=>0 ); # -- ORDER RESPONSE

	$rdata{order_response_path} = "$C->{CONFIG}->{DOCUMENT_ROOT}/_systex/data/GORDR_10391065_$ediparse->{dta}->{ORDER_ID}.xml";

	open(OUT, ">$C->{CONFIG}->{DOCUMENT_ROOT}/_systex/data/edi_order_response_$cr_ord->{order_id}.xml");
	print OUT $edi->{out};
	close(OUT);

	open(OUT, ">$C->{CONFIG}->{DOCUMENT_ROOT}/_systex/data/GORDR_10391065_$ediparse->{dta}->{ORDER_ID}.xml"); # -- 04Feb2025
	print OUT $edi->{out};
	close(OUT);

	$rdata{order_id} = $cr_ord->{order_id};

	\%rdata;
}

sub alarm_handler() {
	open(STDERR, ">&", $orig_stderr); # -- Restore original STDERR
	die "Timeout!\n"; # -- 04Jul2025
}

__END__

Created: 29May2024

create_local_order:

- rc 4 = Errors detected

Test it:
/var/www/html/custom/algonetic/jobs/galaxus_orders_dg2partner.pl --remote_pass "cO...lG" --remote_path "/OrderData/Test/dg2partner" --db $DB_NAME
