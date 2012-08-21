package Debian::LicenseReconcile::Filter::Default;

use 5.006;
use strict;
use warnings;
use base qw(Debian::LicenseReconcile::Filter);
use Debian::LicenseReconcile::Errors;
use Readonly;
use System::Command;
use File::Slurp;

Readonly my @SCRIPT => ('/usr/bin/licensecheck', '--copyright', '--recursive');

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

Readonly my $TEST_NAME => 'Default';

sub get_info {
    my $self = shift;
    my ( $pid, $in, $out, $err ) = System::Command->spawn(@SCRIPT, $self->{directory});
    close $in;
    my $output = read_file $out;
    my @results;
    while ($output =~ /$PARSE_RE/gc) {
        my $file = substr($1, 1+length $self->{directory});
        my $license = $2;
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

=head1 NAME

Debian::LicenseReconcile::Filter::Default - applies licensecheck to get data

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

    use Debian::LicenseReconcile::Filter::Default;

    my $filter = Debian::LicenseReconcile::Filter::Default->new(directory=>'.');
    my @info = $filter->get_info(@files);

=head1 SUBROUTINES/METHODS

=head2 get_info

Returns a list of hash references describing copyright and license information
that should be checked against the copyright target.

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
