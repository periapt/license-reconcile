#!perl -T

use Test::More tests => 2;

BEGIN {
    use_ok( 'Debian::LicenseReconcile' ) || print "Bail out!\n";
    use_ok( 'Debian::LicenseReconcile::FormatSpec' ) || print "Bail out!\n";
}

diag( "Testing Debian::LicenseReconcile $Debian::LicenseReconcile::VERSION, Perl $], $^X" );
