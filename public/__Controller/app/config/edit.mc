<%args>
	$result
</%args>

<%init>
	# -- Controller: edit 
	# -- Created:    19Apr2026

	use strict;
	use warnings;
	use utf8;
	use App::MVC::Model;
	use CGI qw(-utf8);
	use JSON;
	use Carp;
	use ScreenPoint::Prism;

	my $app  = $r->pnotes('app');
	my $cgi  = $app->{cgi};
	my $perm = $app->{auth}->{perm};
	my $C    = $app->{C};

	my $p = ScreenPoint::Prism->new(dbh => $C->{dbh});

	my $msg = '';

	if ($cgi->param('bUpdate')) {

		my $res = $p->set_config_key(
			area  => $cgi->param('area'),
			key   => $cgi->param('key'),
			value => $cgi->param('value'),
			C     => $C
		);

		$msg = $res->{msg};
	}

	my $config = $p->get_config_key(
		area     => $cgi->param('area'),
		key      => $cgi->param('key'),
		C        => $C
	);

	%$result = (
		perm   => $perm,
		C      => $app->{C},
		cgi    => $cgi,
		view   => !$perm->{is_admin} ? 'login.html' : '',
		msg    => $msg,
		config => $config
	);
</%init>
