package Sledge::MobileGate::Mobile;

use strict;
use vars qw($VERSION);
$VERSION = '0.02';

use base qw(
	Sledge::MobileGate::Mobile::Download
);

use HTTP::MobileAgent;

use base qw(Class::Accessor);

__PACKAGE__->mk_ro_accessors(
	'agent',    # HTTP::MobileAgent
	'page',     # Sledge::Pages
	'career',
	'id',
);

# -------------------------------------------------------------------------
# new
#
# -------------------------------------------------------------------------
sub new {
	my $class = shift;
	my $page  = shift;

	my $self = bless {
		agent     => HTTP::MobileAgent->new(),
		page      => $page,
		download  => {},
		career    => "",
		id        => "",
	}, $class;

	$self->{career} = (
		$self->agent->is_docomo  ? "i"  :
		$self->agent->is_ezweb   ? "ez" :
		$self->agent->is_j_phone ? "j"  : undef
	);

	$self->{id} = $self->_id($page);

	return $self;
}

# -------------------------------------------------------------------------
# キャリアごとの端末IDを取得
#
# -------------------------------------------------------------------------
sub _id {
	my $self = shift;
	my $page  = shift;

	if ($self->agent->is_docomo or $self->agent->is_j_phone) {
		return $page->r->header_in('x-jphone-uid');
	}
	elsif ($self->agent->is_ezweb) {
		return $page->r->header_in('x-up-subno');
	}

	return undef;
}

1;
