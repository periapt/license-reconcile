#!perl 

use Test::More tests => 16;
use Test::Compile;

BEGIN {
    use_ok( 'Debian::LicenseReconcile' ) || print "Bail out!\n";
    use_ok( 'Debian::LicenseReconcile::Errors' ) || print "Bail out!\n";
    use_ok( 'Debian::LicenseReconcile::App' ) || print "Bail out!\n";
    use_ok( 'Debian::LicenseReconcile::LicenseCheck' ) || print "Bail out!\n";
    use_ok( 'Debian::LicenseReconcile::FormatSpec' ) || print "Bail out!\n";
    use_ok( 'Debian::LicenseReconcile::CopyrightTarget' ) || print "Bail out!\n";
    use_ok( 'Debian::LicenseReconcile::CopyrightDatum' ) || print "Bail out!\n";
    use_ok( 'Debian::LicenseReconcile::CopyrightDatum::Holder' ) || print "Bail out!\n";
    use_ok( 'Debian::LicenseReconcile::Utils' ) || print "Bail out!\n";
    use_ok( 'Debian::LicenseReconcile::Filter' ) || print "Bail out!\n";
    use_ok( 'Debian::LicenseReconcile::Filter::Rules' ) || print "Bail out!\n";
    use_ok( 'Debian::LicenseReconcile::Filter::Std' ) || print "Bail out!\n";
    use_ok( 'Debian::LicenseReconcile::Filter::Shebang' ) || print "Bail out!\n";
    use_ok( 'Debian::LicenseReconcile::Filter::ChangeLog' ) || print "Bail out!\n";
    use_ok( 'Debian::LicenseReconcile::VerifyLicense' ) || print "Bail out!\n";
}

diag( "Testing Debian::LicenseReconcile $Debian::LicenseReconcile::VERSION, Perl $], $^X" );

pl_file_ok('bin/license-reconcile');
