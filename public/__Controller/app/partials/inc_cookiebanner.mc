<%args>
	$result
</%args>

<%init>
	# -- Controller: partials/inc_cookiebanner
	# -- Created: 05Apr2026

	use strict;
	use warnings;
	use utf8;
	use App::MVC::Model;
	use CGI qw(-utf8);

	my $app  = $r->pnotes('app');
	my $cgi  = $app->{cgi};
	my $perm = $app->{auth}->{perm};

	my $cookie_consent_decision = $cgi->param('decision');
	my $analytics_storage       = $cgi->param('analytics_storage' ) // 0;
	my $ad_personalization      = $cgi->param('ad_personalization') // 0;

	if ($cookie_consent_decision eq 'accept_all') {
		$analytics_storage  = 1;
		$ad_personalization = 1;
	}

	if ($cookie_consent_decision eq 'deny_all') {
		$analytics_storage  = 0;
		$ad_personalization = 0;
	}

	# XX $app->{C}->saveSessData('cookie_consent_decision',           $cookie_consent_decision);
	# XX $app->{C}->saveSessData('cookie_consent_analytics_storage',  $analytics_storage);
	# XX $app->{C}->saveSessData('cookie_consent_ad_personalization', $ad_personalization);

	%$result = (
		perm  => $perm,
		C     => $app->{C},
		cgi   => $cgi
		# spez  => \%spezial_daten # -- Spezielle Model-Daten gehen an den View
	);
</%init>
