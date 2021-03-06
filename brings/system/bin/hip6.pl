#!/usr/bin/perl

# vim: sw=3

#$ENV{LC_TIME} = 'en_US.UTF-8';

# HIPv6 ...
#
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
#--------------------------------
printf "--- # %s\n",$0 if $yml;

# IPFS peerid
$ENV{IPMS_HOME} = $ENV{HOME}.'/.ipms' unless exists $ENV{IPMS_HOME};
$ENV{PATH} = $ENV{IPMS_HOME}.'/bin:'.$ENV{PATH};
my $peerid = `ipms --offline config Identity.PeerID`; chomp($peerid);
printf "peerid: %s\n",$peerid if $all;


my $hubin = &decode_base58($peerid);
my $hipb = substr($hubin,6,16); # /6\ assumption on varint range !
my $hipq = &hex2quint(unpack'H*',$hipb);
if ($all) {
printf "hipb: %s\n",unpack'H*',$hipb;
printf "hipq: %s\n",$hipq;
}

my ($hiph,$hipl) = unpack'Q*',$hipb; # /!\ big endianness !
$hiph = (0xfe80 << 48) | ($hiph & 0x003f_ffff_ffffffff);
my $hipn = $hipl & 0xFFFF_FFFF;
my $hip4 = join'.',unpack'C*', pack'N',$hipn;
my $hip = sprintf "%016x%08x",$hiph,($hipl>>32); $hip =~ s/(....)/\1:/g;
my $hip6 = sprintf "%s%s",$hip,$hip4;
my $quint = &u32quint($hipn);

if ($yml || $all) {
   printf "hipn: %u\n",$hipn;
   printf "hip4: %s\n",$hip4;
   printf "hip6: %s\n",$hip6;
   printf "quint: %s\n",$quint;
} else {
   print $hip6;
}

exit $?;

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

die &u32quint($a) if (&u32quint($a = 0xaceaf539) ne 'pugop-zihun');


sub hex2quint {
  return join '-', map { u16toq ( hex('0x'.$_) ) } $_[0] =~ m/(.{4})/g;
}
sub u32quint {
  my $u = shift;
  #printf "%04x.%04x\n",$u>>16,$u&0xFFFF;
  return u16toq(($u>>16) & 0xFFFF) . '-' . u16toq($u & 0xFFFF);
}

sub u16toq {
   my $n = shift;
  #printf "u2q(%04x) =\n",$n;
   my $cons = [qw/ b d f g h j k l m n p r s t v z /]; # 16 consonants only -c -q -w -x
   my $vow = [qw/ a i o u  /]; # 4 wovels only -e -y
   my $s = '';
      for my $i ( 1 .. 5 ) { # 5 letter words
         if ($i & 1) { # consonant
            $s .= $cons->[$n & 0xF];
            $n >>= 4;
            #printf " %d : %s\n",$i,$s;
         } else { # vowel
            $s .= $vow->[$n & 0x3];
            $n >>= 2;
            #printf " %d : %s\n",$i,$s;
         }
      }
   #printf "%s.\n",$s;
   return scalar reverse $s;
}
1;
