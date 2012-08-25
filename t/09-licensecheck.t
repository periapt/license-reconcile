#!/usr/bin/perl

use Test::More tests => 3;
use Test::Deep;
use Debian::LicenseReconcile::Filter::Std;

my $filter = Debian::LicenseReconcile::Filter::Std->new(
    directory=>'t/data/example',
);
isa_ok($filter, 'Debian::LicenseReconcile::Filter');
isa_ok($filter, 'Debian::LicenseReconcile::Filter::Std');

my @data = $filter->get_info;
cmp_deeply(\@data, []);
