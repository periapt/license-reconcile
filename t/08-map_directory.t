#!/usr/bin/perl

use Test::More tests => 9;
use Test::Deep;
use Debian::LicenseReconcile::Errors;
use Debian::LicenseReconcile::CopyrightTarget;
use File::Slurp;

is(Debian::LicenseReconcile::Errors->how_many,0,'how many');
my @list = Debian::LicenseReconcile::Errors->list;
cmp_deeply(\@list, [], 'initial state');

my $copyright = Debian::LicenseReconcile::CopyrightTarget->new;
isa_ok($copyright, 'Debian::LicenseReconcile::CopyrightTarget');
is($copyright->getChildCount, 0, 'getChildrenCount=0');
isa_ok($copyright->parse(scalar read_file('t/data/example/debian/copyright')),'Debian::LicenseReconcile::CopyrightTarget');
is($copyright->getChildCount, 3, 'getChildrenCount=2');

is(Debian::LicenseReconcile::Errors->how_many,0,'how many');
@list = Debian::LicenseReconcile::Errors->list;
cmp_deeply(\@list, [], 'initial state');

my $data = {
    file=>'*',
    copyright=>'
 2010-2011, Nicholas Bamber <nicholas@periapt.co.uk>',
    license=>'Artistic or GPL-2+',
    pattern=>'*',
};
my $data2 = {
    file=>'*.h',
    copyright=>'
 2011, Nicholas Bamber <nicholas@periapt.co.uk>
 2008, Joe Bloggs <joeblogs@example.org>',
    license=>'GPL-3+',
    pattern=>'a/*.h',
};
my $data3 = {
    file=>'*',
    copyright=>'
 2008-2010, gregor hermann <gregoa@debian.org>
 2010-2011, Nicholas Bamber <nicholas@periapt.co.uk>',
    license=>'Artistic or GPL-2+',
    pattern=>'debian/*',
};
my $data4 = {
    file=>'*.g',
    copyright=>'
 2011, Nicholas Bamber <nicholas@periapt.co.uk>
 2009, Damyan Ivanov <dmn@debian.org>',
    license=>'GPL-1+',
    pattern=>'a/*.g',
};
my $data5 = {
    file=>'*.t',
    copyright=>$data4->{copyright},
    license=>$data4->{license},
    pattern=>'a/g/*.t',
};
cmp_deeply($copyright->map_directory('t/data/example'), {
    './a/0.h'=>$data2,
    './a/1.h'=>$data2,
    './a/2.h'=>$data2,
    './a/3.h'=>$data2,
    './a/base'=>$data,
    './a/g/blah'=>$data,
    './a/g/scriggs.t'=>$data5,
    './a/scriggs.g'=>$data4,
    './base'=>$data,
    './debian/control'=>$data3,
    './debian/copyright'=>$data3,
}, 'directory mapping');
