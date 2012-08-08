package Debian::LicenseReconcile::CopyrightTarget;

use 5.006;
use strict;
use warnings;
use Debian::LicenseReconcile::Errors;
use Debian::Copyright;
use base qw(Tree::Simple);
use Readonly;
use Cwd;
use File::Glob qw(:glob);

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

sub map_directory {
    my $self = shift;
    my $directory = shift;
    my $ambiguity_list = {};
    my $file_mapping = {};
    my $cwd = getcwd;
    chdir $directory;
    $self->_recursive_map_directory(
        [{directory=>'./',tree=>$self}],          # queue
        $ambiguity_list,
        $file_mapping, 
    );
    $self->_report_ambiguities($ambiguity_list);
    return $cwd;
    return $file_mapping;
}

sub _recursive_map_directory {
    my $self = shift;
    my $queue = shift;
    my $ambiguity_list = shift;
    my $file_mapping = shift;

    # If the queue is empty then we are done.
    # This is determined by the depth of the file
    # system since each iteration is each going into 
    # a new layer of files.
    return if scalar @{$queue} == 0;

    # This is a mapping from file patterns onto sets of files.
    # Only the basename of the key may contain wild-carding.
    # All filenames are relative to $directory.
    my $local_files = {};

    # An array of pairs (directory, tree). 
    # The directory is relative to $directory.
    # Similarly the 'file' part of the node value of the tree
    # is relative to the directory part.
    # What this represents is the set of paths from $directory
    # that still need to be explored.
    my @new_queue = ();

    # For each child of the tree that has license/copyright info
    # try to find candidate matches.
    # This information ($local_files) becomes hard information
    # such as $file_mapping and $ambiguity_list.
    # For all children of the tree find directory matches.
    foreach my $q (@$queue) {
        $self->_local_glob($q, $local_files, \@new_queue);
    }

    # It is inherent in the DEP-5 spec, for one clause to represent
    # a subset of the other. Granting the subset sole access to
    # the matching files is how regard the core of the DEP-5 spec.
    $self->_reduce_supersets($local_files);

    # Now any overlaps between the sets represent unresolvable
    # ambiguities and must be reported as errors.
    # Meanwhile we can resolve the ambiguity by marking the
    # copyright and license as unknown.
    $self->_find_ambiguities($local_files, $ambiguity_list, $file_mapping);

    # Now $local_files should provide an unambiguous account
    # of the copyright/license status of each file at this level.
    # We just need to harvest it.
    $self->_harvest_mapping($local_files, $file_mapping);

    # down one level
    $self->_recursive_map_directory(
        \@new_queue,
        $ambiguity_list, 
        $file_mapping
    );
    return;
}

sub _local_glob {
    my $self = shift;
    my $old_queue_entry = shift;
    my $local_files = shift;
    my $new_queue = shift;
    my $subdirectory = $old_queue_entry->{directory};
    my $subtree = $old_queue_entry->{tree};
    foreach my $child ($subtree->getAllChildren) {
        my $node = $child->getNodeValue;
        my $pattern = "${subdirectory}$node->{file}";
        my @files = bsd_glob($pattern, GLOB_ERR | GLOB_QUOTE | GLOB_MARK);
        $self->_harvest_directories($new_queue, $child, @files);
        if (exists $node->{copyright}) {
            $self->_harvest_copyright($local_files, $node, @files);
        }
    }
    return;
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

=head2 map_directory

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
