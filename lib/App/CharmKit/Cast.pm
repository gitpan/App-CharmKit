package App::CharmKit::Cast;
$App::CharmKit::Cast::VERSION = '1.0.5';
# ABSTRACT: Wrapper for functional charm testing


use strict;
use warnings;
use App::CharmKit::Helper;
use IO::Socket::PortState qw(check_ports);
use Juju;
use Path::Tiny qw(path);
use YAML::Tiny;
use Class::Tiny qw(endpoint password), {
    juju => sub {
        my $self = shift;
        my $juju =
          Juju->new(endpoint => $self->endpoint, password => $self->password);
        return $juju;
    }
};

sub BUILD {
    my ($self, $args) = @_;
    $self->get_creds unless $self->endpoint || $self->password;
}


sub get_creds {
    my ($self)    = @_;
    my $juju_env  = $ENV{JUJU_ENV};
    my $juju_home = $ENV{JUJU_HOME};

    die "Unable to determine the running Juju environment"
      unless defined($juju_env);
    my $env_file = path($juju_home)->child('environments/$juju_env.jenv');
    my $env_yaml = YAML::Tiny->read($env_file->abspath);
    if (defined($env_yaml->{password})) {
        $self->password($env_yaml->{password});
    }
    if (defined($env_yaml->{state_servers})) {
        $self->endpoint($env_yaml->{state_servers}->[0]);
    }
    else {
        die "Unable to determine api state server";
    }
}

sub deploy {
    my $self = shift;
    $self->juju->deploy(@_);
}

sub add_relation {
    my $self = shift;
    $self->juju->add_relation(@_);
}

sub is_listening {
    my ($self, $service, $port) = @_;

    my $ip = unit_get($service);
    my %porthash = (tcp => $port => {name => $service});
    my $check_port = check_ports($ip, 5, \%porthash);
    return $check_port->{open};
}




1;

__END__

=pod

=encoding UTF-8

=head1 NAME

App::CharmKit::Cast - Wrapper for functional charm testing

=head1 VERSION

version 1.0.5

=head1 SYNOPSIS

Directly,

  use App::CharmKit::Cast qw(cast);

Or sugar,

  use charm -tester;

  my $cast = load_helper(
    'Cast',
    {   endpoint => 'wss://localhost:17070',
        password => 'secret'
    }
  );

  $cast->deploy('wordpress');
  $cast->deploy('mysql');
  $cast->add_relation('wordpress', 'mysql');

=head1 DESCRIPTION

Helper routines for dealing with functional charm testing

=head1 METHODS

=head2 get_creds

Attempts to pull creds from a running juju environment

=head2 deploy

Deploys a charm with default constraints

B<Params>

=over 4

=item *

C<charm>

Name of charm to deploy

=back

=head2 add_relation

Add relations between services

=head2 is_listening

Checks if a service is listening on a port

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
