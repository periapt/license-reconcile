#!/usr/bin/perl

use Test::More tests => 40;
use Test::Deep;
use Debian::LicenseReconcile::CopyrightDatum;
use Debian::LicenseReconcile::Errors;

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

undef $copyright;
is($d->contains($copyright, \$test), 0, 'undefined other');
is($copyright, undef);
is($test, 'The other copyright data was undefined.');

my $d3=Debian::LicenseReconcile::CopyrightDatum->new(' ');
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
is($test2, "Trying to match 'Microflop Inc' against 'Woo Goo & Co' but it does not look like a good match.");

$test2='haha';
is($d5->contains('2005, WiooGoo $ Coc', \$test2), 0);
is($test2, "For copyright holder 'WiooGoo \$ Coc' (which looks like 'Woo Goo & Co') the years 2005 cannot be fitted into 1996-1998,2001.");

$test2='haha';
is($d5->contains('1997,1999, Blah Wah Ltd', \$test2), 1);
is($test2, 'haha');
is($d5->contains('1998, Blah Wah Ltd', \$test2), 0);
is($test2, "For copyright holder 'Blah Wah Ltd' the years 1998 cannot be fitted into 1997,1999-2006.");

my $text2=<<'EOS';
 1997, 1999-2006, Blah1 Wah Ltd
 1997, 1999-2006, Blah Wah8 Ltd
EOS
$test2='haha';
is($d5->contains($text2, \$test2), 0);
is($test2, "Was trying to match 'Blah1 Wah Ltd' to 'Blah Wah Ltd', but 'Blah Wah8 Ltd' would match as well so giving up.");

my $text3=<<'EOS';
 1997, 1999-2006, Blah4 Wah Ltd
 1996-1998, 2001, Blah WaT Ltd
EOS
my $d6=Debian::LicenseReconcile::CopyrightDatum->new($text3);
$test2='haha';
is($d6->contains($text, \$test2), 0);
is($test2, "Was trying to match 'Blah Wah Ltd' to 'Blah4 Wah Ltd', but 'Blah WaT Ltd' would be matched as well so giving up.");
is(Debian::LicenseReconcile::Errors->how_many,0,'how many');

my $text4='Copyright: 1997--1998 Jan Pazdziora, adelton@fi.muni.cz';
my $d7=Debian::LicenseReconcile::CopyrightDatum->new($text4);
$test2='haha';
is($d7->contains('1997-1998 Jan Pazdziora, adelton@fi.muni.cz', \$test2), 0);
is($test2, "For copyright holder 'Jan Pazdziora, adelton\@fi.muni.cz' the years 1997-1998 cannot be fitted into -.");
is(Debian::LicenseReconcile::Errors->how_many,1,'how many');
my @list = Debian::LicenseReconcile::Errors->list;
cmp_deeply(\@list, [
    {
        test=>'Copyright parsing',
        msg=>"Trying to parse 1997--1998: Set::IntSpan::_copy_run_list: Bad order: 1997--1998",
    },
], 'bad copyright');



