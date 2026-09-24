<%init>
	use ScreenPoint::Core;
	my $C = ScreenPoint::Core->new($r, $m);

	my @prod_titles = ('UltraBook Pro 14&Prime;', 'Foo Bar');
	my @products = ();
	for my $i (0 .. 11) {
		push @products, {
			title => $prod_titles[$i],
			price => 9 + int(rand(492))
		};
	}

	my %v = (
		daily_609231 => 'Tagesangebote am Donnerstag',
		products     => \@products
	);

	my $title = $C->{CONFIG}->{site_title};
</%init>
