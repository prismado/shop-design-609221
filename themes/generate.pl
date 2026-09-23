#!/usr/bin/perl -w
use strict;

my $theme = $ARGV[0] // 'shop-609221';

print "----- $theme -----\n\n";

&component('start');
&component('product_full');

sub component ($) {
	print "Component $_[0] ...\n";

	my $errstr = '';

	opendir(D, "$theme/public/$_[0]") or ($errstr = $!);

	if ($errstr) {
		print STDERR "Error $errstr ($_[0])\n";
		exit(1);
	}

	while(my $fn = readdir(D)) {
		next if $fn =~ /^\./;
		print "- $fn\n";
	}

	closedir(D);
	print "\n";
}
