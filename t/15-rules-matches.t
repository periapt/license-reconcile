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
                Glob=>'*a*',
                MMagic=>'text/plain',
                Matches=><<'EOS',
    \*\s+Copyright\s+\(c\)\s+2012,\s+Periapt\s+Technologies\.
    \s+All\s+rights\s+reserved\.
    \s+This\s+program\s+is\s+free\s+software;
    \s+you\s+can\s+redistribute\s+it\s+and\/or\s+modify
    \s+it\s+under\s+the\s+terms\s+of\s+the\s+GNU\s+General\s+Public\s+License
    \s+as\s+published\s+by\s+the\s+Free\s+Software\s+Foundation;
    \s+version\s+2\s+of\s+the\s+License\.
EOS
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
    {
        file=>'base.h',
        license=>'GPL-1',
        test=>'Rules',
        copyright=>'[Copyright: 2012, Periapt Technologies. All rights reserved]',
    },
]);
