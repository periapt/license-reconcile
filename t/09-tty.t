#!/usr/bin/perl

use Test::More tests => 2;
use Test::Deep;
use Debian::LicenseReconcile::LicenseCheck;
use Readonly;

Readonly my $LICENSECHECK => Debian::LicenseReconcile::LicenseCheck->new('t/data', [], 1);

isa_ok($LICENSECHECK, 'Debian::LicenseReconcile::LicenseCheck');

my @data = $LICENSECHECK->get_info('tty.c');
cmp_deeply(\@data, [{
    file=>'tty.c',
    license=>'BSD-3-clause',
    copyright=>['Copyright: 1992, 1993'],
}]);
