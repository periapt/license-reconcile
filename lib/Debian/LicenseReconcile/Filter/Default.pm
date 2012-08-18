package Debian::LicenseReconcile::Filter::Default;

use 5.006;
use strict;
use warnings;
use base qw(Debian::LicenseReconcile::Filter);
use Debian::LicenseReconcile::Errors;
use Readonly;
use System::Command;

Readonly my @SCRIPT => ('/usr/bin/licensecheck', '--copyright', '--recursive');

sub get_info {
    my $self = shift;
    my ( $pid, $in, $out, $err ) = System::Command->spawn(@SCRIPT, $self->{directory});
    my @msg = <$err>;
    if (@msg) {
        Debian::LicenseReconcile::Errors->push(
            test => 'Default',
            msg => "@msg",
        );
    }
    my @out = <$out>;
    return [];
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
