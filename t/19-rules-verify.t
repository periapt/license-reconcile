#!/usr/bin/perl

use Test::More tests => 3;
use Test::Deep;
use Debian::LicenseReconcile::Utils qw(get_files);
use Debian::LicenseReconcile::Filter::Rules;
use Debian::LicenseReconcile::LicenseCheck;
use Readonly;

Readonly my $LICENSECHECK => Debian::LicenseReconcile::LicenseCheck->new('t/data/example', [], 0);

Readonly my $DIR => 't/data/example';

my @files = get_files($DIR);

my $filter = Debian::LicenseReconcile::Filter::Rules->new(
    directory=>$DIR,
    name=>'Rules8',
    licensecheck=>$LICENSECHECK,
    config=>{
        rules=>[
            {
                VerifyLicense=>'BSD',
                License=>'Blah1',
                Copyright=>'[Copyright: 2012, Periapt Technologies. All rights reserved]',
            },
            {
                VerifyLicense=>'GPL-2',
                License=>'Blah2',
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
        license=>'Blah2',
        test=>'Rules8',
        copyright=>'[Copyright: 2012, Periapt Technologies. All rights reserved]',
    },
    {
        file=>'base.h',
        license=>'Blah2',
        test=>'Rules8',
        copyright=>'[Copyright: 2012, Periapt Technologies. All rights reserved]',
    },
]);
