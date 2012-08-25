#!/usr/bin/perl

use Test::More tests => 5;
use Test::Deep;
use Debian::LicenseReconcile::Errors;
use Debian::LicenseReconcile::CopyrightTarget;
use File::Slurp;

is(Debian::LicenseReconcile::Errors->how_many,0,'how many');
my @list = Debian::LicenseReconcile::Errors->list;
cmp_deeply(\@list, [], 'initial state');

my $copyright = Debian::LicenseReconcile::CopyrightTarget->new;
isa_ok($copyright, 'Debian::LicenseReconcile::CopyrightTarget');
isa_ok($copyright->parse(scalar read_file('t/data/copyright')),'Debian::LicenseReconcile::CopyrightTarget');

my $data = {
    copyright=>'
 2010-2011, Nicholas Bamber <nicholas@periapt.co.uk>',
    license=>'Artistic or GPL-2+',
    pattern=>'*',
};
cmp_deeply($copyright->map_directory('t/data/example'), {
    'a/0.h'=>$data,
    'a/1.h'=>$data,
    'a/2.h'=>$data,
    'a/3.h'=>$data,
    'a/base'=>$data,
    'a/g/blah'=>$data,
    'a/g/scriggs.t'=>$data,
    'a/scriggs.g'=>$data,
    'base'=>$data,
    'base.h'=>$data,
    'debian/control'=>$data,
    'debian/copyright'=>$data,
}, 'directory mapping');
