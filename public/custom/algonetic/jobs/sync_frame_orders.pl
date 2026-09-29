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
	'remote_user=s',# Remote user
	'remote_path=s',# Remote directory
	'force' ,	# (Optional) Do a recreate
	'debug' ,	# (Optional) debug mode for development support
	'quiet=s' ,	# (Optional) Silent mode
	'help' ,	#
	'v',		# Verbose mode
);

################################################################################
# -- Infos: https://docs.ch2.be/w/auctionline2019-tech/import
################################################################################

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

print $C->now(2), "  [sync_frame_orders] Start. DB: $ENV{db_name}\n";
unless ($Options{quiet}) {
	$C->log(msg=>'Start. <b>You could suppress verbose messages with --quiet 1</b>', service=>'sync_frame_orders');
}
if ($Options{force}) {
	$C->del_workval("job_id_$Options{JOBID}_latest_ra");
}

my $import_dir  = "$C->{CONFIG}->{DOCUMENT_ROOT}/_systex/data/import/datacopy";
my $remote_path = $Options{remote_path} || '/tmp/datacopy';
   $remote_path =~ tr/;//d;

my $cmd = qq~cd $import_dir; rsync -t $Options{remote_user}\@gurke.ch2.be:$remote_path/RA-*.xml .~;
print $C->now(2), "  $cmd\n";
system("$cmd >/tmp/z_job_$Options{JOBID}_rsync.log 2>/tmp/z_job_$Options{JOBID}_rsync.err"); # && print STDERR "ERROR $!\n";
my $errdata = $C->slurp_file("/tmp/z_job_$Options{JOBID}_rsync.err");
unlink "/tmp/z_job_$Options{JOBID}_rsync.err";

if (${$errdata}) {
	print $C->now(2), "  ERROR: ${$errdata}\n";
	$C->log(msg=>"NOTE: ${$errdata}", importance=>2, service=>'sync_frame_orders');
	sleep 25;
	print $C->now(2), "  $cmd\n";
	system("$cmd >/tmp/z_job_$Options{JOBID}_rsync.log 2>/tmp/z_job_$Options{JOBID}_rsync.err") && print STDERR "ERROR 2 $!\n";
	my $errdata = $C->slurp_file("/tmp/z_job_$Options{JOBID}_rsync.err");
	unlink "/tmp/z_job_$Options{JOBID}_rsync.err";

	if (${$errdata}) {
		print STDERR "ERROR: ${$errdata}\n";
		$C->log(msg=>"ERROR: ${$errdata}", importance=>1, service=>'sync_frame_orders');
	}
}

my $result = $A->auctionl_get_navision_orders_init(generous=>1, already_utf=>0);
my $orders = $A->{_auctionl_nav_orders_arr};
my ($latest_ra, $latest_ra_count) = split /\t/, @{$orders}[$#{$orders}];
my $latest_ra_memo = $C->get_workval("job_id_$Options{JOBID}_latest_ra") || 0;
print $C->now(2), "  Latest RA: $latest_ra vs $latest_ra_memo ($latest_ra_count items)\n";
$C->log(msg=>"Latest RA: $latest_ra ($latest_ra_count items)", service=>'sync_frame_orders') unless $Options{quiet};
$C->set_workval("job_id_$Options{JOBID}_latest_ra", $latest_ra);

my $latest_file = @{$result->{files}}[0];
print $C->now(2), "  Latest file: \"$latest_file\" (RA $latest_ra)\n";

unless ($latest_ra == $latest_ra_memo) {
    if ($latest_ra > 1000) {
	print $C->now(2), "  Neuer Rahmenauftrag RA $latest_ra ($latest_file) ...\n";

	if ($latest_file =~ /^RA\-$latest_ra/) {
		my $resp = $C->file2utf(
			file => "$import_dir/$latest_file",
			out  => "$import_dir/RA-$latest_ra\-utf.xml"
		); 
		foreach (keys %{$resp}) {
			print $C->now(2), "  [file2utf] $_ = $resp->{$_}\n";
		}
	}

	print $C->now(2), "  $import_dir/RA-$latest_ra\-utf.xml created\n";

	$C->log(msg=>"N310240-108: Neuer Rahmenauftrag importiert: RA $latest_ra", importance=>2, service=>'sync_frame_orders');
    }
}

# ====================================================================================
sub Usage($) {
	print STDERR "Wrong usage. $_[0]\n";
	exit(1);
}

__END__
