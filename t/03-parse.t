#!/usr/bin/perl

use Test::More tests => 4;
use Test::Deep;
use Debian::LicenseReconcile::Errors;
use Debian::LicenseReconcile::CopyrightTarget;
#use File::Slurp;

is(Debian::LicenseReconcile::Errors->how_many,0,'how many');
my @list = Debian::LicenseReconcile::Errors->list;
cmp_deeply(\@list, [], 'initial state');

my $copyright = Debian::LicenseReconcile::CopyrightTarget->new("Blah: hello\n");
#isa_ok($copyright, 'Debian::LicenseReconcile::CopyrightTarget');
is($copyright, undef, 'failed parse');

is(Debian::LicenseReconcile::Errors->how_many,1,'how many');
#@list = Debian::LicenseReconcile::Errors->list;
#cmp_deeply(\@list, [
#    {
#        test=>'Debian::LicenseReconcile::FormatSpec',
#        msg=>'copyright data is empty',
#    },
#], 'initial state');
#
#is(Debian::LicenseReconcile::FormatSpec->check(read_file('t/data/good-format')), 1, 'good format');
#is(Debian::LicenseReconcile::Errors->how_many,1,'how many');
#@list = Debian::LicenseReconcile::Errors->list;
#cmp_deeply(\@list, [
#    {
#        test=>'Debian::LicenseReconcile::FormatSpec',
#        msg=>'copyright data is empty',
#    },
#], 'initial state');
#
#is(Debian::LicenseReconcile::FormatSpec->check(read_file('t/data/bad-format')), 0, 'bad format');
#is(Debian::LicenseReconcile::Errors->how_many,2,'how many');
#@list = Debian::LicenseReconcile::Errors->list;
#cmp_deeply(\@list, [
#    {
#        test=>'Debian::LicenseReconcile::FormatSpec',
#        msg=>'copyright data is empty',
#    },
#    {
#        test=>'Debian::LicenseReconcile::FormatSpec',
#        msg=>'Cannot recognize format: Format: http://www.debian.org/doc/packaging-manuals/copyright-format/1.O/',
#    },
#], 'initial state');
#
#
