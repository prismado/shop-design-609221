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

# foreach (sort keys %Options) { $C->log(msg=>"$_ = $Options{$_}", service=>'sitemap'); }

my ($categ, $label) = $A->get_categ_nav('de');

(my $NOW = $C->now(1)) =~ s/ /T/;
    $NOW = "$NOW\+00:00";

open(OUT, ">$C->{CONFIG}->{DOCUMENT_ROOT}/zz_trash_sitemap.xml");

print OUT qq~<?xml version="1.0" encoding="UTF-8"?>
<urlset
      xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9
            http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd">

<url>
	<loc>https://www.auctionline.ch/</loc>
	<lastmod>$NOW</lastmod>
	<priority>1.00</priority>
</url>
~;

foreach (keys %{ $label }) {
	my $url_frnd  = $C->url_friendly( $label->{$_} );
	my $cat_count = $A->get_category_count(cat_id=>$_, debug=>0);
	next unless $cat_count->{count};
	# $C->log(msg=>"$label->{$_}: https://$C->{CONFIG}->{HTTP_HOST}/products/$url_frnd/$_ - ($cat_count->{count} Stk.)",
	#	service=>'sitemap');
	print OUT qq~
	<url>
		<loc>https://$C->{CONFIG}->{HTTP_HOST}/products/$url_frnd/$_</loc>
		<lastmod>$NOW</lastmod>
		<priority>1.00</priority>
	</url>
~;
}

print OUT qq~
<url>
	<loc>https://$C->{CONFIG}->{HTTP_HOST}/info_help.html</loc>
	<lastmod>$NOW</lastmod>
	<priority>0.33</priority>
</url>

<url>
	<loc>https://$C->{CONFIG}->{HTTP_HOST}/info-services.html</loc>
	<lastmod>$NOW</lastmod>
	<priority>0.33</priority>
</url>
~;

print OUT "</urlset>\n";

close(OUT);

__END__

created: 30Oct2023
