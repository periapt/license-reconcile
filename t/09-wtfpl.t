#!/usr/bin/perl

use Test::More tests => 2;
use Test::Deep;
use Debian::LicenseReconcile::LicenseCheck;
use Readonly;

Readonly my $LICENSECHECK => Debian::LicenseReconcile::LicenseCheck->new('t/data', [], 1);

isa_ok($LICENSECHECK, 'Debian::LicenseReconcile::LicenseCheck');

my @data = $LICENSECHECK->get_info('wtfpl');
cmp_deeply(\@data, [{
    file=>'wtfpl',
    license=>'WTFPL',
    copyright=>['Copyright: 2004 Sam Hocevar <sam@hocevar.net>'],
}]);


