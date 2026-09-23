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
	if (-d "$theme/public/$fn") {
		print "$fn is a dir!!\n";
		&sub_dir("$theme/public/$fn");
		next;
	}
	my $cmd = "./$theme/build/start.pl $theme $fn main";
	print "- $cmd\n";
	system($cmd) && print STDERR "Err E609231-26 $! $cmd\n";
}
closedir(D);

# XX &component('public');
sub component ($) {
	my $component = $_[0];
	print "----- 💡 Component: \"$component\" ... -----\n";
}

sub sub_dir($) {
	my @elems     = split /\//, $_[0];
	my $last_elem = $elems[$#elems];

	print "[sub_dir] - $_[0] ... $last_elem ...\n";

	my $errstr = '';
	opendir(DIR, $_[0]) or ($errstr = $!);
	if ($errstr) {
		print STDERR "Err $errstr ($_[0])\n";
	}
	while(my $fn = readdir(DIR)) {
		next if $fn =~ /^\./;
		print "[sub_dir] - fn: $fn\n";
		next if -d "$_[0]/$fn";
		my $cmd = "./$theme/build/start.pl $theme \"$last_elem/$fn\" sub";
		print "[sub_dir] - $cmd\n";
		system($cmd) && print STDERR "Err E609231-77 $! $cmd\n";
	}
	closedir(DIR);
}
