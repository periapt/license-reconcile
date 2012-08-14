package Debian::LicenseReconcile::Utils;

use 5.006;
use strict;
use warnings;
use base qw(Exporter);
use File::Find;

our @EXPORT_OK = qw(specificity get_files);

sub specificity {
    my $s = shift;
    my $t = $s;
    $t =~ s{(?<!\\)[\*\?]}{}xmsg;
    return (1.0 * length $t) / length $s;
}

sub get_files {
    my $directory = shift;
    my @files = ();
    find(sub {
        push @files, substr($File::Find::name,length($directory)+1) if ! -d $_;
    }, $directory);
    return @files;
}

=head1 NAME

Debian::LicenseReconcile::Utils - various just about describable utilities 

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

    use Debian::LicenseReconcile::Utils;

    if (specificity($pattern1) > specificity($pattern2)) {
        ....
    }

=head1 SUBROUTINES/METHODS

=head2 specificity

This method takes a DEP-5 Files clause and returns a number between 0
and 1 inclusively representing how specific the clause is.

=head2 get_files 

Takes a directory and returns a list of all the files in that directory and below.

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
