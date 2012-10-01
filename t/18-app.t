#!/usr/bin/perl

use Test::More tests => 34;
use Test::Deep;
use Test::Output;
use Debian::LicenseReconcile::Errors;
use Debian::LicenseReconcile::App;
use lib qw(t/lib);
use TestData;

is(Debian::LicenseReconcile::Errors->how_many,0,'how many');
my $app1 = Debian::LicenseReconcile::App->new(
    copyright=>'t/data/example/debian/copyright',
    format_spec=>1,
);
isa_ok($app1, 'Debian::LicenseReconcile::App');
my $target = $app1->_read_copyright_file;
is(Debian::LicenseReconcile::Errors->how_many,0,'how many');
isa_ok($target, 'Debian::LicenseReconcile::CopyrightTarget');

my $app2 = Debian::LicenseReconcile::App->new(
    copyright=>'t/data/bad-format',
);
isa_ok($app2, 'Debian::LicenseReconcile::App');
my $target2 = $app2->_read_copyright_file;
is(Debian::LicenseReconcile::Errors->how_many,0,'how many');
isa_ok($target2, 'Debian::LicenseReconcile::CopyrightTarget');

my $app3 = Debian::LicenseReconcile::App->new(
    copyright=>'t/data/bad-format',
    format_spec=>1,
);
isa_ok($app3, 'Debian::LicenseReconcile::App');
my $target3 = $app3->_read_copyright_file;
is(Debian::LicenseReconcile::Errors->how_many,1,'how many');
my @list = Debian::LicenseReconcile::Errors->list;
my $error1 = 'Cannot recognize format: Format: http://www.debian.org/doc/packaging-manuals/copyright-format/1.O/';
cmp_deeply(\@list, [
    { test=>'FormatSpec', msg=>$error1, },
], 'initial state');
isa_ok($target3, 'Debian::LicenseReconcile::CopyrightTarget');

my $app4 = Debian::LicenseReconcile::App->new(
    copyright=>'t/data/flossy',
    format_spec=>1,
);
isa_ok($app4, 'Debian::LicenseReconcile::App');
my $target4 = $app4->_read_copyright_file;
is(Debian::LicenseReconcile::Errors->how_many,2,'how many');
@list = Debian::LicenseReconcile::Errors->list;
my $error2 = 'Invalid field given (Flossy) at /usr/local/share/perl/5.14.2/Debian/Copyright.pm line 141
';
cmp_deeply(\@list, [
    { test=>'FormatSpec', msg=>$error1, },
    { test=>'CopyrightParsing', msg=>$error2, },
]);
is($target4, undef);

my $app5 = Debian::LicenseReconcile::App->new(
    changelog_file=>'t/data/example/debian/changelog',
);
isa_ok($app5, 'Debian::LicenseReconcile::App');
my $target5 = $app5->_parse_changelog;
is(Debian::LicenseReconcile::Errors->how_many,2,'how many');
@list = Debian::LicenseReconcile::Errors->list;
cmp_deeply(\@list, [
    { test=>'FormatSpec', msg=>$error1, },
    { test=>'CopyrightParsing', msg=>$error2, },
]);
isa_ok($target5, 'Parse::DebianChangelog');

my $app6 = Debian::LicenseReconcile::App->new(
    config_file =>'t/data/empty.yml',
);
isa_ok($app6, 'Debian::LicenseReconcile::App');
my $target6 = $app6->_parse_config;
is(Debian::LicenseReconcile::Errors->how_many,2,'how many');
@list = Debian::LicenseReconcile::Errors->list;
cmp_deeply(\@list, [
    { test=>'FormatSpec', msg=>$error1, },
    { test=>'CopyrightParsing', msg=>$error2, },
]);
cmp_deeply($target6, {licensecheck=>{}});

my $app7 = Debian::LicenseReconcile::App->new(
    config_file =>'t/data/almost.yml',
);
isa_ok($app7, 'Debian::LicenseReconcile::App');
my $target7 = $app7->_parse_config;
is(Debian::LicenseReconcile::Errors->how_many,2,'how many');
@list = Debian::LicenseReconcile::Errors->list;
cmp_deeply(\@list, [
    { test=>'FormatSpec', msg=>$error1, },
    { test=>'CopyrightParsing', msg=>$error2, },
]);
cmp_deeply($target7, {licensecheck=>{},Rules=>[],Blah=>[undef]});

my $app8 = Debian::LicenseReconcile::App->new(
    directory=>'t/data/example',
);
isa_ok($app8, 'Debian::LicenseReconcile::App');
my $target8 = $app8->_build_licensecheck($target7);
is(Debian::LicenseReconcile::Errors->how_many,2,'how many');
@list = Debian::LicenseReconcile::Errors->list;
cmp_deeply(\@list, [
    { test=>'FormatSpec', msg=>$error1, },
    { test=>'CopyrightParsing', msg=>$error2, },
]);
isa_ok($target8, 'Debian::LicenseReconcile::LicenseCheck');

my $app9 = Debian::LicenseReconcile::App->new(
    directory=>'t/data/example',
    display_mapping => 0,
);
isa_ok($app9, 'Debian::LicenseReconcile::App');
my $target9 = undef;
stdout_is(sub {
    $target9 = $app9->_build_file_mapping($target);
}, '');
cmp_deeply($target9, {
    'a/0.h'=>$COPYRIGHT_DATA2,
    'a/1.h'=>$COPYRIGHT_DATA2,
    'a/2.h'=>$COPYRIGHT_DATA2,
    'a/3.h'=>$COPYRIGHT_DATA2,
    'a/base'=>$COPYRIGHT_DATA,
    'a/g/blah'=>$COPYRIGHT_DATA2u,
    'a/g/scriggs.t'=>$COPYRIGHT_DATA5,
    'a/scriggs.g'=>$COPYRIGHT_DATA4,
    'base'=>$COPYRIGHT_DATA,
    'sample.png'=>$COPYRIGHT_DATA,
    'base.h'=>$COPYRIGHT_DATA,
    'debian/changelog'=>$COPYRIGHT_DATA3,
    'debian/control'=>$COPYRIGHT_DATA3,
    'debian/copyright'=>$COPYRIGHT_DATA3,
});


