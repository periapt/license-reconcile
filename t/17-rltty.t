#!/usr/bin/perl

use Test::More tests => 2;
use Test::Deep;
use Debian::LicenseReconcile::CopyrightDatum;
use Debian::LicenseReconcile::LicenseCheck;
use Readonly;

Readonly my $LICENSECHECK => Debian::LicenseReconcile::LicenseCheck->new('t/data', [], 1);
Readonly my $RAW_DATA => $LICENSECHECK->get_info('rltty.c');

Readonly my $DATUM => Debian::LicenseReconcile::CopyrightDatum->new($RAW_DATA->{copyright});
isa_ok($DATUM, 'Debian::LicenseReconcile::CopyrightDatum');
cmp_deeply($DATUM->as_hash, {
    'Free Software Foundation, Inc' => methods(min=>1992,max=>2005,size=>14),
});
