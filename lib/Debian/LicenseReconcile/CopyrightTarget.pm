package Debian::LicenseReconcile::CopyrightTarget;

use 5.006;
use strict;
use warnings;
use Debian::LicenseReconcile::Errors;
use Debian::Copyright;

sub new {
    my $class = shift;
    my $copyright = shift;

    my $self = {};
    bless $self, $class;

    my $parser = Debian::Copyright->new($copyright);
    eval {
        $parser->read(\$copyright);
    };
    if ($@) {
        my $msg = $@;
        Debian::LicenseReconcile::Errors->push(
            test => 'CopyrightParsing',
            msg => $msg,
        );
        return;
    }
    
    for(my $i=0; $i<$parser->files->Length; $i++) {
        my $stanza = $parser->files->Values($i);
        my $key = $stanza->Files;
        foreach my $pattern (split qr/\s+/, $key) {
            $self->{$pattern} = $stanza;
        }
    }

    return $self;
}

sub get {
    my $self = shift;
    my $key = shift;
    return $self->{$key};
}

sub keys {
    my $self = shift;
    return keys %$self;
}


=head1 NAME

Debian::LicenseReconcile::CopyrightTarget - file patterns mapped to Debian copyright

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

    use Debian::LicenseReconcile::CopyrightTarget;

    my $tree = Debian::LicenseReconcile::CopyrightTarget->new($copyright);

=head1 SUBROUTINES/METHODS

=head2 new

This constructor returns an object, representing the 
copyright data. If the copyright data cannot be parsed by L<Debian::Copyright>
then the constructor returns undef. If successfully parsed the data is
a mapping from each space-separated part of the C<Files> clauses to the
L<Debian::Copyright::Stanza::Files> objects.

=head2 get

Given a file pattern returns the corresponding object if available
and otherwise undef.

=head2 keys

Returns a list of file patterns.

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
