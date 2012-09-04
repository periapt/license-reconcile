#!/usr/bin/perl

use Test::More tests => 3;
use Test::Deep;
use Debian::LicenseReconcile::Utils qw(get_files);
use Debian::LicenseReconcile::Filter::Rules;
use Readonly;

Readonly my $DIR => 't/data/example';

my @files = get_files($DIR);

my $filter = Debian::LicenseReconcile::Filter::Rules->new(
    directory=>$DIR,
    config=>{
        rules=>[
            {
                Glob=>'b*s?',
                License=>'GPL-1',
                Copyright=>'[Copyright: 2012, Periapt Technologies. All rights reserved]',
            },
        ],
    },
    files_remaining=>\@files,
    name=>'Rules3',
);
isa_ok($filter, 'Debian::LicenseReconcile::Filter');
isa_ok($filter, 'Debian::LicenseReconcile::Filter::Rules');

my @data = $filter->get_info;
cmp_deeply(\@data, [{
    file=>'base',
    license=>'GPL-1',
    test=>'Rules3',
    copyright=>'[Copyright: 2012, Periapt Technologies. All rights reserved]',
}]);
