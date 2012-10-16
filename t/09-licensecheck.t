#!/usr/bin/perl

use Test::More tests => 6;
use Test::Deep;
use Debian::LicenseReconcile::Filter::Std;
use Debian::LicenseReconcile::LicenseCheck;
use Readonly;

Readonly my $LICENSECHECK => Debian::LicenseReconcile::LicenseCheck->new('t/data/example', [], 1);

my $filter = Debian::LicenseReconcile::Filter::Std->new(
    licensecheck=>$LICENSECHECK,
    name=>'Std2',
);
isa_ok($filter, 'Debian::LicenseReconcile::Filter');
isa_ok($filter, 'Debian::LicenseReconcile::Filter::Std');

my @data = $filter->get_info;
cmp_deeply(\@data, [{
    file=>'base.h',
    license=>'GPL-2',
    test=>'Std2',
    copyright=>'[Copyright: 2011, Periapt Technologies. All rights reserved]',
}]);

Readonly my $LICENSECHECK2 => Debian::LicenseReconcile::LicenseCheck->new('t/data/example', [], 0);

my $filter2 = Debian::LicenseReconcile::Filter::Std->new(
    licensecheck=>$LICENSECHECK2,
    name=>'Std2',
);
isa_ok($filter2, 'Debian::LicenseReconcile::Filter');
isa_ok($filter2, 'Debian::LicenseReconcile::Filter::Std');

@data = $filter2->get_info;
cmp_deeply(\@data, [{
    file=>'base.h',
    license=>'GPL-2',
    test=>'Std2',
}]);
