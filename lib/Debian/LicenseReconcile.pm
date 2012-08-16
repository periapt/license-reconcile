package Debian::LicenseReconcile;

use 5.006;
use strict;
use warnings;

sub new {
    my $class = shift;
    my $self = {};
    bless $self, $class;
    return $self;
}

sub check {
}

=head1 NAME

Debian::LicenseReconcile - compare actual and required copyright and license

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

    use Debian::LicenseReconcile;

    my $reconcile = Debian::LicenseReconcile->new();
    $reconcile->check($actual, $required);

=head1 SUBROUTINES/METHODS

=head2 new

=head2 check

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
