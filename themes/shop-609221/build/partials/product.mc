	my %args = $m->caller_args(0);

	my $C     = $args{C};
	my $A     = $args{A};
	my $v     = $args{v};
	my $count = $args{count};

	my $title = $C->{CONFIG}->{site_title};

	my $prod = $A->get_product($count + 1);
