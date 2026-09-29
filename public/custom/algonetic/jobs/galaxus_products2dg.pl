#!/usr/bin/perl -w
use strict;

use ScreenPoint::Core;
use ScreenPoint::Auctionline;
use ScreenPoint::M; # -- Pseudo Mason object
use File::Copy;
use Crypt::Lite;
use Getopt::Long;
use DBI;
use utf8; # -- 28Jan2026

use warnings;
use Net::SFTP::Foreign;
use File::Basename;

my @getopt_args = (
	'h',		# help
	'JOBID=s',	# Assigned Job-ID
	'db=s',		# MySQL Shop Database
	'remote_host=s',# Remote host
	'remote_user=s',# Remote user
	'remote_pass=s',# Remote user password
	'remote_path=s',# Remote directory
	'force' ,	# (Optional) Do a recreate
	'debug' ,	# (Optional) debug mode for development support
	'quiet=s' ,	# (Optional) Silent mode
	'x_extra=s' ,	# x_extra: 1 = NEW / 2 = REFURB
	'help' ,	#
	'v',		# Verbose mode
);

my %Options;
Getopt::Long::config("noignorecase", "bundling");
&Usage('Parameters') unless GetOptions(\%Options, @getopt_args);
&Usage('Help') if $Options{help};
$Options{JOBID} += 0;
$Options{x_extra} += 0;
$Options{debug} ||= 0;

$ENV{db_name} = $Options{db} || 'shop';
my $crypt = Crypt::Lite->new(encoding=>'hex8');
open(P, "/root/bin/data/$ENV{db_name}/pwe.txt") or print STDERR "ERR $!\n";
my $pwe = <P>; chomp $pwe;
close(P);
$ENV{db_pass} = $crypt->decrypt($pwe, $ENV{db_name});

print "mysql_enable_utf8mb4: ", $ENV{mysql_enable_utf8mb4} || 0, "\n"; # -- 09Jan2026
print "mysql_enable_utf8:    ", $ENV{mysql_enable_utf8}    || 0, "\n";

my $m = ScreenPoint::M->new();
my $C = ScreenPoint::Core->new( undef, $m, '', 'shell' );
my $A = ScreenPoint::Auctionline->new($C);

# my $env = $C->get_webenv();

if ($Options{debug}) {
	$C->log(msg=>'START', service=>'galaxus_products2dg');
	foreach (sort keys %Options) {
		my $val = /pass/ ? '********' : $Options{$_};
		$C->log(msg=>"[ Param ] - $_ = $val", service=>'galaxus_products2dg');
	}
}

# ===========================================================================================
# Create export
my $suffix  = $C->{CONFIG}->{HTTP_HOST} =~ /shopd/ ? '_test-dev' : '';
my $outfile = "upload/pricelist_v3$suffix\.csv";

my $export_result = $A->edi_export_articles(
	outfile => $outfile,
	x_extra => $Options{x_extra},
	debug   => 0
);
foreach (sort keys %{ $export_result }) {
	print "[ export_result ] - $_ = $export_result->{$_}\n";
}
# ===========================================================================================

# Konfiguriere die Verbindungsparameter
my $host     = 'ftp.digitecgalaxus.ch'; # SFTP-Serveradresse
my $user     = $Options{remote_user}; # Benutzername
my $password = $Options{remote_pass};

my $remote_dir = '/ProductData'; # Zielverzeichnis auf dem SFTP-Server
my $local_file = "/var/www/html/$outfile"; # Pfad zur lokalen Datei

print "N502041-79: Connecting to $host with remote user $user ...\n";

$SIG{ALRM} = \&alarm_handler; # -- 04Jul2025
alarm 90;

# Unterdrücke STDERR während des Verbindungsaufbaus
open(my $orig_stderr, ">&", STDERR); # Behalte eine Kopie des originalen STDERR
open(STDERR, '>', '/dev/null'); # Leite STDERR nach /dev/null um

# Initialisiere die SFTP-Verbindung
my $sftp = Net::SFTP::Foreign->new(
    host => $host,
    user => $user,
    password => $password,
    more => [-o => "StrictHostKeyChecking=no"], # Optional: deaktiviert die Überprüfung des Host-Schlüssels
);

# Wiederherstellen des ursprünglichen STDERR
open(STDERR, ">&", $orig_stderr);

# Prüfe, ob die Verbindung erfolgreich war
$sftp->error and die "Error E502040-93: Verbindung zum SFTP-Server fehlgeschlagen: " . $sftp->error;

print "N502041-99: Connection established.\n";
print "N502041-100: Going to put $local_file to $remote_dir/", basename($local_file), " ...\n";

# Lade die Datei hoch
# XXX $sftp->put($local_file, "$remote_dir/" . basename($local_file)) or die "Error E502040: Upload in \"$remote_dir\" fehlgeschlagen: " . $sftp->error;
my $ftpres = $C->ftp(host=>$host, local_file=>$local_file, password=>$Options{remote_pass}, debug=>$Options{debug} ? 1 : 0); # -- 04Feb2025
foreach (sort keys %{ $ftpres }) {
	next if $_ eq 'system';
	print "[ ftp ] - $_ = \"$ftpres->{$_}\"\n";
}

print "N502041-104: Datei erfolgreich hochgeladen.\n";

my $ts5 = $C->now(5);
copy($local_file, "$C->{CONFIG}->{DOCUMENT_ROOT}/upload/pricelist_v3_$ts5\.csv");

print "-------------------------------------------------------------------------------------------------------------------------------\n";
my $spec_file = "/var/www/html/produkte/docs/SpecificationData_ssg$suffix\.csv"; # -- Symlink
my $spec_orig = '/var/www/html/produkte/docs/specificationdata-ssg.csv';
my $f_inf     = $C->get_file_info($spec_orig);
my $age_min   = $C->age_of_timestamp_min($f_inf->{mod});
my $last_ts   = $C->txt('50424151_latest_trans', 'sys', '_core');
print "$f_inf->{file_short}: $f_inf->{mod} ($age_min min ago) gt $last_ts ? Then upload...\n";
if ($f_inf->{mod} gt $last_ts) {
	print "$f_inf->{mod} gt $last_ts / $f_inf->{file_short} needs to be uploaded...!\n";
	$C->set_property('_core', '50424151_latest_trans_sys', $C->time_now(1));
	$ftpres = $C->ftp(host=>$host, local_file=>$spec_file, password=>$Options{remote_pass}); # -- 24Apr2025
	foreach (sort keys %{ $ftpres }) {
		next if $_ eq 'system';
		print "[ ftp ] - $_ = \"$ftpres->{$_}\"\n";
	}
}

sub Usage($) {
	print "ERR Usage $_[0]\n";
}

sub alarm_handler() {
	open(STDERR, ">&", $orig_stderr); # -- Restore original STDERR
	die "Error E507042: Timeout!\n"; # -- 04Jul2025
}

__END__

Created: 28May2024
