package Debian::LicenseReconcile::CopyrightTarget;

use 5.006;
use strict;
use warnings;
use Debian::LicenseReconcile::Errors;
use Debian::Copyright;
use Readonly;
use Cwd;
use File::Glob qw(:glob);
use Debian::LicenseReconcile::Utils qw(get_files);
use File::FnMatch qw(:fnmatch);

Readonly my $SPACE => qr{\s+}xms;

sub new {
    my $class = shift;
    my $self = {};
    bless $self, $class;
    return $self;
}

sub parse {
    my $self = shift;
    my $copyright = shift;
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
    $self->{files} = $parser->files;
    return $self;
}

sub map_directory {
    my $self = shift;
    my $directory = shift;
    my @files = get_files($directory);
    my $file_mapping = {};

    # For each Files clause try to find candidate matches.
    foreach my $pattern ($self->{files}->Keys) {
        my @patterns = split $SPACE, $pattern;
        foreach my $p (@patterns) {
            foreach my $file (grep { fnmatch($p, $_) } @files) {
                my $index = $self->{files}->Indices($pattern);
                $file_mapping->{$file} = {
                    pattern=>$p,
                    copyright=>$self->{files}->Values($index)->Copyright,
                    license=>$self->{files}->Values($index)->License,
                };
            }
        }
    }

    return $file_mapping;
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

This constructor returns an empty tree object. Optionally it takes a
hash reference node value as an argument. Each node value must
have a C<file> member representing a file glob at one level in the file system
hierarchy. If the node actually corresponds to a Files clause, then it
should also have C<license> and C<copyright> fields.

=head2 parse

This takes as an argument the copyright data. If the copyright data cannot
be parsed by L<Debian::Copyright> then the method returns undef. If
successfully parsed the L<Debian::Copyright::Stanza::Files> data is
transformed into a tree representation as described under the constructor.

=head2 map_directory

Takes a directory path and attempts to map the contents of that directory
onto the copyright specification. It returns a hash reference containing that
mapping.

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
