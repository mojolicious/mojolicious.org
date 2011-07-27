#!/usr/bin/env perl

use strict;
use warnings;

use lib 'mojo/lib';

use Getopt::Long 'GetOptions';
use Mojo::JSON;
use Mojo::UserAgent;
use Mojo::Util qw/encode get_line html_unescape/;

# Twitter
my $PATTERN  = 'mojolicious,mojo+perl';
my $STREAM   = "stream.twitter.com/1/statuses/filter.json";
my $USER     = '';
my $PASSWORD = '';

# Google Translate
my $TRANSLATE = 'http://ajax.googleapis.com/ajax/services/language/translate';

# IRC
my $SERVER  = 'irc.perl.org';
my $PORT    = 6667;
my $CHANNEL = '#mojo';
my $NICK    = '';

# Options
my $help;
GetOptions(
  'channel=s'  => sub { $CHANNEL  = $_[1] },
  help         => sub { $help     = 1 },
  'nick=s'     => sub { $NICK     = $_[1] },
  'password=s' => sub { $PASSWORD = $_[1] },
  'pattern=s'  => sub { $PATTERN  = $_[1] },
  'port=s'     => sub { $PORT     = $_[1] },
  'server=s'   => sub { $SERVER   = $_[1] },
  'user=s'     => sub { $USER     = $_[1] },
);

# Check user and password
$help = 1 unless $USER && $PASSWORD;

# Usage
die <<"EOF" if $help;
usage: $0 [OPTIONS]

  perlrocks.pl --user perlrocks --password s3cret
  perlrocks.pl --user perlrocks --password s3cret --nick mojorocks

These options are available:
  --channel    IRC channel to announce on.
  --help       Show this message.
  --nick       IRC nick.
  --password   Twitter password.
  --pattern    Pattern to search for on Twitter.
  --port       IRC port to connect to.
  --server     IRC server to connect to.
  --user       Twitter user.
EOF

# User agent
my $ua = Mojo::UserAgent->new(keep_alive_timeout => 300);

# Twitter stream
twitter_stream();

# IRC
my $irc;
irc_connect() if $NICK;

# Mainloop
Mojo::IOLoop->start;

sub irc_announce {
  my $message = shift;
  $message =~ s/\n/\ /g;
  encode 'UTF-8', $message;
  Mojo::IOLoop->singleton->write($irc => "PRIVMSG $CHANNEL :$message\r\n")
   if $irc;
}

sub irc_connect {

  # Buffer
  my $buffer = '';

  # Server connection
  $irc = Mojo::IOLoop->connect(
    address    => $SERVER,
    port       => $PORT,
    on_connect => sub {
      my ($self, $id) = @_;

      # Connected
      print "Connected to IRC server.\n";

      # Increase connection timeout
      $self->connection_timeout($id => 3000);

      # Identify
      $self->write($id => qq/USER $NICK "mojolicio.us" "$NICK" :$NICK\r\n/);
      $self->write($id => "NICK $NICK\r\n");

      # Join channel
      $self->write($id => "JOIN $CHANNEL\r\n");
    },
    on_read => sub {
      my ($self, $id, $chunk) = @_;

      # Append to buffer
      $buffer .= $chunk;

      # Parse
      while (my $line = get_line $buffer) {

        # Ping
        $self->write($id => "PONG $1\r\n")
         if $line =~ /^PING\s+\:(\S+)/;
      }
    },
    on_close => sub { irc_connect() },
    on_error => sub { irc_connect() }
  );
}

sub twitter_stream {

  # Streaming
  print "Starting Twitter stream.\n";

  # Prepare transaction for streaming response
  my $tx = $ua->build_tx(GET => "$USER:$PASSWORD\@$STREAM?track=$PATTERN");
  $tx->res->body(
    sub {

      # JSON
      return unless my $tweet = Mojo::JSON->new->decode(pop);

      # Google Translate
      google_translate($tweet);
    }
  );

  # Connect to Twitter
  $ua->start(
    $tx => sub {
      my $tx = pop;

      # Error
      warn $tx->error unless $tx->success;

      # Reconnect
      twitter_stream();
    }
  );
}

sub google_translate {
  my $tweet = shift;

  # Extract information
  my $name = $tweet->{user}->{screen_name};
  my $id   = $tweet->{id_str};
  my $url  = "http://twitter.com/$name/status/$id";
  my $lang = $tweet->{user}->{lang};

  # New tweet
  print qq/New tweet from "$name" ($lang).\n/;

  # Text
  my $text = $tweet->{text};
  $lang = '' if $lang eq 'en';

  # Retweet
  if ($text =~ /(?:^\s*RT|via\s*\@)/) {
    print "Just a retweet!\n";
    return;
  }

  # Translate
  $ua->get(
    Mojo::URL->new($TRANSLATE)
     ->query([v => '1.0', q => $text, langpair => "$lang|en"]) => sub {
      my $tx = pop;

      # JSON
      return unless my $t = $tx->res->json;

      # Translation
      my $translated = $t->{responseData}->{translatedText};
      $text = $translated if $translated;

      # Detected language
      my $detected = $t->{responseData}->{detectedSourceLanguage};
      $lang = $detected if $detected;
      $lang = $lang ? $lang ne 'en' ? " ($lang)" : '' : '';

      # Announce
      html_unescape $text;
      print qq/"$text"$lang --$name $url\n/;
      irc_announce(qq/\x{0002}Twitter:\x{000F} "$text"$lang --$name $url/);
    }
  );
}

1;
