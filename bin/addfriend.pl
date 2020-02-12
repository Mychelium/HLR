#!/usr/bin/perl

# usage:
#  perl -S addfriend.pl nickname peerkey

my $ff='/my/friends/peerids.yml';
use lib $ENV{IPMS_HOME}.'/lib';
use IPMS qw(mfs_append ipms_api);

my $nickname = shift;
my $peerkey = shift;
my $mh = &mfs_append("$nickname: $peerkey",$ff);
my $buf = &ipms_api('files/read',$ff);
printf "friends: %s\n",$ff;
printf "%s.\n",(split"\n",$buf)[-1];

exit;
1; # $Source: /my/perl/scripts/addfriend.pl$





