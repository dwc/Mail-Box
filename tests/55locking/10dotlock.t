#!/usr/bin/perl -T
#
# Test the locking methods.
#

use strict;
use warnings;

use lib qw(. .. tests);
use Tools;

use Test::More tests => 7;
use File::Spec;

use Mail::Box::Locker::DotLock;

my $fakefolder = bless {MB_foldername=> 'this'}, 'Mail::Box';

my $lockfile  = File::Spec->catfile('folders', 'lockfiletest');
unlink $lockfile;

my $locker = Mail::Box::Locker->new
 ( method  => 'DotLock'
 , timeout => 1
 , wait    => 1
 , file    => $lockfile
 , folder  => $fakefolder
 );

ok($locker);
is($locker->name, 'DOTLOCK');

ok($locker->lock);
ok(-f $lockfile);
ok($locker->hasLock);

# Already got lock, so should return immediately.
ok($locker->lock);

$locker->unlock;
ok(not $locker->hasLock);
