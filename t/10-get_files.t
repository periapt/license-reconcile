#!/usr/bin/perl

use Test::More tests => 1;
use Debian::LicenseReconcile::Utils qw(get_files);
use Test::Deep;

my @files = get_files('t/data/example');
cmp_deeply(\@files, [
	'base',
	'base.h',
	'a/base',
	'a/2.h',
	'a/0.h',
	'a/scriggs.g',
	'a/3.h',
	'a/1.h',
	'a/g/scriggs.t',
	'a/g/blah',
	'debian/control',
	'debian/copyright',
]);
