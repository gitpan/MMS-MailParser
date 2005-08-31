#!perl -T

use Test::More tests => 10;
use MMS::MailParser;
use MIME::Parser;

use MMS::ProviderMailParser;

my $mmsparser = new MMS::MailParser;
my $parser= new MIME::Parser;
my $providermailparser = new MMS::ProviderMailParser;

is($mmsparser->output_dir('/tmp/'),'/tmp/');
is($mmsparser->output_dir,'/tmp/');
is($mmsparser->mimeparser($parser),$parser);
is($mmsparser->mimeparser,$parser);
is($mmsparser->providermailparser($providermailparser),$providermailparser);
isa_ok($mmsparser->providermailparser(),'MMS::ProviderMailParser');
is($mmsparser->debug(1),1);
is($mmsparser->debug,1);
is_deeply($mmsparser->errors,[]);
is($mmsparser->lasterror,undef);

