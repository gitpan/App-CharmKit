package App::CharmKit::Role::Lint;
$App::CharmKit::Role::Lint::VERSION = '0.014';
# ABSTRACT: charm linter

use strict;
use warnings;
use boolean;
use YAML::Tiny;
use Path::Tiny;
use File::ShareDir qw(dist_file);
use Util::Any -list;
use Set::Light;
use App::CharmKit::Logging qw/prettyLog/;

use Class::Tiny {
    rules => YAML::Tiny->read(dist_file('App-CharmKit', 'lint_rules.yaml')),
    has_error => 0
};

sub parse {
    my ($self) = @_;

    # Check attributes
    my $rules = $self->rules->[0];
    foreach my $meta (@{$rules->{files}}) {
        $self->validate_attributes($meta);
        if ($meta->{name} =~ /^metadata\.yaml/) {
            $self->validate_metadata($meta);
        }
        if ($meta->{name} =~ /^config\.yaml/) {
            $self->validate_configdata($meta);
        }
    }

    # Check for a hooks path
    if (!path('hooks')->exists) {
        $self->lint_fatal('hooks/', 'No hooks directory.');
    }
    else {
        foreach my $hook (@{$rules->{hooks}}) {
            $self->validate_hook($hook);
        }
    }

    # Check for a tests path
    if (!path('tests')->exists) {
        $self->lint_fatal('tests/', 'No tests directory.');
    } else {
      $self->validate_tests;
    }
}



sub validate_tests {
    my ($self) = @_;
    my $tests_path = path('tests');
    $self->lint_fatal('00-autogen',
        'Includes template test file, tests/00-autogen')
      if ($tests_path->child('00-autogen')->exists);
}

sub validate_configdata {
    my ($self, $configdata) = @_;
    my $config_on_disk = YAML::Tiny->read($configdata->{name})->[0];
    my $filepath       = path($configdata->{name});

    # This needs to be a hash
    if (ref($config_on_disk) ne 'HASH') {
        $self->lint_fatal($filepath,
            'config.yaml is not properly formatted.');
    }

    # No root options key
    $self->lint_fatal($configdata->{name},
        'options is not the toplevel root key.')
      unless defined($config_on_disk->{options});

    # Missing required keys for an option
    foreach my $option (keys %{$config_on_disk->{options}}) {
        my $check_opt = $config_on_disk->{options}->{$option};
        if (   !defined($check_opt->{type})
            || !defined($check_opt->{description})
            || !defined($check_opt->{default}))
        {
            $self->lint_fatal(
                $filepath,
                sprintf(
                    "Missing required field(type,description,default) for (%s)",
                    $option)
            );
        }
    }
}


sub validate_metadata {
    my ($self, $metadata) = @_;
    my $meta_on_disk = YAML::Tiny->read($metadata->{name})->[0];
    my $filepath     = path($metadata->{name});

    # Check directory name against metadata name
    my $base_dirname = path('.')->absolute->basename;
    if ($base_dirname ne $meta_on_disk->{name}) {
        $self->lint_fatal(
            $metadata->{name},
            sprintf(
                'metadata name(%s) doesnt match directory name(%s)',
                $meta_on_disk->{name}, $base_dirname
            )
        );
    }

    # Verify required meta keys
    foreach my $metakey (@{$metadata->{known_meta_keys}}) {
        if ($metakey =~ /name|summary|description/
            && !defined($meta_on_disk->{$metakey}))
        {
            $self->lint_fatal($metadata->{name},
                sprintf('Missing required item: %s', $metakey));
        }
        elsif (!defined($meta_on_disk->{$metakey})) {

            # Charm must provide at least one thing
            if ($metakey eq 'provides') {
                $self->lint_fatal($metadata->{name},
                    sprintf('Missing required item: %s', $metakey));
            }
            else {
                $self->lint_warn($metadata->{name},
                    sprintf('Missing optional item: %s', $metakey));
            }
        }
    }

    # MAINTAINER
    # Make sure there isn't maintainer and maintainers listed
    if (   defined($meta_on_disk->{maintainer})
        && defined($meta_on_disk->{maintainers}))
    {
        $self->lint_fatal($metadata->{name},
                "Can not have maintainer and maintainer(s) listed. "
              . "Only pick one.");
    }

    my $maintainers = [];
    if (defined($meta_on_disk->{maintainer})) {
        if (ref $meta_on_disk->{maintainer} eq 'ARRAY') {
            $self->lint_fatal($metadata->{name},
                'Maintainer field must not be a list');
        }
        else {
            push @{$maintainers}, $meta_on_disk->{maintainer};
        }
    }

    if (defined($meta_on_disk->{maintainers})) {
        if (ref $meta_on_disk->{maintainers} ne 'ARRAY') {
            $self->lint_fatal($metadata->{name},
                'Maintainers field must be a list');
        }
        else {
            push @{$maintainers}, @{$meta_on_disk->{maintainers}};
        }
    }

    # TODO: Add maintainer email format checker

    # check for keys not known to charm
    my $meta_keys_set = Set::Light->new(@{$metadata->{known_meta_keys}});

    foreach my $meta_on_disk_key (keys %{$meta_on_disk}) {
        $self->lint_fatal($metadata->{name},
            sprintf("Unknown config item: %s", $meta_on_disk_key))
          if (!$meta_keys_set->has($meta_on_disk_key));
    }

    # check if relations defined
    foreach my $relation (@{$metadata->{known_relation_keys}}) {
        $self->lint_warn($metadata->{name},
            sprintf("Missing relation item: %s", $relation))
          if (!defined($meta_on_disk->{$relation}));
    }

    # no revision key should exist
    if (defined($meta_on_disk->{revision})) {
        $self->lint_fatal($metadata->{name},
                'Revision should not be stored in metadata.yaml. '
              . 'Move to a revision file.');
    }

    foreach my $re (@{$metadata->{parse}}) {

        # Dont parse if file doesn't exist and wasn't required
        next if !$filepath->exists;
        my $input  = $filepath->slurp_utf8;
        my $search = $re->{pattern};
        if ($input !~ /$search/m) {
            $self->lint_warn($filepath, 'Failed to parse.');
        }
    }
}


