package Debian::LicenseReconcile::CopyrightDatum;

use 5.006;
use strict;
use warnings;
use Scalar::Util qw(blessed);
use Readonly;
use Set::IntSpan;
use Debian::LicenseReconcile::CopyrightDatum::Holder;
use Debian::LicenseReconcile::Errors;
use List::MoreUtils qw(part);
use Smart::Comments -ENV;

Readonly my $NL_RE => qr{
    \s*
    $
    \s*
}xms;

Readonly my $FILLER_RE => '[\-,\s\(\)]';

# We regard each line as a Set::IntSpan run list followed by free text.
Readonly my $LINE_RE => qr{
    \A                          # start of string
    (?:
        Copyright
        (?:\s+\([cC]\)\s*?)?
        [:\s]
    )?                          # Copyright string
    $FILLER_RE*                 # filler
    (                           # start of Set::IntSpan
        \d{4}                   # year
        (?:$FILLER_RE+\d{4})*   # more years
    )?                          # end of Set::IntSpan
    $FILLER_RE*                 # filler
    (.*?)                       # free text copyright holder
    (?:                         # All rights reserved
        \s*
        All\s+[Rr]ights\s+[Rr]eserved
        \.?
    )?
    \s*
    \z                          # end of string
}xms;

Readonly my $MAX_RELATIVE_WIDTH => 0.33;

sub new {
    my $class = shift;
    my $self = {};
    bless $self, $class;
    my $text = shift;
    if (ref $text eq 'ARRAY') {
        foreach my $line (@$text) {
            $self->_parse($line);
        }
    }    
    elsif ($text) {
        $self->_parse($text);
    }
    return $self;
}

sub _parse {
    my $self = shift;
    my $text = shift;
    foreach my $line (split $NL_RE, $text) {
        next if not $line;
        my $match = ($line =~ $LINE_RE);
        ### assert: $match
        my $set_intspan = $1;
        my $copyright_holder = $2;
        $self->{$copyright_holder} = eval {
            Set::IntSpan->new($set_intspan)
        };
        if ($@) {
            my @err = split $NL_RE, $@;
            Debian::LicenseReconcile::Errors->push(
                test => 'Copyright parsing',
                msg => "Trying to parse $set_intspan: $err[0]",
            );
            $self->{$copyright_holder} = Set::IntSpan->new;
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
        $other = Debian::LicenseReconcile::CopyrightDatum->new($other);
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
    my $our_size = keys %$our_data;
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

    my @pairs =
        sort {$a <=> $b}
        map {
            my $ours = $_;
            map {
                Debian::LicenseReconcile::CopyrightDatum::Holder->new(
                    theirs=>$_,
                    ours=>$ours
                )
            }
            keys %$their_data # note could be a subset of @their_keys
        }
        keys %$our_data;
    while(@pairs) {
        my $subject = $pairs[0];
        if ($subject->relative_width > $MAX_RELATIVE_WIDTH) {
            my $ours = $subject->ours;
            my $theirs = $subject->theirs;
            return _msg($msg_ref,
                "Trying to match '$theirs' against '$ours' but it does not look like a good match.");
        }
        my ($like_subject, $unlike_subject) = part {not $subject->touches($_)} @pairs;
        if ($subject->is_ambiguous($like_subject)) {
            my $friend = $like_subject->[1];
            my $subject_ours = $subject->ours;
            my $friend_ours = $friend->ours;
            my $subject_theirs = $subject->theirs;
            my $friend_theirs = $friend->theirs;
            if ($subject_ours eq $friend_ours) {
                return _msg($msg_ref,
                    "Was trying to match '$subject_theirs' to '$subject_ours', but '$friend_theirs' would match as well so giving up."); 
            }
            ### assert: $subject_theirs eq $friend_theirs
            return _msg($msg_ref,
                "Was trying to match '$subject_theirs' to '$subject_ours', but '$friend_ours' would be matched as well so giving up."); 
        }
        my $our_key = $subject->ours;
        my $their_key = $subject->theirs;
        my $our_years = delete $our_data->{$our_key};
        my $their_years = delete $their_data->{$their_key};
        if (not $their_years le $our_years) {
            return _msg($msg_ref,
                "For copyright holder '$their_key' (which looks like '$our_key') the years $their_years cannot be fitted into $our_years.");
        }
        @pairs = $unlike_subject ? @$unlike_subject : ();
    }

    return 1;
}

sub _msg {
    my $msg_ref = shift;
    my $text = shift;
    ### assert: $msg_ref
    $$msg_ref = $text;
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
