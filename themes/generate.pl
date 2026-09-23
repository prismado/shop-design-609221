#!/usr/bin/perl -w
use strict;

my $theme = $ARGV[0] // 'shop-609221';

print "----- $theme -----\n";

my $errstr = '';

opendir(D, "$theme/public/start") or ($errstr = $!);

if ($errstr) {
	print STDERR "Error $errstr\n";
	exit(1);
}

while(my $fn = readdir(D)) {
	next if $fn =~ /^\./;
	print "$fn\n";
}

closedir(D);
