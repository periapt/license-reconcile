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
    $DLR_ERROR1
    $DLR_ERROR2
    $DLR_ERROR3
    $DLR_ERROR4
    $DLR_ERROR5
    $DLR_ERROR6
    $DLR_ERROR7
    $DLR_ERROR8
    $DLR_ERROR9
    $DLR_ERROR10
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
Readonly our $DLR_ERROR1 => {
    test=>'FormatSpec',
    msg=>'Cannot recognize format: Format: http://www.debian.org/doc/packaging-manuals/copyright-format/1.O/',
};
Readonly our $DLR_ERROR2 => {
    test=>'CopyrightParsing',
    msg=>'Invalid field given (Flossy) at /usr/local/share/perl/5.14.2/Debian/Copyright.pm line 141
',
};
Readonly our $DLR_ERROR3 => {
    test=>'License mismatch',
    msg=>'File base.h has license GPL-2 which does not match Artistic or GPL-2+.',
};
Readonly our $DLR_ERROR4 => {
    test=>'Copyright mismatch',
    msg=>"File base.h: Trying to match 'Copyright: 2011, Periapt Technologies. All rights reserved' against 'Nicholas Bamber <nicholas\@periapt.co.uk>' but it does not look like a good match.",
};
Readonly our $DLR_ERROR5 => {
    test=>'License mismatch',
    msg=>'File debian/control has license GPL-2+ which does not match Artistic or GPL-2+.',
};
Readonly our $DLR_ERROR6 => {
    test=>'Copyright mismatch',
    msg=>"File debian/control: Trying to match 'Christian Schwarz <schwarz\@debian.org>' against 'Nicholas Bamber <nicholas\@periapt.co.uk>' but it does not look like a good match.",
};
Readonly our $DLR_ERROR7 => {
    test=>'License mismatch',
    msg=>"File debian/copyright has license GPL-2+ which does not match Artistic or GPL-2+.",
};
Readonly our $DLR_ERROR8 => {
    test=>'Copyright mismatch',
    msg=>"File debian/copyright: Trying to match 'Christian Schwarz <schwarz\@debian.org>' against 'Nicholas Bamber <nicholas\@periapt.co.uk>' but it does not look like a good match.",
};
Readonly our $DLR_ERROR9 => {
    test=>'License mismatch',
    msg=>"File debian/changelog has license GPL-2+ which does not match Artistic or GPL-2+.",
};
Readonly our $DLR_ERROR10 => {
    test=>'Copyright mismatch',
    msg=>"File debian/changelog: Trying to match 'Christian Schwarz <schwarz\@debian.org>' against 'Nicholas Bamber <nicholas\@periapt.co.uk>' but it does not look like a good match.",
};
1
