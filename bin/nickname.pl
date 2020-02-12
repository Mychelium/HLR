#!/usr/bin/perl

use YAML::Syck qw(Dump);
use lib $ENV{IPMS_HOME}.'/lib';
use IPMS qw(get_peeridkey ipms_local_mutable_resolve get_mutable_content get_hash_content);

our $dbug=0;
#--------------------------------
# -- Options parsing ...
#
my $all = 0;
while (@ARGV && $ARGV[0] =~ m/^-/)
{
  $_ = shift;
  #/^-(l|r|i|s)(\d+)/ && (eval "\$$1 = \$2", next);
  if (/^-v(?:erbose)?/) { $verbose= 1; }
  elsif (/^-a(?:ll)?/) { $all= 1; }
  elsif (/^-y(?:ml)?/) { $yml= 1; }
  else                  { die "Unrecognized switch: $_\n"; }

}
#understand variable=value on the command line...
eval "\$$1='$2'"while $ARGV[0] =~ /^(\w+)=(.*)/ && shift;


my $peerid;
if (@ARGV) {
  $peerid = shift;
} else {
  $peerid = &get_peeridkey();
}
my $nick = &get_nickname($peerid);

if ($all) {
printf "nickname: %s\n",$nick;
} else {
print $nick;
}

exit $?;

sub get_nickname {
  my $key = shift;
  #printf "key: %s\n",$key;
  my $peerids = &get_peerids_table();
  #printf "table: %s.\n",Dump($peerids);
  my %table = ();
  @table{values%$peerids} = keys %$peerids; # /!\ non optimal
  my $nick = $table{$key};
  return $nick;
}

sub get_peerids_table {
   if (0) {
      my $peerids_hash = &ipms_local_mutable_resolve('mfs:/my/friends/peerids.yml');
      printf "peerids_hash: %s\n",$peerids_hash;
#     my $buf = &get_hash_content($peerids_hash);
   } 
   my $buf = &get_mutable_content('mfs:/my/friends/peerids.yml');
   my $peerids_table = &YAML::Syck::Load($buf);
   return $peerids_table;
}
