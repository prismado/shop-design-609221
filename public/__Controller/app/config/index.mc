<%args>
	$result
</%args>

<%init>
	# -- Controller: config
	# -- Created:    19Apr2026

	use strict;
	use warnings;
	use utf8;
	use App::MVC::Model;
	use CGI qw(-utf8);
	use JSON;
	use Carp;

	my $app  = $r->pnotes('app');
	my $cgi  = $app->{cgi};
	my $perm = $app->{auth}->{perm};
	my $C    = $app->{C};

	my $config = Config(
		file => "$C->{CONFIG}->{DOCUMENT_ROOT}/__Controller/app/config/config.json"
	);

	my %spezial_daten = (
		link      => '/signin',
		link2     => '/signin', # -- SSO Entra
		client_id => ''
	);

	%$result = (
		perm   => $perm,
		C      => $app->{C},
		cgi    => $cgi,
		view   => !$perm->{is_admin} ? 'login.html' : '',
		spez   => \%spezial_daten,
		config => $config
	);

	sub Config {
		my (%args) = @_;
		my $file = $args{file} or croak "Parameter 'file' fehlt";

		# Datei einlesen
		open my $fh, '<:encoding(UTF-8)', $file
			or croak "Kann Datei '$file' nicht öffnen: $!";

		local $/;
		my $json_text = <$fh>;
		close $fh;

		# JSON dekodieren
		my $json = JSON->new->relaxed(1);
		my $data = $json->decode($json_text);

		# Sicherstellen, dass es ein Hash ist
		croak "Ungültige JSON-Struktur" unless ref $data eq 'HASH';

		# Direkt zurückgeben (bereits gewünschte Struktur)
		return $data;
	}
</%init>
