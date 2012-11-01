#!/usr/bin/perl

use Test::More tests => 7;
use Test::Deep;
use Test::NoWarnings;
use Debian::LicenseReconcile::LicenseCheck;
use Readonly;

Readonly my $LICENSECHECK => Debian::LicenseReconcile::LicenseCheck->new('t/data', [], 1);

my @data = $LICENSECHECK->get_info('copyright_extract1');
cmp_deeply(\@data, [{
    file=>'copyright_extract1',
    license=>'GPL-2',
    copyright=>[
        'Copyright: 2007 Google Inc',
        '2008 MySQL AB, 2008-2009 Sun Microsystems, Inc'
    ],
}]);

@data = $LICENSECHECK->get_info(
    'copyright_extract1',
    '(?:Copyright\s+\(C\)\s+((?:\d{4}(?:\s|,\s|\-))*Google\s+Inc)\.\s*\R+)?\s*Copyright\s+\(c\)\s+(2008\s+MySQL\s+AB),\s+(2008-2009\s+Sun\s+Microsystems,\s+Inc)\.',
);
cmp_deeply(\@data, [{
    file=>'copyright_extract1',
    license=>'GPL-2',
    copyright=>[
        '2007 Google Inc',
        '2008 MySQL AB',
        '2008-2009 Sun Microsystems, Inc'],
}]);

