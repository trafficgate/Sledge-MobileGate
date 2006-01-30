package Sledge::MobileGate;

use strict;
use vars qw($VERSION);
$VERSION = '0.15';

1;
__END__

=head1 NAME

Sledge::MobileGate - Sledgeフレームワークに携帯用の機能を追加

=head1 SYNOPSIS

  package Project::Pages;

  use Sledge::MobileGate::Pages::Compat;
  use Sledge::MobileGate::Charset;
  use Sledge::MobileGate::Mobile;

  sub create_mobile {
      my $self = shift;
      return Sledge::MobileGate::Mobile->new($self);
  }

  sub create_charset {
      my $self = shift;

      return Sledge::MobileGate::Charset->new($self);
  }

=head1 DESCRIPTION

Sledge::MobileGate はSledgeフレームワークに携帯用のいろいろな
機能を追加するモジュール群です。

=head2 diapatch の追加

アクセス端末ごとに、(i|ez|j)_dipatch_page が存在した場合
実行します。

=head2 絵文字の処理

入力された絵文字は自動的に、i-mode の場合 &#*****; の形式に変換します。
vodafone の絵文字は i-mode に類する絵文字があった場合は、対応する&#*****;
という形に変換します。無かった場合は&#v[**]; という形式に変換します。

&#v[**]; という形式は、Sledge::MobileGate 独自の形式です。

FillInFormされる直前、入力されたデータを上記の形式からバイナリコードに戻します。

HTMLとして出力前に上記の形式から、アクセスしている、端末の
エージェント判断して、バイナリコードに戻します。
その、エージェントで対応する絵文字が存在しない場合は、削除されます。

=head2 HTMLの変更

vodafone では HTML上の istyle -> mode 、accesskey -> directkey に変更
されます。

Ezweb の場合 WAP1 端末で コンテンツ内に .gif があったら .png に拡張子
を変更されます。
つまり、GIF画像を使うときは、PNG画像も同じファイル名で用意しておく
必要があります。

パケット削減フィルター。 全角カタカナは半角カタカナに変換、
空白、改行のの連続は 改行1文字変換、全角英数字は半角変換されます。

=head2 テンプレート

以下の優先順位で、各キャリアごとのテンプレートを検索し
そのファイルがあれば、それを優先して使用。

=item ファイルの末尾

$TMPL_PATH/$DIR/foo.html.ez

$TMPL_PATH/$DIR/foo.html.mobile

=item ディレクトリ

$TMPL_PATH/ez/$DIR/foo.html

=item 通常

$TMPL_PATH/$DIR/foo.html

=head2 mobile メソッドの追加

mobile というメソッドを追加します。

=over 4

=item id

アクセスユーザの固有ID(ez, vodafoneのみ)を返します。

  $self->mobile->id;

docomo, vodafone(ユーザIDがとれない場合)はアクセス端末の端末固有ID(シリアルナンバー)を返します。

=item agent

L<HTTP::MobileAgent> のオブジェクトを返します。

  if ($self->mobile->agent->is_ezweb) {
      .....  
  }

=item career

アクセス端末の キャリア（i, ez, jという文字列）返します。
が、これtypoでした。(恥)

  $self->mobile->career;

=item carrier

L<HTTP::MobileAgent> の carrier と同じ結果がを返します。
career とは結果が異なるので注意。

  $self->mobile->carrier;

=item download

各端末にあわせたダウンロードの処理を行います。
Content-Type は URL(QUERY_STRING ふくむ) の末尾から自動的に
判断して出力します。

 /dl.cgi?sid=xxxx&file=aaaa.mld

などの用に使用できます。
判断出来なかった場合は、"application/x-up-download"になります。


  $self->mobile->download($content_data, [MIME_TYPE]);

=item output_content

Content-Type は $self->r->uri の末尾が .mld .mmf .pmd .gif
.jpg .qcp .png の場合は自動的に正しい Content-Type を出力します。
それ以外の拡張子の場合は "application/x-up-download"になります。

  $self->mobile->output_content($content_data, [MIME_TYPE]);

=back

=head1 TODO

=over 4

=item vodafon の 絵文字

vodafon の絵文字の対応表を完成させる。
patch 歓迎。

L<http://www.nttdocomo.co.jp/p_s/imode/tag/emoji/list.html#list1>,
L<http://www.dp.j-phone.com/dp/tool_dl/web/picword_top.php>

=item ezweb の 絵文字

ezweb の絵文字の対応表も作成する。
patch 歓迎。

L<http://www.nttdocomo.co.jp/p_s/imode/tag/emoji/list.html#list1>,
L<http://www.au.kddi.com/ezfactory/tec/spec/3.html>

基本的にezゲートウエイがやってくれるが、メールや拡張絵文字に
対応できるようになるかも。

=item ezweb wap1, wap2の振り分け

テンプレート、diapatch の振り分けに wap1 wap2 とかを追加。


=back

=head1 AUTHOR

KIMURA, takefumi E<lt>takefumi@takefumi.comE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<HTTP::MobileAgent>

=cut
