package App::CharmKit::Role::Pack;
$App::CharmKit::Role::Pack::VERSION = '0.014';
# ABSTRACT: Fatpack hooks

use strict;
use warnings;
use Path::Tiny;


use Class::Tiny {
    src       => path('.')->child('src/hooks'),
    src_tests => path('.')->child('src/tests')
};


sub build {
    my ($self) = @_;
    my ($cmd, $dst);
    my $iter = $self->src->iterator;
    while (my $p = $iter->()) {
        $dst = path('hooks')->child($p->basename);
        $cmd =
            "fatpack pack "
          . $p->absolute . " > "
          . $dst->absolute
          . " 2>/dev/null";
        printf("Processing hook: %s\n", $p->basename);
        `$cmd`;
        $dst->chmod(0777);
    }
    my @tests_path = $self->src_tests->children(qr/\.test$/);
    for my $testp (@tests_path) {
        $dst = path('tests')->child($testp->basename);
        $cmd =
            "fatpack pack "
          . $testp->absolute . " > "
          . $dst->absolute
          . " 2> /dev/null";
        `$cmd`;
        $dst->chmod(0777);
        printf("Processing test: %s\n", $testp->basename);
    }
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

App::CharmKit::Role::Pack - Fatpack hooks

=head1 VERSION

version 0.014

=head1 ATTRIBUTES

=head2 src

Path::Tiny object for pristine hooks. Primarily used during development
of non fatpacked hooks.

=head2 src_tests

Path::Tiny object for pristine tests. Primarily used during development
of non fatpacked hooks.

=head1 METHODS

=head2 build()

Uses fatpack to build the hooks and pulls in any necessary
perl dependencies for use

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
