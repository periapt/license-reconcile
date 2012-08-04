#!/usr/bin/perl

use Test::More tests => 6;
use Test::Deep;
use Debian::LicenseReconcile::Errors;
use Debian::LicenseReconcile::CopyrightTarget;

is(Debian::LicenseReconcile::Errors->how_many,0,'how many');
my @list = Debian::LicenseReconcile::Errors->list;
cmp_deeply(\@list, [], 'initial state');

my $copyright = Debian::LicenseReconcile::CopyrightTarget->new;
isa_ok($copyright, 'Debian::LicenseReconcile::CopyrightTarget');
is($copyright->parse("Blah: hello\n"), undef, 'failed parse');

is(Debian::LicenseReconcile::Errors->how_many,1,'how many');
@list = Debian::LicenseReconcile::Errors->list;
cmp_deeply(\@list, [
    {
        test=>'CopyrightParsing',
        msg=>"Got copyright stanza with unrecognised field\n",
    },
], 'bad copyright');
