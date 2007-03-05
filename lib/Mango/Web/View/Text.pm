# $Id$
package Mango::Web::View::Text;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Web::View::HTML/;
};

sub process {
    my ($self, $c) = (shift, shift);

    $self->NEXT::process($c, @_);
    $c->res->content_type('text/plain; charset=utf-8');

    return 1;
};

=head1 NAME

MyApp::View::Text - TT View for MyApp

=head1 DESCRIPTION

TT View for MyApp. 

=head1 AUTHOR

=head1 SEE ALSO

L<MyApp>

A clever guy

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;