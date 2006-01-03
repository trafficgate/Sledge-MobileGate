use strict;
use warnings;
use Test::More tests => 3;

sub register_hook { "dummy function for test" }
BEGIN { use_ok 'Sledge::MobileGate::Filter' }

# escape &<>" 0.14�ǥ��������פ��ʤ��褦�ˤ����Τǡ� is -> inst 
isnt Sledge::MobileGate::Filter::filter_hankaku('dummy self', "a\x81\x95\x81\x83\x81\x84\x81\x68"), 'a&amp;&lt;&gt;&quot;', 'sanitize zenkaku-character';


# ���������פ���ʤ�����
is Sledge::MobileGate::Filter::filter_hankaku('dummy self', "a\x81\x95\x81\x83\x81\x84\x81\x68"), "a\x81\x95\x81\x83\x81\x84\x81\x68", 'sanitize zenkaku-character';

