use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Data::Typed::Expression',
    AUTHOR              => 'Przemyslaw Wesolek <jest@go.art.pl>',
    VERSION_FROM        => 'lib/Data/Typed/Expression.pm',
    ABSTRACT_FROM       => 'lib/Data/Typed/Expression.pm',
    LICENSE             => 'artistic_2',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'Test::Exception' => 0.21,
        'Text::Balanced' => 0,
        'Carp' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Data-Typed-Expression-*' },
);
