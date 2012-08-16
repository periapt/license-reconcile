package Debian::LicenseReconcile::Filter;

use 5.006;
use strict;
use warnings;

sub new {
    my $class = shift;
    my %self = @_;
    bless \%self, $class;
    return \%self;
}

sub get_info {
    my $self = shift;
    die "not implemented in base class";
}

=head1 NAME

Debian::LicenseReconcile::Filter - abstract interface to license info

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

    use Debian::LicenseReconcile::Filter;

    my $filter = Debian::LicenseReconcile::Filter->new(arg1=>"blah",...);
    my @info = $filter->get_info(@files);

=head1 SUBROUTINES/METHODS

=head2 new

This constructor takes key value pairs and returns the correspondingly blessed
object.

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
