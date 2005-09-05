use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'MMS::MailParser',
    AUTHOR              => 'Rob Lee <robl@robl.co.uk>',
    VERSION_FROM        => 'lib/MMS/MailParser.pm',
    ABSTRACT_FROM       => 'lib/MMS/MailParser.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
	'MMS::MailMessage' => 0.02,
	'MIME::Parser' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'MMS-MailParser-*' },
);
