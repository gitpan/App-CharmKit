use 5.006;
use strict;
use warnings;

# this test was generated with Dist::Zilla::Plugin::Test::Compile 2.046

use Test::More  tests => 22 + ($ENV{AUTHOR_TESTING} ? 1 : 0);



my @module_files = (
    'App/CharmKit.pm',
    'App/CharmKit/Cast.pm',
    'App/CharmKit/Command/clean.pm',
    'App/CharmKit/Command/clone.pm',
    'App/CharmKit/Command/deploy.pm',
    'App/CharmKit/Command/generate.pm',
    'App/CharmKit/Command/init.pm',
    'App/CharmKit/Command/lint.pm',
    'App/CharmKit/Command/pack.pm',
    'App/CharmKit/Command/test.pm',
    'App/CharmKit/Faker.pm',
    'App/CharmKit/Helper.pm',
    'App/CharmKit/Logging.pm',
    'App/CharmKit/Role/Clean.pm',
    'App/CharmKit/Role/Generate.pm',
    'App/CharmKit/Role/Git.pm',
    'App/CharmKit/Role/Init.pm',
    'App/CharmKit/Role/Lint.pm',
    'App/CharmKit/Role/Pack.pm',
    'App/CharmKit/Sys.pm',
    'charm.pm'
);

my @scripts = (
    'bin/charmkit'
);

# no fake home requested

my $inc_switch = -d 'blib' ? '-Mblib' : '-Ilib';

use File::Spec;
use IPC::Open3;
use IO::Handle;

open my $stdin, '<', File::Spec->devnull or die "can't open devnull: $!";

my @warnings;
for my $lib (@module_files)
{
    # see L<perlfaq8/How can I capture STDERR from an external command?>
    my $stderr = IO::Handle->new;

    my $pid = open3($stdin, '>&STDERR', $stderr, $^X, $inc_switch, '-e', "require q[$lib]");
    binmode $stderr, ':crlf' if $^O eq 'MSWin32';
    my @_warnings = <$stderr>;
    waitpid($pid, 0);
    is($?, 0, "$lib loaded ok");

    if (@_warnings)
    {
        warn @_warnings;
        push @warnings, @_warnings;
    }
}

foreach my $file (@scripts)
{ SKIP: {
    open my $fh, '<', $file or warn("Unable to open $file: $!"), next;
    my $line = <$fh>;

    close $fh and skip("$file isn't perl", 1) unless $line =~ /^#!\s*(?:\S*perl\S*)((?:\s+-\w*)*)(?:\s*#.*)?$/;
    my @flags = $1 ? split(' ', $1) : ();

    my $stderr = IO::Handle->new;

    my $pid = open3($stdin, '>&STDERR', $stderr, $^X, $inc_switch, @flags, '-c', $file);
    binmode $stderr, ':crlf' if $^O eq 'MSWin32';
    my @_warnings = <$stderr>;
    waitpid($pid, 0);
    is($?, 0, "$file compiled ok");

   # in older perls, -c output is simply the file portion of the path being tested
    if (@_warnings = grep { !/\bsyntax OK$/ }
        grep { chomp; $_ ne (File::Spec->splitpath($file))[2] } @_warnings)
    {
        warn @_warnings;
        push @warnings, @_warnings;
    }
} }



is(scalar(@warnings), 0, 'no warnings found') or diag 'got warnings: ', explain \@warnings if $ENV{AUTHOR_TESTING};

