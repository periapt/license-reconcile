package Debian::LicenseReconcile::CopyrightTarget;

use 5.006;
use strict;
use warnings;
use Debian::LicenseReconcile::Errors;
use Debian::Copyright;
use base qw(Tree::Simple);
use Readonly;

Readonly my $FS_SEPARATOR => '/';

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
    if (exists $tree->getNodeValue->{license} 
        or exists $tree->getNodeValue->{copyright}) {
        Debian::LicenseReconcile::Errors->push(
            test => 'CopyrightParsing',
            msg => "The file pattern $pattern was defined twice",
        );
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

#sub get {
#    my $self = shift;
#    my $key = shift;
#    return $self->{$key};
#}
#
#sub keys {
#    my $self = shift;
#    return keys %$self;
#}

sub directory {
    my $self = shift;
    my $directory = shift;
    return {};
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
then the constructor returns undef. If successfully parsed the 
L<Debian::Copyright::Stanza::Files> data is transformed into a tree
representation

=head2 get

Given a file pattern returns the corresponding object if available
and otherwise undef.

=head2 keys

Returns a list of file patterns.

=head2 directory

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
