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
use Set::Object;

Readonly my $FS_SEPARATOR => '/';
Readonly my $NL => "\n";
Readonly my $UNKNOWN => 'UNKNOWN';
Readonly my $UNKNOWN_NODE => {
    file => $UNKNOWN,
    pattern => $UNKNOWN,
    license => $UNKNOWN,
    copyright => $UNKNOWN,
};

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
    $tree->getNodeValue->{pattern} = $pattern;
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
    chdir $cwd;
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
    # All filenames are relative to $directory and must match the
    # pattern in the key.
    # $local_files->{$pattern} = {
    #    node=>{
    #           license => $license,
    #           copyright => $copyright,
    #           pattern => $pattern,
    #    },
    #    files => Set::Object->new(file1, file2, .....),
    # }
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
    foreach my $child (_getAllChildrenIncludingGhosts($subtree)) {
        my $node = (ref $child eq 'HASH') ? $child : $child->getNodeValue;
        my $pattern = "${subdirectory}$node->{file}";
        my @files = bsd_glob($pattern, GLOB_ERR | GLOB_QUOTE | GLOB_MARK);
        $self->_harvest_directories($new_queue, $child, $subdirectory, @files);
        if (exists $node->{copyright}) {
            $self->_harvest_copyright($local_files, $node, @files);
        }
    }
    return;
}

# We need to handle the case where a Files clause ends in '*'.
# This means that the same Node details can continue indefinitely
# down the file system hierarchy. 
# So we just represent this with that Node value,
# which happens to be a hash reference.
sub _getAllChildrenIncludingGhosts {
    my $tree = shift;
    return ($tree) if ref $tree eq 'HASH';
    my @children = $tree->getAllChildren;
    my $node = $tree->getNodeValue;
    if ($node and exists $node->{copyright} and $node->{file} =~ m{\*\z}xms) {
        my $ghost = {
            copyright => $node->{copyright},
            license => $node->{license},
            pattern => $node->{pattern},
            # The parent may not have had a straight '*'.
            file => '*',
        };
        push @children, $ghost;
    }
    return @children;
}

sub _harvest_directories {
    my $self = shift;
    my $new_queue = shift;
    my $child = shift;
    my $subdirectory = shift;
    foreach my $file (@_) {
        next if $file !~ m{/$};
        push @$new_queue, {
            directory => $file,
            tree => $child,
        };
    }
    return;
}

sub _harvest_copyright {
    my $self = shift;
    my $local_files = shift;
    my $node = shift;
    foreach my $file (@_) {
        next if $file =~ m{/$};
        if (exists $local_files->{$node->{pattern}}) {
            $local_files->{$node->{pattern}}->{files}->insert($file);
        }
        else {
            $local_files->{$node->{pattern}} = {
                files => Set::Object->new($file),
                node => $node,
            };
        }
            
    }
    return;
}

sub _reduce_supersets {
    my $self = shift;
    my $local_files = shift;

    # Order matters because it determines what gets removed from.
    # I suppose we should really be comparing two Files clauses
    # and working out which is the superset in a semantic sense.
    # However that looks pretty deep. So instead we are using
    # practical measures.
    #
    # We want to reduce the largest sets first.
    # TODO: Then if sets have equal size
    # the one with more wildcards should be first.
    my @keys = sort {
        $local_files->{$a}->{files}->size <=> $local_files->{$b}->{files}->size
    } keys %$local_files;

    while (@keys) {
        my $key = pop @keys;
        my $key_set = $local_files->{$key}->{files};
        foreach my $candidate (@keys) {
            if ($key_set > $local_files->{$candidate}->{files}) {
                $key_set->remove($local_files->{$candidate}->{files}->members);
            }
        }
    }

    return;
}

sub _find_ambiguities {
    my $self = shift;
    my $local_files = shift;
    my $ambiguity_list = shift;
    my $file_mapping = shift;

    # Here removals will be symmetric so order
    # should no longer matter.
    my @keys = keys %$local_files;

    while (@keys) {
        my $key = pop @keys;
        my $key_set = $local_files->{$key}->{files};
        foreach my $candidate (@keys) {
            my $intersection = $local_files->{$candidate}->{files}*$key_set;
            if ($intersection->size > 0) {
                $key_set->remove($intersection->members);
                $local_files->{$candidate}->{files}->remove($intersection->members);
                $self->_mapping_ambiguities($file_mapping, $intersection);
                $self->_process_ambiguities(
                    $ambiguity_list,
                    $intersection,
                    [$key, $candidate],
                );
            }
        }
    }
    return;
}

sub _mapping_ambiguities {
    my $self = shift;
    my $file_mapping = shift;
    my $intersection = shift;
    foreach my $file ($intersection->members) {
        $file_mapping->{$file} = $UNKNOWN_NODE;
    }
    return;
}

sub _process_ambiguities {
    my $self = shift;
    my $ambiguity_list = shift;
    my $intersection = shift;
    my $clashers = shift;
    foreach my $file ($intersection->members) {
        $ambiguity_list->{$file} = $clashers;
    }
    return;
}

sub _harvest_mapping {
    my $self = shift;
    my $local_files = shift;
    my $file_mapping = shift;
    foreach my $pattern (keys %$local_files) {
        foreach my $file ($local_files->{$pattern}->{files}->members) {
            $file_mapping->{$file} = $local_files->{$pattern}->{node};
        }
    }
    return;
}

sub _report_ambiguities {
    my $self = shift;
    my $ambiguity_list = shift;
    foreach my $file (keys %$ambiguity_list) {
        my $msg = "Cannot resolve membership for $file from amongst: ";
        foreach my $clasher (@{$ambiguity_list->{$file}}) {
            $msg .= "$clasher, ";
        }
        Debian::LicenseReconcile::Errors->push(
            test => 'FilesClauseAmbiguity',
            msg => $msg,
        );
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
