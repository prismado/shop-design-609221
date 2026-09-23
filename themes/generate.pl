#!/usr/bin/perl -w

use utf8;
use strict;
use open qw(:std :encoding(UTF-8));

my $theme = $ARGV[0] // 'shop-609221';

print "===== 🚀 $theme =====\n\n";

my $errstr = '';
opendir(D, "$theme/public") or ($errstr = $!);
if ($errstr) {
	print STDERR "Error E609232-13 $errstr\n";
	exit(1);
}
while(my $fn = readdir(D)) {
	next if $fn =~ /^\./;
	my $cmd = "./$theme/build/start.pl $theme $fn";
	print "- ..........$cmd\n";
}
closedir(D);

&component('public');
# XX &component('index');
# XX &component('index/partials');
# XX &component('product_full');

sub component ($) {
	my $component = $_[0];

	print "----- 💡 Component: \"$component\" ... -----\n";

	my $errstr = '';

	opendir(D, "$theme/$component") or ($errstr = $!);

	if ($errstr) {
		print STDERR "Error E609231-25 $errstr ($component)\n";
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
	print "XX $cmd\n";
	system($cmd) && print STDERR "Err E609230 $! $cmd\n";
	print "\n";
}
