<%args>
	$result
</%args>

<%init>
	# -- Controller: load-cookie-banner

	use strict;
	use warnings;
	use utf8;
	use App::MVC::Model;

	my %spezial_daten;

	my $model = App::MVC::Model->new( $r, $m );

	my $app  = $r->pnotes('app');
	my $perm = $app->{auth}->{perm};

	my $decisions = $app->{C}->get_cookie_consent(
		perm => $perm
	);

	%$result = (
		perm    => $perm,
		C       => $app->{C},
		consent => $decisions
	);

	$r->content_type('application/javascript; charset=utf-8');
</%init>
