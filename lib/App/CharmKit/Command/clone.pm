package App::CharmKit::Command::clone;
$App::CharmKit::Command::clone::VERSION = '1.0.6';
# ABSTRACT: Clone charm from github


use strict;
use warnings;
use Path::Tiny;
use App::CharmKit -command;
use parent 'App::CharmKit::Role::Git';

sub opt_spec {
    return (["output|o=s", "Destination directory to place cloned charm"],);
}

sub usage_desc {
    my $self = shift;
    my $eg   = "charmkit clone battlemidget/charm-plone -o plone";
    "$eg\n\n%c clone [-o]";
}

sub validate_args {
    my ($self, $opt, $args) = @_;
    $self->usage_error("Needs a location")
      unless $args->[0];
    $self->usage_error("Invalid location specified")
      unless $args->[0] =~ /^\w+\/\w+/;
}

sub execute {
    my ($self, $opt, $args) = @_;
    if ($opt->{output}) {
        $self->clone($args->[0], path($opt->{output}));
    }
    else {
        $self->clone($args->[0]);
    }
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

App::CharmKit::Command::clone - Clone charm from github

=head1 VERSION

version 1.0.6

=head1 SYNOPSIS

  $ charmkit clone battlemidget/charm-plone -o ~/charms/trusty/plone

=head1 DESCRIPTION

Clones a charm from a git endpoint, supports GitHub with <username>/<repo>.

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
