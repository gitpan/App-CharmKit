package App::CharmKit::Helper;
$App::CharmKit::Helper::VERSION = '0.20';
# ABSTRACT: charm helpers


use strict;
use warnings;
use App::CharmKit::Sys qw/execute/;
use HTTP::Tiny;
use YAML::Tiny;
use JSON::PP;
use Text::MicroTemplate;
use base "Exporter::Tiny";

our @EXPORT = qw/config_get
  relation_ids
  relation_get
  relation_set
  relation_list
  relation_type
  relation_id
  local_unit
  remote_unit
  service_name
  hook_name
  in_relation_hook
  open_port
  close_port
  unit_get
  unit_private_ip
  json
  yaml
  tmpl
  http/;

sub json { JSON::PP->new->utf8; }

sub yaml { YAML::Tiny->new(@_); }

sub tmpl { Text::MicroTemplate->new(@_); }

sub http { HTTP::Tiny->new; }


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



sub unit_private_ip {
    return unit_get('private-address');
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


sub in_relation_hook {
    return defined($ENV{'JUJU_RELATION'});
}


sub relation_type {
    return $ENV{'JUJU_RELATION'} || undef;
}


sub relation_id {
    return $ENV{'JUJU_RELATION_ID'} || undef;
}


sub local_unit {
    return $ENV{'JUJU_UNIT_NAME'} || undef;
}


sub remote_unit {
    return $ENV{'JUJU_REMOTE_UNIT'} || undef;
}


sub service_name {
    return (split /\//, local_unit())[0];
}


sub hook_name {
    return $0;
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

App::CharmKit::Helper - charm helpers

=head1 VERSION

version 0.20

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

Wrapper for L<JSON::PP>

=head2 yaml

Wrapper for L<YAML::Tiny>

=head2 tmpl

Wrapper for L<Text::MicroTemplate>

=head2 http

Wrapper for L<HTTP::Tiny>

=head2 config_get

Queries a config option

=head2 relation_get

Gets relation

=head2 relation_set

Relation set

=head2 relation_ids

Get relation ids

=head2 relation_list

Relation list

=head2 unit_get

Get unit information

=head2 unit_private_ip

Get units private ip

=head2 open_port

Open port on service

=head2 close_port

Close port on service

=head2 in_relation_hook

Determine if we're in relation hook

=head2 relation_type

scope for current relation

=head2 relation_id

relation id for current relation hook

=head2 local_unit

local unit id

=head2 remote unit

remote unit for current relation hook

=head2 service_name

name of service running unit belongs too

=head2 hook_name

name of running hook

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
