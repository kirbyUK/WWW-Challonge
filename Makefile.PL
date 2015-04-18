use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'WWW::Challonge',
    AUTHOR           => q{Alex Kerr <kirby@cpan.org>},
    VERSION_FROM     => 'lib/WWW/Challonge.pm',
    ABSTRACT_FROM    => 'lib/WWW/Challonge.pm',
    LICENSE          => 'artistic_2',
    PL_FILES         => {},
    MIN_PERL_VERSION => 5.010,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
        'Test::More' => 0,
    },
    PREREQ_PM => {
		"REST::Client"		=> 271,
		"JSON"				=> 2.61,
		"Carp"				=> 1.04,
    },
	META_MERGE => {
		"meta-spec" => { version => 2 },
		resources => {
			repository => {
				type => "git",
				url => "git://github.com/kirbyUK/WWW-Challonge.git",
				web => "https://github.com/kirbyUK/WWW-Challonge",
			},
		},
		release_status => "testing",
	},
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'WWW-Challonge-*' },
);
