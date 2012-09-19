package Debian::LicenseReconcile::CopyrightDatum;

use 5.006;
use strict;
use warnings;
use Scalar::Util qw(blessed);
use Readonly;
use Set::IntSpan;
use Debian::LicenseReconcile::CopyrightDatum::Holder;
use List::MoreUtils qw(part pairwise);

# We allow the copyright to be given in square brackets.
Readonly my $SQBR_RE => qr{
    \A
    \[
    ([^]]*)
    \]
    \z
}xms;

Readonly my $NL_RE => qr{
    \s*
    $
    \s*
}xms;

# We regard each line as a Set::IntSpan run list followed by free text.
Readonly my $LINE_RE => qr{
    \A                          # start of string
    ([0-9-,\s\(\)]*)            # Set::IntSpan
    (.*\S)                      # free text copyright holder
    \z                          # end of string
}xms;

sub new {
    my $class = shift;
    my $self = {};
    bless $self, $class;
    my $text = shift;
    if ($text) {
        $self->_parse($text);
    }
    return $self;
}

sub _parse {
    my $self = shift;
    my $text = shift;
    if ($text =~ $SQBR_RE) {
        $text = $1;
    }
    foreach my $line (split $NL_RE, $text) {
        if ($line =~ $LINE_RE) {
            $self->{$2} = Set::IntSpan->new($1);
        }
    }
    return;
}
    
sub contains {
    my $self = shift;
    my $other = shift;
    my $msg_ref = shift;
    undef $msg_ref if not ref $msg_ref;
    return _msg($msg_ref, 'The other copyright data was undefined.')
        if not defined $other;
    my $other_class = blessed $other || '';
    if ($other_class ne 'Debian::LicenseReconcile::CopyrightDatum') {
        $other = Debian::LicenseReconcile::CopyrightDatum->new("$other");
    }

    # 1.) Get lists of our and their copyright holders.
    # 2.) If we have less than theirs that is an easy fail.
    # 3.) Match off any that are exact matches and check those
    # 4.) Now create a mapping from Levenshtein distances to sets of pairs
    # of copyright holders. However if a holder is equidistant between
    # two oppisate holders then we immediately reject the whole
    # match as being ambiguous.
    # 5.) If we get this far then working from the shortest Levenshtein
    # distances up, we can pair off copyright holders and run the other
    # checks.
    my $our_data = $self->as_hash;
    my $their_data = $other->as_hash;
    my @their_keys = keys %$their_data;
    my @our_keys = keys %$our_data;
    my $our_size = @our_keys;
    my $their_size = @their_keys;
    if ($our_size < $their_size) {
        my $our_list = join '|', keys %$our_data;
        my $their_list = join '|', keys %$their_data;
        return _msg($msg_ref, "$their_size cannot be fitted into $our_size: ($their_list) versus ($our_list)");
    }

    foreach my $key (@their_keys) {
        if (exists $our_data->{$key}) {
            my $our_years = delete $our_data->{$key};
            my $their_years = delete $their_data->{$key};
            if (not $their_years le $our_years) {
                return _msg($msg_ref,
                    "For copyright holder '$key' the years $their_years cannot be fitted into $our_years.");
            }
        }
    }

    my @pairs = sort {$a <=> $b} pairwise {
        Debian::LicenseReconcile::CopyrightDatum::Holder->new(
            theirs=>$a,
            ours=>$b,
        )
    } @their_keys, @our_keys;
    while(@pairs) {
        my $subject = $pairs[0];
        my ($like_subject, $unlike_subject) =
            part {
                $subject->ours eq $_->ours or $subject->theirs eq $_->theirs
            } @pairs;
        if (scalar @$like_subject > 1
            and $subject->width==$like_subject->[1]->width) {
                # report ambiguity
        }
        my $our_key = $subject->ours;
        my $their_key = $subject->theirs;
        my $our_years = delete $our_data->{$our_key};
        my $their_years = delete $their_data->{$their_key};
        if (not $their_years le $our_years) {
            return _msg($msg_ref,
                "For copyright holder '$their_key' (matched against '$our_key') the years $their_years cannot be fitted into $our_years.");
        }
        @pairs = @$unlike_subject;
    }

    return 1;
}

sub _msg {
    my $msg_ref = shift;
    my $text = shift;
    if ($msg_ref) {
        $$msg_ref = $text;
    }
    return 0;
}

sub copyright_holders {
    my $self = shift;
    return keys %$self;
}

sub years {
    my $self = shift;
    my $holder = shift;
    return if not exists $self->{$holder};
    return $self->{$holder};
}

sub as_hash {
    my $self = shift;
    my %hash = %$self;
    return \%hash;
}

=head1 NAME

Debian::LicenseReconcile::CopyrightDatum - copyright data as an object

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 DESCRIPTION

This module conceives of copyright data as a mapping from strings
(the individual copyright holders) to sets of years.

Copyright data can be compared. Datum C<A> is contained in Datum C<B>
if for every key C<k> in C<A>, C<A{k}> is contained in C<B{l}>, where C<l> is the
key in C<B> that most closely matches C<k>. When matching strings they
are paired off in a 1-1 manner.

=head1 SYNOPSIS

    use Debian::LicenseReconcile::CopyrightDatum;

    my $copyright = Debian::LicenseReconcile::CopyrightDatum->new($text);

    my $explanation = "";
    if (not $copyright->contains($copyright2, \$explanation)) {
        warn $explanation;
    }

=head1 SUBROUTINES/METHODS

=head2 new

This constructor parses a copyright string.

=head2 contains

This method returns a boolean indicating whether the object contains the argument.
The method will respect the argument if it is a
L<Debian::LicenseReconcile::CopyrightDatum> and otherwise stringify and parse it.
It may also take an optional reference. If this is set on failing to
veryify containment the reason found will be placed in that reference.

=head2 copyright_holders 

This method returns the list of copyright holders parsed from the original string.

=head2 years

Given an exactly matching copyright holder this returns the set of years
as an L<Set::IntSpan> object.

=head2 as_hash

Returns a hash reference of the objects data.

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
