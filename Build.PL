use 5.006;
use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Debian::LicenseReconcile',
    license             => 'perl',
    dist_author         => q{Nicholas Bamber <nicholas@periapt.co.uk>},
    dist_version_from   => 'lib/Debian/LicenseReconcile.pm',
    build_requires => {
        'Test::More' => 0,
        'Test::Compile' => 0,
        'Test::Deep' => 0,
        'Test::Output' => 0,
        'Test::NoWarnings' => 0,
    },
    requires => {
        'perl' => 5.006,
        'Scalar::Util'=>0,
        'Class::XSAccessor' => 0,
        'Config::Any' => 0,
        'Debian::Copyright' => '0.2',
        'Dpkg::Version' => 0,
        'Parse::DebianChangelog' => 0,
        'Email::Address' => 0,
        'List::MoreUtils'=>0,
        'Readonly'=>0,
        'File::Slurp' => 0,
        'File::MMagic' => 0,
        'File::FnMatch' => 0,
        'Set::IntSpan' => 0,
        'Text::LevenshteinXS' => 0,
        'Smart::Comments' => 0,
    },
    add_to_cleanup      => [ 'Debian-LicenseReconcile-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
