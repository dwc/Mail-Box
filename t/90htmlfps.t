#!/usr/bin/perl
#
# Test conversions from HTML/XHTML to postscript with HTML::FormatPS
#

use Test;
use strict;
use warnings;

use lib qw(. t);

use Tools;
use Mail::Message::Body::Lines;

BEGIN {
   
   eval 'require HTML::FormatPS';

   if($@)
   {   warn "requires HTML::FormatPS.\n";
       plan tests => 0;
       exit 0;
   }

   require Mail::Message::Convert::HtmlFormatPS;
   plan tests => 5;
}

my $html  = Mail::Message::Convert::HtmlFormatPS->new;

my $body = Mail::Message::Body::Lines->new
  ( type => 'text/html'
  , data => $raw_html_data
  );

my $f = $html->format($body);
ok(defined $f);
ok(ref $f);
ok($f->isa('Mail::Message::Body'));
ok($f->type eq 'application/postscript');
ok($f->transferEncoding eq 'none');

# The result of the conversion is not checked, because the output
# is rather large and may vary over versions of HTML::FormatPS
