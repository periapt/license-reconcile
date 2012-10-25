package Debian::LicenseReconcile::Filter;

use 5.006;
use strict;
use warnings;
use Class::XSAccessor
    constructor => 'new',
    getters => {
        directory => 'directory',
        files_remaining => 'files_remaining',
        changelog => 'changelog',
        config => 'config',
        licensecheck => 'licensecheck',
        name=>'name',
    },
;
use Readonly;
use File::Slurp;
use File::FnMatch qw(:fnmatch);
use File::MMagic;
use Dpkg::Version;

Readonly my $MMAGIC => File::MMagic->new('/etc/magic');


sub get_info {
    my $self = shift;
    die "not implemented in base class";
}

sub find_rule {
    my $self = shift;
    my $file = shift;
    my $rules = shift;
    my $matching_rule = undef;
    my $contents = undef;
    my $this_version = undef;
    foreach my $rule (@$rules) {

        # Run through the test clauses
        if (exists $rule->{Glob}) {
            next if not fnmatch($rule->{Glob}, $file);
        }
        if (exists $rule->{MaxVersion}) {
            if (not $this_version) {
                $this_version
                    = Dpkg::Version->new($self->changelog->data->[0]->Version);
            }
            my $max_version = Dpkg::Version->new($rule->{MaxVersion});
            next if $this_version > $max_version;
        }
        if (exists $rule->{VerifyLicense}) {
            my $license = $self->licensecheck->raw_license($file);
            next if -1 == index $license, $rule->{VerifyLicense};
        }
        if (not $contents) {
            $contents = read_file($self->directory."/$file");
        }
        if (exists $rule->{MMagic}) {
            next if length $contents == 0; # don't apply magic to degenerates
            next if $rule->{MMagic} ne $MMAGIC->checktype_contents($contents);
        }
        if (exists $rule->{Contains}) {
            next if -1 == index $contents, $rule->{Contains};
        }
        if (exists $rule->{Matches}) {
            next if $contents !~ qr/$rule->{Matches}/xms;
        }
            

        # Now we've found a matching rule
        $matching_rule = $rule;
        return $rule;
    }
    return;
}

=head1 NAME

Debian::LicenseReconcile::Filter - abstract interface to license info

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

    use Debian::LicenseReconcile::Filter;

    my $filter = Debian::LicenseReconcile::Filter->new(arg1=>"blah",...);
    my @info = $filter->get_info(@files);

=head1 SUBROUTINES/METHODS

=head2 new

This constructor takes key value pairs and returns the correspondingly blessed
object.

=head2 get_info

Returns a list of hash references describing copyright and license information
that should be checked against the copyright target.

=head2 directory

Returns the search directory as set in the constructor.

=head2 files_remaining

Returns the files to be checked as set in the constructor.

=head2 changelog

Returns the L<Parse::DebianChangelog> as set in the constructor.

=head2 config

Returns the config data as set in the constructor.

=head2 licensecheck

Returns the L<Debian::LicenseReconcile::LicenseCheck> object
as set in the constructor.

=head2 name 

Returns the name set in the constructor.

=head2 find_rule

This is a helper method designed to allow derived classes implement
rules based semantics. It takes a file name and an array ref to a sequence
of rules. Each rule is a hash ref, which may contain the following fields:

=over 

=item - Glob (optional) - a file glob to limit which files the rule applies to.

=item - Contains (optional) - a piece of text which the file must contain for the
rule to apply.

=item - Matches (optional) - an extended regular expression which the file contents
must match for the rule to apply.

=item - MMagic (optional) - a string which must equal the magic value obtained from
L<File::MMagic> for the rule to apply.

=item - MaxVersion (optional) - an upstream version string after which the rule
will not be applied. This is recommended unless you are certain that the rule
is robust so that the rule will be regularly reviewed.

=item - VerifyLicense (optional) - a string which must be present in the
license portion of L<licensecheck> output.

=back

The first rule which matches the file is returned. If no rule matches then 
undef is returned.

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
