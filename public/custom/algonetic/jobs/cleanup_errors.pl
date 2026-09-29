#!/usr/bin/perl -w
use strict;

# -- Cleanup Errors

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
	'match=s',	# Match for this pattern
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

$ENV{db_name} ||= $Options{db};
my $crypt = Crypt::Lite->new(encoding=>'hex8');
my $errstr = '';
open(P, "/root/bin/data/$ENV{db_name}/pwe.txt") or ($errstr = $!);
my $pwe;
unless ($errstr) {
	$pwe = <P>; chomp $pwe;
	close(P);
}
$ENV{db_pass} ||= $crypt->decrypt($pwe, $ENV{db_name});

my $m = ScreenPoint::M->new();
my $C = ScreenPoint::Core->new( undef, $m, '', 'shell' );
my $A = ScreenPoint::Auctionline->new($C);

print "DB $ENV{db_name}\n";

foreach (sort keys %Options) {
	$C->log(msg=>"[ Param ] $_: $Options{$_}", service=>'cleanup_errors');
}

foreach my $pat (split /,/, $Options{match}) {
	$C->{dbh}->do("delete from log where action like '%$pat%'");
	$C->log(msg=>"Cleaned up log with pattern \"$pat\"", service=>'cleanup_errors');
	# XXX $C->{dbh}->do("delete from log where action like '%$Options{match}%'");
}

$C->log(msg=>"Cleaned up log with pattern $Options{match}", service=>'cleanup_errors');

__END__

