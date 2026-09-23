#!/usr/bin/perl -w

# -- themes/shop-609221/build/start.pl

use strict;
use utf8;
use open qw(:std :encoding(UTF-8));

my $theme = $ARGV[0] || 'shop-609221';
my $comp  = $ARGV[1] || 'start';
my $type  = $ARGV[2]; # -- sub / main

print "$0 $theme $comp (type: $type)\n";

my $in_file  = "./$theme/public/$comp";
my $out_file = "../public/$comp";

print "- In:  $in_file\n";
print "- Out: $out_file\n";

open(IN, $in_file)      or print STDERR "Err E609231-33 $!\n";
open(OUT, ">$out_file") or print STDERR "Err E609231-32 $! ($out_file)\n";

if ($in_file =~ /partials\/product\.html$/) {
	local $/ = undef;
	open(CODE, "./$theme/build/partials/product.mc") or print STDERR "*** Error $!\n";
	my $code = <CODE>;
	close(CODE);

	print OUT "$code\n";
	print OUT qq~<%init>
	my \%args = \$m->caller_args(0);

	my \$C = \$args{C};
	my \$v = \$args{v};
	my \$count = \$args{count};

	my \$title = \$C->{CONFIG}->{site_title};
</%init>
~ if 1==2;
}
elsif ($type eq 'main') {
	print OUT qq~<%init>
	use ScreenPoint::Core;
	my \$C = ScreenPoint::Core->new(\$r, \$m);

	my \@prod_titles = ('UltraBook Pro 14&Prime;', 'Foo Bar');
	my \@products = ();
	for my \$i (0 .. 11) {
		push \@products, {
			title => \$prod_titles[\$i],
			price => 9 + int(rand(492))
		};
	}

	my %v = (
		daily_609231 => 'Tagesangebote am Mittwoch',
		products     => \\\@products
	);

	my \$title = \$C->{CONFIG}->{site_title};
</%init>
~;
}
else {
	print OUT qq~<%init>
	my \%args = \$m->caller_args(0);

	my \$C = \$args{C};
	my \$v = \$args{v};

	my \$title = \$C->{CONFIG}->{site_title};
</%init>
~;
}

while(my $line = <IN>) {
	chomp $line;
	$line =~ s/\[%(.+)%\]/<%$1%>/g;
	$line =~ s/<& product\.html &>/<& product\.html, count => \$i, v => \$v, C => \$C &>/;
	$line =~ s/<& partials\/(.+)\.html &>/<& partials\/$1\.html, v => \\%v, C => \$C &>/;
	$line =~ s/<& (.+)\.html &>/<& $1\.html, v => \$v, C => \$C &>/;
	print OUT "$line\n";
}

close(IN);
close(OUT);
