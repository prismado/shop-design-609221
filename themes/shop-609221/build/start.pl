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

my $exists = -e $dir ? 1 : 0;

print "XX $dir ($exists)\n";

exit(0); # XX

opendir(D, $dir) or ($errstr = $!);

if ($errstr) {
	print STDERR "Error E609230-13 $errstr at $0 - dir: $dir - $pwd\n";
	exit(1);
}

while(my $fn = readdir(D)) {
	next if $fn =~ /^\./;

	if (-d "$dir/$fn") {
		print "- Skipping $fn (directory)\n";
		next;
	}

	my $out_file = "$theme/$fn/tbd";

	print "- IN:  $dir/$fn\n";
	print "- OUT: $out_file ...\n";

	# open(IN, "$dir/$fn") or print STDERR "Err E609231-33 $!\n";
	# open(OUT, ">$out_file") or print STDERR "Err E609231-32 $!\n";

	# print OUT qq~<%init>my \$foo = 3+5; </%init> ~;

	# close(IN);
	# close(OUT);
}

closedir(D);

__END__

/home/retos/shop-design-609221/themes/shop-609221/build/
/home/retos/shop-design-609221/themes/shop-609221/public/start/
