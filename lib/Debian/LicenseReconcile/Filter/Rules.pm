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
        my $result = {
            file=>$file,
            test=>$self->name,
        };
        my @info;
        if (not ($rule->{License} and $rule->{Copyright})) {
            push @info, $self->licensecheck->get_info($file);
        }
        $result->{license}
            = $rule->{License}
            ? $rule->{License} : $info[0]->{license};
        $result->{copyright}
            = $rule->{Copyright}
            ? $rule->{Copyright} : $info[0]->{copyright};
        push @results, $result;
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
Each rule might have the fields as discussed in 
L<Debian::LicenseReconcile::Filter>.

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
