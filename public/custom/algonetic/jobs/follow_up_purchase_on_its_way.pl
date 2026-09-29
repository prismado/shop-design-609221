#!/usr/bin/perl -w

use strict;
use utf8;

use ScreenPoint::Core;
use ScreenPoint::Auctionline;
use ScreenPoint::M; # -- Pseudo Mason object
use Prismado::Shop;
use Crypt::Lite;
use Getopt::Long;
use DBI;

my @getopt_args = (
	'h',		# help
	'JOBID=s',	# Assigned Job-ID
	'db=s',		# MySQL Shop Database
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

$ENV{db_name} //= $Options{db};
my $crypt = Crypt::Lite->new(encoding=>'hex8');
open(P, "/root/bin/data/$ENV{db_name}/pwe.txt") or print STDERR "ERR $!\n";
my $pwe = <P>; chomp $pwe;
close(P);
$ENV{db_pass} = $crypt->decrypt($pwe, $ENV{db_name});

my $m = ScreenPoint::M->new();
my $C = ScreenPoint::Core->new( undef, $m, '', 'shell' );
my $A = ScreenPoint::Auctionline->new($C);
my $P = Prismado::Shop->new( dbh => $C->{dbh} );

print $C->now(12), " - Start\n";

$C->log(msg => 'Start', service => 'follow_up_purchase_on_its_way') unless $Options{quiet};

my $sth = $C->{dbh}->prepare(q~
	select  DISTINCT o.id, o.instime, o.uid
	from    orders o, orders_status s
	where   o.id=s.order_id and
	        o.instime <= CURRENT_TIMESTAMP - INTERVAL 12 HOUR and
	        o.instime >= CURRENT_TIMESTAMP - INTERVAL 25 DAY and
	        o.status=4 and s.status_id=250
	order   by 1 desc
~);
   $sth->execute() or print STDERR "Error $DBI::errstr\n";

print $C->now(12), " - ", $sth->rows(), " Bestellungen werden geprueft.\n";

my $tech_cc      = (split /,/, $C->txt('40221185_cc_addr', 'sys', '_core'))[0];
my $send_tech_cc = (split /,/, $C->txt('40221185_send_cc', 'sys', '_core'))[0] + 0;
my $site_company = $C->prp('site_company');
my $site_addr    = $C->prp('site_addr');
my $site_zip     = $C->prp('site_zip');
my $site_city    = $C->prp('site_city');
my $site_url_biz = $C->txt('site_url_google_business');

while(my $r = $sth->fetch()) {
	my ($order_id, $instime, $uid) = @{$r};

	# XX my $is_anon = $C->query("select id from users where id=$uid and status=4")->[0] ? 1 : 0;
	my $delivered  = $C->query("select id from orders_status where order_id=$order_id and status_id=251 limit 1")->[0];
	my $already_nt = $C->query("select id from users_details where user_id=$uid and xkey like 'hist_onitsway_%' limit 1")->[0];
	my $instime_ch = $C->trans_date_very_short($instime);

	print $C->now(12), " - $instime_ch - Order-ID $order_id - Delivered: $delivered\n" if $Options{debug};

	# XX next unless $is_anon;
	next if $already_nt or $delivered;

	my $track = $P->get_shipment_tracking(order_id => $order_id);
	my $email = $C->query("select email from users where id=$uid")->[0];

	$track->{tracking_piece_hr} //= 'n/a';
	my $estimated = $track->{tracking}->{shipments}->[0]->{estimatedDeliveryDate} // ''; # -- 29Aug2026

	print $C->now(12), " - O-ID $order_id - $instime_ch - UID $uid - DHL # $track->{tracking_number} - Delivered: $delivered ";

	my $uinf = $A->get_user_info($uid);
	my $lang = $C->query("select xval from users_details where user_id=$uid and xkey='lang' limit 1")->[0];
	print "- lang $lang - $email / cc $tech_cc - ";

	my $salutation = '<p>Sehr geehrt' . ($uinf->{gender} == 2 ? 'e Frau ' : 'er Herr ') . $uinf->{lastname} . '</p>';

	my $dhl_box = $C->slurp_file("$C->{CONFIG}->{DOCUMENT_ROOT}/custom/algonetic/mail_templates/includes/dhl_box.html"); # -- 28Aug2026
	 ${$dhl_box} =~ s/\{\{tracking_id\}\}/$track->{tracking_number}/gs;
	 ${$dhl_box} =~ s/\{\{dhl_shipment\}\}/$track->{tracking_piece_hr}/;

	my @mbody = ();
	push(@mbody, '<div style="font-family:Roboto, Arial; font-size:15px; color:#414141; line-height:125%; padding:0px 10px 10px 10px;">');
	push(@mbody, "$salutation<p><b>Vielen Dank für Ihren Einkauf bei Auctionline.ch!</b></p>");
	if ($estimated) {
		my $estim = $C->trans_date_short_nt((split /T/, $estimated)[0]);
		push(@mbody, qq~<p>Erwartetes Lieferdatum: <b>$estim</b> bis Tagesende.</p>~);
	}
	push(@mbody, ${$dhl_box});
	push(@mbody, $C->txt('invitation_to_registration', $lang));
	push(@mbody, qq~
			<table role="presentation" cellpadding="0" cellspacing="0" border="0" style="margin:0 0 28px 0;">
			<tr>
			  <td style="border-radius:6px; background-color:#1a1a1a;">
			    <a href="https://$C->{CONFIG}->{HTTP_HOST}/send_pwd.html?email_pwd=$uinf->{email}&amp;pwd_send=1"
			       style="display:inline-block; padding:12px 28px;
				font-family:Roboto,Arial,Verdana,Helvetica,sans-serif; font-size:14px;
				font-weight:bold; color:#ffffff; text-decoration:none; border-radius:6px;">
			      Pers&ouml;nliches Passwort abrufen
			    </a>
			  </td>
			</tr>
			</table>

			Freundliche Gr&uuml;sse / Meilleures salutations<br><br>

			<b><big>Auctionline.ch</big></b><br />
			<small>
				Ein Webshop der $site_company<br /><br />
				$C->{CONFIG}->{order_email_sender} | <a href="https://$C->{CONFIG}->{HTTP_HOST}">https://$C->{CONFIG}->{HTTP_HOST}</a>
			</small><br /><br />
			<hr noshade size="1" style="color:#717171; max-width:340px; margin-left:0" />

			<span style="color:#717171">
			    <small>
				<b>$site_company | $site_addr | $site_zip $site_city</b><br>
				<a href="$site_url_biz">Bewerten Sie uns auf Google</a> &#11088;&#11088;&#11088;&#11088;&#11088;<br><br>

			    </small>
			</span>
			<span style="font-size:8px; line-height:10px; color:#b1b1b1;">Vorlage V608270 - OID $order_id</span>
	~);
	push(@mbody, '</div>');

	$C->mail_x(
		sender      => $C->{CONFIG}->{tech_email_sender} || $C->{CONFIG}->{tech_email},
		to          => $email,
		subject     => "📦 Sendung unterwegs - Ihre Bestellung $order_id bei Auctionline",
		encode_subj => 1,
		data        => \(join "\n", @mbody)
	);

	$C->mail_x(
		sender      => $C->{CONFIG}->{tech_email_sender} || $C->{CONFIG}->{tech_email},
		to          => $tech_cc,
		subject     => "Kopie: 📦 Sendung unterwegs - Ihre Bestellung $order_id bei Auctionline",
		encode_subj => 1,
		data        => \(join "\n", @mbody)
	);

	# (my $uname_new = $uinf->{uname}) =~ s/^anonymous/user/;
	# $C->{dbh}->do("update users set uname='$uname_new', status=1 where id=$uid");

	my $now9 = $C->now(9);
	my $note = substr("Sendung O-ID $order_id unterwegs an $email", 0, 255);
	$A->set_user_detail($uid, "hist_onitsway_$now9", $note);

	print "gesendet!";
	$C->log(msg => "N608241: Invitation sent to UID $uid, $email", service => 'follow_up_purchase_on_its_way');
	sleep 2;
	print "\n";
}

print $C->now(12), " - Beendet\n";

__END__

Created: 27Aug2026
