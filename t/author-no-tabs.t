
BEGIN {
  unless ($ENV{AUTHOR_TESTING}) {
    require Test::More;
    Test::More::plan(skip_all => 'these tests are for testing by the author');
  }
}

use strict;
use warnings;

# this test was generated with Dist::Zilla::Plugin::Test::NoTabs 0.09

use Test::More 0.88;
use Test::NoTabs;

my @files = (
    'bin/charmkit',
    'bin/juju-ck',
    'lib/App/CharmKit.pm',
    'lib/App/CharmKit/Command/clean.pm',
    'lib/App/CharmKit/Command/generate.pm',
    'lib/App/CharmKit/Command/init.pm',
    'lib/App/CharmKit/Command/pack.pm',
    'lib/App/CharmKit/Command/test.pm',
    'lib/App/CharmKit/Helper.pm',
    'lib/App/CharmKit/Logging.pm',
    'lib/App/CharmKit/Manual.pod',
    'lib/App/CharmKit/Manual/GettingStarted.pod',
    'lib/App/CharmKit/Role/Clean.pm',
    'lib/App/CharmKit/Role/Generate.pm',
    'lib/App/CharmKit/Role/Init.pm',
    'lib/App/CharmKit/Role/Pack.pm',
    'lib/App/CharmKit/Sys.pm',
    'lib/charm.pm',
    't/00-sugar.t',
    't/author-no-tabs.t',
    't/release-minimum-version.t'
);

notabs_ok($_) foreach @files;
done_testing;
