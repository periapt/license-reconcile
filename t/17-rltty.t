#!/usr/bin/perl

use Test::More tests => 8;
use Test::Deep;
use Debian::LicenseReconcile::CopyrightDatum;
use Debian::LicenseReconcile::LicenseCheck;
use Debian::LicenseReconcile::Filter::Rules;
use Readonly;

Readonly my $LICENSECHECK => Debian::LicenseReconcile::LicenseCheck->new('t/data', [], 1);
Readonly my $RAW_DATA => $LICENSECHECK->get_info('rltty.c');

Readonly my $DATUM => Debian::LicenseReconcile::CopyrightDatum->new($RAW_DATA->{copyright});
isa_ok($DATUM, 'Debian::LicenseReconcile::CopyrightDatum');
cmp_deeply($DATUM->as_hash, {
    'Free Software Foundation, Inc' => methods(min=>1992,max=>2005,size=>14),
});

my $filter = Debian::LicenseReconcile::Filter::Rules->new(
    directory=>'t/data/',
    config=>{
        rules=>[ {}, ],
    },
    files_remaining=>[
        'rltty.c',
    ],
    licensecheck=>$LICENSECHECK,
    name=>'Rules3',
);
isa_ok($filter, 'Debian::LicenseReconcile::Filter');
isa_ok($filter, 'Debian::LicenseReconcile::Filter::Rules');

my @data = $filter->get_info;
cmp_deeply(\@data, [{
    file=>'rltty.c',
    license=>'GPL-2+',
    test=>'Rules3',
    copyright=>'[Copyright: 1992-2005 Free Software Foundation, Inc]',
}]);

$filter = Debian::LicenseReconcile::Filter::Rules->new(
    directory=>'t/data/',
    config=>{
        rules=>[ {
            License=>'Apache-2.0',
        }, ],
    },
    files_remaining=>[
        'rltty.c',
    ],
    licensecheck=>$LICENSECHECK,
    name=>'Rules4',
);
isa_ok($filter, 'Debian::LicenseReconcile::Filter');
isa_ok($filter, 'Debian::LicenseReconcile::Filter::Rules');

my @data = $filter->get_info;
cmp_deeply(\@data, [{
    file=>'rltty.c',
    license=>'Apache-2.0',
    test=>'Rules4',
    copyright=>'[Copyright: 1992-2005 Free Software Foundation, Inc]',
}]);
