package Sledge::MobileGate::Pages::Apache;

use strict;
use base qw(Sledge::MobileGate::Pages::Base);

use Apache;
use Apache::Request;

sub create_request {
    my($self, $r) = @_;
    my $req = Apache::Request->new($r || Apache->request);
    $req->param;                # do parse here
    return $req;
}

1;
