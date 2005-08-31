#!perl -T

use Test::More tests=> 4;
use MMS::MailParser;

my $parser;
my $mmsparser;
my $message;
my $parsed;

SKIP: {

  eval {
    require MMS::ProviderMailParser;
    require MMS::MailMessage;
    require MMS::MailMessage::ProviderParsed;
  };

  skip "MMS::* not installed", 4 if $@;
  $mmsparser = new MMS::MailParser;
  $message = $mmsparser->parse_open('t/msgs/Default');
  isa_ok($message, 'MMS::MailMessage');
  is($message->isvalid,1);
  $parsed = $mmsparser->providermailparse;
  isa_ok($parsed, 'MMS::MailMessage::ProviderParsed');
  is($parsed->isvalid,1);

}
