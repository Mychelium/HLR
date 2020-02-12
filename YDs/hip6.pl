#!/usr/bin/perl

# this script take your qm58 peerid and return the your HIP address
# node the Human IP is simple a 16B truncation of the peerid hash
# 
# the advantage is that we are missing some bit for accessing the complete profile

# fe80::/64 link-local address prefix), rendering them non-routable. 
# fe80::/10 Link-local address

# http://fe80--1ff-fe23-4567-890aseth0.ipv6-literal.net

our $dbug = $1 if (exists $ENV{QUERY_STRING} && $ENV{QUERY_STRING} =~ m/\&dbug=(\d+)/o);
our $VERSION = '0.1';


my $qm58;
my $params = {};
if (@ARGV) {
 $qm58 = shift;
} elsif (exists $ENV{QUERY_STRING}) {
   my $query = (exists $ENV{QUERY_STRING}) ? $ENV{QUERY_STRING} : '';
   my @params = split /\&/,$query;
   foreach my $e (@params) {
      my ($p,$v) = split/=/,$e;
      $params->{$p} = $v;
   }
  $qm58 = $params->{qm} if (exists $params->{qm});
} else {
  print "Status: 406 Not Acceptable\r\n";
  print "Content-Type: text/html\r\n";
  print "\r\n";
  print "<h1><center>406<br>Not acceptable</center></h1>\n";
  $qm58 = `ipfs config Identity.PeerID`; chomp($qm58);
}

my $hubin = &decode_base58($qm58);
my $hipb = substr($hubin,6,16); # /6\ assumption on varint range !
printf "X-hipb: %s\n",unpack'H*',$hipb;

my ($hiph,$hipl) = unpack'Q*',$hipb; # /!\ big endianness !
printf "X-hipH: %x\n",$hiph;
printf "X-hipL: %x\n",$hipl;

$hiph = (0xfe80 << 48) | ($hiph & 0x003f_ffff_ffffffff);
my $hipn = $hipl & 0xFFFF_FFFF;
my $hip4 = join'.',unpack'C*', pack'N',$hipn;
my $quint = &uint32proquint($hipn);
if (1) {
   my $piglat = $quint;
   $piglat =~ s/\b(qu|[cgpstw]h # First syllable, including digraphs
              |[^\W0-9_aeiou])  # Unless it begins with a vowel or number
              ?([a-z]+)/        # Store the rest of the word in a variable
              $1?"$2$1ay"       # move the first syllable and add -ay
              :"$2way"          # unless it should get -way instead 
              /iegx;

   printf "X-quint: $quint\n";
   printf "X-piglat: $piglat\n";
}

print "Content-Type: text/plain\r\n";
print "\r\n";

my $hip = sprintf "%016x%08x",$hiph,($hipl>>32); $hip =~ s/(....)/\1:/g;
my $hip6 = sprintf "%s%s",$hip,$hip4;

printf "--- # Sovereign ID for %s (%s)\n",$quint,$VERSION;
printf "HIP6: %s\n",$hip6;
printf "Date: %s\n",&hdate(time);
printf "peerid: %s\n",$qm58;

use Proquint qw(uint32proquint hex2proquint);

my $hipq = &hex2proquint(unpack'H*',$hipb);
printf "hipq: $hipq\n";
printf "attr: QmbFMke1KXqnYyBBWxB74N4c5SBnJMVAiMNRcGu6x1AwQH\n";
print  "...\n";

local *F;
open F,'>',"$quint.yml";
printf F "--- # Sovereign ID for %s\n",$quint;
printf F "HIP6: %s%s\n",$hip6;
printf F "Date: %s\n",&hdate(time);
printf F "peerid: %s\n",$qm58;
printf F "attr: QmbFMke1KXqnYyBBWxB74N4c5SBnJMVAiMNRcGu6x1AwQH\n";
print  F "...\n";
close F;

print "$quint.yml created\n";







exit $?;

sub encode_base58 {
  use Math::BigInt;
  use Encode::Base58::BigInt qw();
  my $bin = join'',@_;
  my $bint = Math::BigInt->from_bytes($bin);
  my $h58 = Encode::Base58::BigInt::encode_base58($bint);
  $h58 =~ tr/a-km-zA-HJ-NP-Z/A-HJ-NP-Za-km-z/;
  return $h58;
}
sub decode_base58 {
  use Math::BigInt;
  use Encode::Base58::BigInt qw();
  my $s = $_[0];
  # $e58 =~ tr/a-km-zA-HJ-NP-Z/A-HJ-NP-Za-km-z/;
  $s =~ tr/A-HJ-NP-Za-km-z/a-km-zA-HJ-NP-Z/;
  my $bint = Encode::Base58::BigInt::decode_base58($s);
  my $bin = Math::BigInt->new($bint)->as_bytes();
  return $bin;
}
# ---------------------------------------------------------
sub hdate { # return HTTP date (RFC-1123, RFC-2822) 
  my ($time,$delta) = @_;
  my $stamp = $time+$delta;
  my $tic = int($stamp);
  #my $ms = ($stamp - $tic)*1000;
  my $DoW = [qw( Sun Mon Tue Wed Thu Fri Sat )];
  my $MoY = [qw( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec )];
  my ($sec,$min,$hour,$mday,$mon,$yy,$wday) = (gmtime($tic))[0..6];
  my ($yr4,$yr2) =($yy+1900,$yy%100);

  # Mon, 01 Jan 2010 00:00:00 GMT
  my $date = sprintf '%3s, %02d %3s %04u %02u:%02u:%02u GMT',
             $DoW->[$wday],$mday,$MoY->[$mon],$yr4, $hour,$min,$sec;
  return $date;
}
# ---------------------------------------------------------



1;










