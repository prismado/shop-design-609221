#!/usr/bin/perl -w
$| = 1;
use strict;

use ScreenPoint::Core;
use ScreenPoint::Auctionline;
use ScreenPoint::M; # -- Pseudo Mason object
use Getopt::Long;
use DBI;

my @getopt_args = (
	'h',            # help
	'db=s',         # MySQL Shop Database
	'call=s' ,      # tbd
	'debug=s' ,     # debug mode for development support
	'help' ,        #
	'v',            # Verbose mode
);

my %Options;
Getopt::Long::config("noignorecase", "bundling");
&Usage('') unless GetOptions(\%Options, @getopt_args);
&Usage('Help') if $Options{help};

$ENV{db_name} = $Options{db} || 'zzshopd';

my $m = ScreenPoint::M->new();
my $C = ScreenPoint::Core->new( undef, $m, '', 'shell' );
my $A = ScreenPoint::Auctionline->new($C);

# print $C->now(2), "  [run] $Options{call}\n";

eval ( 'use HTML::Mason::Interp;' );
eval ( $Options{call} );

if ($@) {
	print STDERR "Error $@\n";
}

__END__

Algo-23

__METACLONING__
