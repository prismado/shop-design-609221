#!/usr/bin/perl -w

# -- themes/shop-609221/build/start.pl

use strict;
use utf8;
use open qw(:std :encoding(UTF-8));

my $theme = $ARGV[0] || 'shop-609221';
my $comp  = $ARGV[1] || 'start';

print "$0 $theme $comp\n";

my $pwd    = `pwd`;
my $errstr = '';
my $dir    = "./$theme/public/$comp";

my $in_file  = $dir;
my $out_file = "../public/$comp";

# XXX my $in_exists  = -e $dir ?      1 : 0;
# XXX my $out_exists = -e $out_file ? 1 : 0;

print "In:  $in_file\n";
print "Out: $out_file\n";

open(IN, $in_file)      or print STDERR "Err E609231-33 $!\n";
open(OUT, ">$out_file") or print STDERR "Err E609231-32 $!\n";

print OUT qq~<%init>
	my \$foo = 3+5;
</%init>
~;

while(my $line = <IN>) {
	chomp $line;
	$line =~ s/\[%(.+)%\]/<%$1%>/g;
	print OUT "$line\n";
}

close(IN);
close(OUT);

__END__

/home/retos/shop-design-609221/themes/shop-609221/build/
/home/retos/shop-design-609221/themes/shop-609221/public/start/
