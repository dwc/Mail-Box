#!/usr/bin/perl
#
# Encoding and Decoding quoted-print bodies
#

use Test;
use strict;
use warnings;

use lib qw(. t /home/markov/MailBox2/fake);

use Mail::Message::Body::Lines;
use Mail::Message::TransferEnc::QuotedPrint;
use Tools;

BEGIN { plan tests => 10 }

my $src = <<SRC;
In the source text, there are a few \010\r strange characters,
which \200\201 must become encoded.  There is also a \010== long line, which must be broken into pieces, and
there are = confusing constructions like this one: =0D, which looks
encoded, but is not.
SRC

my $encoded = <<ENCODED;
In the source text, there are a few =08=0D strange characters,
which =80=81 must become encoded.  There is also a =08=3D=3D long line, whic
h must be broken into pieces, and
there are =3D confusing constructions like this one: =3D0D, which looks
encoded, but is not.
ENCODED

my $decoded = <<'DECODED';   # note the quotes!
In the source text, there are a few \010\015 strange characters,
which \200\201 must become encoded.  There is also a \010== long line, whic
h must be broken into pieces, and
there are = confusing constructions like this one: =0D, which looks
encoded, but is not.
DECODED

my $codec = Mail::Message::TransferEnc::QuotedPrint->new;
ok(defined $codec);
ok($codec->name eq 'quoted-printable');

# Test encoding

my $body   = Mail::Message::Body::Lines->new
  ( mime_type => 'text/html'
  , data      => $src
  );

my $enc    = $codec->encode($body);
ok($body!=$enc);
ok($enc->type eq 'text/html');
ok($enc->transferEncoding eq 'quoted-printable');
ok($enc->string eq $encoded);

# Test decoding

$body   = Mail::Message::Body::Lines->new
  ( transfer_encoding => 'quoted-printable'
  , mime_type         => 'text/html'
  , data              => $encoded
  );

my $dec = $codec->decode($body);
ok($dec!=$body);
ok($enc->type eq 'text/html');
ok($dec->transferEncoding eq 'none');
ok($dec->string eq $decoded);

