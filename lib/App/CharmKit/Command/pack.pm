package App::CharmKit::Command::pack;
$App::CharmKit::Command::pack::VERSION = '0.003_2';
# ABSTRACT: Package hooks for distribution


use App::CharmKit -command;

use Moo;
with('App::CharmKit::Role::Pack');

use namespace::clean;

sub opt_spec {
    return ();
}

sub abstract { 'Build distributable hooks for charm deployment'}
sub usage_desc {'%c pack'}

sub execute {
    my ($self, $opt, $args) = @_;
    $self->build;
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

App::CharmKit::Command::pack - Package hooks for distribution

=head1 VERSION

version 0.003_2

=head1 SYNOPSIS

Coerce your charm code to a releasable charm.

  $ charmkit pack

=head1 OVERVIEW

In order for a charm to be utilized by juju all hooks must be executable
and located within your `<toplevel-dir>/hooks` folder. In order to provide
all dependencies needed by the hooks a method of `fatpacking` occurs to
bake in all necessary code for each hook to utilize.

The `pack` command will handle all the heavy lifting of fatpacking and
producing the hooks needed by Juju and if necessary the charm store during
publishing.

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