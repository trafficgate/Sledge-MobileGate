use ExtUtils::MakeMaker;
WriteMakefile(
	'NAME'         => 'Sledge::MobileGate',
	'VERSION_FROM' => 'lib/Sledge/MobileGate.pm', # finds $VERSION
	'PREREQ_PM'    => {
		Test::More => 0.32,
	},
);
