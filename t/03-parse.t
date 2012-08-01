#!/usr/bin/perl

use Test::More tests => 5;
use Test::Deep;
use Debian::LicenseReconcile::Errors;
use Debian::LicenseReconcile::CopyrightTarget;
#use File::Slurp;

is(Debian::LicenseReconcile::Errors->how_many,0,'how many');
my @list = Debian::LicenseReconcile::Errors->list;
cmp_deeply(\@list, [], 'initial state');

my $copyright = Debian::LicenseReconcile::CopyrightTarget->new("Blah: hello\n");
is($copyright, undef, 'failed parse');

is(Debian::LicenseReconcile::Errors->how_many,1,'how many');
@list = Debian::LicenseReconcile::Errors->list;
cmp_deeply(\@list, [
    {
        test=>'CopyrightParsing',
        msg=>"Got copyright stanza with unrecognised field\n",
    },
], 'bad copyright');
