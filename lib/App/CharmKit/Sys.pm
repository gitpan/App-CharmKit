package App::CharmKit::Sys;
$App::CharmKit::Sys::VERSION = '0.008';
# ABSTRACT: system utilities


use Path::Tiny;
use IPC::Run qw(run timeout);
use Exporter qw(import);

our @EXPORT = qw/execute
  apt_inst
  apt_upgrade
  apt_update
  make_dir
  remove_dir
  set_owner
  add_user
  del_user
  spew
  slurp
  getent/;

sub spew {
  my $path = path(shift);
  my $contents = shift;
  $path->spew_utf8($contents);
}

sub slurp {
    my $path = path(shift);
    return $path->slurp_utf8;
}

sub make_dir {
    my $dirs = shift;
    foreach my $dir (@{$dirs}) {
        path($dir)->mkpath;
    }
}

sub remove_dir {
    my $dirs = shift;
    foreach my $dir (@{$dirs}) {
        path($dir)->remove_tree;
    }
}

sub set_owner {
    my ($user, $dirs) = @_;
    foreach my $dir (@{$dirs}) {
        execute(['chown', $user, '-R', $dir]);
    }
}

sub getent {
    my ($db, $key) = @_;
    my $ret = execute(['getent', $db, $key]);
    return $ret;
}

sub add_user {
    my $user    = shift;
    my $homedir = shift || undef;
    my $cmd     = ['adduser', '--gecos ""', '--disabled-password'];
    if ($homedir) {
        push @{$cmd}, ['--home', $homedir];
    }
    my $ret = execute($cmd);
    return $ret;
}

sub del_user {
  my $user = shift;
  my $ret = execute(['deluser', '--remove-home', $user]);
  return $ret;
}

sub execute {
    my ($command) = @_;
    my $result = run $command, \my $stdin, \my $stdout, \my $stderr;
    chomp for ($stdout, $stderr);

    +{  stdout    => $stdout,
        stderr    => $stderr,
        has_error => $? > 0,
        error     => $?,
    };
}

sub apt_inst {
    my $pkgs = shift;
    my $cmd = ['apt-get', '-qyf', 'install'];
    map { push @{$cmd}, $_ } @{$pkgs};
    my $ret = execute($cmd);
    return $ret->{stdout};
}

sub apt_upgrade {
    my $cmd = ['apt-get', '-qyf', 'dist-upgrade'];
    my $ret = execute($cmd);
    return $ret->{stdout};
}

sub apt_update {
    my $cmd = ['apt-get', 'update'];
    my $ret = execute($cmd);
    return $ret->{stdout};
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

App::CharmKit::Sys - system utilities

=head1 VERSION

version 0.008

=head1 SYNOPSIS

  use charm -sys;

or

  use App::CharmKit::Sys;

  apt_update();
  apt_upgrade();
  apt_inst(['nginx-common', 'redis-server']);

=head1 DESCRIPTION

Provides system utilities such as installing packages, managing files, and more.

=head1 FUNCTIONS

=head2 spew(STR path, STR contents)

writes to a file, defaults to utf8

=head2 slurp(STR path)

reads a file, defaults to utf8

=head2 make_dir(ARRAYREF dirs)

mkdir helper for creating directories

=head2 remove_dir(ARRAYREF dirs)

removes directories

=head2 set_owner(STR user, ARRAYREF dirs)

sets owner of directories

=head2 getent(STR db, STR key)

accesses user info from nss

Params:
  db: nss database to query
  key: what to query

=head2 add_user(STR user, STR homedir)

adds user to system

=head2 del_user(STR user)

removes a user, does attempt to remove home directory

=head2 execute(ARRAYREF command)

Executes a local command:

   my $cmd = ['juju-log', 'a message'];
   my $ret = execute($cmd);
   print $ret->{stdout};

=head2 apt_inst(ARRAYREF pkgs)

Installs packages via apt-get

   apt_inst(['nginx']);

=head2 apt_upgrade()

Upgrades system

   apt_upgrade();

=head2 apt_update()

Update repository sources

   apt_update();

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
