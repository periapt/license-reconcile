#!/usr/bin/perl

use Test::More tests => 7;
use Test::Deep;
use Debian::LicenseReconcile::Errors;
use Debian::LicenseReconcile::CopyrightTarget;
use File::Slurp;

is(Debian::LicenseReconcile::Errors->how_many,0,'how many');
my @list = Debian::LicenseReconcile::Errors->list;
cmp_deeply(\@list, [], 'initial state');

my $copyright = Debian::LicenseReconcile::CopyrightTarget->new(scalar read_file('t/data/copyright'));
isa_ok($copyright, 'Debian::LicenseReconcile::CopyrightTarget', 'good copyright');
isa_ok($copyright->get('*'), 'Debian::Copyright::Stanza::Files', 'tree not empty');

is(Debian::LicenseReconcile::Errors->how_many,0,'how many');
@list = Debian::LicenseReconcile::Errors->list;
cmp_deeply(\@list, [], 'initial state');

my @keys = $copyright->keys;
cmp_deeply(\@keys, bag( '*', 'lib/Debian/Copyright*'), 'keys');


