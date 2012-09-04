package Debian::LicenseReconcile::Filter::Shebang;

use 5.006;
use strict;
use warnings;
use base qw(Debian::LicenseReconcile::Filter);

sub get_info {
    my $self = shift;
    my @results;

    # set up default rules that give the class its name.
    my $rules = ref $self->config eq 'HASH'
              ? $self->config->{rules}
              : [{ Matches=>'\A\#\!'}];

    foreach my $file (@{$self->files_remaining}) {
        my $rule = $self->find_rule($file, $rules);
        next if not $rule;
        my @tmp = $self->licensecheck->get_info($file);
        if (@tmp) {
            $tmp[0]->{test} = $self->name;
            push @results, $tmp[0];
        }
    }
    return @results;
}

=head1 NAME

Debian::LicenseReconcile::Filter::Shebang - applies licensecheck to probable scripts

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

    use Debian::LicenseReconcile::Filter::Shebang;

    my $filter = Debian::LicenseReconcile::Filter::Rules->new(
        files_remaining=>[....],
    );
    my @info = $filter->get_info();

=head1 SUBROUTINES/METHODS

=head2 get_info

Returns a list of hash references describing copyright and license information
that should be checked against the copyright target. The results returned
are those obtained by applying the rules in the config file in sequence
and applying licensecheck to any file that matches one of the rules.
Each rule might have the following fields:

=over

=item - Glob (optional) - a file glob to limit which files the rule applies to.

=item - Contains (optional) - a piece of text which the file must contain for the
rule to apply.

=item - Matches (optional) - an extended regular expression which the file contents
must match for the rule to apply.

=item - MMagic (optional) - a string which must equal the magic value obtained from
L<File::MMagic> for the rule to apply.

=item - MaxVersion (optional) - an upstream version string after which the rule will
not be applied. This is recommended unless you are certain that the rule is robust
so that the rule will be regularly reviewed.

=back

The default rules are to check any file starting with '#!', hence the name.
Normal recursive use of licensecheck might not find these files as it might
not have one of the file extensions that licensecheck looks for.

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
