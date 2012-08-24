package Debian::LicenseReconcile::Filter::Rules;

use 5.006;
use strict;
use warnings;
use base qw(Debian::LicenseReconcile::Filter);
use Debian::LicenseReconcile::Errors;
use Readonly;
use System::Command;
use File::Slurp;

Readonly my %LICENSE_MAPPING => (
    'GPL-2' => 'GPL-2',
    'GPL (v2)' => 'GPL-2',
    'GPL (v2 or later)' => 'GPL-2+',
    'LGPL (v2)' => 'LGPL',
    'zlib/libpng' => 'zlib/libpng',
);

Readonly my @SCRIPT => ('/usr/bin/licensecheck', '--no-conf', '--copyright', '--recursive');

Readonly my $PARSE_RE => qr{
    ^                           # beginning of line
    ([^\n:]+)                   # file name
    :\s+                        # separator
    ([^\n]+)                    # license
    \s*                         # just in case
    $                           # end of line
    \s*                         # just in case
    ([^\n]+)                    # copyright notice
    \s*                         # just in case
    $                           # end of line
    \s*                         # just in case
}xms;

Readonly my $TEST_NAME => 'Rules';

sub get_info {
    my $self = shift;
    my ( $pid, $in, $out, $err ) = System::Command->spawn(@SCRIPT, $self->{directory});
    close $in;
    my $output = read_file $out;
    my @results;
    while ($output =~ /$PARSE_RE/g) {
        my $file = substr($1, 1+length $self->{directory});
        my $license = $self->_cleanup_license($2);
        next if not $license;
        my $copyright = $3;
        push @results, {
            file => $file,
            license => $license,
            copyright => $copyright,
            test => $TEST_NAME,
        };
    }
    return @results;
}

sub _cleanup_license {
    my $self = shift;
    my $license = shift;
    $license =~ s{\*No\s+copyright\*}{}xms;
    $license =~ s{GENERATED\s+FILE}{}xms;
    $license =~ s{^\s+}{}xms;
    $license =~ s{\s+$}{}xms;
    $license =~ s{\s+\(with\s+incorrect\s+FSF\s+address\)}{}xms;
    return $LICENSE_MAPPING{$license} if exists $LICENSE_MAPPING{$license};
    return if $license eq 'UNKNOWN';
    return $license;
}

=head1 NAME

Debian::LicenseReconcile::Filter::Rules - applies licensecheck to get data

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

    use Debian::LicenseReconcile::Filter::Rules;

    my $filter = Debian::LicenseReconcile::Filter::Rules->new(directory=>'.');
    my @info = $filter->get_info(@files);

=head1 SUBROUTINES/METHODS

=head2 get_info

Returns a list of hash references describing copyright and license information
that should be checked against the copyright target. The results returned
from this filter are those that are obtained from
C<licensecheck --no-conf --recursive --copyright DIR>.

=head1 AUTHOR

Nicholas Bamber, C<< <nicholas at periapt.co.uk> >>

=head1 LICENSE AND COPYRIGHT

Copyright 2012 Nicholas Bamber.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of Debian::LicenseReconcile::FormatSpec
