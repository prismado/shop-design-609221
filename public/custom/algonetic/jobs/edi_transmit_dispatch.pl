#!/usr/bin/perl -w
use strict;

use ScreenPoint::Core;
use ScreenPoint::Auctionline;
use ScreenPoint::M; # -- Pseudo Mason object
use File::Copy;
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
	'force' ,	# (Optional) Do a recreate
	'debug' ,	# (Optional) debug mode for development support
	'quiet=s' ,	# (Optional) Silent mode
	'help' ,	#
	'v',		# Verbose mode
);

my %Options;
Getopt::Long::config("noignorecase", "bundling");
&Usage('Parameters') unless GetOptions(\%Options, @getopt_args);
&Usage('Help') if $Options{help};
$Options{JOBID} += 0;

$ENV{db_name} = $Options{db} || 'shop';
my $crypt = Crypt::Lite->new(encoding=>'hex8');
open(P, "/root/bin/data/$ENV{db_name}/pwe.txt") or print STDERR "ERR $!\n";
my $pwe = <P>; chomp $pwe;
close(P);
$ENV{db_pass} = $crypt->decrypt($pwe, $ENV{db_name});

my $m = ScreenPoint::M->new();
my $C = ScreenPoint::Core->new( undef, $m, '', 'shell' );
my $A = ScreenPoint::Auctionline->new($C);

my $env = $C->get_webenv();
my $THIS = 'edi_transmit_dispatch';
$C->log(msg=>"== <b>START</b> Job-ID $Options{JOBID} == $0", service=>$THIS);

foreach (sort keys %Options) {
	my $val = /pass/ ? '********' : $Options{$_};
	next if /^JOBID$/ or /^quiet$/ or /^db$/ or /^remote_pass$/;
	$C->log(msg=>"[ Param ] - $_ = $val", service=>$THIS, importance=>3);
}

my $edi_orders = $A->edi_dispatch_to_transmit();
$C->log(msg=>"[ edi_dispatch_to_transmit ] - DN406181-59: Total $edi_orders->{rows} EDI Orders / To transmit: $edi_orders->{count_to_transmit}", service=>$THIS);

unless ($edi_orders->{count_to_transmit}) {
	my $last_order_id = $edi_orders->{orders}->[0]->{order_id} || 0;
	$C->log(msg=>"DN406181-62: Nothing to do / No need to connect to S-FTP / Last Order-ID $last_order_id",
		service=>$THIS, importance=>3);
	exit(0);
}

foreach my $d (@{ $edi_orders->{orders} }) {
	# XX $C->log(msg=>"[ edi_dispatch_to_transmit ] - Via EDI: Order-ID $d->{order_id} - already trans: $d->{already_trans}",
	# XX	service=>$THIS, importance=>3);
	foreach (sort keys %{ $d }) {
		next if /^order_id/ or /^uid$/ or /^id$/ or /^already_trans$/ or /^dn_src$/ or /^dn_action$/ or /^dn_created_at$/;
		$C->log(msg=>"X -------- $_ = $d->{$_}", service=>$THIS);
	}
}

# Konfiguriere die Verbindungsparameter
my $host     = 'ftp.digitecgalaxus.ch'; # SFTP-Serveradresse
my $user     = $Options{remote_user}; # Benutzername
my $password = $Options{remote_pass};

my $suffix     = $C->{CONFIG}->{HTTP_HOST} =~ /shopd/ ? 'Test' : 'Live';
my $remote_dir = $Options{remote_path} || "/OrderData/$suffix/partner2dg"; # Zielverzeichnis auf dem SFTP-Server

# Unterdrücke STDERR während des Verbindungsaufbaus
open(my $orig_stderr, ">&", STDERR); # Behalte eine Kopie des originalen STDERR
open(STDERR, '>', '/dev/null'); # Leite STDERR nach /dev/null um

# Initialisiere die SFTP-Verbindung
my $sftp = Net::SFTP::Foreign->new(
    host => $host,
    user => $user,
    password => $password,
    more => [-o => "StrictHostKeyChecking=no"], # Optional: deaktiviert die Überprüfung des Host-Schlüssels
);

# Wiederherstellen des ursprünglichen STDERR
open(STDERR, ">&", $orig_stderr);

# Prüfe, ob die Verbindung erfolgreich war
$sftp->error and die "Verbindung zum SFTP-Server fehlgeschlagen: " . $sftp->error;

$C->log(msg=>"SFTP Conn to $host ($remote_dir) established", service=>$THIS);

my $sth = $C->{dbh}->prepare(qq~
	SELECT	id, created_at, uid, src, order_id, xval
	FROM	orders_status
	WHERE	status_id=228
	ORDER	by 1 DESC
	limit	500
~);
$sth->execute();

$C->log(msg=>"Local Path:  <tt>_systex/data</tt>", service=>$THIS);
$C->log(msg=>"Remote Path: <tt>$remote_dir</tt>",  service=>$THIS);
my $count = 0;

while(my $r = $sth->fetch()) {
	my ($id, $created_at, $uid, $src, $order_id, $xval) = @{$r};
	my $x_order_id = $C->query("select xval from orders_details where order_id=$order_id and xkey='x_order_id'")->[0];
	my $local_file = "/var/www/html/_systex/data/GDELR_10391065_$x_order_id\.xml";
	my $already_trans = $C->query("select id from orders_status where order_id=$order_id and status_id=229 limit 1")->[0];
	if ($already_trans) {
		$C->log(msg=>"WARN: DN for O-ID $order_id already transmitted", service=>$THIS, importance=>3);
		next;
	}

	print "Going to transfer $local_file to $remote_dir ...\n";
	my $ftpres = $C->ftp(host=>$host, local_file=>$local_file, remote_dir=>$remote_dir, password=>$Options{remote_pass}); # -- 04Feb2025
	foreach (sort keys %{ $ftpres }) {
		next if $_ eq 'system';
		print "[ ftp ] - $_ = \"$ftpres->{$_}\"\n";
	}
	print "------------------------------------------------------------------------------------\n";

	my $errstr = '';
	# XXX $sftp->put($local_file, "$remote_dir/" . basename($local_file)) or do { $errstr = "Upload fehlgeschlagen: " . $sftp->error };
	if ($errstr) {
		$C->log(msg=>"ERROR Order-ID $order_id $errstr", service=>$THIS, importance=>1);
	}
	else {
		$C->log(msg=>"N406191-133: Order-ID $order_id, X-O-ID $x_order_id / $created_at / GDELR_10391065_$x_order_id\.xml to -- ID $id transmitted",
			service=>$THIS);
		$A->set_order_status( $order_id, 229, "GDELR_10391065_$x_order_id\.xml transmitted to $host", $THIS );
		# foreach (sort keys %{ $res }) {
		#	$C->log(msg=>"[ set_order_status ] - $_ = $res->{$_}", importance=>1, service=>$THIS);
		# }
		$count++;
	}
}

$C->log(msg=>"$count dispatch notifications (XML) transmitted to $remote_dir", service=>$THIS);

sub Usage($) {
	print "ERR Usage $_[0]\n";
}

__END__

Created: 18Jun2024
