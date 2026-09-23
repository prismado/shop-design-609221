#!/usr/bin/perl -w

# -- themes/shop-609221/build/start.pl

use utf8;
use strict;

print "$0\n";

my $theme = $ARGV[0] || 'shop-609221';
my $comp  = $ARGV[1] || 'start';

my $pwd = `pwd`;

my $errstr = '';

my $dir = "./$theme/public/$comp";

opendir(D, $dir) or ($errstr = $!);

if ($errstr) {
	print STDERR "Error E609230-13 $errstr at $0 - dir: $dir - $pwd\n";
	exit(1);
}

while(my $fn = readdir(D)) {
	next if $fn =~ /^\./;
	print "[special - $comp] ...... $fn\n";
}

closedir(D);

__END__

/home/retos/shop-design-609221/themes/shop-609221/build/
/home/retos/shop-design-609221/themes/shop-609221/public/start/
