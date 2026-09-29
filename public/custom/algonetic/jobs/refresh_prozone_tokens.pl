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
	'quiet=s' ,	# (Optional) Silent mode
	'help' ,	#
	'v',		# Verbose mode
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

my $sth = $C->{dbh}->prepare(q~
	SELECT  split_str(substr(featkey, 16, 15), '_', 1)+0 as camp_id, featname
	FROM    config_prod_feat
	WHERE   featkey LIKE 'prozone_507141_%_tok'
~);
   $sth->execute();

while(my $r = $sth->fetch()) {
	my ($camp_id, $tok_pattern) = @{$r};
	my $cur_token = $C->query("select token from campaign_data where id=$camp_id")->[0];
	my $interval  = $C->get_safe_property("prozone_507141_$camp_id\_iv", 'sys') + 0;

	my @allowed_chars = grep { $_ ne '0' && $_ ne '1' && $_ ne 'D' && $_ ne 'I' && $_ ne 'J' && $_ ne 'O' && $_ ne 'W' } ('A'..'Z', '2'..'9');
	my $string = '';
	for (1..6) { $string .= $allowed_chars[int(rand(@allowed_chars))]; }

	(my $tok_new = $tok_pattern) =~ s/\{\{RANDOM\}\}/$string/;

	$C->{dbh}->do(qq~update campaign_data set token='$tok_new' where id=$camp_id~);

	$C->log(msg=>"N507142: Camp-ID $camp_id: $tok_pattern - $cur_token - $interval h, new: $tok_new", service=>'refresh_prozone_tokens');
}

__END__

Created: 14Jul2025

https://www.auctionline.ch/adx/show.html?macro=prism_sys_jobs&q=prozone
