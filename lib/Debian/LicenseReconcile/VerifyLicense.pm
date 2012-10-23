package Debian::LicenseReconcile::VerifyLicense;

use 5.006;
use strict;
use warnings;
use Readonly;
use base qw(Exporter);

our @EXPORT = qw(verify_license);

Readonly my %LICENSES => (
    'GPL (v2)' => [
        qr{version 2[.,]? (?:\(?only\)?.? )?(?:of the GNU General Public License )?(as )?published by the Free Software Foundation}i,
        qr{GNU General Public License (?:as )?published by the Free Software Foundation; version 2[.,]? }i,
    ],
);


#    if ($licensetext =~ /version ([^, ]+?)[.,]? (?:\(?only\)?.? )?(?:of the GNU (Affero )?(Lesser |Library )?General Public License )?(as )?published by the Free Software Foundation/i or
#	$licensetext =~ /GNU (?:Affero )?(?:Lesser |Library )?General Public License (?:as )?published by the Free Software Foundation; version ([^, ]+?)[.,]? /i) {
#
#	$gplver = " (v$1)";
#    } elsif ($licensetext =~ /GNU (?:Affero )?(?:Lesser |Library )?General Public License, version (\d+(?:\.\d+)?)[ \.]/) {
#	$gplver = " (v$1)";
#    } elsif ($licensetext =~ /either version ([^ ]+)(?: of the License)?, or \(at your option\) any later version/) {
#	$gplver = " (v$1 or later)";
#    }
#
#    if ($licensetext =~ /(?:675 Mass Ave|59 Temple Place|51 Franklin Steet|02139|02111-1307)/i) {
#	$extrainfo = " (with incorrect FSF address)$extrainfo";
#    }
#
#    if ($licensetext =~ /permission (?:is (also granted|given))? to link (the code of )?this program with (any edition of )?(Qt|the Qt library)/i) {
#	$extrainfo = " (with Qt exception)$extrainfo"
#    }
#
#    if ($licensetext =~ /(All changes made in this file will be lost|DO NOT (EDIT|delete this file)|Generated (automatically|by|from)|generated.*file)/i) {
#	$license = "GENERATED FILE";
#    }
#
#    if ($licensetext =~ /is (free software.? you can redistribute it and\/or modify it|licensed) under the terms of (version [^ ]+ of )?the (GNU (Library |Lesser )General Public License|LGPL)/i) {
#	$license = "LGPL$gplver$extrainfo $license";
#    }
#
#    if ($licensetext =~ /is free software.? you can redistribute it and\/or modify it under the terms of the (GNU Affero General Public License|AGPL)/i) {
#	$license = "AGPL$gplver$extrainfo $license";
#    }
#
#    if ($licensetext =~ /is free software.? you (can|may) redistribute it and\/or modify it under the terms of (?:version [^ ]+ (?:\(?only\)? )?of )?the GNU General Public License/i) {
#	$license = "GPL$gplver$extrainfo $license";
#    }
#
#    if ($licensetext =~ /is distributed under the terms of the GNU General Public License,/
#	and length $gplver) {
#	$license = "GPL$gplver$extrainfo $license";
#    }
#
#    if ($licensetext =~ /is distributed.*terms.*GPL/) {
#	$license = "GPL (unversioned/unknown version) $license";
#    }
#
#    if ($licensetext =~ /This file is part of the .*Qt GUI Toolkit. This file may be distributed under the terms of the Q Public License as defined/) {
#	$license = "QPL (part of Qt) $license";
#    } elsif ($licensetext =~ /may be distributed under the terms of the Q Public License as defined/) {
#	$license = "QPL $license";
#    }
#
#    if ($licensetext =~ /opensource\.org\/licenses\/mit-license\.php/) {
#	$license = "MIT/X11 (BSD like) $license";
#    } elsif ($licensetext =~ /Permission is hereby granted, free of charge, to any person obtaining a copy of this software and(\/or)? associated documentation files \(the (Software|Materials)\), to deal in the (Software|Materials)/) {
#	$license = "MIT/X11 (BSD like) $license";
#    } elsif ($licensetext =~ /Permission is hereby granted, without written agreement and without license or royalty fees, to use, copy, modify, and distribute this software and its documentation for any purpose/) {
#	$license = "MIT/X11 (BSD like) $license";
#    }
#
#    if ($licensetext  =~ /Permission to use, copy, modify, and(\/or)? distribute this software for any purpose with or without fee is hereby granted, provided.*copyright notice.*permission notice.*all copies/) {
#	$license = "ISC $license";
#    }
#
#    if ($licensetext =~ /THIS SOFTWARE IS PROVIDED .*AS IS AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY/) {
#	if ($licensetext =~ /All advertising materials mentioning features or use of this software must display the following acknowledge?ment.*This product includes software developed by/i) {
#	    $license = "BSD (4 clause) $license";
#	} elsif ($licensetext =~ /(The name .*? may not|Neither the names? .*? nor the names of (its|their) contributors may) be used to endorse or promote products derived from this software/i) {
#	    $license = "BSD (3 clause) $license";
#	} elsif ($licensetext =~ /Redistributions of source code must retain the above copyright notice/i) {
#	    $license = "BSD (2 clause) $license";
#	} else {
#	    $license = "BSD $license";
#	}
#    }
#
#    if ($licensetext =~ /Mozilla Public License Version ([^ ]+)/) {
#	$license = "MPL (v$1) $license";
#    }
#
#    if ($licensetext =~ /Released under the terms of the Artistic License ([^ ]+)/) {
#	$license = "Artistic (v$1) $license";
#    }
#
#    if ($licensetext =~ /is free software under the Artistic [Ll]icense/) {
#	$license = "Artistic $license";
#    }
#
#    if ($licensetext =~ /This program is free software; you can redistribute it and\/or modify it under the same terms as Perl itself/) {
#	$license = "Perl $license";
#    }
#
#    if ($licensetext =~ /under the Apache License, Version ([^ ]+)/) {
#	$license = "Apache (v$1) $license";
#    }
#
#    if ($licensetext =~ /(THE BEER-WARE LICENSE)/i) {
#	$license = "Beerware $license";
#    }
#
#    if ($licensetext =~ /This source file is subject to version ([^ ]+) of the PHP license/) {
#	$license = "PHP (v$1) $license";
#    }
#
#    if ($licensetext =~ /under the terms of the CeCILL /) {
#	$license = "CeCILL $license";
#    }
#
#    if ($licensetext =~ /under the terms of the CeCILL-([^ ]+) /) {
#	$license = "CeCILL-$1 $license";
#    }
#
#    if ($licensetext =~ /under the SGI Free Software License B/) {
#	$license = "SGI Free Software License B $license";
#    }
#
#    if ($licensetext =~ /is in the public domain/i) {
#	$license = "Public domain $license";
#    }
#
#    if ($licensetext =~ /terms of the Common Development and Distribution License(, Version ([^(]+))? \(the License\)/) {
#	$license = "CDDL " . ($1 ? "(v$2) " : '') . $license;
#    }
#
#    if ($licensetext =~ /Microsoft Permissive License \(Ms-PL\)/) {
#        $license = "Ms-PL $license";
#    }
#
#    if ($licensetext =~ /Permission is hereby granted, free of charge, to any person or organization obtaining a copy of the software and accompanying documentation covered by this license \(the \"Software\"\)/ or
#	$licensetext =~ /Boost Software License([ ,-]+Version ([^ ]+)?(\.))/i) {
#	$license = "BSL " . ($1 ? "(v$2) " : '') . $license;
#    }
#
#    if ($licensetext =~ /PYTHON SOFTWARE FOUNDATION LICENSE (VERSION ([^ ]+))/i) {
#	$license = "PSF " . ($1 ? "(v$2) " : '') . $license;
#    }
#
#    if ($licensetext =~ /The origin of this software must not be misrepresented.*Altered source versions must be plainly marked as such.*This notice may not be removed or altered from any source distribution/ or
#        $licensetext =~ /see copyright notice in zlib\.h/) {
#	$license = "zlib/libpng $license";
#    } elsif ($licensetext =~ /This code is released under the libpng license/) {
#        $license = "libpng $license";
#    }
#
#    if ($licensetext =~ /Do What The Fuck You Want To Public License, Version ([^, ]+)/i) {
#        $license = "WTFPL (v$1) $license";
#    }
#
#    if ($licensetext =~ /Do what The Fuck You Want To Public License/i) {
#        $license = "WTFPL $license";
#    }
#
#    if ($licensetext =~ /(License WTFPL|Under (the|a) WTFPL)/i) {
#        $license = "WTFPL $license";
#    }

sub verify_license {
    my $self = shift;
    my $license = shift;
    my $text = shift;
    next 0 if not exists $LICENSES{$license};
    foreach my $re (@{$LICENSES{$license}}) {
        return 1 if $text =~ $re;
    }
    return 0;
}

=head1 NAME

Debian::LicenseReconcile::VerifyLicense - proactively verify license

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

    use Debian::LicenseReconcile::VerifyLicense;

    if ($self->verify_license('GPL-2', $contents)) {
        ...
    }

=head1 DESCRIPTION

This module is designed to provide a way of matching files against
specfic license texts. It offers more granularity than 
L<Debian::LicenseReconcile::LicenseReconcile>.

=head1 SUBROUTINES/METHODS

=head2 verify_license

This method takes a license tag and a text string as arguments.
It returns true if the license is recognized and the text matches
the license and false otherwise.

=head1 AUTHOR

Nicholas Bamber, C<< <nicholas at periapt.co.uk> >>

=head1 LICENSE AND COPYRIGHT

Copyright 2012 Nicholas Bamber.

Some regular expressions were borrowed from /usr/bin/licensecheck.

Copyright 2007, 2008 Adam D. Barratt
Copyright 2012 Francesco Poli

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of Debian::LicenseReconcile::FormatSpec
