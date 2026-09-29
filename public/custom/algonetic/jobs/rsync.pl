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
	'src=s',	# directory
	'dest=s',	# directory
	'debug' ,	# (Optional) debug mode for development support
	'quiet=s' ,	# (Optional) Silent mode
	'help' ,	#
	'v',		# Verbose mode
);

################################################################################
# -- Infos: https://docs.ch2.be/w/auctionline2019-tech/import
################################################################################

my $VERSION = 0.8003;

my %Options;
Getopt::Long::config("noignorecase", "bundling");
&Usage('Parameters') unless GetOptions(\%Options, @getopt_args);
&Usage('Help') if $Options{help};
$Options{JOBID} += 0;

$ENV{db_name} ||= $Options{db};
my $crypt = Crypt::Lite->new(encoding=>'hex8');
open(P, "/root/bin/data/$ENV{db_name}/pwe.txt") or print STDERR "ERR $!\n";
my $pwe = <P>; chomp $pwe;
close(P);
$ENV{db_pass} ||= $crypt->decrypt($pwe, $ENV{db_name});

my $m = ScreenPoint::M->new();
my $C = ScreenPoint::Core->new( undef, $m, '', 'shell' );
my $A = ScreenPoint::Auctionline->new($C);
my $dbh = $C->{dbh};
my $THEME = $C->{CONFIG}->{theme};
my $PATH = "$C->{CONFIG}->{DOCUMENT_ROOT}/custom/$THEME/jobs";

print $C->now(2), "  [sync_db] Start. DB: $ENV{db_name}\n";

my $now_yyyymmdd = substr($C->now(5), 0, 8);

$Options{src} =~ s/\{\{YYYYMMDD\}\}/$now_yyyymmdd/;

my $cmd = qq~rsync -tog $Options{src} $Options{dest}~;

system("$cmd >/tmp/z_job_$Options{JOBID}.log 2>/tmp/z_job_$Options{JOBID}.err");
my $errdata = $C->slurp_file("/tmp/z_job_$Options{JOBID}.err");
unlink "/tmp/z_job_$Options{JOBID}.err";

if (${$errdata}) {
	print $C->now(2), "  ERROR: ${$errdata}\n";
	$C->log(msg=>"ERROR: ${$errdata}", importance=>1, service=>'sync_db');
}

# $C->log(msg=>$cmd, importance=>1, service=>'sync_db');

unless ($Options{quiet}) {
	$C->log(msg=>"Start V$VERSION\. <b>You could suppress verbose messages with --quiet 1</b>", service=>'sync_db');
	$C->log(msg=>$now_yyyymmdd, service=>'sync_db');
	$C->log(msg=>$cmd, service=>'sync_db');
	foreach (sort keys %Options) {
		$C->log(msg=>"[ Para ] -- $_ = $Options{$_}", service=>'sync_db');
	}
}

# ====================================================================================
sub Usage($) {
	print STDERR "Wrong usage. $_[0]\n";
	exit(1);
}

__END__

Created: 07Aug2023
