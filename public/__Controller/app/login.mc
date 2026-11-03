<%args>
	$result
</%args>

<%init>
	# -- Controller:login
	# -- Created: 13Apr2026

	use strict;
	use warnings;
	use utf8;
	use App::MVC::Model;
	use CGI qw(-utf8);

	my $app  = $r->pnotes('app');
	my $cgi  = $app->{cgi};
	my $perm = $app->{auth}->{perm};
	my $C    = $app->{C};

	my $client_id     = $app->{C}->{CONFIG}->{sso_entra_client_id};
	my $scope         = $C->uri_esc('openid profile');
	my $redirect_uri  = $C->uri_esc("https://$C->{CONFIG}->{HTTP_HOST}/app/_callback/");
	my $state         = 'asdfstate';
	my $state2        = 's604161priv';
	my $nonce         = 'asdfnone';

	my $link = "https://login.microsoftonline.com/organizations/oauth2/v2.0/authorize?client_id=$client_id&nonce=$nonce&redirect_uri=$redirect_uri&scope=$scope&state=$state&response_type=code";

	my $link2 = "https://login.microsoftonline.com/common/oauth2/v2.0/authorize?client_id=$client_id&nonce=$nonce&redirect_uri=$redirect_uri&scope=$scope&state=$state2&response_type=code";

	# XX $m->redirect($link);

	my %spezial_daten = (
		link      => $link,
		link2     => $link2,
		client_id => $client_id
	);

	%$result = (
		perm  => $perm,
		C     => $app->{C},
		cgi   => $cgi,
		spez  => \%spezial_daten # -- Spezielle Model-Daten gehen an den View
	);
</%init>
