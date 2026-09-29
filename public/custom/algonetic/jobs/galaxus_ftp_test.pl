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
	'remote_dir=s',
	# XXX 'remote_user=s',# Remote user
	'local_file=s',
	'remote_path=s',# Remote directory
	'debug' ,	# (Optional) debug mode for development support
	'v',		# Verbose mode
);

my %Options;
Getopt::Long::config("noignorecase", "bundling");
&Usage('Parameters') unless GetOptions(\%Options, @getopt_args);
foreach (sort keys %Options) { print "[ Option ] - $_ = $Options{$_}\n"; }

$Options{password}   ||= 'cOc0EdU8acipH8yot5lG';
$Options{local_file} ||= '/var/www/html/upload/pricelist_v3_test-dev.csv';
$Options{remote_dir} ||= '/ProductData';
$Options{JOBID} += 0;
$Options{debug} ||= 0;

$ENV{db_name} = $Options{db} || 'shop';
my $crypt = Crypt::Lite->new(encoding=>'hex8');
open(P, "/root/bin/data/$ENV{db_name}/pwe.txt") or print STDERR "ERR $!\n";
my $pwe = <P>; chomp $pwe;
close(P);
$ENV{db_pass} = $crypt->decrypt($pwe, $ENV{db_name});

my $m = ScreenPoint::M->new();
my $C = ScreenPoint::Core->new( undef, $m, '', 'shell' );
my $A = ScreenPoint::Auctionline->new($C);

print $C->time_now(4), "\n";

my $res = $C->sftp(
	password   => $Options{password},
	remote_dir => $Options{remote_dir},
	local_file => $Options{local_file}
);

foreach (sort keys %{ $res }) {
	print "[ res ] - $_ = $res->{$_}\n";
}

sub Usage() { print "Error\n;" }

__END__

Created: 06Jul2025

/var/www/html/custom/algonetic/jobs/_galaxus_ftp_test.pl --local_file /tmp/zz_trash_foo/batchfile.txt --remote_dir /OrderData/Live/partner2dg
