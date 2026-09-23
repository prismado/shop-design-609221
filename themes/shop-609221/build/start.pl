#!/usr/bin/perl -w
use strict;

my $errstr = '';

opendir(D, '../public/start') or ($errstr = $!);

if ($errstr) {
	print STDERR "Error $errstr\n";
	exit(1);
}

while(my $fn = readdir(D)) {
	print "$fn\n";
}

closedir(D);
