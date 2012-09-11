#!/usr/bin/perl

use Test::More tests => 3;
use Test::Deep;
use Debian::LicenseReconcile::CopyrightDatum;

my $d = Debian::LicenseReconcile::CopyrightDatum->new;
isa_ok($d, 'Debian::LicenseReconcile::CopyrightDatum');
is($d->contains($d), 1, 'contains');
my @dk = $d->copyright_holders;
cmp_deeply(\@dk, [], 'copyright holders');
