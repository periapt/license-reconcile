package Debian::LicenseReconcile;

use 5.006;
use strict;
use warnings;
use Debian::LicenseReconcile::Errors;

sub new {
    my $class = shift;
    my $self = {};
    bless $self, $class;
    return $self;
}

sub check {
    my $self = shift;
    my $subject = shift;
    my $target = shift;
    my $license = $subject->{license};

    if ($license) {
        my $target_license = $target->{license};
        $target_license =~ s{\n.*\z}{}xms;
        if ($license ne $target_license) {
            my $msg = "File $subject->{file} has license $license which does not match $target_license.";
            Debian::LicenseReconcile::Errors->push(
                test => 'License mismatch',
                msg => $msg,
            );
        }
    }
    return;
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
