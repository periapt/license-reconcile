#!/usr/bin/perl

use Test::More tests => 3;
use Test::Deep;
use Debian::LicenseReconcile::Utils qw(get_files);
use Debian::LicenseReconcile::Filter::Rules;
use Readonly;

Readonly my $DIR => 't/data/example';

my @files = get_files($DIR);

my $filter = Debian::LicenseReconcile::Filter::Rules->new(
    directory=>$DIR,
    name=>'Rules4',
    config=>{
        rules=>[
            {
                Glob=>'*b*',
                Contains=><<'EOS',
/* Copyright (c) 2012, Periapt Technologies. All rights reserved.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; version 2 of the License.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301  USA */
EOS
                License=>'GPL-1',
                Copyright=>'[Copyright: 2012, Periapt Technologies. All rights reserved]',
            },
        ],
    },
    files_remaining=>\@files,
);
isa_ok($filter, 'Debian::LicenseReconcile::Filter');
isa_ok($filter, 'Debian::LicenseReconcile::Filter::Rules');

my @data = $filter->get_info;
cmp_deeply(\@data, [{
    file=>'base',
    license=>'GPL-1',
    test=>'Rules4',
    copyright=>'[Copyright: 2012, Periapt Technologies. All rights reserved]',
}]);
