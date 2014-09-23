package App::CharmKit;
$App::CharmKit::VERSION = '0.002';
# ABSTRACT: Perl Framework for authoring Juju charms

use strict;
use warnings;
use App::Cmd::Setup -app;

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

App::CharmKit - Perl Framework for authoring Juju charms

=head1 VERSION

version 0.002

=head1 OVERVIEW

A perl way to charm authoring. CharmKit allows the creation of charm
projects for publishing to the Charm Store. In addition, there is built in
charm linter, packaging of all hooks and their dependencies, testing framework,
and helper routines to aide in the development of charms.

=head2 DIRECTORY LAYOUT

A charm directory created with CharmKit is:

  charm-project/
    hooks/
      install
      config-changed
      start
      stop
    src/
      hooks/
        install
        config-changed
        start
        stop
      tests/
        00-basic.test
    tests/
      00-basic.test
    config.yaml
    metadata.yaml
    LICENSE
    README.md

=head2 WORKFLOW

All development happens within B<src/> and the builtin C<pack> command
is used for generating the proper hooks/tests and dependencies within that
directory so Juju is able to act upon them. Hooks within B<hooks/> directory
are always overwritten, think of this similar to a B<dist> or B<release> directory.

To start a project:

  $ charmkit init [--with-hooks] <charm-name>

If used C<--with-hooks> then B<src/hooks/> will be populated with all the default
hooks. A few questions will be prompted and then the project is generated with
B<config.yaml, metadata.yaml, LICENSE, and README.md>.

In order to create additional hooks:

  $ charmkit generate -r database-relation-joined
  $ charmkit generate upgrade-charm

=head2 WRITING A HOOK

Hooks are written using perl with automatically imported helpers for convenience.
When developing hooks they should reside in B<src/hooks>.

A typical hook starts with

   #!/usr/bin/env perl

   use charm -helper, -logging;

   log 'Starting install hook for database';
   my $dbhost = relation_get 'dbhost';
   my $dbuser = relation_get 'dbuser';

=head2 WRITING A TEST

Tests are written in the same way and should live in B<src/tests/*.test>.

A typical test starts with

   #!/usr/bin/env perl

   use charm -tester, -sys;

   # See if an nginx config file exists
   ok -e '/etc/nginx/sites-enabled/mysite.com';

   my $cmd = ['service', 'nginx', 'status'];
   my $ret = execute($cmd);
   ok $ret->{error} eq 0;

   # finish tests
   done_testing;

Tests are built in a way that the test runner from the charm reviewers will be
able to run and validate your charm. The tests can be executed calling them directly
(how the test runner does it) or running with:

   $ prove tests/*.test

=head2 PACKAGING A CHARM FOR RELEASE

Once development is complete and you have your hooks defined and tests written.
Packaging a charm for release to either Git or the Charm Store is a matter of running:

  $ charmkit pack

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
