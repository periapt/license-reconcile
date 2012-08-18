#!perl 

use Test::More tests => 8;
use Test::Compile;

BEGIN {
    use_ok( 'Debian::LicenseReconcile' ) || print "Bail out!\n";
    use_ok( 'Debian::LicenseReconcile::Errors' ) || print "Bail out!\n";
    use_ok( 'Debian::LicenseReconcile::FormatSpec' ) || print "Bail out!\n";
    use_ok( 'Debian::LicenseReconcile::CopyrightTarget' ) || print "Bail out!\n";
    use_ok( 'Debian::LicenseReconcile::Utils' ) || print "Bail out!\n";
    use_ok( 'Debian::LicenseReconcile::Filter' ) || print "Bail out!\n";
    use_ok( 'Debian::LicenseReconcile::Filter::Default' ) || print "Bail out!\n";
}

diag( "Testing Debian::LicenseReconcile $Debian::LicenseReconcile::VERSION, Perl $], $^X" );

pl_file_ok('bin/license-reconcile');
