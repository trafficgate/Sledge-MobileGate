package Sledge::MobileGate::Pictogram;

use strict;
use vars qw($VERSION);
$VERSION = '0.03';

use vars qw(@ISA @EXPORT);

use Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(encode_pictogram decode_pictogram);


use HTML::Entities::ImodePictogram ();
use vars qw(
    %TABLE_I2V
    %TABLE_V2I
);


# -------------------------------------------------------------------------
# エンコード系
#
# -------------------------------------------------------------------------
sub encode_pictogram {
    my $self    = shift;
    my $content = shift;
    my $career  = shift;

    if ($career eq "i" or $self->mobile->agent->is_docomo) {
        $content = HTML::Entities::ImodePictogram::encode_pictogram($content);
    }
    elsif ($career eq "ez" or $self->mobile->agent->is_ezweb) {
        ;
    }
    elsif ($career eq "j" or $self->mobile->agent->is_j_phone) {
		require Sledge::MobileGate::Pictogram::Vodafone;
		import  Sledge::MobileGate::Pictogram::Vodafone;

        $content =~ s/\x1b\$(.+?)\x0f/&_encode_pictogram_j2i($1)/eg;
    }

    return $content;
}

sub _encode_pictogram_j2i {
    my ($key1, @key2) = split //, shift;

    my $str;
    for my $key2 (@key2) {
        my $value = $TABLE_V2I{$key1.$key2};
        $str .= defined $value ? "&#$value;" : "&#v[$key1$key2];";
    }

    return $str;
}

# -------------------------------------------------------------------------
# デコード系
#
# -------------------------------------------------------------------------
sub decode_pictogram {
    my $self    = shift;
    my $content = shift;
    my $career  = shift;

    #
    # DoComo
    #
    if ($career eq "i" or $self->mobile->agent->is_docomo) {
        $content = HTML::Entities::ImodePictogram::decode_pictogram($content);
    }

    #
    # Ezweb
    #
    elsif ($career eq "ez" or $self->mobile->agent->is_ezweb) {
		$content =~ s/\&#v\[(.+?)\];//gi;
    }

    #
    # Vodafone
    #
    elsif ($career eq "j" or $self->mobile->agent->is_j_phone) {
		require Sledge::MobileGate::Pictogram::Vodafone;
		import  Sledge::MobileGate::Pictogram::Vodafone;

        $content =~ s/\&#v\[(.+?)\];/&_decode_pictogram_j($self, $1)/egi;
        $content =~ s/\&#(\d{5}|[A-F0-9]{4});/&_decode_pictogram_i2j($self, $1)/egi;
    }

	#
	# その他
	#
	else {
    	$content =~ s/\&#(\d{5}|[A-F0-9]{4});//gi;
		$content =~ s/\&#v\[(.+?)\];//gi;
	}

    return $content;
}


sub _decode_pictogram_i2j {
	my $self = shift;
    my $num  = shift;

    my $value = $TABLE_I2V{$num};
	&_decode_pictogram_j($self, $value);
}

sub _decode_pictogram_j {
	my $self = shift;
	my $value = shift;

	if (
		# 置換する値が存在しない
		$value eq "" or

		# パケット対応機種じゃなくて、OPQ系だったら表示しない
		(!$self->mobile->agent->packet_compliant and $value =~ /^[OPQ]/)
	) {
		return "";
	}
	else {
    	return "\x1b\$" .$value. "\x0f";
	}
}

1;
