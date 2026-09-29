#!/usr/bin/perl -w
use strict;

use ScreenPoint::Core;
use ScreenPoint::Auctionline;
use ScreenPoint::M; # -- Pseudo Mason object
use Crypt::Lite;
use Getopt::Long;
use DBI;

my @getopt_args = (
	'h',		# help
	'JOBID=s',	# Assigned Job-ID
	'db=s',		# MySQL Shop Database
	'wait_min=s',	# Wait <s> minutes before reminding
	'wait_min_storno=s', # Wait <s> minutes before cancelling
	'debug' ,	# (Optional) debug mode for development support
	'quiet=s' ,	# (Optional) Silent mode
	'notify_mail=s',# Send notificaion after cancellation
	'help' ,	#
	'v',		# Verbose mode
);

my %Options;
Getopt::Long::config("noignorecase", "bundling");
&Usage('Parameters') unless GetOptions(\%Options, @getopt_args);
&Usage('Help') if $Options{help};
$Options{JOBID} += 0;
$Options{wait_min} += 0;
$Options{wait_min} ||= 60;
$Options{wait_min_storno} += 0;
$Options{wait_min_storno} ||= 180;
$Options{notify_mail} ||= 'cancel@eshop.pub';

$ENV{db_name} = $Options{db} || 'zzshopd';
my $crypt = Crypt::Lite->new(encoding=>'hex8');
open(P, "/root/bin/data/$ENV{db_name}/pwe.txt") or print STDERR "ERR $!\n";
my $pwe = <P>; chomp $pwe;
close(P);
$ENV{db_pass} = $crypt->decrypt($pwe, $ENV{db_name});

my $m = ScreenPoint::M->new();
my $C = ScreenPoint::Core->new( undef, $m, '', 'shell' );
my $A = ScreenPoint::Auctionline->new($C);

my $sth = $C->{dbh}->prepare(
	'select id, uid, instime from orders where status=1 and pay_meth IN (4, 5, 7, 10, 11, 14) order by id desc limit 9999');
   $sth->execute();

if ($Options{debug}) {
	print STDERR $C->now(2), "  DB: $ENV{db_name}, ", $sth->rows(), " rows\n";
	print STDERR $C->now(2), "  Wait for $Options{wait_min} minutes until reminder\n";
	print STDERR $C->now(2), "  Wait for $Options{wait_min_storno} minutes until cancellation\n";
	$C->log(msg=>'Debug Mode', importance=>1, service=>'send_reminder');
}

while(my $r = $sth->fetch()) {
	my ($id, $uid, $instime) = @{$r};
	my $email     = $C->query("select email from users where id=$uid")->[0];
	my $time      = $C->trans_date_short($instime);
	my $mail_sent = $C->query("select xval from orders_details where xkey='_mail_sent' and order_id=$id")->[0];
	my ($Dd,$Dh,$Dm,$Ds,$total_min) = $C->time_delta($instime, $C->now(1));

	if ($mail_sent) {
		if ($total_min > $Options{wait_min_storno}) {
			print STDERR $C->now(2),
				"  Order-ID $id (created $total_min min ago): Ready for cancellation\n" if $Options{debug};
			$A->cancel_order(id=>$id, notify_mail=>$Options{notify_mail});
		}
		else {
			print STDERR $C->now(2),
			"  Order-ID $id (Reminder already sent). Order created $total_min min ago ($Options{wait_min_storno})\n"
				if $Options{debug};
		}
		$C->log(msg=>qq~Pending <a href='admix.html?func=orders&id=$id'>Order-ID $id</a> of $time,
			UID $uid $email\. Sent: $mail_sent~,
			service=>'send_reminder', importance=>2) unless $Options{quiet};
	}
	else {
		my $send_remind = 0;
		if ($Options{debug}) {
			print STDERR $C->now(2), "  N100: Checking Order-ID $id: Created $total_min min ago\n";
		}

		if ($total_min > $Options{wait_min}) {
			if ($total_min > 43200) {
				if ($Options{debug}) {
					print STDERR $C->now(2), "  Warning written\n";
				}
				$C->log(msg=>"WARN: Check pending <a href='admix.html?func=orders&id=$id'>Order-ID $id</a>: Age is $Dd days",
						importance=>1, service=>'send_reminder');
			}
			else {
				$send_remind = 1;
			}
		}
		if ($send_remind) {
			$C->log(msg=>qq~Pending <a href='admix.html?func=orders&id=$id'>Order-ID $id</a>
				of $time, $total_min min ago, $email\. Going to send reminder!~,
					service=>'send_reminder', importance=>1);

			my $md5_secret  = $C->md5_secret($id);

			$A->send_reminder_open_order(
				order_id   => $id,
				order_time => $time, 
				link       => "https://$C->{CONFIG}->{HTTP_HOST}/checkout.html?id=$id&check=$md5_secret",
				debug      => $Options{debug}
			);
		}
		else {
			$C->log(msg=>qq~Pending <a href='admix.html?func=orders&id=$id'>Order-ID $id</a>
				of $time, $total_min min, UID $uid $email~,
					service=>'send_reminder', importance=>2) unless $Options{quiet};
		}
	}
}

sub Usage($) {
	print "Check usage\n";
	exit(0);
}

__END__

Next free codes (3)
N101
