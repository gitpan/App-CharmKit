package App::CharmKit::Command::generate;
$App::CharmKit::Command::generate::VERSION = '0.002';
# ABSTRACT: Generator for hook composition


use App::CharmKit -command;
use Moo;
with('App::CharmKit::Role::Generate');
use namespace::clean;

sub opt_spec {
    return (
        ["relation|r", "generate a relation hook"],
        ["all|a",      "generate all default hooks"]
    );
}

sub abstract { 'Generator for hook composition'}
sub usage_desc {'%c generate [-r] <hook-name>'}

sub validate_args {
    my ($self, $opt, $args) = @_;
    if (!$opt->{all}) {
        $self->usage_error("Must be a hook of name install, "
              . "config-changed, start, start, upgrade-charm")
          unless $opt->{relation}
          || $args->[0] =~ /^install|config-changed|start|stop|upgrade-charm/;
    }
}

sub execute {
    my ($self, $opt, $args) = @_;
    if ($opt->{all}) {
        printf("Generating all hooks ..\n");
        $self->create_all_hooks;
    }
    else {
        printf("Generating %s hook ..\n", $args->[0]);
        $self->create_hook($args->[0]);
    }
    printf("Done.\n");
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

App::CharmKit::Command::generate - Generator for hook composition

=head1 VERSION

version 0.002

=head1 SYNOPSIS

Generate `install` hook

  $ charmkit generate install

Generate all hooks

  $ charmkit generate -a

Generate a website relation based hook

  $ charmkit -r website-relation-changed

=head1 OPTIONS

=head2 relation|r

Generates hook based on its relation

=head2 all|a

Generates all known hooks

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
