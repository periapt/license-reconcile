package Debian::LicenseReconcile::Errors;

use 5.006;
use strict;
use warnings;

my @errors = ();

sub push {
    shift; # class method;
    my %info = @_;
    push @errors, \%info;
    return;
}

sub how_many {
    shift; # class method;
    return scalar @errors;
}

sub list {
    shift; # class method;
    return @errors;
}

=head1 NAME

Debian::LicenseReconcile::Errors - list of license reconciliation errors

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

    use Debian::LicenseReconcile::Errors;

    Debian::LicenseReconcile::Errors->push(short=>'Format',long=>.....);

    foreach my $error (Debian::LicenseReconcile::Errors->list) {
        print Dump($error);
    }

    exit(Debian::LicenseReconcile::Errors->how_many());

=head1 DESCRIPTION

This module represents somewhere to store errors so that they can 
be displayed later. 

=head1 SUBROUTINES/METHODS

=head2 push

This method takes a set of key value pairs, and pushes them onto the 
list of errors.

=head2 how_many

=head2 list

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
