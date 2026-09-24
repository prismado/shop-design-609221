<%init>
	use ScreenPoint::Core;

	my $C = ScreenPoint::Core->new($r, $m);

	my $prodcat = {
		0 => { title => 'UltraBook Pro 14&Prime;',  price => 799 },
		1 => { title => 'HP EliteBook x360 830 G7', price => 650 }
	};

	my @products = ();

	for my $i (0 .. 11) {
		push @products, {
			title => $prodcat->{$i}->{title},
			price => $prodcat->{$i}->{price}
		};
	}

	my %v = (
		daily_609231 => 'Tagesangebote am Donnerstag',
		products     => \@products
	);

	my $title = $C->{CONFIG}->{site_title};
</%init>
