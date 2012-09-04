package Debian::LicenseReconcile::Filter::Rules;

use 5.006;
use strict;
use warnings;
use base qw(Debian::LicenseReconcile::Filter);

sub get_info {
    my $self = shift;
    my @results;

    foreach my $file (@{$self->files_remaining}) {
        my $rule = $self->find_rule($file, $self->config->{rules});
        next if not $rule;
        push @results, {
            file=>$file,
            copyright=>$rule->{Copyright},
            license=>$rule->{License},
            test=>$self->name,
        };
    }
    return @results;
}

=head1 NAME

Debian::LicenseReconcile::Filter::Rules - applies licensecheck to get data

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

    use Debian::LicenseReconcile::Filter::Rules;

    my $filter = Debian::LicenseReconcile::Filter::Rules->new(
        directory=>'.',
        files_remaining=>[....],
        config=>[....],
    );
    my @info = $filter->get_info();

=head1 SUBROUTINES/METHODS

=head2 get_info

Returns a list of hash references describing copyright and license information
that should be checked against the copyright target. The results returned
are those obtained by applying the rules in the config file in sequence.
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

=item - Comment (optional) - free text documentation concerning the rule. This might
include the reasons for the rule as well as any Debian or upstream bug reports
relating to the rule.

=item - License (mandatory) - the short form of the license.

=item - Copyright (mandatory) - the copyright data in the same format as the
C<debian/copyright> file.

=back

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
