package App::CharmKit::Logging;
$App::CharmKit::Logging::VERSION = '1.0.6';
# ABSTRACT: reporting utilities

use strict;
use warnings;
use Data::Dumper;
use App::CharmKit::Sys qw/execute/;
use base "Exporter::Tiny";

our @EXPORT = qw/log prettyLog/;

sub log {
    my $message = shift;
    my $level = shift || undef;
    my $cmd = ['juju-log'];
    if ($level) {
      push @{$cmd}, '-l';
      push @{$cmd}, $level;
    }
    push @{$cmd}, $message;
    execute($cmd);
}

sub prettyLog {
    my $obj = shift;
    print Dumper($obj);
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

App::CharmKit::Logging - reporting utilities

=head1 VERSION

version 1.0.6

=head1 SYNOPSIS

Directly,

  use App::CharmKit::Logging;

Or sugar,

  use charm;

  log 'this is a log emitter';

=head1 DESCRIPTION

Reporting utilities

=head1 FUNCTIONS

=head2 log

Utilizies juju-log for any additional logging

=head2 prettyLog

Dumps the perl data structure into something readable

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
