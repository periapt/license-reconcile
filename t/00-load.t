#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Debian::LicenseReconcile' ) || print "Bail out!\n";
}

diag( "Testing Debian::LicenseReconcile $Debian::LicenseReconcile::VERSION, Perl $], $^X" );
