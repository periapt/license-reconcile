package Debian::LicenseReconcile::Filter::ChangeLog;

use 5.006;
use strict;
use warnings;
use base qw(Debian::LicenseReconcile::Filter);
use Readonly;

Readonly my $TEST_NAME => 'ChangeLog';

Readonly my $ACTUAL_NAME_RE => '\pL[\s\pL\-\'\.]*\pL';

# See http://www.faqs.org/rfcs/rfc2822.html
# Section 3.4.1
use Email::Address;
Readonly my $EMAIL_RE => $Email::Address::addr_spec;

Readonly my $EMAIL_CHANGES_RE => qr{
    ^                           # beginining of line
    \s+\*\s                     # item marker
    Email\schange:\s            # email change token
    ($ACTUAL_NAME_RE)           # actual name
    \s+->\s+                    # gap between name and email
    ($EMAIL_RE)                 # email address
    $                           # end of line
}xms;

Readonly my $PERSON_PARSE_RE => qr{
    \A                          # beginining of string
    ($ACTUAL_NAME_RE)           # actual name
    \s                          # gap
    \<$EMAIL_RE\>               # logged email
    \z                          # end of string
}xms;


sub get_info {
    my $self = shift;
    my $license = $self->config->{license} | 'GPL-2+';
    my %maintainers = ();
    my %email_changes = ();
    foreach ( $self->changelog->data() ) {
        my $person      = $_->Maintainer;
        my $date        = $_->Date;
        my @date_pieces = split( " ", $date );
        my $year        = $date_pieces[3];
        if (my %changes = ($_->Changes =~ m/$EMAIL_CHANGES_RE/xmsg)) {
            # This way round since we are going backward in time thru changelog
            foreach my $p (keys %changes) {
                $changes{$p} =~ s{[\s\n]+$}{}xms;
            }
            %email_changes = (
                %changes,
                %email_changes
            );
        }
        if (my ($name) = ($person =~ $PERSON_PARSE_RE)) {
            if (exists $email_changes{$name}) {
                $person = "$name <$email_changes{$name}>";
            }
        }
        if ( defined( $maintainers{$person} ) ) {
            push @{ $maintainers{$person} }, $year;
            @{ $maintainers{$person} } = sort( @{ $maintainers{$person} } );
        }
        else {
            @{ $maintainers{$person} } = ($year);
        }
    }
    my @strings;
    foreach my $maint_name ( keys %maintainers ) {
        my $str = " ";
        my %uniq = map { $_ => 0 } @{ $maintainers{$maint_name} };
        foreach ( sort keys %uniq ) {
            $str .= $_;
            $str .= ", ";
        }
        $str .= $maint_name;
        push @strings, $str;
    }
    @strings = sort @strings;
    my @results;
    foreach my $file ($self->files_remaining) {
        next if not $file =~ m{\Adebian/}xms;
        push @results, {
            test=>$TEST_NAME,
            file=>$file,
            license=>$license,
            copyright=>\@strings,
        };
    }
    return @results;
}

=head1 NAME

Debian::LicenseReconcile::Filter::ChangeLog - parses changelog

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

    use Debian::LicenseReconcile::Filter::ChangeLog;

    my $filter = Debian::LicenseReconcile::Filter::ChangeLog->new(
        directory=>'.',
        changelog=>$CHANGELOG,
    );
    my @info = $filter->get_info();

=head1 SUBROUTINES/METHODS

=head2 get_info

Returns a list of hash references describing copyright and license information
that should be checked against the copyright target. The results returned
from this filter consist of blocks whose copyright holders and years
are taken from the changelog. One block is generated for every file with
unassigned copyright below the debian directory. The license string
is taken from the license field of the filter config but defaults to 'GPL-2+'.

Also the code will look for changelog lines of the form:

    Email change: Nicholas Bamber -> periapt@debian.org

The purpose of this is that if a maintainer's email address has changed
over the course of the history of the package only the email address
specified in that directive will be used.

=head1 AUTHOR

Nicholas Bamber, C<< <nicholas at periapt.co.uk> >>

=head1 LICENSE AND COPYRIGHT

This file draws heavily upon the L<DhMakePerl::Command::Packaging>
module. Inspection of the history of that file suggests that 
appropriate copyright declaration is:

=over 4

=item Copyright (C) 2007-2010 Damyan Ivanov <dmn@debian.org>

=item Copyright (C) 2011-2012, Nicholas Bamber <nicholas@periapt.co.uk>

=back

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of Debian::LicenseReconcile::FormatSpec
