package Debian::LicenseReconcile::CopyrightDatum::Holder;

use 5.006;
use strict;
use warnings;
use Text::LevenshteinXS qw(distance);
use Class::XSAccessor
    setters=>{
        _set_width=>'width',
    },
    getters=>{
        ours=>'ours',
        theirs=>'theirs',
        width=>'width',
    };

sub new {
    my $class = shift;
    my $self = bless { @_ }, ref($class)||$class;
    $self->_set_width(distance($self->theirs, $self->ours));
    return $self;
}

use overload '<=>' => \&_my_cmp;

sub _my_cmp {
    my $a = shift;
    my $b = shift;
    return $a->width <=> $b->width;
}

=head1 NAME

Debian::LicenseReconcile::CopyrightDatum::Holder - encapsulate pair

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

    use Debian::LicenseReconcile::CopyrightDatum::Holder;

    my $holder = Debian::LicenseReconcile::CopyrightDatum::Holder->new(
        theirs=>'AA',
        ours=>'BA',
    );
    if ($holder > $holder2) {
        ...
    }

=head1 DESCRIPTION

We want to be able to quickly find the two texts that are closest to each other.
So these objects have C<ours>, C<theirs> and C<width> fields.
The comparison just compares by the distance field.

=head1 SUBROUTINES/METHODS

=head1 AUTHOR

Nicholas Bamber, C<< <nicholas at periapt.co.uk> >>

=head1 LICENSE AND COPYRIGHT

Copyright 2012 Nicholas Bamber.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of Debian::LicenseReconcile
