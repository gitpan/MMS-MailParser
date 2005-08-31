package MMS::MailParser;

use warnings;
use strict;
use IO::Wrap;
use IO::File;
use MIME::Parser;

use MMS::MailMessage;

#  These are eval'd so the user doesn't have to install all ProviderParsers
eval {
  use MMS::ProviderMailParser;
  use MMS::ProviderMailParser::UKVodafone;
};

=head1 NAME

MMS::MailParser - A class for parsing MMS (or picture) messages.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

This class takes an MMS message and parses it into two 'standard' formats (an MMS::MailMessage and MMS::MailMessage::ProviderParsed) for further use.  It is intended to make parsing MMS messages network/provider agnostic such that a 'standard' object results from parsing, independant of the network/provider it was sent through.

=head2 Code usage example 

This example demonstrates the use of the two stage parse.  The first pass provides an MMS::MailMessage object that is then passed through to the providermailparse message that attempts to determine the Network provider the message was sent through and extracts the relevant information and places it into an MMS::MailMessage::ProviderParsed object.

    use MMS::MailParser;
    my $mms = MMS::MailParser->new();
    my $message = $mms->parse(\*STDIN);
    if (defined($message)) {
      my $parsed = $mms->providermailparse;
      print $parsed->subject."\n";
    }

=head2 Examples of input

    MMS::Parser has the same input methods as MIME::Parser.

    # Parse from a filehandle:
    $entity = $parser->parse(\*STDIN);

    # Parse an in-memory MIME message: 
    $entity = $parser->parse_data($message);

    # Parse a file based MIME message:
    $entity = $parser->parse_open("/some/file.msg");

    # Parse already-split input (as "deliver" would give it to you):
    $entity = $parser->parse_two("msg.head", "msg.body");

=head2 Examples of parser modification

MMS::MailParser uses MIME::Parser as it's parsing engine.  The MMS::MailParser class creates it's own MIME::Parser object if one is not passed in via the new or mimeparser method.  There are a number of reasons for providing your own parser such as forcing all attachment storage to be done in memory than on disk (providing a speed increase to your application at the cost of memory usage).

    my $parser = new MIME::Parser;
    $parser->output_to_core(1);
    my $mmsparser = new MMS::MailParser;
    $mmsparser->mimeparser($parser);
    my $message = $mmsparser->parse(\*STDIN);
    if (defined($message)) {
      my $parsed = $mms->providermailparse;
    }

=head2 Examples of error handling
    
The parser contains an error stack and will ultimately return an undef value from any of the main parse methods if an error occurs.  The last error message can be retreived by calling lasterror method.

    my $message = $mmsparser->parse(\*STDIN);
    unless (defined($message)) {
      print STDERR $mmsparser->lasterror."\n";
      exit(0);
    }

=head2 Miscellaneous methods

There are a small set of miscellaneous methods available.  The output_dir method is provided so that a new MIME::Parser object does not have to be created to supply a separate storage directory for parsed attachments (however any attachments created as part of the process are removed when the message object is detroyed so the lack of specification of a storage location is not a huge issue ).

    # Provide debug ouput to STDERR
    $mmsparser->debug(1);

    # Set an output directory for MIME::Parser 
    $mmsparser->output_dir('/tmp');
    
    # Get/set an array reference to the error stack
    my $errors = $mmsparser->errors;

    # Get/set the MIME::Parser object used by MMS::Parser
    $mmsparser->mimeparser($parser);

=head2 Tutorial

A thorough tutorial can be accessed at http://www.robl.co.uk/redirects/articles/mmsmailparser/

=head1 METHODS

 The following are the top-level methods of MMS::MailParser object.

=head2 Constructor

=over 

=item new()

Return a new MMS::MailParser object. Valid attributes are:

=over

=item mimeparser MIME::Parser

Passed as an array reference, parser specifies the MIME::Parser object to use instead of MMS::MailParser creating it's own.

=item debug INTEGER

Passed as an array reference, debug determines whether debuging information is outputted to standard error (default 0)	

=back

=back

=head2 Regular Methods

=over

=item parse INSTREAM

Returns an MMS::MailMessage object by parsing the input stream INSTREAM

=item parse_data DATA 

Returns an MMS::MailMessage object by parsing the in memory string DATA

=item parse_open EXPR

Returns an MMS::MailMessage object by parsing the file specified in EXPR

=item parse_two HEADFILE, BODYFILE

Returns an MMS::MailMessage object by parsing the header and body file specified in HEADFILE and BODYFILE

=item providermailparse MMS::MailMessage

