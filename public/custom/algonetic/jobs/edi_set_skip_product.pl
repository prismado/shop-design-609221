#!/usr/bin/perl -w
use strict;

use ScreenPoint::Core;
use ScreenPoint::M; # -- Pseudo Mason object
use Crypt::Lite;
use Getopt::Long;
use DBI;

my @getopt_args = (
	'JOBID=s',
	'db=s',		# -- Database
	'quiet=s'
);

my %Options;
Getopt::Long::config("noignorecase", "bundling");
&Usage('Parameters') unless GetOptions(\%Options, @getopt_args);
&Usage('Help') if $Options{help};

$ENV{db_name} = $Options{db} || 'shop';
my $crypt     = Crypt::Lite->new(encoding=>'hex8');
open(P, "/root/bin/data/$ENV{db_name}/pwe.txt") or print STDERR "ERR $!\n"; my $pwe = <P>; chomp $pwe; close(P);
$ENV{db_pass} = $crypt->decrypt($pwe, $ENV{db_name});

my $m = ScreenPoint::M->new();
my $C = ScreenPoint::Core->new( undef, $m, '', 'shell' );

my $sth = $C->{dbh}->prepare(q~
	SELECT  DISTINCT p.id
	FROM	products p, products_feat f
	WHERE	p.id=product_id AND `count` < 1
		AND featkey='EDI_SKIP' AND f.description='0'
~);
$sth->execute();

$C->log(msg=>'N509072-37: ' . $sth->rows . ' rows to update', service=>'edi_set_skip_product') unless $Options{quiet};

while(my $r = $sth->fetch()) {
	$C->log(msg=>"N509072-40: Set EDI_SKIP to 1 at Prod-ID $r->[0]", service=>'edi_set_skip_product');
}

$C->{dbh}->do(q~
	UPDATE	products_feat

	SET	`description` = '1'

	WHERE	product_id IN (
			SELECT	p.id
			FROM	products p, products_feat f
			WHERE	p.id=product_id AND `count`<1
				AND featkey='EDI_SKIP' AND f.description='0'
		)
		AND featkey='EDI_SKIP' AND featname='_exclude'
~);

sub Usage($) {
	print STDERR "Error $_[0]\n";
	exit(1);
}

__END__

Created: 07Sep2025

Manage:
https://shopd.algonetic.ch/adx/show.html?macro=prism_sys_jobs&q=set+edi\_skip
