#!/usr/bin/perl

#
# Test writing of maildir folders.
#

use Test::More;
use strict;
use warnings;

use Mail::Box::Maildir;
use Tools;

use File::Compare;
use File::Copy;

BEGIN {
   if($windows)
   {   plan skip_all => 'Filenames not compatible with Windows';
       exit 1;
   }
   plan tests => 31;
}

my $mdsrc = File::Spec->catfile('folders', 'maildir.src');

unpack_mbox2maildir($src, $mdsrc);

my $folder = new Mail::Box::Maildir
  ( folder       => $mdsrc
  , extract      => 'LAZY'
  , access       => 'rw'
  );

ok(defined $folder);

#
# Count files flagged for deletion  (T flag)
#

my $to_be_deleted =0;
$_->deleted && $to_be_deleted++  foreach $folder->messages;
cmp_ok($to_be_deleted, "==", 7);

$folder->close;

#
# Reopen the folder and see whether the messages flagged for deletion
# are away.
#

$folder = new Mail::Box::Maildir
  ( folder       => $mdsrc
  , extract      => 'LAZY'
  , access       => 'rw'
  );

cmp_ok($folder->messages, "==", 38);

my $msg6 = $folder->message(6);
like($msg6->filename , qr/:2,$/);
ok(!$msg6->label('draft'));
ok(!$msg6->label('flagged'));
ok(!$msg6->label('replied'));
ok(!$msg6->label('seen'));
ok(!$msg6->modified);

my $msg12 = $folder->message(12);
like($msg12->filename , qr/:2,DFRS$/);
ok($msg12->label('draft'));
ok($msg12->label('flagged'));
ok($msg12->label('replied'));
ok($msg12->label('seen'));

ok(!$msg12->label(flagged => 0));
ok(!$msg12->label('flagged'));
like($msg12->filename , qr/:2,DRS$/);

ok(!$msg12->label(draft => 0));
ok(!$msg12->label('draft'));
like($msg12->filename , qr/:2,RS$/);

ok(!$msg12->label(seen => 0));
ok(!$msg12->label('seen'));
like($msg12->filename , qr/:2,R$/);

ok($msg12->label(flagged => 1));
ok($msg12->label('flagged'));
like($msg12->filename , qr/:2,FR$/);

ok(!$msg12->label(flagged => 0, replied => 0));
ok(!$msg12->label('flagged'));
ok(!$msg12->label('replied'));
like($msg12->filename , qr/:2,$/);

ok(!$msg12->modified);

clean_dir $mdsrc;
