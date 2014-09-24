package App::CharmKit::Helper;
$App::CharmKit::Helper::VERSION = '0.005';
# ABSTRACT: charm helpers


use App::CharmKit::Sys qw/execute/;
use HTTP::Tiny;
use YAML::Tiny;
use JSON::PP;
use Text::MicroTemplate;
use Exporter qw/import/;

our @EXPORT = qw/config_get
  relation_ids
  relation_get
  relation_set
  relation_list
  service_control
  open_port
  close_port
  unit_get
  json
  yaml
  tmpl
  http/;

sub json { JSON::PP->new->utf8; }

sub yaml { YAML::Tiny->new(@_); }

sub tmpl { Text::MicroTemplate->new(@_); }

sub http { HTTP::Tiny->new; }

sub service_control {
    my $service_name = shift;
    my $action       = shift;
    my $cmd          = ['service', $service_name, $action];
    my $ret          = execute($cmd);
    return $ret->{stdout};
}

sub config_get {
    my ($key) = @_;
    my $cmd = ['config-get', $key];
    my $ret = execute($cmd);
    return $ret->{stdout};
}

sub relation_get {
    my $attribute = shift || undef;
    my $unit      = shift || undef;
    my $rid       = shift || undef;
    my $cmd       = ['relation-get'];

    if ($rid) {
        push @{$cmd}, '-r';
        push @{$cmd}, $rid;
    }
    if ($attribute) {
        push @{$cmd}, $attribute;
    }
    if ($unit) {
        push @{$cmd}, $unit;
    }
    my $ret = execute($cmd);
    return $ret->{stdout};
}

sub relation_set {
    my $opts = shift;
    my $cmd  = ['relation-set'];
    my $opts_str;
    foreach my $key (keys %{$opts}) {
        $opts_str .= sprintf("%s=%s ", $key, $opts->{$key});
    }
    push @{$cmd}, $opts_str;
    my $ret = execute($cmd);
    return $ret->{stdout};
}

sub relation_ids {
  my ($relation_name) = @_;
  my $cmd = ['relation-ids', $relation_name];
  my $ret = execute($cmd);
  return $ret->{stdout};
}

sub relation_list {
    my $rid = shift || undef;
    my $cmd = ['relation-list'];
    if ($rid) {
        push @{$cmd}, '-r';
        push @{$cmd}, $rid;
    }
    my $ret = execute($cmd);
    return $ret->{stdout};
}

sub unit_get {
  my ($key) = @_;
  my $cmd = ['unit-get', $key];
  my $ret = execute($cmd);
  return $ret->{stdout};
}

sub open_port {
    my $port     = shift;
    my $protocol = shift || 'TCP';
    my $cmd      = ['open-port', "$port/$protocol"];
    my $ret      = execute($cmd);
    return $ret->{stdout};
}

sub close_port {
    my $port     = shift;
    my $protocol = shift || 'TCP';
    my $cmd      = ['close-port', "$port/$protocol"];
    my $ret      = execute($cmd);
    return $ret->{stdout};
}
1;

__END__

=pod

=encoding UTF-8

=head1 NAME

App::CharmKit::Helper - charm helpers

=head1 VERSION

version 0.005

=head1 SYNOPSIS

  use App::CharmKit::Helper;

or

  use charm;

  my $port = config_get 'port';
  my $database = relation_get 'database';
  my $dbuser = relation_get 'user';

=head1 DESCRIPTION

Charm helpers for composition

=head1 FUNCTIONS

=head2 json

Wrapper for JSON::PP

=head2 yaml

Wrapper for YAML::Tiny

=head2 tmpl

Wrapper for Text::MicroTemplate

=head2 http

Wrapper for HTTP::Tiny

=head2 service_control(STR service_name, STR action)

Controls a upstart service

=head2 config_get(STR option)

Queries a config option

=head2 relation_get(STR attribute, STR unit, STR rid)

Gets relation

=head2 relation_set(HASHREF opts)

Relation set

=head2 relation_ids(STR relation_name)

Get relation ids

=head2 relation_list(INT rid)

Relation list

=head2 unit_get(STR key)

Get unit information

=head2 open_port(INT port, STR protocol)

Open port on service

=head2 close_port(INT port, STR protocol)

Close port on service

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
