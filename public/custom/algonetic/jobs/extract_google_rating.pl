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
	'debug' ,	# (Optional) debug mode for development support
	'wait=s' ,	# (Optional) Wait for minutes
	'quiet=s' ,	# (Optional) Silent mode
	'help' ,	#
	'v',		# Verbose mode
);

my %Options;
Getopt::Long::config("noignorecase", "bundling");
&Usage('Parameters') unless GetOptions(\%Options, @getopt_args);
&Usage('Help') if $Options{help};
$Options{JOBID} += 0;
$Options{wait} += 0; $Options{wait} ||= 10;

$ENV{db_name} = $Options{db} || 'shop';
my $crypt = Crypt::Lite->new(encoding=>'hex8');
open(P, "/root/bin/data/$ENV{db_name}/pwe.txt") or print STDERR "ERR $!\n";
my $pwe = <P>; chomp $pwe;
close(P);
$ENV{db_pass} = $crypt->decrypt($pwe, $ENV{db_name});

my $m = ScreenPoint::M->new();
my $C = ScreenPoint::Core->new( undef, $m, '', 'shell' );
my $A = ScreenPoint::Auctionline->new($C);

my $cur_rating  = $C->get_property('506241_g_rating', '_core', 'sys');
my $rating_time = $C->get_property('506241_g_rating_time', '_core', 'sys');
my $age_min     = $C->age_of_timestamp_min($rating_time);
   $age_min     = 9999 if $rating_time =~ /^\* .+/;

print $C->now(2), " Current Rating: $cur_rating ($rating_time, $age_min min ago)\n";

if ($age_min < $Options{wait}) {
	print $C->now(2), " Too early after $age_min min. Wating time is $Options{wait} minutes. Exiting\n";
	exit(0);
}

print $C->now(2), " Going to fetch ...\n";
my $page_content = $C->lwp_get_raw(URL=>'https://www.google.com/storepages?q=auctionline.ch&c=CH&so=NEWEST&hl=de', content_type=>'text/html');
print $C->now(2), " Done.\n";

my $score = 0;

foreach my $line (split /[\n\r]/, ${ $page_content }) {
	if ($line =~ m{<span\s+aria-label="Die Gesamtbewertung für diesen Händler ist ([\d,.]+) von 5[^"]*">([\d,.]+)</span>}i) {
		$score = $2;
	}
}

(my $score_check = $score) =~ s/,/\./;
    $score_check += 0;

if ($score_check < 3 or $score_check > 5) {
	$C->log(msg=>"Error E506241: Possible scraping error ($score_check)", importance=>1, service=>'extract_google_rating');
}
else {
	$C->set_property('_core', '506241_g_rating_sys', "$score");
	$C->set_property('_core', '506241_g_rating_time_sys', $C->time_now(1));
	$C->log(msg=>"Google Rating updated ($score_check). Going to wait for at least $Options{wait} min", service=>'extract_google_rating');
}

print "Current Score: $score / $score_check\n";

__END__

Created: 24Jun2025

Manage:
/adx/manage-property.html?area=506241

wget -q 'https://www.google.com/storepages?q=auctionline.ch&c=CH&so=NEWEST&hl=de' -O google_rating.html
