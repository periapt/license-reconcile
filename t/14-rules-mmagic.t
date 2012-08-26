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
                MMagic=>'application/octet-stream',
                License=>'BSD',
                Copyright=>'[Copyright: 2012, Periapt Technologies. All rights reserved]',
            },
            {
                Glob=>'b*s?',
                MMagic=>'text/plain',
                License=>'GPL-1',
                Copyright=>'[Copyright: 2012, Periapt Technologies. All rights reserved]',
            },
        ],
    },
    files_remaining=>\@files,
);
isa_ok($filter, 'Debian::LicenseReconcile::Filter');
isa_ok($filter, 'Debian::LicenseReconcile::Filter::Rules');

my @data = $filter->get_info;
cmp_deeply(\@data, [
    {
        file=>'sample.png',
        license=>'BSD',
        test=>'Rules',
        copyright=>'[Copyright: 2012, Periapt Technologies. All rights reserved]',
    },
    {
        file=>'base',
        license=>'GPL-1',
        test=>'Rules',
        copyright=>'[Copyright: 2012, Periapt Technologies. All rights reserved]',
    },
]);
