<%args>
	$result
</%args>

<%init>
	# -- Controller: app/_callback
	#    Created: 13Apr2026

	use strict;
	use warnings;
	use utf8;
	use App::MVC::Model;
	use CGI qw(-utf8);

	my %spezial_daten;

	my $app  = $r->pnotes('app');
	my $cgi  = $app->{cgi};
	my $perm = $app->{auth}->{perm};
	my $C    = $app->{C};

	my $code = $cgi->param('code');

	%spezial_daten = ();

	my $authority = $cgi->param('state') eq 's604161priv' ? 'common' : 'organizations';

	if ( $code ) {
		my $redirect_uri  = "https://$C->{CONFIG}->{HTTP_HOST}/app/_callback/";
		my $client_id     = 'cecd3e78-45b3-42dc-9388-e79c7dc0a212';
		my $client_secret = '';
		my $data          = "client_id=$client_id&client_secret=$client_secret&grant_type=authorization_code&" .
								"code=$code&scope=openid+profile&redirect_uri=$redirect_uri";

		my $res = $C->lwp_post_raw_v2(
			URL          => "https://login.microsoftonline.com/$authority/oauth2/v2.0/token",
			content_type => 'application/x-www-form-urlencoded',
			debug        => 0, # -- 0, 1, or 2
			data         => \$data
		);

		my $decoded = $C->json_decode(data=>$res)->{result};

		$spezial_daten{decoded} = $decoded;

		eval { $spezial_daten{jwt} = $C->auth_verify(id_token=>$decoded->{id_token}); };
		my $jwt = $spezial_daten{jwt}; # -- 07Jul2026

		if ( $@ ) {
			$spezial_daten{xError} = $@;
		}
		else {
			my ($uid, $uname, $email) = @{$C->query("select id, uname, email from users where email='$jwt->{login}' order by 1 limit 1")};
			if ($uid) {
				# -- Authentifizierung war erfolgreich und Nutzer bereits bekannt
				my $domain = (split /\@/, $email)[1];
				if ($domain eq 'ch-shop.ch' or $domain eq 'swisssolutiongroup.com'
					or $domain eq '' or $domain eq 'bechtle.com' or $domain eq 'eltronix.ch') {
					$C->set_user_detail($uid, 'perm_is_ssg', '1');
				}
				$C->establish_web_session(uname=>$uname);
				$C->saveSessData('signin_sso', 1);
				my $remote_addr = $ENV{HTTP_X_REAL_IP} || $ENV{HTTP_X_REMOTE_ADDR} || $ENV{REMOTE_ADDR}; # -- 08Jul2026
				$C->notify_login_event(ip => $remote_addr, uid => $uid, uname => $uname, src => 'app/_callback/index.mc');
			}
			elsif ($jwt->{rc} == 0) {
				# -- JWT akzeptiert, aber Benutzer noch nicht lokal
				my $cust_pwd  = $C->generate_password()->{password};
				my ($first, $last) = split / /, $jwt->{name};
				my $email          = $jwt->{login};
				my $SID            = $C->getSID();
				my $real_ip        = $ENV{HTTP_X_REAL_IP} || $ENV{HTTP_X_REMOTE_ADDR} || $ENV{REMOTE_ADDR};
				my $res_batch = $C->call_batch(call=>"\\\$A->register_and_send_login( email=>'$email', sid=>$SID,
						x_reg_ip=>'$real_ip', suppress_welcome_mail=>1,
						firstname=>'$first', surname=>'$last', cust_pwd=>'$cust_pwd', caller=>'sso/_callback' );");
				sleep 2;
				my $uid = $C->query("select id from users where uname='$jwt->{login}' limit 1")->[0];
				$C->set_user_detail($uid, 'reg_sso_tid',   $jwt->{tid});
				$C->set_user_detail($uid, 'reg_sso_oid',   $jwt->{oid});
				$C->set_user_detail($uid, 'reg_sso_login', $jwt->{login});
				$C->establish_web_session(uname => $jwt->{login});
				$C->saveSessData('_uid', $uid);
				$C->saveSessData('signin_sso', 1);
			}
			unless ($ENV{NODE_ENV} eq 'development') {
				$spezial_daten{redirected} = 1;
			}
		}
	}

	%$result = (
		perm  => $perm,
		C     => $app->{C},
		cgi   => $cgi,
		spez  => \%spezial_daten # -- Spezielle Model-Daten gehen an den View
	);
</%init>
