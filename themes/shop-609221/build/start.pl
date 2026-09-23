#!/usr/bin/perl -w

# -- themes/shop-609221/build/start.pl

use strict;
use utf8;
use open qw(:std :encoding(UTF-8));

my $theme = $ARGV[0] || 'shop-609221';
my $comp  = $ARGV[1] || 'start';

print "$0 $theme $comp\n";

my $in_file  = "./$theme/public/$comp";
my $out_file = "../public/$comp";

print "- In:  $in_file\n";
print "- Out: $out_file\n";

open(IN, $in_file)      or print STDERR "Err E609231-33 $!\n";
open(OUT, ">$out_file") or print STDERR "Err E609231-32 $!\n";

print OUT qq~<%init>
	use ScreenPoint::Core;
	my \$C = ScreenPoint::Core->new(\$r, \$m);

	my \$title = \$C->{CONFIG}->{site_title};
</%init>
~;

while(my $line = <IN>) {
	chomp $line;
	$line =~ s/\[%(.+)%\]/<%$1%>/g;
	print OUT "$line\n";
}

close(IN);
close(OUT);
