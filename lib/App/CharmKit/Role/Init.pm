package App::CharmKit::Role::Init;
$App::CharmKit::Role::Init::VERSION = '0.003_2';
# ABSTRACT: Initialization of new charms

use Carp;
use YAML::Tiny;
use Software::License;
use Moo::Role;

sub init {
    my ($self, $path, $project) = @_;
    $path->child('hooks')->mkpath     or die $!;
    $path->child('tests')->mkpath     or die $!;
    $path->child('src/hooks')->mkpath or die $!;
    $path->child('src/tests')->mkpath or die $!;

    # .gitignore
    (   my $gitignore = qq{
fatlib
blib/
.build/
_build/
cover_db/
inc/
Build
!Build/
Build.bat
.last_cover_stats
Makefile
Makefile.old
MANIFEST.bak
MYMETA.*
nytprof.out
pm_to_blib
!META.json
.tidyall.d
_build_params
perltidy.LOG
}
    );
    $path->child('.gitignore')->spew_utf8($gitignore);

    # tests/tests.yaml
    my $yaml = YAML::Tiny->new({packages => ['perl']});
    $yaml->write($path->child('tests/tests.yaml'));

    # src/tests/00-basic.test
    (   my $basic_test =
          qq{#!/usr/bin/env perl

use charm -tester;

# How to write test using Test::More
use_ok('App::CharmKit');
done_testing;
}
    );
    $path->child('src/tests/00-basic.test')->spew_utf8($basic_test);

    # metadata.yaml
    $yaml = YAML::Tiny->new($project);
    $yaml->write($path->child('metadata.yaml'));

    # config.yaml
    $path->child('config.yaml')->touch;

    # LICENSE
    my $class = "Software::License::" . $project->{license};
    eval "require $class;";
    my $license = $class->new({holder => $project->{maintainer}});
    my $year    = $license->year;
    my $notice  = $license->notice;
    $path->child('LICENSE')->spew_utf8($license->fulltext);

    # README.md
    (   my $readme = qq{
# $project->{name} - $project->{summary}

$project->{description}

# AUTHOR

$project->{maintainer}

# COPYRIGHT

$year $project->{maintainer}

# LICENSE

$notice
}
    );
    $path->child('README.md')->spew_utf8($readme);

}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

App::CharmKit::Role::Init - Initialization of new charms

=head1 VERSION

version 0.003_2

=head1 METHODS

=head2 init(Path::Tiny path, HASH project)

Builds the initialization directory structure for
charm authoring.

B<hooks/> is where the finalized charms are built

B<tests/> is for tests

B<src/hooks/> is where all hook development happens

B<project> hash can consist of the following:

    name => 'charm-test'
    summary => 'charm summary'
    description => 'extended description'
    maintainer => 'Joe Hacker'

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
