#!/usr/local/bin/perl -w

#
# Test appending messages on MH folders.
#

use Test;
use File::Compare;
use File::Copy;
use lib '..', 't';
use strict;

use Mail::Box::Manager;
use Tools;

BEGIN {plan tests => 12}

my $orig = 't/mbox.src';
my $src  = 't/mh.src';

#
# Unpack the file-folder.
#

unpack_mbox($orig, $src);

my $mgr = Mail::Box::Manager->new;

my $folder = $mgr->open
  ( folder       => $src
  , lock_method  => 'NONE'
  , lazy_extract => 'ALWAYS'
  , access       => 'rw'
  , save_on_exit => 0
  );

die "Couldn't read $src." unless $folder;

# We checked this in other scripts before, but just want to be
# sure we have enough messages again.

ok($folder->messages==45);

# Add a message which is already in the opened folder.  However, the
# message heads are not yet parsed, hence the message can not be
# ignored.

my $message3 = $folder->message(3);

my $fake = bless { %$message3 }, ref $message3;

$folder->addMessage($fake);
ok($folder->messages==46);
ok(not $message3->headIsRead);
my $added = $folder->message(-1);
ok($added);
ok(not $added->headIsRead);

# Now we trigger the load of the original message, which should cause it
# to do to deleted.

$message3->head;
ok(not $message3->deleted);
$added->head;
ok($added->deleted);
ok(not $message3->deleted);

#
# Create an MIME::Entity and add this to the open folder.
#

my $msg = MIME::Entity->build
  ( From    => 'me@example.com'
  , To      => 'you@anywhere.aq'
  , Subject => 'Just a try'
  , Data    => [ "a short message\n", "of two lines.\n" ]
  );

$mgr->appendMessage($src, $msg);
ok($folder->messages==46);

ok($mgr->openFolders==1);
$mgr->close($folder);      # changes are not saved.
ok($mgr->openFolders==0);

$mgr->appendMessage($src, $msg
  , lock_method  => 'NONE'
  , lazy_extract => 'ALWAYS'
  , access       => 'rw'
  );

ok(-f "$src/47");  # skipped 13, so new is 46+1

clean_dir $src;
