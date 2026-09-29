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
	'prefix=s',	# File prefix to check for deletion
	'age=s',	# Age in days
	'dir=s',	# Directory to scan
	'quiet=s',
	'db=s',		# MySQL Shop Database
	'debug' ,	# debug mode for development support
	'help' ,	#
	'v',		# Verbose mode
);

my %Options;
Getopt::Long::config("noignorecase", "bundling");
&Usage('') unless GetOptions(\%Options, @getopt_args);
&Usage('Help') if $Options{help};

$ENV{db_name} = $Options{db} || 'zzshopd';
my $crypt = Crypt::Lite->new(encoding=>'hex8');
open(P, "/root/bin/data/$ENV{db_name}/pwe.txt") or print STDERR "ERR $!\n";
my $pwe = <P>; chomp $pwe;
close(P);
$ENV{db_pass} = $crypt->decrypt($pwe, $ENV{db_name});

my $m = ScreenPoint::M->new();
my $C = ScreenPoint::Core->new( undef, $m, '', 'shell' );
my $A = ScreenPoint::Auctionline->new($C);
my $dbh = $C->{dbh};
my $THEME = $C->{CONFIG}->{theme};
my $PATH = "$C->{CONFIG}->{DOCUMENT_ROOT}/custom/$THEME/jobs";
$Options{prefix} ||= 'RA-';
$Options{age} += 0;
$Options{age}    ||= 333;
my $dir = $Options{dir} || 'tmp';

if ($dir =~ /^\./) {
	print $C->now(2), "  ERROR: $dir\n";
	$dir = 'tmp';
}

my $dir_final = "$C->{CONFIG}->{DOCUMENT_ROOT}/$dir";

if ($dir =~ /^\/tmp\//) {
	$dir_final = $dir;
}

$C->log(msg=>"Cleanup Job-ID $Options{JOBID}", importance=>2, service=>'cleanup') unless $Options{quiet};

my $cmd = "cd $dir_final; /usr/local/bin/cleanup.pl $Options{age} $Options{prefix}";

print $C->now(2), "  $cmd\n";

system($cmd);

__END__

/usr/local/bin/cleanup.pl