Returns an MMS::MailMessage::ProviderParsed object by attempting to discover the network provider the message was sent through and parsing through the appropriate MMS::ProviderMailParser.  If an MMS::MailMessage object is supplied as an argument then the providermailparse method will parse the supplied MMS::MailMessage object.  If a providermailparser has been set via the providermailparser method then that parser will be used by providermailparse instead of attempting to discover the network provider from the MMS::MailMessage.

=item output_dir DIRECTORY

Returns the output_dir parameter used with the MIME::Parser object when invoked with no argument supplied.  When an argument is supplied it sets the output_dir used by the MIME::Parser to the value of the argument supplied.

=item mimeparser MIME::Parser

Returns the MIME::Parser object used by MMS::MailParser (if created) when invoked with no argument supplied.  When an argument is supplied it sets the MIME::Parser object used by MMS::MailParser to parse messages.

=item providermailparser CLASSNAME

Returns a string denoting the currently set providermailparser when invoked with no argument supplied.  When an argument is supplied it sets the providermailparser classname used to parse messages (e.g. 'MMS::ProviderMailParser::UKVodafone').

=item errors 

Returns the error stack used by the MMS::MailParser object as an array reference.

=item lasterror

Returns the last error from the stack.

=item debug INTEGER

Returns a number indicating whether STDERR debugging output is active (1) or not (0).  When an argument is supplied it sets the debug property to that value.

=back

=head1 AUTHOR

Rob Lee, C<< <robl@robl.co.uk> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-mms-mailparser@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=MMS-MailParser>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 NOTES

To quote the perl artistic license ('perldoc perlartistic') :

10. THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
    WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES
    OF MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.

=head1 ACKNOWLEDGEMENTS

As per usual this module is sprinkled with a little Deb magic.

=head1 COPYRIGHT & LICENSE

Copyright 2005 Rob Lee, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

sub new {
  my $type = shift;
  my $args = {@_};

  my $self = {};
  bless $self, $type;

  if (exists $args->{mimeparser}) {
    $self->{mimeparser} = $args->{mimeparser};
  } else {
    $self->{mimeparser} = undef;
  }

  if (exists $args->{debug}) {
    $self->{debug} = $args->{debug};
  } else {
    $self->{debug}=0;
  }

  $self->{message} = undef;
  $self->{errors} = [];

  return $self;
}

sub parse {

  my $self = shift;
  my $in = wraphandle(shift);

  print STDERR "Starting to parse\n" if ($self->debug);
  return $self->_parse($in);
}

sub parse_data {

  my $self = shift;
  my $in = shift;

  print STDERR "Starting to parse string\n" if ($self->debug);
  return $self->_parse($in);
}

sub parse_open {
    my $self = shift;
    my $opendata = shift;

    my $in = IO::File->new($opendata) || $self->_adderror("Could not open file - $opendata");
    return $self->_parse($in);
}

sub parse_two {
    my $self = shift;
    my $headfile = shift;
    my $bodyfile = shift;

    my @lines;
    foreach ($headfile, $bodyfile) {
        open IN, "<$_" || $self->_adderror("Could not open file - $_");
        push @lines, <IN>;
        close IN;
    }
    return $self->parse_data(\@lines);
}

sub _parse {

  my $self = shift;
  my $in = shift;

  unless (defined $self->mimeparser) {
    my $parser = new MIME::Parser;
    $parser->ignore_errors(1);
    $self->{mimeparser} = $parser;
  }

  if (defined $self->output_dir) {
    $self->{mimeparser}->output_dir($self->output_dir);
  }

  unless (defined $self->mimeparser) {
    $self->_adderror("Failed to create parser");
    return undef;
  }

  print STDERR "Created MIME::Parser\n" if ($self->debug);

  my $message = new MMS::MailMessage;
  $self->{message} = $message;

  print STDERR "Created MMS::MailMessage\n" if ($self->debug);

  my $parsed = eval { $self->{mimeparser}->parse($in) };
  if (defined $@ && $@) {
    $self->_adderror($@);
  }
  unless ($self->_recursemessage($parsed)) {
    $self->_adderror("Failed to parse message");
    return undef;
  }

  print STDERR "Parsed message\n" if ($self->debug);

  unless ($self->{message}->isvalid) {
    $self->_adderror("Parsed message is not valid");
    print STDERR "Parsed message is not valid\n" if ($self->debug);
    return undef;
  }

  print STDERR "Parsed message is valid\n" if ($self->debug);

  return $self->{message};

}

