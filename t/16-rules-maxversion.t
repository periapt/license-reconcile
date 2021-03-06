#!/usr/bin/perl

use Test::More tests => 3;
use Test::Deep;
use Debian::LicenseReconcile::Utils qw(get_files);
use Debian::LicenseReconcile::Filter::Rules;
use Readonly;
use Parse::DebianChangelog;

Readonly my $DIR => 't/data/example';
Readonly my $CHANGELOG => Parse::DebianChangelog->init({infile=>"$DIR/debian/changelog"});

my @files = get_files($DIR);

my $filter = Debian::LicenseReconcile::Filter::Rules->new(
    directory=>$DIR,
    name=>'Rules7',
    changelog=>$CHANGELOG,
    config=>{
        rules=>[
            {
                MMagic=>'application/octet-stream',
                License=>'BSD',
                MaxVersion=>'3.20.16beta-1',
                Copyright=>'[Copyright: 2012, Periapt Technologies. All rights reserved]',
            },
            {
                Glob=>'ba*',
                MMagic=>'text/plain',
                MaxVersion=>'3.20.16beta-2',
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
        file=>'base',
        license=>'GPL-1',
        test=>'Rules7',
        copyright=>'[Copyright: 2012, Periapt Technologies. All rights reserved]',
    },
    {
        file=>'base.h',
        license=>'GPL-1',
        test=>'Rules7',
        copyright=>'[Copyright: 2012, Periapt Technologies. All rights reserved]',
    },
]);
