#!/usr/bin/perl
#
# Test the processing of a message header, in this case purely the reading
# from a file.
#

use Test;
use strict;
use warnings;

use lib qw(. t);

use Mail::Message::Head;
use Mail::Box::Parser::Perl;
use Tools;

BEGIN { plan tests => 15 }

my $h = Mail::Message::Head->new;
ok(defined $h);

my $parser = Mail::Box::Parser::Perl->new(filename => $src);
ok($parser);

my $head = Mail::Message::Head->new;
ok(defined $head);
ok(! $head);  # no lines yet

$parser->pushSeparator('From ');
my ($where, $sep) = $parser->readSeparator;
ok($sep);
ok($where==0);
ok($sep =~ m/^From mag.*2000$/);

$head->read($parser);
ok($head);  # now has lines
ok($head->names==20);
ok($head->get('subject') eq 'Re: File Conversion From HTML to PS and TIFF');

my @received = $head->get('received');
ok(@received==5);

my $received = $head->get('received');  #last
ok(defined $received);
ok($received->name eq 'received');
my $recb = "(from majordomo\@localhost)\tby unca-don.wizards.dupont.com (8.9.3/8.9.3) id PAA29389\tfor magick-outgoing";

ok($received->body eq $recb);
ok($received->comment eq 'Wed, 9 Feb 2000 15:38:42 -0500 (EST)');

