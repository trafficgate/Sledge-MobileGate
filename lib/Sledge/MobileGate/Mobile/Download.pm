package Sledge::MobileGate::Mobile::Download;

use strict;
use vars qw($VERSION);
$VERSION = '0.04';

use constant MIME_TYPES => {
	mld => 'application/download',
	mmf => 'application/x-smaf',
	pmd => 'application/x-pmd',
	gif => 'image/gif',
	jpg => 'image/jpeg',
	qcp => 'audio/vnd',
	png => 'image/png',
	amc => 'application/x-mpeg',
	'3g2' => 'video/3gpp2',
};

sub download {
	my $self = shift;
	my $contents = shift;
	$self->{download}->{mime_type} = shift;

	my $method = "download_" . $self->career();
	return $self->$method($contents);
}

sub mime_type {
	my $self = shift;
	
	my $url = $self->page->r->uri;
	$url .= '?' . $self->page->r->args if $self->page->r->args;
	$url =~ /\.(\w+)$/;

	return (
		$self->{download}->{mime_type} ||
		MIME_TYPES->{$1} ||
		"application/x-up-download"
	);
}

sub output_content {
	my $self = shift;
	my $content = shift;

    $self->page->r->content_type( $self->mime_type() );
	$self->page->r->header_out("Content-Length" => length($content));
    $self->page->r->send_http_header;
	$self->page->r->print($content);
    $self->page->finished(1);

	return 1;
}

sub download_i {
	my $self = shift;
	return $self->output_content(@_);
}

sub download_j {
	my $self = shift;
	return $self->output_content(@_);
}

sub download_ez {
	my $self = shift;
	my $content = shift;

    my $offsetx = $self->page->r->param('offset');
    my $countx  = $self->page->r->param('count');

	#
	# コンテンツダウンロード
	#
	if( $offsetx >= 0 and $countx > 0 ){
    	$self->page->r->content_type("application/x-up-download");
		my $data = substr($content, $offsetx, $countx);
        $self->page->r->header_out("Content-Length" => length($data));

        $self->page->r->send_http_header;
        $self->page->r->print($data);
        $self->page->finished(1);

        return;
    }

	#	
	# If &receipt was appended to the download request,
	# the device will request a buffer of size count=0
	# to indicate completion; so, return an "empty"
	# download header
	#	
	elsif( $offsetx == 0 and $countx == 0 ){
    	#$self->page->r->content_type( $self->mime_type() );
    	$self->page->r->content_type("application/x-up-download");
        $self->page->r->header_out("Content-Length" => 0);
        $self->page->r->send_http_header;
        $self->page->finished(1);
        return;
    }

    #
    # ダウンロード成功
    #
    elsif( $offsetx == -1 && $countx == -1 ){
		$self->download_ez_result(1);
        return 1;
    }

    #
    # ダウンロード失敗
    #
	else {
		$self->download_ez_result(0);
        return 0;
    }
}

sub download_ez_result {
	my $self = shift;
	my $result = (shift)? "成功" : "失敗";

	my ($content,) = (
		qq{<HDML VERSION="3.0" TTL="0" PUBLIC="TRUE">\n} .
		qq{<display>ﾀﾞｳﾝﾛｰﾄﾞが$resultしました\n} .
		qq{</display>\n} .
		qq{</HDML>\n}
	);


    $self->page->r->content_type("text/x-hdml;charset=Shift_JIS");
    $content = Jcode->new($content, 'euc')->sjis;
    $self->page->set_content_length(length $content);
    $self->page->send_http_header;
    $self->page->r->print($content);
    $self->page->invoke_hook('AFTER_OUTPUT');
    $self->page->finished(1);
}

1;
