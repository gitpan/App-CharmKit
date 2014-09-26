package App::CharmKit::Role::Lint;
$App::CharmKit::Role::Lint::VERSION = '0.010';
# ABSTRACT: charm linter

use strict;
use warnings;
use YAML::Tiny;
use Path::Tiny;
use File::ShareDir qw(dist_file);

use Class::Tiny {
    errors => {
        ERR_INVALID_COPYRIGHT => {
            message => 'Copyright is malformed or missing',
            level   => 'WARNING'
        },
        ERR_REQUIRED_CONFIG_ITEM => {
            message => 'Missing required configuration item',
            level   => 'FATAL'
        },
        ERR_CONFIG_ITEM => {
            message => 'Missing optional configuration item',
            level   => 'WARNING'
        },
        ERR_NO_REQUIRES => {
            message => 'No requires set for charm relations',
            level   => 'WARNING'
        },
        ERR_NO_PROVIDES => {
            message => 'No provides set for charm relations',
            level   => 'WARNING'
        },
        ERR_NO_PEERS => {
            message => 'No peers set for charm relations',
            level   => 'INFO'
        },
        ERR_NO_SUBORDINATES => {
            message => 'No subordinates set for charm relations',
            level   => 'INFO'
        },
        ERR_EXISTS => {
            message => 'File does not exist',
            level   => 'FATAL'
        },
        ERR_EMPTY => {
            message => 'File is empty',
            level   => 'FATAL'
        }
    },
    rules => YAML::Tiny->read(dist_file('App-CharmKit', 'lint_rules.yaml')),
    has_error => 0
};

sub parse {
    my ($self) = @_;

    # Check attributes
    my $rules = $self->rules->[0];
    foreach my $meta (@{$rules->{files}}) {
        $self->validate($meta);
    }
}



sub validate {
    my ($self, $filemeta) = @_;
    my $filepath = path($filemeta->{name});
    my $name     = $filemeta->{name};
    foreach my $attr (@{$filemeta->{attributes}}) {
        if ($attr =~ /NOT_EMPTY/ && -z $name) {
            $self->check_error($name, 'ERR_EMPTY');
        }
        if ($attr =~ /EXISTS/) {

            # Verify any file aliases
            my $alias_exists = 0;
            foreach my $alias (@{$filemeta->{aliases}}) {
                next unless path($alias)->exists;
                $alias_exists = 1;
            }
            if (!$alias_exists) {
                $self->check_error($name, 'ERR_EXISTS')
                  unless $filepath->exists;
            }
        }
    }

    foreach my $re (@{$filemeta->{parse}}) {

        # Dont parse if file doesn't exist and wasn't required
        next if !$filepath->exists;
        my $input  = $filepath->slurp_utf8;
        my $search = $re->{pattern};
        if ($input !~ /$search/m) {
            $self->check_error($name, $re->{error});
        }
    }
}

sub check_error {
    my ($self, $key, $error_key) = @_;
    my $err = $self->errors->{$error_key};
    $self->lint_print($key, $err);

    # Only set error on fatals
    if ($err->{level} =~ /FATAL/) {
        $self->has_error(1);
    }
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

version 0.010

=head1 SYNOPSIS

  $ charmkit lint

=head1 DESCRIPTION

Performs various lint checks to make sure the charm is in accordance with
Charm Store policies.

=head1 ATTRIBUTES

=head2 errors

Errors hash, current list of errors:

=over 4

=item *

ERR_INVALID_COPYRIGHT

=item *

ERR_REQUIRED_CONFIG_ITEM

=item *

ERR_CONFIG_ITEM

=item *

ERR_NO_REQUIRES

=item *

ERR_NO_PEERS

=item *

ERR_NO_PROVIDERS

=item *

ERR_NO_SUBORDINATES

=item *

ERR_EXISTS

=item *

ERR_EMPTY

=back

=head2 rules

Lint rules file

=head2 has_error

Stores whether or not a fatal error was found

=head1 METHODS

=head2 parse

Parses charm

=head2 validate(HASHREF filemeta)

Performs validation of file based on available attribute

=head2 check_error(STR key, STR error_key)

Processes errors from matched_result

key: file or object being matched against

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
