#!perl -T

use Test::More tests => 4;
use MMS::MailParser;

my $parser;
my $mmsparser;
my $message;
my $parsed;

SKIP: {

  eval {
    require MMS::ProviderMailParser::UKVodafone;
  };

  skip "MMS::ProviderMailParser::UKVodafone not installed", 4 if $@;

  $parser = new MIME::Parser;
  $mmsparser = MMS::MailParser->new(mimeparser=>$parser);
  $message = $mmsparser->parse_open('t/msgs/UKVodafone');
  isa_ok($message, 'MMS::MailMessage');
  is($message->is_valid,1);
  $parsed = $mmsparser->provider_mail_parse;
  isa_ok($parsed, 'MMS::MailMessage::ProviderParsed');
  is($parsed->is_valid,1);

}
