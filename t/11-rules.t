#!/usr/bin/perl

use Test::More tests => 3;
use Test::Deep;
use Debian::LicenseReconcile::Filter::Rules;

my $filter = Debian::LicenseReconcile::Filter::Rules->new(
    directory=>'t/data/example',
    config=>{
        rules=>[
            {
                License=>'GPL-1',
                Copyright=>'[Copyright: 2012, Periapt Technologies. All rights reserved]',
            },
        ],
    },
    files_remaining=>[
        'base',
    ],
    name=>'Rules2',
);
isa_ok($filter, 'Debian::LicenseReconcile::Filter');
isa_ok($filter, 'Debian::LicenseReconcile::Filter::Rules');

my @data = $filter->get_info;
cmp_deeply(\@data, [{
    file=>'base',
    license=>'GPL-1',
    test=>'Rules2',
    copyright=>'[Copyright: 2012, Periapt Technologies. All rights reserved]',
}]);
