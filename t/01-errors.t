#!/usr/bin/perl

use Test::More tests => 20;
use Debian::LicenseReconcile::Errors;

for(my $i = 0; $i < 10; $i++) {
    is(Debian::LicenseReconcile::Errors->how_many,$i,'how many');
    my $digest = join '', (map { $_->{text} } Debian::LicenseReconcile::Errors->list);
    is($digest, 'x' x $i, 'digest');
    Debian::LicenseReconcile::Errors->push(text=>'x');
}
