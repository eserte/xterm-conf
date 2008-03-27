use 5.005;
use ExtUtils::MakeMaker;

$is_devel_host = defined $ENV{USER} && $ENV{USER} eq 'eserte' && $^O =~ /bsd/i && -f "../../perl.release.mk";

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

sub MY::postamble {
    my $postamble = '';

    if ($is_devel_host) {
	$postamble .= <<'EOF';

.include "../../perl.release.mk"
.include "../../perl.cvs.mk"

EOF
    }

    $postamble;
}
