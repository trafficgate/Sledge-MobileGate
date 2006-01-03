package Sledge::MobileGate::Filter;

use strict;
use vars qw($VERSION);
$VERSION = '0.09';

use Jcode;

sub import {
    my $class = shift;
    my $pkg   = caller;

    $pkg->register_hook(
        AFTER_INIT      => \&add_filter,
		BEFORE_DISPATCH => \&filter_mail_pictogram,
    );
}

# -------------------------------------------------------------------------
# 追加するフィルタ
#
# -------------------------------------------------------------------------
sub add_filter {
	my $self = shift;

	unless ($self->mobile->agent->is_non_mobile) {
		$self->add_filter(\&filter_hankaku);
		$self->add_filter(\&filter_pictogram);
	}

	if ($self->mobile->agent->is_ezweb) {
		$self->add_filter(\&filter_ezweb);
	}
	elsif ($self->mobile->agent->is_j_phone) {
		$self->add_filter(\&filter_vodafone);
	}
}

# -------------------------------------------------------------------------
# ezweb向けフィルタ
#
# -------------------------------------------------------------------------
sub filter_ezweb {
	my $self = shift;
	local $_ = shift;

	#
	# XHTML端末じゃなかったら GIF画像を PNG 画像へ
	#
	unless ($self->mobile->agent->xhtml_compliant) {
		s/src\s*=\s*(["'])(.+)\.gif(["'])/src=$1$2.png$3/g;
	}

	return $_;
}

# -------------------------------------------------------------------------
# Vodafone向けフィルタ
#
# -------------------------------------------------------------------------
sub filter_vodafone {
	my $self = shift;
	local $_ = shift;

	#
	# istyle
	#
	my %mode = (
		1 => 'hiragana',
		2 => 'hankakukana',
		3 => 'alphabet',
		4 => 'numeric',
	);
	s/istyle\s*=\s*(["'])(\d)(["'])/mode=$1$mode{$2}$3/g;

	#
	# accesskey
	#
	s/accesskey\s*=\s*(["'])(\d)(["'])/directkey=$1$2$3/g;


	return $_;
}

# -------------------------------------------------------------------------
# 絵文字相互変換
#
# -------------------------------------------------------------------------
sub filter_pictogram {
	my $self    = shift;
	my $content = shift;

	return $self->decode_pictogram($content);
}


# -------------------------------------------------------------------------
# Sledge::Plugin::Mailer と連動
#
# -------------------------------------------------------------------------
sub filter_mail_pictogram {
	my $self = shift;

	if (ref $self->{mailer} eq 'Sledge::Plugin::Mailer::Base') {
		return if ($Sledge::Plugin::Mailer::VERSION < 0.04);

		shift @{$self->mailer->{filters}};
		$self->mailer->add_filter ( \&_filter_mail_pictogram );
	}
}

sub _filter_mail_pictogram {
    my $self    = shift;   # Sledge::Plugin::Mailer
    my $content = Jcode->new(shift)->jis;

    $content =~ /To:.+\@(.+?)\./i;
    my $career = $1;
    $career = (
        ($career eq 'docomo')?   'i'  :
        ($career eq 'ezweb')?    'ez' :
        ($career eq 'vodafone')? 'j'  : ''
    );

    #
    # 絵文字相互変換
    #
    $content =  $self->{sledge}->decode_pictogram($content, $career);

    #
    # MIMEヘッダ
    #
    my @mail = split /\r\n|\r|\n/, $content;
    for my $mail (@mail) {
        next if ($mail =~ /Subject:/i);
        last if ($mail eq "");
        $mail = Jcode->new($mail)->mime_encode;
    }
    $content = join("\n", @mail);

    return $content;
}

# -------------------------------------------------------------------------
# 半角変換
#
# -------------------------------------------------------------------------
sub filter_hankaku {
	my $self = shift;
	my $content = shift;

	$content = Jcode->new($content, 'sjis')->z2h->sjis;
	$content =~ s/[\s\n\r]{2,}/\n/g;

	#
	# FIXME: 記号は対応しない?
	# というか、カタカナもケースバイケース。ここでやるのはビミョウかもね。
	#
	#eval{require Lingua::JA::Regular;};
	#unless ($@) {
	#	$content = Lingua::JA::Regular->new($content, 'sjis')->h_ascii->to_s;
	#}

	return $content;
}

1;
