package Sledge::MobileGate::Pages::Compat;

use strict;
use constant MOD_PERL => defined $ENV{MOD_PERL};

sub import {
    my $base = MOD_PERL ? 'Sledge::MobileGate::Pages::Apache' : 'Sledge::MobileGate::Pages::CGI';

    eval qq{require $base};
    {
        my $pkg = caller;
        no strict 'refs';
        unshift @{"$pkg\::ISA"}, $base;
    }
}

1;
