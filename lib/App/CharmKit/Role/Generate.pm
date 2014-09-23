package App::CharmKit::Role::Generate;
$App::CharmKit::Role::Generate::VERSION = '0.003_2';
# ABSTRACT: Generators for common tasks

use Path::Tiny;
use Moo::Role;

has src => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        path('.')->child('src/hooks');
    }
);

has default_hooks => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        ['install', 'config-changed', 'upgrade-charm', 'start', 'stop'];
    }
);

sub create_hook {
    my ($self, $hook) = @_;

    (   my $hook_heading =
          qq{#!/usr/bin/env perl
# To see what helper functions are available to you automatically, run:
# > perldoc App::CharmKit::Helper
#
# Other functionality can be enabled by putting the following in the beginning
# of the file:
# use charm -sys;

use charm;

log "Start of charm authoring for $hook";
}
    );
    $self->src->child($hook)->spew_utf8($hook_heading);
}

sub create_all_hooks {
    my ($self) = @_;
    foreach (@{$self->default_hooks}) {
        $self->create_hook($_);
    }
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

App::CharmKit::Role::Generate - Generators for common tasks

=head1 VERSION

version 0.003_2

=head1 ATTRIBUTES

=head2 src

Path::Tiny object for pristine hooks. Primarily used during development
of non fatpacked hooks.

=head2 default_hooks

Arrayref of default charm hooks used when doing a blanket generate
of all hooks.

=head1 METHODS

=head2 create_hook(STR hook)

Creates a hook file defined by `hook` parameter, also writes out some
initial starter code to file.

=head2 create_all_hooks()

Iterates `default_hooks` and creates the necessary hook files.

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
