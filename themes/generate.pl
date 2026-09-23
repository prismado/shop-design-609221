#!/usr/bin/perl -w

use utf8;
use strict;
use open qw(:std :encoding(UTF-8));

my $theme = $ARGV[0] // 'shop-609221';

print "===== 🚀 $theme =====\n\n";

&component('index');
&component('index/partials');
&component('product_full');
# XXX &component('partials');

sub component ($) {
	my $component = $_[0];

	print "----- 💡 Component: \"$component\" ... -----\n";

	my $errstr = '';

	opendir(D, "$theme/public/$component") or ($errstr = $!);

	if ($errstr) {
		print STDERR "Error $errstr ($component)\n";
		exit(1);
	}

	print "----- Files of $component -----\n";
	while(my $fn = readdir(D)) {
		next if $fn =~ /^\./;
		print "- $fn\n";
	}

	closedir(D);
	print "\n";

	my $cmd = "./$theme/build/start.pl $theme $component";
	system($cmd) && print STDERR "Err E609230 $! $cmd\n";
	print "\n";
}
