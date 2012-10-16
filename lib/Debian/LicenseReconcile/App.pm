package Debian::LicenseReconcile::App;

use 5.006;
use strict;
use warnings;
use Class::XSAccessor
    constructor => 'new',
    getters => {
        quiet => 'quiet',
        display_mapping => 'display_mapping',
        changelog_file => 'changelog_file',
        config_file => 'config_file',
        copyright => 'copyright',
        check_copyright => 'check_copyright',
        directory =>'directory',
        filters => 'filters',
        format_spec => 'format_spec',
    },
;
use File::Slurp;
use Readonly;
use Debian::LicenseReconcile::Errors;
use Debian::LicenseReconcile::FormatSpec;
use Debian::LicenseReconcile::CopyrightTarget;
use Debian::LicenseReconcile::LicenseCheck;
use Debian::LicenseReconcile;
use Parse::DebianChangelog;
use UNIVERSAL::require;
use Config::Any;

sub _read_copyright_file {
    my $self = shift;
    my $copyright_text = scalar read_file($self->copyright);
    if ($self->format_spec) {
        Debian::LicenseReconcile::FormatSpec->check($copyright_text);
    }
    my $copyright_target = Debian::LicenseReconcile::CopyrightTarget->new;
    if ($copyright_target->parse($copyright_text)) {
        return $copyright_target;
    }
    return;
}

sub _parse_changelog {
    my $self = shift;
    return Parse::DebianChangelog->init(
        {
            infile=>$self->changelog_file
        }
    );
}

sub _parse_config {
    my $self = shift;
    my $config = Config::Any->load_files({
        files=>[$self->config_file],
        use_ext=>1,
        flatten_to_hash=>1,
    })->{$self->config_file};
    if (not defined $config) {
        $config = {};
    }
    if (not exists $config->{licensecheck}) {
        $config->{licensecheck} = {};
    }
    if ($self->filters) {
        foreach my $key (@{$self->filters}) {
            if (not exists $config->{$key}) {
                $config->{$key}={rules=>[]};
            }
        }
    }
    foreach my $key (keys %$config) {
        next if $key eq 'licensecheck';
        next if ref $config->{$key} ne 'HASH';
        next if exists $config->{$key}->{rules};
        $config->{$key}->{rules}=[];
    }
    return $config;
}

sub _build_licensecheck {
    my $self = shift;
    my $config = shift;
    return Debian::LicenseReconcile::LicenseCheck->new(
        $self->directory,
        $config->{LicenseCheck},
        $self->check_copyright,
    );
}

sub _build_file_mapping {
    my $self = shift;
    my $copyright_target = shift;
    my $file_mapping = $copyright_target->map_directory($self->directory);

    if ($self->display_mapping) {
        foreach my $file (sort keys %$file_mapping) {
            print "$file: $file_mapping->{$file}->{pattern}\n";
        }
    }
    return $file_mapping;
}

sub run {
    my $self = shift;

    Readonly my $CHANGELOG => $self->_parse_changelog;
    Readonly my $CONFIG => $self->_parse_config;
    Readonly my $LICENSECHECK => $self->_build_licensecheck($CONFIG);
    Readonly my $COPYRIGHT_TARGET => $self->_read_copyright_file;
    if ($COPYRIGHT_TARGET) {

        Readonly my $FILE_MAPPING => $self->_build_file_mapping($COPYRIGHT_TARGET);
        Readonly my $RECONCILE =>
            Debian::LicenseReconcile->new(
                $COPYRIGHT_TARGET->patterns($self->check_copyright)
            );
        my $file_checked = {};
        foreach my $filter_name (@{$self->filters}) {
            $file_checked = $self->_run_filter(
                $filter_name,
                $file_checked,
                $CONFIG,
                $CHANGELOG,
                $LICENSECHECK,
                $FILE_MAPPING,
                $RECONCILE
            );
        }

    }
    return $self->_report_errors;
}

sub _run_filter {
    my $self = shift;
    my $filter_name = shift;
    my $file_checked = shift;
    my $config = shift;
    my $changelog = shift;
    my $licensecheck = shift;
    my $file_mapping = shift;
    my $reconcile = shift;
    my $class;
    ($class, $filter_name) = _parse_filter_name($filter_name);
    $class->require;
    my @files_remaining
        = grep {not exists $file_checked->{$_}} keys %$file_mapping;
    my $our_config = {rules=>[]};
    if (exists $config->{$filter_name}->{rules}
        and ref $config->{$filter_name}->{rules} eq 'ARRAY') {
        $our_config = $config->{$filter_name};
    }
    my $test = $class->new(
        directory=>$self->directory,
        files_remaining=>\@files_remaining,
        config=>$our_config,
        changelog=>$changelog,
        licensecheck=>$licensecheck,
        name=>$filter_name,
    );
    foreach my $titbit ($test->get_info) {
        next if $file_checked->{$titbit->{file}};
        $file_checked->{$titbit->{file}} = 1;
        if (exists $file_mapping->{$titbit->{file}}) {
            $reconcile->check(
                $titbit,
                $file_mapping->{$titbit->{file}},
                $self->check_copyright,
            );
        }
        else {
            Debian::LicenseReconcile::Errors->push(
                test => 'File mismatch',
                msg => "Filter $filter_name found $titbit->{file} which was not in the file mapping. This probably implies a bug in the filter.",
            );
        }
    }
    return $file_checked;
}

sub _report_errors {
    my $self = shift;
    if (not $self->quiet) {
        foreach my $error (Debian::LicenseReconcile::Errors->list) {
            warn "$error->{test}: $error->{msg}";
        }
    }
    return Debian::LicenseReconcile::Errors->how_many > 0 ? 1 : 0;
}

sub _parse_filter_name {
    my $filter_name = shift;
    my $class = "Debian::LicenseReconcile::Filter::";
    if ($filter_name =~ m{\A(\w+)~(\w+)\z}xms) {
        $class .= $2;
        $filter_name = $1;
    }
    else {
        $class .= $filter_name;
    }
    return $class, $filter_name;
}

=head1 NAME

Debian::LicenseReconcile::App - encapsulate the application code

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

    use Debian::LicenseReconcile::App;

    my $app = Debian::LicenseReconcile::App->new(...);
    exit($app->run);

=head1 SUBROUTINES/METHODS

=head2 new

This constructor takes key value pairs and returns the correspondingly blessed
object.

=head2 run

=head2 quiet

=head2 display_mapping

=head2 changelog_file

=head2 config_file

=head2 copyright

=head2 check_copyright

=head2 directory

=head2 filters

=head2 format_spec

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
