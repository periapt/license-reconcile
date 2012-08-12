#!/usr/bin/perl

use Test::More tests => 6;
use Debian::LicenseReconcile::Utils;

is(specificity('*'), 0);
is(specificity('?'), 0);
is(specificity('\*'), 1);
is(specificity('a'), 1);
is(specificity('a*'), 1/2);
is(specificity('a/*'), 2/3);

