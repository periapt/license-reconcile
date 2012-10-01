#!/usr/bin/perl

use Test::More tests => 7;
use Test::Deep;
use Debian::LicenseReconcile::Errors;
use Debian::LicenseReconcile::CopyrightTarget;
use File::Slurp;
use lib qw(t/lib);
use TestData;

is(Debian::LicenseReconcile::Errors->how_many,0,'how many');
my @list = Debian::LicenseReconcile::Errors->list;
cmp_deeply(\@list, [], 'initial state');

my $copyright = Debian::LicenseReconcile::CopyrightTarget->new;
isa_ok($copyright, 'Debian::LicenseReconcile::CopyrightTarget');
isa_ok($copyright->parse(scalar read_file('t/data/example/debian/copyright')),'Debian::LicenseReconcile::CopyrightTarget');

is(Debian::LicenseReconcile::Errors->how_many,0,'how many');
@list = Debian::LicenseReconcile::Errors->list;
cmp_deeply(\@list, [], 'initial state');

my $data = {
    copyright=>'
 2010-2011, Nicholas Bamber <nicholas@periapt.co.uk>',
    license=>'Artistic or GPL-2+',
    pattern=>'*',
};
my $data2 = {
    copyright=>'
 2011, Nicholas Bamber <nicholas@periapt.co.uk>
 2008, Joe Bloggs <joeblogs@example.org>',
    license=>'GPL-3+',
    pattern=>'a/*.h',
};
my $data2u = {
    copyright=>'
 2011, Nicholas Bamber <nicholas@periapt.co.uk>
 2008, Joe Bloggs <joeblogs@example.org>',
    license=>'GPL-3+',
    pattern=>'a/g/*',
};
my $data3 = {
    copyright=>'
 2008-2010, gregor hermann <gregoa@debian.org>
 2010-2011, Nicholas Bamber <nicholas@periapt.co.uk>',
    license=>'Artistic or GPL-2+',
    pattern=>'debian/*',
};
my $data4 = {
    copyright=>'
 2011, Nicholas Bamber <nicholas@periapt.co.uk>
 2009, Damyan Ivanov <dmn@debian.org>',
    license=>'GPL-1+',
    pattern=>'a/*.g',
};
my $data5 = {
    copyright=>$data4->{copyright},
    license=>$data4->{license},
    pattern=>'a/g/*.t',
};
cmp_deeply($copyright->map_directory('t/data/example'), {
    'a/0.h'=>$COPYRIGHT_DATA2,
    'a/1.h'=>$COPYRIGHT_DATA2,
    'a/2.h'=>$COPYRIGHT_DATA2,
    'a/3.h'=>$COPYRIGHT_DATA2,
    'a/base'=>$COPYRIGHT_DATA,
    'a/g/blah'=>$COPYRIGHT_DATA2u,
    'a/g/scriggs.t'=>$COPYRIGHT_DATA5,
    'a/scriggs.g'=>$COPYRIGHT_DATA4,
    'base'=>$COPYRIGHT_DATA,
    'sample.png'=>$COPYRIGHT_DATA,
    'base.h'=>$COPYRIGHT_DATA,
    'debian/changelog'=>$COPYRIGHT_DATA3,
    'debian/control'=>$COPYRIGHT_DATA3,
    'debian/copyright'=>$COPYRIGHT_DATA3,
}, 'directory mapping');

