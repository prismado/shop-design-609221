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
	'remote_user=s',# Remote user
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

$C->log(msg => 'Start', service => 'set_shipping_state') unless $Options{quiet};

my $sth = $C->{dbh}->prepare(q~
	select	DISTINCT o.id, o.instime
	from	orders o, orders_status s
	where	o.id=s.order_id and
		o.instime <= CURRENT_TIMESTAMP - INTERVAL 12 HOUR and
		o.instime >= CURRENT_TIMESTAMP - INTERVAL 100 DAY and
		o.status=4 and s.status_id=104
	order	by 1 desc
	limit	1000
~);
   $sth->execute() or print STDERR "Error $DBI::errstr\n";

while(my $r = $sth->fetch()) {
	my ($order_id, $instime) = @{$r};
	my $delivered  = $C->query("select id from orders_status where order_id=$order_id and status_id=251 limit 1")->[0];
	next if $delivered;
	my $track      = $P->get_shipment_tracking(order_id => $order_id);
	my $instime_ch = $C->trans_date_short($instime);

	print $C->now(12), " - [Order-ID $order_id] - $instime_ch - Status: $track->{status} ... ";

	if ($track->{status} eq 'Delivered') {
		my $set_status = $P->set_order_status($order_id, 251, 'Zugestellt / abgeschlossen', 'DHL');
		$C->{dbh}->do("update orders_status set created_at='$track->{delivered_time}' where id=$set_status->{status_dbid}");
		print "Marked as Delivered";
		$C->log(msg => "N608232-74: O-ID $order_id: Marked as Delivered", service => 'set_shipping_state');
		sleep 2;
	}
	elsif ($track->{status} eq 'OnItsWay') {
		my $already = $C->query("select id from orders_status where order_id=$order_id and status_id=250 limit 1")->[0];
		unless ($already) {
			my $set_status = $P->set_order_status($order_id, 250, 'Sendung unterwegs. Details im Paketverfolgungslink', 'DHL');
			$C->{dbh}->do("update orders_status set created_at='$track->{processed_time}' where id=$set_status->{status_dbid}");
			print "Marked as On-its-way ($track->{processed_time})";
			$C->log(msg => "N608232-83: O-ID $order_id: Marked as On-its-way ($track->{processed_time})", service => 'set_shipping_state');
			sleep 2;
		}
	}

	print "\n";
}

__END__

Created: 23Aug2026