sub validate_hook {
    my ($self, $hookmeta) = @_;
    my $filepath = path('hooks')->child($hookmeta->{name});
    my $name     = $filepath->stringify;
    foreach my $attr (@{$hookmeta->{attributes}}) {
        if ($attr =~ /EXISTS/) {
            $self->lint_fatal($name, 'Required hook does not exist')
              unless $filepath->exists;
        }
        if ($attr =~ /NOT_EMPTY/ && -z $filepath) {
            $self->lint_fatal($name, 'Hook is empty');
        }
    }
    if (!-x $filepath) {
        $self->lint_fatal($name, 'Hook is not executable');
    }
}


sub validate_attributes {
    my ($self, $filemeta) = @_;
    my $filepath = path($filemeta->{name});
    my $name     = $filemeta->{name};
    foreach my $attr (@{$filemeta->{attributes}}) {
        if ($attr =~ /^NOT_EMPTY/ && -z $name) {
            $self->lint_fatal($name, 'File is empty.');
        }
        if ($attr =~ /^EXISTS/) {

            # Verify any file aliases
            my $alias_exists = 0;
            foreach my $alias (@{$filemeta->{aliases}}) {
                next unless path($alias)->exists;
                $alias_exists = 1;
            }
            if (!$alias_exists) {
                $self->lint_fatal($name, 'File does not exist.')
                  unless $filepath->exists;
            }
        }
        if ($attr =~ /^NOT_EXISTS/) {
            $self->lint_warn($name, 'Includes template ' . $name . ' file.')
              if (path($name)->exists);
        }
    }
}

sub lint_fatal {
    my ($self, $item, $message) = @_;
    $self->has_error(1);
    $self->lint_print(
        $item,
        {   level   => 'FATAL',
            message => $message
        }
    );
}

sub lint_warn {
    my ($self, $item, $message) = @_;
    $self->lint_print(
        $item,
        {   level   => 'WARN',
            message => $message
        }
    );
}

sub lint_info {
    my ($self, $item, $message) = @_;
    $self->lint_print(
        $item,
        {   level   => 'INFO',
            message => $message
        }
    );
}

sub lint_print {
    my ($self, $item, $error) = @_;
    printf("%s: (%s) %s\n",
        substr($error->{level}, 0, 1),
        $item, $error->{message});
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

App::CharmKit::Role::Lint - charm linter

=head1 VERSION

version 0.014

=head1 SYNOPSIS

  $ charmkit lint

=head1 DESCRIPTION

Performs various lint checks to make sure the charm is in accordance with
Charm Store policies.

=head1 ATTRIBUTES

=head2 rules

Lint rules file

=head2 has_error

Stores whether or not a fatal error was found

=head1 METHODS

=head2 parse

Parses charm

=head2 validate_tests

Does basic sanity checking on tests directory

=head2 validate_configdata(HASHREF configdata)

Validates B<config.yaml>

=head2 validate_metadata(HASHREF metadata)

Validates B<metadata.yaml>

=head2 validate_hook(HASHREF hookmeta)

Validates charm hooks

=head2 validate_attributes(HASHREF filemeta)

Performs validation of file based on available attribute

=head2 lint_fatal(STR item, STR message)

Prints a FATAL lint message

=head2 lint_warn(STR item, STR message)

Prints a WARNING lint message

=head2 lint_info(STR item, STR message)

Prints a INFO lint message

=head2 lint_print(STR item, HASHREF error)

Prints out lint errors

=head1 Format of lint rules

Lint rules are loaded from B<lint_rules.yaml> in the distributions share directory.
The format for rules is as follows:

  ---
  files:
    file:
      name: 'config.yaml'
      attributes:
        - NOT_EMPTY
        - EXISTS
    file:
      name: 'copyright'
      attributes:
        - NOT_EMPTY
        - EXISTS
      parse:
        - pattern: '^options:\s*\n'
          error: 'ERR_INVALID_COPYRIGHT'

=head2 Available Attributes

=over 4

=item *

NOT_EMPTY

=item *

NOT_EXISTS

=item *

EXISTS

=back

=head1 AUTHOR

Adam Stokes <adamjs@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Adam Stokes.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT
WHEN OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER
PARTIES PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND,
EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE
SOFTWARE IS WITH YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME
THE COST OF ALL NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE LIABLE
TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE THE
SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH
DAMAGES.

=cut
