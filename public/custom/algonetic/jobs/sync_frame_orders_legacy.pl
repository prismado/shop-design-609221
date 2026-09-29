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
	'db=s',		# MySQL Shop Database
	'JOBID=s',	# Assigned Job-ID
	'remote_user=s',# Remote user
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

$C->log(msg=>"Datacopy-Dateien von 94.230.210.85 holen...", importance=>2, service=>'sync_frame_orders_legacy');

my $cmd = qq~cd $C->{CONFIG}->{DOCUMENT_ROOT}/_systex/data/import/datacopy; rsync -t $Options{remote_user}\@94.230.210.85:/tmp/datacopy/RA-2*-utf.xml . >/dev/null 2>&1~;
print $C->now(2), "  $cmd\n";
system($cmd);

$C->log(msg=>"Datacopy-Dateien von 94.230.210.85 geholt nach _systex/data/import/datacopy. Job-ID $Options{JOBID} beendet", importance=>2, service=>'sync_frame_orders_legacy');

__END__

*/44 06-22 * * * cd /var/www/html/_vhosts/extern/www19d.auctionline.ch/_systex/data/import/datacopy; rsync -t reto@94.230.210.85:/tmp/datacopy/RA-2*-utf.xml . >/dev/null 2>&1

cd /var/www/shop/_systex/data/import/datacopy; rsync -t temp19jun28@94.230.210.85:/tmp/datacopy/RA-2*-utf.xml . >/tmp/ra_copy.log 2>/tmp/ra_copy.err
