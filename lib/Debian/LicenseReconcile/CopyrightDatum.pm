package Debian::LicenseReconcile::CopyrightDatum;

use 5.006;
use strict;
use warnings;

sub new {
    my $class = shift;
    my $self = {};
    bless $self, $class;
    return $self;
}

sub contains {return 1}
sub copyright_holders {}

=head1 NAME

Debian::LicenseReconcile::CopyrightDatum - copyright data as an object

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 DESCRIPTION

This module conceives of copyright data as a mapping from strings
(the individual copyright holders) to sets of years.

Copyright data can be compared. Datum C<A> is contained in Datum C<B>
if for every key C<k> in C<A>, C<A{k}> is contained in C<B{l}>, where C<l> is the
key in C<B> that most closely matches C<k>. When matching strings they
are paired off in a 1-1 manner.

=head1 SYNOPSIS

    use Debian::LicenseReconcile::CopyrightDatum;

    my $copyright = Debian::LicenseReconcile::CopyrightDatum->new($text);

    if ($copyright->contains($copyright2)) {
        ...
    }

=head1 SUBROUTINES/METHODS

=head2 new

This constructor parses a copyright string.

=head2 contains

This method returns a boolean indicating whether the object contains the argument.
The method will respect the argument if it is a
L<Debian::LicenseReconcile::CopyrightDatum> and otherwise stringify and parse it.

=head2 copyright_holders 

This method returns the list of copyright holders parsed from the original string.

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
