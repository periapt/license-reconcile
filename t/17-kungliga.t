#!/usr/bin/perl

use Test::More tests => 1;
use Test::Deep;
use Debian::LicenseReconcile::CopyrightDatum;
use Readonly;

Readonly my $DATUM => Debian::LicenseReconcile::CopyrightDatum->new('1997-2000 - Kungliga Tekniska Högskolan');
isa_ok($DATUM, 'Debian::LicenseReconcile::CopyrightDatum');

