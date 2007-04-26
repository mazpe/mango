# $Id$
package Mango::Catalyst::View::HTML;
use strict;
use warnings;

BEGIN {
    use base qw/Catalyst::View::TT/;
};

sub process {
    my ($self, $c) = (shift, shift);

    $self->NEXT::process($c, @_);
    $c->res->content_type('text/html; charset=utf-8');

    return 1;
};

1;
__END__

=head1 NAME

Mango::Catalyst::View::HTML - View class for HTML output

=head1 SYNOPSIS

    $c->view('HTML');

=head1 DESCRIPTION

Mango::Catalyst::View::HTML renders content using Catalyst::View::TT and
serves it with the following content type:

    text/html; charset=utf-8

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
