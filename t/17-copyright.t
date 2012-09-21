#!/usr/bin/perl

use Test::More tests => 33;
use Test::Deep;
use Debian::LicenseReconcile::CopyrightDatum;

my $d = Debian::LicenseReconcile::CopyrightDatum->new;
isa_ok($d, 'Debian::LicenseReconcile::CopyrightDatum');
is($d->contains($d), 1, 'contains');
is($d->contains($d, 'no better than a default'), 1, 'contains');
my @dk = $d->copyright_holders;
cmp_deeply(\@dk, [], 'copyright holders');
is($d->years(''), undef, 'years');
my $test = 'blah';
my $copyright = \'blah';
is($d->contains($copyright, \$test), 0);
is($$copyright, 'blah');
like($test, qr/1 cannot be fitted into 0:/);
is($d->contains('[]', \$test), 1, 'square brackets');
like($test, qr/1 cannot be fitted into 0:/);

undef $copyright;
is($d->contains($copyright, \$test), 0, 'undefined other');
is($copyright, undef);
is($test, 'The other copyright data was undefined.');

my $d2=Debian::LicenseReconcile::CopyrightDatum->new('[]');
isa_ok($d2, 'Debian::LicenseReconcile::CopyrightDatum');
my @dk2 = $d2->copyright_holders;
cmp_deeply(\@dk2, [], 'copyright holders');

my $d3=Debian::LicenseReconcile::CopyrightDatum->new('[ ]');
isa_ok($d3, 'Debian::LicenseReconcile::CopyrightDatum');
my @dk3 = $d3->copyright_holders;
cmp_deeply(\@dk3, [], 'copyright holders');

my $d4=Debian::LicenseReconcile::CopyrightDatum->new('X');
isa_ok($d4, 'Debian::LicenseReconcile::CopyrightDatum');
my @dk4 = $d4->copyright_holders;
cmp_deeply(\@dk4, ['X'], 'copyright holders');
isa_ok($d4->years('X'), 'Set::IntSpan');
ok($d4->years('X')->empty, 'empty set of years');

my $text=<<'EOS';
 1997, 1999-2006, Blah Wah Ltd
 1996-1998, 2001, Woo Goo & Co
EOS
my $d5=Debian::LicenseReconcile::CopyrightDatum->new($text);
isa_ok($d5, 'Debian::LicenseReconcile::CopyrightDatum');
my @dk5 = $d5->copyright_holders;
cmp_deeply(\@dk5, ['Woo Goo & Co','Blah Wah Ltd'], 'copyright holders');
isa_ok($d5->years('Woo Goo & Co'), 'Set::IntSpan');
isa_ok($d5->years('Blah Wah Ltd'), 'Set::IntSpan');
my $woo_years = $d5->years('Woo Goo & Co')->elements;
cmp_deeply($woo_years,[1996,1997,1998,2001], 'woo years');
my $blah_years = $d5->years('Blah Wah Ltd')->elements;
cmp_deeply($blah_years,[1997,1999,2000,2001,2002,2003,2004,2005,2006], 'blah years');

my $test2='haha';
is($d5->contains('2005, Microflop Inc', \$test2), 0);
is($test2, "For copyright holder 'Microflop Inc' (which looks like 'Woo Goo & Co') the years 2005 cannot be fitted into 1996-1998,2001.");

$test2='haha';
is($d5->contains('1997,1999, Blah Wah Ltd', \$test2), 1);
is($test2, 'haha');
is($d5->contains('1998, Blah Wah Ltd', \$test2), 0);
is($test2, "For copyright holder 'Blah Wah Ltd' the years 1998 cannot be fitted into 1997,1999-2006.");

