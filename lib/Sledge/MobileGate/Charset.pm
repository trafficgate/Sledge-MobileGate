package Sledge::MobileGate::Charset;

use strict;
use vars qw($VERSION);
$VERSION = '0.01';

use base qw(Sledge::Charset::Shift_JIS);

use Jcode;
use HTML::Entities::ImodePictogram;

sub convert_param {
    my $self = shift;
	my $page = shift;

    for my $p ($page->r->param) {
        my @v = (
			map { Jcode->new($_, 'sjis')->h2z->euc() }
			map { $page->encode_pictogram($_) }
			$page->r->param($p)
		);
        $page->r->param($p => \@v);
    }
    return;
}

1;

__END__
sub content_type {
    return 'text/html; charset=Shift_JIS';
}


1;
