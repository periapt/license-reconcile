package Debian::LicenseReconcile::Filter;

use 5.006;
use strict;
use warnings;
use Class::XSAccessor
    constructor => 'new',
    getters => {
        directory => 'directory',
        files_remaining => 'files_remaining',
        changelog => 'changelog',
        config => 'config',
    },
;

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

=head2 directory

Returns the search directory as set in the constructor.

=head2 files_remaining

Returns the files to be checked as set in the constructor.

=head2 changelog

Returns the L<Parse::DebianChangelog> as set in the constructor.

=head2 config

Returns the config data as set in the constructor.

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
