#!/usr/bin/perl

use Test::More tests => 2;
use Debian::LicenseReconcile::Filter;
use Test::Exception;

my $f = Debian::LicenseReconcile::Filter->new;
isa_ok($f, 'Debian::LicenseReconcile::Filter');

throws_ok { $f->get_info } qr/not implemented in base class/;
