package charm;
$charm::VERSION = '1.0.6';
# ABSTRACT: charm helpers for App::CharmKit



use strict;
use utf8::all;
use warnings;
use boolean;
use Import::Into;

use feature ();
use Path::Tiny;
use Test::More;
use Test::Exception;

sub import {
    my $target = caller;
    my $class  = shift;

    my @flags = grep /^-\w+/, @_;
    my %flags = map +($_, 1), map substr($_, 1), @flags;

    'strict'->import::into($target);
    'warnings'->import::into($target);
    'utf8::all'->import::into($target);
    'autodie'->import::into($target, ':all');
    'feature'->import::into($target, ':5.14');
    'English'->import::into($target, '-no_match_vars');
    'boolean'->import::into($target, ':all');
    Path::Tiny->import::into($target, qw(path));

    if ($flags{tester}) {
        Test::More->import::into($target);
        Test::Exception->import::into($target);
    }

    # expose system utilities by default
    require 'App/CharmKit/Sys.pm';
    'App::CharmKit::Sys'->import::into($target);

    # data faker utilities
    require 'App/CharmKit/Faker.pm';
    'App::CharmKit::Faker'->import::into($target);

    # expose charm helpers by default
    require 'App/CharmKit/Helper.pm';
    'App::CharmKit::Helper'->import::into($target);

    require 'App/CharmKit/Logging.pm';
    'App::CharmKit::Logging'->import::into($target);

}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

charm - charm helpers for App::CharmKit

=head1 VERSION

version 1.0.6

=head1 SYNOPSIS

  use charm;

  log "Starting install";
  my $ret = execute(['ls', '/tmp']);
  print($ret->{stdout});

=head1 DESCRIPTION

Exposing helper subs from various packages that would be useful in writing
charm hooks. Including but not limited too strict, warnings, utf8, Path::Tiny,
etc ..

=head1 MODULES

List of modules exported by helper:

=over 4

=item *

L<Path::Tiny>

Exposes B<path> routine

=item *

L<YAML::Tiny>

Exposes object as B<yaml>

=item *

L<JSON::PP>

Exposes object as B<json>

=item *

L<Text::MicroTemplate>

Exposes object as B<tmpl>

=item *

L<Test::More>

=item *

L<autodie>

=item *

L<utf8::all>

=item *

L<boolean>

=back

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
