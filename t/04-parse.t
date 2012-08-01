#!/usr/bin/perl

use Test::More tests => 5;
use Test::Deep;
use Debian::LicenseReconcile::Errors;
use Debian::LicenseReconcile::CopyrightTarget;
use File::Slurp;

is(Debian::LicenseReconcile::Errors->how_many,0,'how many');
my @list = Debian::LicenseReconcile::Errors->list;
cmp_deeply(\@list, [], 'initial state');

my $copyright = Debian::LicenseReconcile::CopyrightTarget->new(read_file('t/data/copyright'));
isa_ok($copyright, 'Debian::LicenseReconcile::CopyrightTarget', 'good copyright');

is(Debian::LicenseReconcile::Errors->how_many,0,'how many');
@list = Debian::LicenseReconcile::Errors->list;
cmp_deeply(\@list, [], 'initial state');