sub _recursemessage {

  my $self = shift;
  my $mime = shift;

  unless (defined($mime)) {
    $self->_adderror("No mime message supplied");
    return 0;
  }

  print STDERR "Parsing MIME Message\n" if ($self->debug);

  my $header = $mime->head;
  unless (defined($self->{message}->headerfrom)) {
    $self->{message}->headerdatetime($header->get('Date'));
    $self->{message}->headerfrom($header->get('From'));
    $self->{message}->headerto($header->get('To'));
    $self->{message}->headersubject($header->get('Subject'));
    print STDERR "Parsed Headers\n" if ($self->debug);
  }

  my @multiparts;

  if($mime->parts == 0) {
    $self->{message}->headertext($mime->bodyhandle->as_string);
    print STDERR "No parts to MIME mail - grabbing header text\n" if ($self->debug);
    $mime->bodyhandle->purge;
  }

  print STDERR "Recursing through message parts\n" if ($self->debug);
  foreach my $part ($mime->parts) {
        my $bh = $part->bodyhandle;

        print STDERR "Message contains ".$part->mime_type."\n" if ($self->debug);

        if ($part->mime_type eq 'text/plain') {
          if (defined($self->{message}->headertext())) {
            $self->{message}->headertext(($self->{message}->headertext()) . $bh->as_string);
          } else {
            $self->{message}->headertext($bh->as_string);
          }
          $bh->purge;
          next;
        }

        if ($part->mime_type =~ /multipart/) {
          print STDERR "Adding multipart to stack for later processing\n" if ($self->debug);
          push @multiparts, $part;
          next;
        } else {
          print STDERR "Adding attachment to stack\n" if ($self->debug);
          $self->{message}->addattachment($part);
        }

    }
    # Loop through multiparts
    print STDERR "Preparing to loop through multipart stack\n" if ($self->debug);
    foreach my $multi (@multiparts) {
      return $self->_recursemessage($multi);
    }

    return 1;

}

sub _decipher {

  my $self = shift;

  unless (defined($self->{message})) {
    $self->_adderror("No MMS mail message supplied");
    return undef;
  }

  if (defined($self->providermailparser)) {
    my $message;
    #eval( 'require '.$self->providermailparser.';'.'$message='.$self->providermailparser.'::parse($self->{message})');
    $message = $self->providermailparser->parse($self->{message});

    unless (defined $message) {
      print STDERR "Failed to create custom ProviderParser\n" if ($self->debug);
      if (defined($@) && $@) {
        $self->_adderror($@);
      }
    }

    return $message;
  }

  if ($self->{message}->headerfrom =~ /vodafone.co.uk$/) {
    print STDERR "Vodafone message type detected\n" if ($self->debug);
    return MMS::ProviderMailParser::UKVodafone::parse($self->{message});
  } else {
    print STDERR "No message type detected using default parser\n" if ($self->debug);
    return MMS::ProviderMailParser::parse($self->{message});
  }

}

sub providermailparse {

  my $self = shift;
  my $message = shift;
  
  if (defined($message)) {
    $self->{message} = $message;
  }

  my $mms = $self->_decipher;

  unless (defined $mms) {
    $self->_adderror("Could not create provider parser");
    print STDERR "Could not create provider parser\n" if ($self->debug);
    return undef;
  }

  print STDERR "Created Provider Parser\n" if ($self->debug);
  print STDERR "Returning MMS::MailMessage::ProviderParsed\n" if ($self->debug);

  return $mms;
}

sub debug {

  my $self = shift;
  my $debug = shift;

  unless (defined $debug) {
    if (exists($self->{debug})) {
      return $self->{debug};
    } else {
      return undef;
    }
  }
  chomp($debug);
  $self->{debug}=$debug;
}

sub mimeparser {

  my $self = shift;

  if (@_) { $self->{mimeparser} = shift }
  return $self->{mimeparser};

}

sub _adderror {

  my $self = shift;
  my $error = shift;

  unless (defined $error) {
    return 0;
  }
  push @{$self->{errors}}, $error;

  return 1;
}

sub errors {

  my $self = shift;
  return $self->{errors};

}

sub lasterror {

  my $self = shift;

  if (@{$self->{errors}} > 0) {
    return ((pop @{$self->{errors}})."\n");
  } else {
    return undef;
  }

}

sub output_dir {

  my $self = shift;

  if (@_) { $self->{output} = shift }
  return $self->{output};

}

sub providermailparser {

  my $self = shift;

  if (@_) { $self->{providermailparser} = shift }
  return $self->{providermailparser};

}


1; # End of MMS::MailParser
