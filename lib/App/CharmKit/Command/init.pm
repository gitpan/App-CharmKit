package App::CharmKit::Command::init;
$App::CharmKit::Command::init::VERSION = '0.20';
# ABSTRACT: Generate a charm project



use strict;
use warnings;
use Path::Tiny;
use File::chdir;
use IO::Prompter [-verb];
use App::CharmKit -command;

use parent 'App::CharmKit::Role::Init', 'App::CharmKit::Role::Generate';

sub opt_spec {
    return (
        [   "category=s",
            "charm category: applications(default), app-servers, "
              . "cache-proxy, databases, file-servers, misc",
            {default => 'applications'}
        ],
        ["with-hooks", "build directory with generated hook files"]
    );
}

sub usage_desc {'%c init [--options] <charm-name>'}

sub validate_args {
    my ($self, $opt, $args) = @_;
    if ($opt->{category} !~
        /^applications|app-servers|cache-proxy|databases|file-servers|misc/)
    {
        $self->usage_error("Incorrect type specified, see help.");
    }

    $self->usage_error("Needs a project name") unless defined $args->[0];

    if ($args->[0] =~ /^[0-9\-]|\-$/) {
        $self->usage_error(
            "Name must start with [a-z] and not end with a '-'");
    }
}

sub execute {
    my ($self, $opt, $args) = @_;
    my $path    = path(shift @{$args});
    my $project = {};
    if ($path->exists) {
        $self->usage_error("Project already exists at $path,"
              . "please pick a new one or remove that directory.");
    }
    printf("Initializing project %s\n", $path->absolute);

    my $default_maintainer = 'Joe Hacker <joe.hacker@mail.com>';
    my $default_category   = $opt->{category};
    @ARGV = ();    # IO::Prompter workaround
    $project->{name} = prompt "Name [default $path]:", -def => "$path";
    $project->{version} = prompt "Version [default 0.0.1]:", -def => '0.0.1';
    $project->{summary} = prompt 'Summary:', -def => 'WRITE A SUMMARY';
    $project->{description} = prompt 'Description:',
      -def => 'WRITE A DESCRIPTION';
    $project->{maintainer} =
      prompt "Maintainer [default $default_maintainer]:",
      -def => $default_maintainer;
    $project->{categories} = [
        prompt "Category [default: $default_category]:",
        -def => $default_category
    ];
    $project->{license} = prompt 'License [? for list]:',
      -menu => {
        agpl_3      => 'AGPL_3',
        apache_2_0  => 'Apache_2_0',
        artistic_1  => 'Artistic_1_0',
        artistic_2  => 'Artistic_2_0',
        bsd         => 'BSD',
        gpl_2       => 'GPL_2',
        gpl_3       => 'GPL_3',
        lgpl_2_1    => 'LGPL_2_1',
        lgpl_3_0    => 'LGPL_3_0',
        mit         => 'MIT',
        perl_5      => 'Perl_5'
      },
      '>';

    $self->init($path, $project);
    if ($opt->{with_hooks}) {
        {
            local $CWD = $path->absolute;
            $self->create_all_hooks;
        }
    }
    printf("Project skeleton created.\n");
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

App::CharmKit::Command::init - Generate a charm project

=head1 VERSION

version 0.20

=head1 SYNOPSIS

Create a directory suitable for charm authoring with optional
hook generation.

  $ charmkit init [--with-hooks] <charm-name>

=head1 OPTIONS

=head2 with-hooks

Generates charm hooks during init.

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
