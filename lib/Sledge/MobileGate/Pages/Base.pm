package Sledge::MobileGate::Pages::Base;

use strict;
use vars qw($VERSION);
$VERSION = '0.03';
use base qw(Sledge::Pages::Base);

__PACKAGE__->mk_accessors(
	'mobile'    # Sledge::MobileGate::Mobile
);

use Sledge::Exceptions;
use Sledge::Registrar;
use Sledge::MobileGate::Mobile;
use Sledge::MobileGate::Pictogram;
use Sledge::MobileGate::Filter;

# -------------------------------------------------------------------------
# mobile オブジェクトの作成
#
# -------------------------------------------------------------------------

sub create_mobile { Sledge::Exception::AbstractMethod->throw }

sub init {
	my $self = shift;

	$self->SUPER::init(@_);
	$self->mobile($self->create_mobile);
}

# -------------------------------------------------------------------------
# dispatch
# - キャリアごとの dispatch を追加
#
# -------------------------------------------------------------------------
sub dispatch {
    my($self, $page) = @_;
    return if $self->finished; # already redirected?

    local *Sledge::Registrar::context = sub { $self };
    Sledge::Exception->do_trace(1) if $self->debug_level;
    eval {
        $self->init_dispatch($page);
        $self->invoke_hook('BEFORE_DISPATCH') unless $self->finished;
        unless ($self->finished) {
			my $career =  $self->r->param('_career') || $self->mobile->career();
            my $method = "${career}_dispatch_" . $page;
            $self->$method() if $self->can($method);
        }
        if ($self->is_post_request && ! $self->finished) {
            my $postmeth = 'post_dispatch_' . $page;
            $self->$postmeth() if $self->can($postmeth);
        }
        unless ($self->finished) {
            my $method = 'dispatch_' . $page;
            $self->$method();
            $self->invoke_hook('AFTER_DISPATCH');
        }
        $self->output_content unless $self->finished;
    };
    $self->handle_exception($@) if $@;
    $self->_destroy_me;
}

# -------------------------------------------------------------------------
# 各キャリア用のテンプレートがあったら優先するようにする。
#
# -------------------------------------------------------------------------
sub guess_filename {
	my $self = shift;
	my $page = shift;

    # foo     => $TMPL_PATH/$DIR/foo.html
    # /foo    => $TMPL_PATH/foo.html
    # foo.txt => $TMPL_PATH/$DIR/foo.txt
    my $dir = ($page =~ s,^/,,) ? '' : $self->tmpl_dirname . '/';
    my $suf = $page =~ /\./ ? '' : '.html';
	my $career =  $self->r->param('_career') || $self->mobile->career();

	#
    # $TMPL_PATH/$DIR/foo.html.ez
    # $TMPL_PATH/ez/$DIR/foo.html
	#
	my $c = $self->create_config;
	for my $path (
    	sprintf('%s/%s%s%s.%s',
			$c->tmpl_path, $dir, $page, $suf, $career
		),
    	sprintf('%s/%s/%s%s%s',
			$c->tmpl_path, $career, $dir, $page, $suf
		),
	) {
		return $path if (-f $path);
	}

    # $TMPL_PATH/$DIR/foo.html
	return sprintf('%s/%s%s%s', $c->tmpl_path, $dir, $page, $suf);
}

# -------------------------------------------------------------------------
# FillInFormにする前に絵文字を元に戻す
# 
# -------------------------------------------------------------------------
sub make_content {
	my $self = shift;

	if ($self->fillin_form) {
		for my $p ($self->r->param) {
			my @v = (
				map { $self->decode_pictogram($_) }
				$self->r->param($p)
			);
			$self->r->param($p => \@v);
		}
	}

	return $self->SUPER::make_content();
}

1;
