#!/usr/bin/perl

use Test::More tests => 10;
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
isa_ok($copyright->parse(scalar read_file('t/data/copyright')),'Debian::LicenseReconcile::CopyrightTarget');
is($copyright->getChildCount, 2, 'getChildrenCount=2');
cmp_deeply($copyright, noclass({
    _children=>[
        {
            _children=>[],
            _depth=>0,
            _height=>1,
            _node=>{
                file=>'*',
                license=>re('Artistic or GPL-2'),
                copyright=>re('2010-2011, Nicholas Bamber'),
                pattern=>'*',
            },
            _parent=>ignore(),
            _uid=>ignore(),
            _width=>1,
        },
        {
            _children=>[
                {
                    _children=>[
                        {
                            _children=>[],
                            _depth=>2,
                            _height=>1,
                            _node=>{
                                file=>'Copyright*',
                                license=>re('GPL-2'),
                                copyright=>re('2009, Damyan Ivanov'),
                                pattern=>'lib/Debian/Copyright*',
                            },
                            _parent=>ignore(),
                            _uid=>ignore(),
                            _width=>1,
                        },
                    ],
                    _depth=>1,
                    _height=>2,
                    _node=>{
                        file=>'Debian',
                    },
                    _parent=>ignore(),
                    _uid=>ignore(),
                    _width=>1,
                },
            ],
            _depth=>0,
            _height=>3,
            _node=>{
                file=>'lib',
            },
            _parent=>ignore(),
            _uid=>ignore(),
            _width=>1,
        },
    ],
    _depth=>-1,
    _height=>4,
    _node=>undef,
    _parent=>ignore(),
    _uid=>ignore(),
    _width=>2,
}), 'deep structure');

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
cmp_deeply($copyright->map_directory('t/data/example'), {
    './a/0.h'=>$data,
    './a/1.h'=>$data,
    './a/2.h'=>$data,
    './a/3.h'=>$data,
    './a/base'=>$data,
    './a/g/blah'=>$data,
    './a/g/scriggs.t'=>$data,
    './a/scriggs.g'=>$data,
    './base'=>$data,
    './debian/control'=>$data,
    './debian/copyright'=>$data,
}, 'directory mapping');
