package TestData;
use strict;
use warnings;
use base qw(Exporter);
use Readonly;

our @EXPORT = qw(
    $COPYRIGHT_DATA
    $COPYRIGHT_DATA2
    $COPYRIGHT_DATA2u
    $COPYRIGHT_DATA3
    $COPYRIGHT_DATA4
    $COPYRIGHT_DATA5
);

Readonly our $COPYRIGHT_DATA => {
    copyright=>'
 2010-2011, Nicholas Bamber <nicholas@periapt.co.uk>',
    license=>'Artistic or GPL-2+',
    pattern=>'*',
};
Readonly our $COPYRIGHT_DATA2 => {
    copyright=>'
 2011, Nicholas Bamber <nicholas@periapt.co.uk>
 2008, Joe Bloggs <joeblogs@example.org>',
    license=>'GPL-3+',
    pattern=>'a/*.h',
};
Readonly our $COPYRIGHT_DATA2u => {
    copyright=>'
 2011, Nicholas Bamber <nicholas@periapt.co.uk>
 2008, Joe Bloggs <joeblogs@example.org>',
    license=>'GPL-3+',
    pattern=>'a/g/*',
};
Readonly our $COPYRIGHT_DATA3 => {
    copyright=>'
 2008-2010, gregor hermann <gregoa@debian.org>
 2010-2011, Nicholas Bamber <nicholas@periapt.co.uk>',
    license=>'Artistic or GPL-2+',
    pattern=>'debian/*',
};
Readonly our $COPYRIGHT_DATA4 => {
    copyright=>'
 2011, Nicholas Bamber <nicholas@periapt.co.uk>
 2009, Damyan Ivanov <dmn@debian.org>',
    license=>'GPL-1+',
    pattern=>'a/*.g',
};
Readonly our $COPYRIGHT_DATA5 => {
    copyright=>$COPYRIGHT_DATA4->{copyright},
    license=>$COPYRIGHT_DATA4->{license},
    pattern=>'a/g/*.t',
};
1
