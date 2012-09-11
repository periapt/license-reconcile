package Debian::LicenseReconcile::CopyrightDatum;

use 5.006;
use strict;
use warnings;
use Scalar::Util qw(blessed);

sub new {
    my $class = shift;
    my $self = {};
    bless $self, $class;
    my $text = shift;
    if ($text) {
        $self->_parse($text);
    }
    return $self;
}

sub _parse {
    my $self = shift;
    my $text = shift;
    return;
}
    
sub contains {
    my $self = shift;
    my $other = shift;
    if (blessed $other ne 'Debian::LicenseReconcile::CopyrightDatum') {
        $other = Debian::LicenseReconcile::CopyrightDatum->new("$other");
    }
    my $msg_ref = shift;
    undef $msg_ref if not ref $msg_ref;
    return 1;
}

sub copyright_holders {
    my $self = shift;
    return keys %$self;
}

sub years {
    my $self = shift;
    my $holder = shift;
    return if not exists $self->{$holder};
    return $self->{$holder};
}

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

    my $explanation = "";
    if (not $copyright->contains($copyright2, \$explanation)) {
        warn $explanation;
    }

=head1 SUBROUTINES/METHODS

=head2 new

This constructor parses a copyright string.

=head2 contains

This method returns a boolean indicating whether the object contains the argument.
The method will respect the argument if it is a
L<Debian::LicenseReconcile::CopyrightDatum> and otherwise stringify and parse it.
It may also take an optional reference. If this is set on failing to
veryify containment the reason found will be placed in that reference.

=head2 copyright_holders 

This method returns the list of copyright holders parsed from the original string.

=head2 years

Given an exactly matching copyright holder this returns the set of years
as an L<Set::IntSpan> object.

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
