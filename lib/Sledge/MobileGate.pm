package Sledge::MobileGate;

use strict;
use vars qw($VERSION);
$VERSION = '0.15';

1;
__END__

=head1 NAME

Sledge::MobileGate - Sledge�ե졼�����˷����Ѥε�ǽ���ɲ�

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

Sledge::MobileGate ��Sledge�ե졼�����˷����ѤΤ������
��ǽ���ɲä���⥸�塼�뷲�Ǥ���

=head2 diapatch ���ɲ�

��������ü�����Ȥˡ�(i|ez|j)_dipatch_page ��¸�ߤ������
�¹Ԥ��ޤ���

=head2 ��ʸ���ν���

���Ϥ��줿��ʸ���ϼ�ưŪ�ˡ�i-mode �ξ�� &#*****; �η������Ѵ����ޤ���
vodafone �γ�ʸ���� i-mode ���ह�볨ʸ�������ä����ϡ��б�����&#*****;
�Ȥ��������Ѵ����ޤ���̵���ä�����&#v[**]; �Ȥ����������Ѵ����ޤ���

&#v[**]; �Ȥ��������ϡ�Sledge::MobileGate �ȼ��η����Ǥ���

FillInForm�����ľ�������Ϥ��줿�ǡ�����嵭�η�������Х��ʥꥳ���ɤ��ᤷ�ޤ���

HTML�Ȥ��ƽ������˾嵭�η������顢�����������Ƥ��롢ü����
�����������Ƚ�Ǥ��ơ��Х��ʥꥳ���ɤ��ᤷ�ޤ���
���Ρ�����������Ȥ��б����볨ʸ����¸�ߤ��ʤ����ϡ��������ޤ���

=head2 HTML���ѹ�

vodafone �Ǥ� HTML��� istyle -> mode ��accesskey -> directkey ���ѹ�
����ޤ���

Ezweb �ξ�� WAP1 ü���� ����ƥ����� .gif �����ä��� .png �˳�ĥ��
���ѹ�����ޤ���
�ĤޤꡢGIF������Ȥ��Ȥ��ϡ�PNG������Ʊ���ե�����̾���Ѱդ��Ƥ���
ɬ�פ�����ޤ���

�ѥ��åȺ︺�ե��륿���� ���ѥ������ʤ�Ⱦ�ѥ������ʤ��Ѵ���
���򡢲��ԤΤ�Ϣ³�� ����1ʸ���Ѵ������ѱѿ�����Ⱦ���Ѵ�����ޤ���

=head2 �ƥ�ץ졼��

�ʲ���ͥ���̤ǡ��ƥ���ꥢ���ȤΥƥ�ץ졼�Ȥ򸡺���
���Υե����뤬����С������ͥ�褷�ƻ��ѡ�

=item �ե����������

$TMPL_PATH/$DIR/foo.html.ez

$TMPL_PATH/$DIR/foo.html.mobile

=item �ǥ��쥯�ȥ�

$TMPL_PATH/ez/$DIR/foo.html

=item �̾�

$TMPL_PATH/$DIR/foo.html

=head2 mobile �᥽�åɤ��ɲ�

mobile �Ȥ����᥽�åɤ��ɲä��ޤ���

=over 4

=item id

���������桼���θ�ͭID(ez, vodafone�Τ�)���֤��ޤ���

  $self->mobile->id;

docomo, vodafone(�桼��ID���Ȥ�ʤ����)�ϥ�������ü����ü����ͭID(���ꥢ��ʥ�С�)���֤��ޤ���

=item agent

L<HTTP::MobileAgent> �Υ��֥������Ȥ��֤��ޤ���

  if ($self->mobile->agent->is_ezweb) {
      .....  
  }

=item career

��������ü���� ����ꥢ��i, ez, j�Ȥ���ʸ������֤��ޤ���
��������typo�Ǥ�����(��)

  $self->mobile->career;

=item carrier

L<HTTP::MobileAgent> �� carrier ��Ʊ����̤����֤��ޤ���
career �ȤϷ�̤��ۤʤ�Τ���ա�

  $self->mobile->carrier;

=item download

��ü���ˤ��碌����������ɤν�����Ԥ��ޤ���
Content-Type �� URL(QUERY_STRING �դ���) ���������鼫ưŪ��
Ƚ�Ǥ��ƽ��Ϥ��ޤ���

 /dl.cgi?sid=xxxx&file=aaaa.mld

�ʤɤ��Ѥ˻��ѤǤ��ޤ���
Ƚ�ǽ���ʤ��ä����ϡ�"application/x-up-download"�ˤʤ�ޤ���


  $self->mobile->download($content_data, [MIME_TYPE]);

=item output_content

Content-Type �� $self->r->uri �������� .mld .mmf .pmd .gif
.jpg .qcp .png �ξ��ϼ�ưŪ�������� Content-Type ����Ϥ��ޤ���
����ʳ��γ�ĥ�Ҥξ��� "application/x-up-download"�ˤʤ�ޤ���

  $self->mobile->output_content($content_data, [MIME_TYPE]);

=back

=head1 TODO

=over 4

=item vodafon �� ��ʸ��

vodafon �γ�ʸ�����б�ɽ���������롣
patch ���ޡ�

L<http://www.nttdocomo.co.jp/p_s/imode/tag/emoji/list.html#list1>,
L<http://www.dp.j-phone.com/dp/tool_dl/web/picword_top.php>

=item ezweb �� ��ʸ��

ezweb �γ�ʸ�����б�ɽ��������롣
patch ���ޡ�

L<http://www.nttdocomo.co.jp/p_s/imode/tag/emoji/list.html#list1>,
L<http://www.au.kddi.com/ezfactory/tec/spec/3.html>

����Ū��ez�����ȥ���������äƤ���뤬���᡼����ĥ��ʸ����
�б��Ǥ���褦�ˤʤ뤫�⡣

=item ezweb wap1, wap2�ο���ʬ��

�ƥ�ץ졼�ȡ�diapatch �ο���ʬ���� wap1 wap2 �Ȥ����ɲá�


=back

=head1 AUTHOR

KIMURA, takefumi E<lt>takefumi@takefumi.comE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<HTTP::MobileAgent>

=cut
