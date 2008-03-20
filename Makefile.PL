use 5.000;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'XTerm::Config',
    VERSION_FROM        => 'lib/XTerm/Config.pm',
    EXE_FILES           => ['xterm-config'],
    PREREQ_PM		=> {
	'Getopt::Long'  => 0,
	'Term::ReadKey' => 0,
    },
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
	(AUTHOR              => 'Slaven Rezic <srezic@cpan.org>',
	 ABSTRACT_FROM       => 'lib/XTerm/Config.pm') : ()),
);
