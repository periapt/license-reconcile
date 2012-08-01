package Debian::LicenseReconcile::FormatSpec;

use 5.006;
use strict;
use warnings;
use Debian::LicenseReconcile::Errors;
use Readonly;

Readonly my %PERMITTED_FORMATS => (
    'Format: http://www.debian.org/doc/packaging-manuals/copyright-format/1.0/'=>1,
);

Readonly my $NL => "\n";

=head1 NAME

Debian::LicenseReconcile::FormatSpec - check format is recognized

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

    use Debian::LicenseReconcile::FormatSpec;

    my $check = Debian::LicenseReconcile::FormatSpec->check($copyright);

=head1 SUBROUTINES/METHODS

=head2 check

This class method takes the copyright data as input and returns a boolean
indicating whether it has a permitted format. It also records the error
in the L<Debian::LicenseReconcile::Errors> system.

=cut

sub check {
    my $class = shift;
    my $copyright = shift;
    my @lines = split $NL, $copyright;

    if (scalar @lines == 0) {
        Debian::LicenseReconcile::Errors->push(
            test => __PACKAGE__,
            msg => 'copyright data is empty',
        );
        return 0;
    }

    return 1 if exists $PERMITTED_FORMATS{$lines[0]};

    Debian::LicenseReconcile::Errors->push(
        test => __PACKAGE__,
        msg => "Cannot recognize format: $lines[0]",
    );
    return 1;
}

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
