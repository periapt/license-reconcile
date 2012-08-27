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
    },
    requires => {
        'perl' => 5.006,
        'Class::XSAccessor' => 0,
        'Config::Any' => 0,
        'Debian::Copyright' => '0.2',
        'Parse::DebianChangelog' => 0,
        'File::Slurp' => 0,
        'File::MMagic' => 0,
        'File::FnMatch' => 0,
        'Dpkg::Version' => 0,
    },
    add_to_cleanup      => [ 'Debian-LicenseReconcile-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
