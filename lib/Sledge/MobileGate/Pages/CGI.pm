package Sledge::MobileGate::Pages::CGI;

use strict;
use base qw(Sledge::MobileGate::Pages::Base);

use CGI;
use Sledge::Request::CGI;

sub create_request {
    my($self, $query) = @_;
    return Sledge::Request::CGI->new($query || CGI->new);
}

1;
