#!/usr/bin/perl

use Test::More tests => 12;
use Test::Deep;
use Debian::LicenseReconcile::CopyrightDatum;

my $d = Debian::LicenseReconcile::CopyrightDatum->new;
isa_ok($d, 'Debian::LicenseReconcile::CopyrightDatum');
is($d->contains($d), 1, 'contains');
my @dk = $d->copyright_holders;
cmp_deeply(\@dk, [], 'copyright holders');
is($d->years(''), undef, 'years');
my $test = 'blah';
my $copyright = \'blah';
is($d->contains($copyright, \$test), 1, 'actually should be NO');
is($$copyright, 'blah');
is($test, 'blah');
is($d->contains('[]', \$test), 1, 'square brackets');
is($test, 'blah');

undef $copyright;
is($d->contains($copyright, \$test), 0, 'undefined other');
is($copyright, undef);
is($test, 'The other copyright data was undefined.');
