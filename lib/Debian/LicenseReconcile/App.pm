package Debian::LicenseReconcile::App;

use 5.006;
use strict;
use warnings;
use Class::XSAccessor
    constructor => 'new',
    getters => {
        quiet => 'quiet',
        display_mapping => 'display_mapping',
        changelog_file => 'changelog_file',
        config_file => 'config_file',
        copyright => 'copyright',
        directory =>'directory',
        filters_override => 'filters_override',
        format_spec => 'format_spec',
    },
;

=head1 NAME

Debian::LicenseReconcile::App - encapsulate the application code

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

    use Debian::LicenseReconcile::App;

    my $app = Debian::LicenseReconcile::App->new(...);
    exit($app->run);

=head1 SUBROUTINES/METHODS

=head2 new

This constructor takes key value pairs and returns the correspondingly blessed
object.

=head2 run

=head2 quiet

=head2 display_mapping

=head2 changelog_file

=head2 config_file

=head2 copyright

=head2 directory

=head2 filters_override

=head2 format_spec

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
