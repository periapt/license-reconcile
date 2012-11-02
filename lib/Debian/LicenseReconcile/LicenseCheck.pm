package Debian::LicenseReconcile::LicenseCheck;

use 5.006;
use strict;
use warnings;
use Readonly;
use File::Slurp;
use Smart::Comments -ENV;

Readonly my $SQBR_RE => qr{
    \A
    \[
    ([^]]*)
    \]
    \z
}xms;

Readonly my $SEP_RE => qr{
    \s+
    /
    \s+
}xms;

Readonly my %LICENSE_MAPPING => (
    'Apache (v2.0)' => 'Apache-2.0',
    'GPL' => 'GPL-2',
    'GPL-2' => 'GPL-2',
    'GPL (v2)' => 'GPL-2',
    'GPL (v2 or later)' => 'GPL-2+',
    'LGPL (v2)' => 'LGPL',
    'zlib/libpng' => 'zlib/libpng',
    'BSD (4 clause)' => 'BSD-4-clause',
    'BSD (2 clause)' => 'BSD-2-clause',
    'BSD (3 clause)' => 'BSD-3-clause',
);

Readonly my $SCRIPT => '/usr/bin/licensecheck --no-conf';

Readonly my $PARSE_RE => qr{
    ^                           # beginning of line
    ([^\n:]+)                   # file name
    :\s+                        # separator
    ([^\n]+)                    # license
    \s*                         # just in case
    $                           # end of line
    \s*                         # just in case
    ([^\n]+)?                   # copyright notice
    \s*                         # just in case
    $                           # end of line
    \s*                         # just in case
}xms;

sub new {
    my $class = shift;
    my $self = {
        mapping=>{},
        raw=>{},
    };
    $self->{directory} = shift;
    my $mapping = shift || [];
    $self->{check_copyright} = shift;
    %{$self->{mapping}} = (%LICENSE_MAPPING, @$mapping);
    bless $self, $class;
    $self->_get_raw_data;
    return $self;
}

sub get_info {
    my $self = shift;
    my $subject = shift;
    my $copyright_extract = shift;
    my @files = $subject ? ($subject) : keys %{$self->{raw}};
    my @results;
    foreach my $file (@files) {
        if (not exists $self->{raw}->{$file}) {
            $self->_get_raw_data($file);
        }
        my $license = $self->{raw}->{$file}->{license};
        my $copyright = $self->{raw}->{$file}->{copyright};
        my $addresult = 0;
        my $result = { file => $file };
        ### assert: $license
        $license = $self->_cleanup_license($license);
        if ($license) {
            $addresult = 1;
            $result->{license} = $license;
        }
        if ($self->{check_copyright}) {
            my $found_copyright = 0;
            if ($copyright_extract and
                my @lines = $self->_extract_copyright($file, $copyright_extract)) {
                    $result->{copyright} = \@lines;
                    $addresult = 1;
                    $found_copyright = 1;
            }
            if ($copyright and not $found_copyright) {
                $copyright =~ $SQBR_RE;
                $copyright = $1;
                if ($copyright) {
                    $addresult = 1;
                    my @lines = split $SEP_RE, $copyright;
                    $result->{copyright} = \@lines;
                }
            }
        }
        next if not $addresult;
        push @results, $result;
    }
    return @results;
}

sub _extract_copyright {
    my $self = shift;
    my $file = shift;
    my $copyright_extract = shift;
    my $contents = read_file "$self->{directory}/$file";
    my @lines = ($contents =~ m{$copyright_extract}xms);
    my @results;
    foreach my $line (@lines) {
        next if not $line;
        $line =~ s{\s*\R+\s*}{ }xmsg;
        push @results, $line;
    }
    return @results;
}

sub _get_raw_data {
    my $self = shift;
    my $subject = shift;
    if (defined $subject) {
        $subject = "$self->{directory}/$subject";
    }
    else {
        $subject = $self->{directory};
    }
    my $commands = $SCRIPT;
    if ($self->{check_copyright}) {
        $commands .= ' --copyright';
    }
    if (-d $subject) {
        $commands .= ' --recursive';
    }
    $commands .= " $subject" ;
    my $output = `$commands`;
    while ($output =~ /$PARSE_RE/g) {
        my $file = substr($1, 1+length $self->{directory});
        $self->{raw}->{$file} = {
            license => $2,
            copyright => $3,
        };
    }
    return;
}

sub _cleanup_license {
    my $self = shift;
    my $license = shift;
    $license =~ s{\*No\s+copyright\*}{}xms;
    $license =~ s{GENERATED\s+FILE}{}xms;
    $license =~ s{^\s+}{}xms;
    $license =~ s{\s+$}{}xms;
    $license =~ s{\s+\(with\s+incorrect\s+FSF\s+address\)}{}xms;
    return $self->{mapping}->{$license} if exists $self->{mapping}->{$license};
    return if $license eq 'UNKNOWN';
    return $license;
}

sub raw_license {
    my $self = shift;
    my $file = shift;
    ### assert: $file and -f $file;
    return $self->{raw}->{$file}->{license} if exists $self->{raw}->{$file};
    $self->_get_raw_data($file);
    ### assert: exists $self->{raw}->{$file}->{license}
    return $self->{raw}->{$file}->{license};
}

=head1 NAME

Debian::LicenseReconcile::LicenseCheck - wrapper around licensecheck

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

    use Debian::LicenseReconcile::LicenseCheck;

    my $filter = Debian::LicenseReconcile::LicenseCheck->new(directory=>'.');
    my @info = $filter->get_info();

=head1 DESCRIPTION

This module is designed to provide an interface to the licensecheck program
suitable for use in L<Debian::LicenseReconcile::Filter> objects.

=head1 SUBROUTINES/METHODS

=head2 new

The constructor takes the base directory as an argument. Any other
arguments are interpreted as key/value pairs mapping the license statements
generated by licensecheck onto those used in C<debian/copyright>.

=head2 get_info

Returns a list of hash references describing copyright and license information
that should be checked against the copyright target. If no additional argument
is passed, the results returned from this filter are those that are obtained from
C<licensecheck --no-conf --recursive --copyright DIR>.
The optional file argument must be relative to the directory given to the
constructor. If the file is a directory then the C<--recursive> option is used.

Optionally this method may take an additional regular expression format string
argument. If present this regular expression will be used to extract copyright
data from the file contents in preference to what licensecheck returns. If the
regular expression fails to match, licensecheck data will be used instead. The
regular expression should have a capture for each line. A capture may span lines
and the regular expression will be enclosed in C<m{...}xms>.

=head2 raw_license 

Given a file this method returns the license data produced
from C<licensecheck --no-conf FILE>.

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
