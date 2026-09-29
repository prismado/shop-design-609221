#!/usr/bin/perl -w
use strict;

use ScreenPoint::Core;
use ScreenPoint::Auctionline;
use ScreenPoint::M; # -- Pseudo Mason object
use Crypt::Lite;
use Getopt::Long;
use DBI;

my @getopt_args = (
	'h',		  # help
	'JOBID=s',	  # Assigned Job-ID
	'db=s',		  # MySQL Shop Database
	'sender_email=s', # Remote user
	'debug' ,	  # (Optional) debug mode for development support
	'quiet=s' ,	  # (Optional) Silent mode
	'help' ,	  #
	'v',		  # Verbose mode
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

unless ($Options{quiet}) {
	foreach (sort keys %Options) {
		$C->log(msg=>"[ Option ] $_ = $Options{$_}", service=>'send_invitation_reg');
	}
}

my $sth = $C->{dbh}->prepare(q~SELECT id, uid, instime, uname, email
				FROM vorders WHERE status=4 AND uname LIKE 'anonymous%' ORDER BY 1 DESC LIMIT 25~);
   $sth->execute();

while(my $r = $sth->fetch()) {
	my ($id, $uid, $instime, $uname, $email) = @{$r};
	$C->log(msg=>"O-ID $id of $instime, UID $uid: $uname $email", service=>'send_invitation_reg');
}

__END__

Created: 31Jul2024 // Wurde ersetzt durch follow_up_purchase.pl
