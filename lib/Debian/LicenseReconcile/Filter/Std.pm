package Debian::LicenseReconcile::Filter::Std;

use 5.006;
use strict;
use warnings;
use base qw(Debian::LicenseReconcile::Filter);
use Readonly;

sub get_info {
    my $self = shift;
    return map { $_->{test} = $self->name; $_ } $self->licensecheck->get_info;
}

=head1 NAME

Debian::LicenseReconcile::Filter::Std - applies licensecheck to get data

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

    use Debian::LicenseReconcile::Filter::Std;

    my $filter = Debian::LicenseReconcile::Filter::Std->new(
        directory=>'.',
        licensecheck=>$LICENSECHECK,
    );
    my @info = $filter->get_info();

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
