#!/usr/bin/perl -w

use utf8;
use strict;

my $theme = $ARGV[0] // 'shop-609221';

print "----- 🚀 $theme -----\n\n";

&component('start');
&component('product_full');

sub component ($) {
	my $component = $_[0];

	print "Component: \"$component\" ...\n";

	my $errstr = '';

	opendir(D, "$theme/public/$component") or ($errstr = $!);

	if ($errstr) {
		print STDERR "Error $errstr ($component)\n";
		exit(1);
	}

	print "----- Files -----\n";
	while(my $fn = readdir(D)) {
		next if $fn =~ /^\./;
		print "- $fn\n";
	}

	closedir(D);
	print "\n";
}
