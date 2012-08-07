package Debian::LicenseReconcile::CopyrightTarget;

use 5.006;
use strict;
use warnings;
use Debian::LicenseReconcile::Errors;
use Debian::Copyright;
use base qw(Tree::Simple);
use Readonly;

Readonly my $FS_SEPARATOR => '/';
Readonly my $NL => "\n";

sub new {
    my $class = shift;
    my $nodeValue = shift;

    my $self = Tree::Simple->new;
    if ($nodeValue) {
        $self->setNodeValue($nodeValue);
    }
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
    
    for(my $i=0; $i<$parser->files->Length; $i++) {
        my $stanza = $parser->files->Values($i);
        my $key = $stanza->Files;
        foreach my $pattern (split qr/\s+/, $key) {
            $self->_analyzeClause($pattern, $stanza);
        }
    }

    return $self;
}

sub _analyzeClause {
    my $self = shift;
    my $pattern = shift;
    my $stanza = shift;
    my $tree = $self;
    foreach my $file (split $FS_SEPARATOR, $pattern) {
        $tree = $tree->_findOrAddFile($file);
    }
    $tree->getNodeValue->{license} = $stanza->License;
    $tree->getNodeValue->{copyright} = $stanza->Copyright;
}

sub _findOrAddFile {
    my $self = shift;
    my $file = shift;
    foreach my $child ($self->getAllChildren) {
        return $child if $child->getNodeValue->{file} eq $file;
    }
    my $child = Debian::LicenseReconcile::CopyrightTarget->new({file=>$file});
    $self->addChild($child);
    return $child;
}

sub directory {
    my $self = shift;
    my $directory = shift;
    return {};
}

sub display {
    my $self = shift;
    my $result = "";
    my $node = $self->getNodeValue;
    if ($node) {
        $result .= " " x $self->getDepth;
        $result .= "$node->{file}: ";
        if (exists $node->{license}) {
            my @license = split /$NL/, $node->{license};
            $result .= "$license[0], ";
        }
        if (exists $node->{copyright}) {
            my @copyright = split /$NL/, $node->{copyright};
            chomp $copyright[0];
            chomp $copyright[0];
            $result .= "$copyright[0]...\n";
        }
        else {
            $result .= "\n";
        }
    }
    foreach my $child ($self->getAllChildren) {
        $result .= $child->display;
    }
    return $result;
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

=head2 directory

Takes a directory path and attempts to map the contents of that directory
onto the copyright specification. It returns a hash reference containing that
mapping.

=head2 display

Returns a summary representation of the file structure defined by the
copyright data.

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
