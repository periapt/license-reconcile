#!/usr/bin/perl

use Test::More tests => 6;
use Test::Deep;
use Test::NoWarnings;
use Debian::LicenseReconcile::LicenseCheck;
use Readonly;

Readonly my $LICENSECHECK => Debian::LicenseReconcile::LicenseCheck->new('t/data', [], 1);
Readonly my $RE => '(?:Copyright\s+\(C\)\s+((?:\d{4}(?:\s|,\s|\-))*Google\s+Inc)\.\s*\R+)?\s*Copyright\s+\(c\)\s+((?:\d{4}(?:\s|,\s|\-))*MySQL\s+AB),\s+((?:\d{4}(?:\s|,\s|\-))*Sun\s+Microsystems,\s+Inc)\.\s*\R+';

my @data = $LICENSECHECK->get_info('copyright_extract1');
cmp_deeply(\@data, [{
    file=>'copyright_extract1',
    license=>'GPL-2',
    copyright=>[
        'Copyright: 2007 Google Inc',
        '2008 MySQL AB, 2008-2009 Sun Microsystems, Inc'
    ],
}]);

@data = $LICENSECHECK->get_info('copyright_extract1', $RE);
cmp_deeply(\@data, [{
    file=>'copyright_extract1',
    license=>'GPL-2',
    copyright=>[
        '2007 Google Inc',
        '2008 MySQL AB',
        '2008-2009 Sun Microsystems, Inc'],
}]);

@data = $LICENSECHECK->get_info('copyright_extract2');
cmp_deeply(\@data, [{
    file=>'copyright_extract2',
    license=>'GPL-2',
    copyright=>[
        'Copyright: 2008 MySQL AB, 2008-2009 Sun Microsystems, Inc'
    ],
}]);

@data = $LICENSECHECK->get_info('copyright_extract2', $RE);
cmp_deeply(\@data, [{
    file=>'copyright_extract2',
    license=>'GPL-2',
    copyright=>[
        '2008 MySQL AB',
        '2008-2009 Sun Microsystems, Inc'],
}]);

@data = $LICENSECHECK->get_info('wtfpl', 'blah');
cmp_deeply(\@data, [{
    file=>'wtfpl',
    license=>'WTFPL',
    copyright=>[
        'Copyright: 2004 Sam Hocevar <sam@hocevar.net>'],
}]);





