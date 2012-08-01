#!/usr/bin/perl

use Test::More tests => 5;
use Test::Deep;
use Debian::LicenseReconcile::Errors;
use Debian::LicenseReconcile::FormatSpec;

is(Debian::LicenseReconcile::Errors->how_many,0,'how many');
my @list = Debian::LicenseReconcile::Errors->list;
cmp_deeply(\@list, [], 'initial state');

is(Debian::LicenseReconcile::FormatSpec->check(''), 0, 'empty copyright');
is(Debian::LicenseReconcile::Errors->how_many,1,'how many');
@list = Debian::LicenseReconcile::Errors->list;
cmp_deeply(\@list, [
    {
        test=>'Debian::LicenseReconcile::FormatSpec',
        msg=>'copyright data is empty',
    },
], 'initial state');

