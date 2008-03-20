use 5.000;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'XTerm::Conf',
    VERSION_FROM        => 'lib/XTerm/Conf.pm',
    EXE_FILES           => ['xterm-conf'],
    PREREQ_PM		=> {
	'Getopt::Long'  => 0,
	'Term::ReadKey' => 0,
    },
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
	(AUTHOR              => 'Slaven Rezic <srezic@cpan.org>',
	 ABSTRACT_FROM       => 'lib/XTerm/Conf.pm') : ()),
);
