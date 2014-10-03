package App::CharmKit::Role::Lint;
$App::CharmKit::Role::Lint::VERSION = '0.015';
# ABSTRACT: charm linter

use strict;
use warnings;
use boolean;
use YAML::Tiny;
use Path::Tiny;
use File::ShareDir qw(dist_file);
use Set::Tiny;
use Email::Address;
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

    my $known_option_keys = Set::Tiny->new(qw/type description default/);
    foreach my $option (keys %{$config_on_disk->{options}}) {
        my $check_opt            = $config_on_disk->{options}->{$option};
        my $existing_option_keys = Set::Tiny->new(keys %{$check_opt});

        # Missing required keys for an option
        my $missing_keys =
          $known_option_keys->difference($existing_option_keys);
        $self->lint_fatal(
            $filepath,
            sprintf(
                "Missing required keys for %s: %s",
                $option, $missing_keys->as_string
            )
          )
          unless $missing_keys->is_empty
          || $check_opt->{type} =~ /^(int|float|string)/;

        # Invalid keys in config option
        my $invalid_keys =
          $existing_option_keys->difference($known_option_keys);
        $self->lint_fatal(
            $filepath,
            sprintf(
                "Unknown keys for %s: %s",
                $option, $invalid_keys->as_string
            )
        ) unless $invalid_keys->is_empty;
    }

}


sub validate_metadata {
    my ($self, $metadata) = @_;
    my $meta_on_disk = YAML::Tiny->read($metadata->{name})->[0];
    my $filepath     = path($metadata->{name});

    # sets
    my $meta_keys_set = Set::Tiny->new(@{$metadata->{known_meta_keys}});
    my $meta_keys_on_disk_set = Set::Tiny->new(keys %{$meta_on_disk});

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
    my $meta_key_optional_set = Set::Tiny->new;
    my $meta_key_required_set = Set::Tiny->new;
    foreach my $metakey (@{$metadata->{known_meta_keys}}) {
        if ($metakey =~ /^(name|summary|description)/
            && !defined($meta_on_disk->{$metakey}))
        {
            $meta_key_required_set->insert($metakey);
        }
        elsif (!defined($meta_on_disk->{$metakey})) {

            # Charm must provide at least one thing
            if ($metakey eq 'provides') {
                $self->lint_fatal(
                    $metadata->{name},
                    sprintf('Charm must provide at least one thing: %s',
                        $metakey)
                );
            }
            else {
                $meta_key_optional_set->insert($metakey);
            }
        }
    }
    $self->lint_fatal(
        $metadata->{name},
        sprintf('Missing required item(s): %s',
            $meta_key_required_set->as_string)
    ) unless $meta_key_required_set->is_empty;

    $self->lint_warn(
        $metadata->{name},
        sprintf('Missing optional item(s): %s',
            $meta_key_optional_set->as_string)
    ) unless $meta_key_optional_set->is_empty;


    # MAINTAINER
    # Make sure there isn't maintainer and maintainers listed
    if ($meta_keys_on_disk_set->contains(qw/maintainer maintainers/)) {
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

    # validate email format
    my $email_invalid = 0;
    foreach my $m (@{$maintainers}) {
        my @addresses = Email::Address->parse($m);
        $email_invalid = 1
          unless (ref $addresses[0] eq 'Email::Address');
    }
    if ($email_invalid) {
        $self->lint_fatal($metadata->{name},
            sprintf("Maintainer format should be 'Name <email>'"));
    }


    # check for keys not known to charm
    my $invalid_keys = $meta_keys_on_disk_set->difference($meta_keys_set);
    $self->lint_fatal($metadata->{name},
        sprintf("Unknown key: %s", $invalid_keys->as_string))
      unless $invalid_keys->is_empty;

    # check if relations defined
    my $missing_relation = Set::Tiny->new;
    foreach my $relation (@{$metadata->{known_relation_keys}}) {
        $missing_relation->insert($relation)
          unless $meta_keys_on_disk_set->contains([$relation]);
    }
    $self->lint_warn($metadata->{name},
        sprintf("Missing relation item(s): %s", $missing_relation->as_string))
      unless $missing_relation->is_empty;

    # no revision key should exist
    if (defined($meta_on_disk->{revision})) {
        $self->lint_fatal($metadata->{name},
                'Revision should not be stored in metadata.yaml. '
              . 'Move to a revision file.');
    }

    # TODO lint subordinate
    # TODO lint peers

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

version 0.015

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
