package App::CharmKit::Command::deploy;
$App::CharmKit::Command::deploy::VERSION = '0.20';
# ABSTRACT: Deploy charm


use strict;
use warnings;
use Path::Tiny;
use App::CharmKit::Sys "execute" => { -as => "run" };
use App::CharmKit -command;

sub opt_spec {
    return (
        [   "charmdir|c=s",
            "Location of toplevel charm directory, used in local charm deploys"
        ],
        ["series|s=s", "Series of charm, defaults to trusty"]
    );
}

sub usage_desc {
    "charmkit deploy <charmname> -c ~/charms";
}

sub validate_args {
    my ($self, $opt, $args) = @_;
    $self->usage_error("Needs a charm name")
      unless $args->[0];
    $self->usage_error("No toplevel charm directory found")
      unless $opt->{charmdir};
    $self->usage_error("Charm directory does not exist")
      unless path($opt->{charmdir})->exists;
}

sub execute {
    my ($self, $opt, $args) = @_;
    my $series = $opt->{series} || "trusty";
    my $cmd = sprintf("juju deploy --repository=%s local:%s/%s",
        $opt->{charmdir}, $series, $args->[0]);
    my $out = run([$cmd]);
    if ($out->{error}) {
        printf("Deployed failed: %s", $out->{stderr});
    }
    else {
        printf("Deployed: %s", $out->{stdout});
    }
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

App::CharmKit::Command::deploy - Deploy charm

=head1 VERSION

version 0.20

=head1 SYNOPSIS

  $ charmkit deploy <charmname> -c ~/charms

=head1 DESCRIPTION

Deploys a charm, accepts locations such as git, http, and local file directories

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
