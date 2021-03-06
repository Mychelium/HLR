#!/usr/bin/env perl

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

use YAML::Syck qw();
# get key as argument or stdin

if (@ARGV) {
 $key = shift;
} else {
 $key = <STDIN>;
 chomp($key);
}
$key =~ s,.*/ip[fhnm]s/,,;
$key = 'QmboiLojgoteK2P1NWhAjUutsgCpBmgpbrD1iKDAjSWxf4' unless $key;
print "key: $key\n" if $all;

# ----------------------------------------------------------------
# decode data (keep only the binary-hash value
my $bindata = "\0";
if ($key =~ m/^Qm/) {
 $bindata = &decode_base58($key);
 printf "mh58: %s (%uc, %uB) : f%s...\n",$key,length($key),
        length($bindata), substr(unpack('H*',$bindata),0,11) if $dbug;
 $bindata = substr($bindata,-32); # remove header
 printf "bin: %s\n",unpack'H*',$bindata if $all;
# ----------------------------------------------------------------
} elsif ($key =~ m/^z[bd]/) {
 $bindata = &decode_base58(substr($key,1));
 printf "zb58: %s (%uc, %uB) : f%s...\n",$key,length($key),
 length($bindata), substr(unpack('H*',$bindata),0,11) if $dbug;
 my $cid = substr($bindata,0,2);
 if ($cid eq "\x01\x55" || $cid eq "\x01\x70") {
   #my $header = substr($bindata,0,4);
   $bindata = substr($bindata,4);
 } else {
   $bindata = substr($bindata,2); # remove header
 }
printf "sha2: f%s\n",unpack('H*',$bindata) if $dbug;
# ----------------------------------------------------------------
} else { # if key is plain text ... do a sha2 on it
  $key =~ s/\\n/\n/g;
  $key .= ' '.join' ',@ARGV if (@ARGV);
  $bindata = &hashr('SHA-256',1,$key); # SHA-256 if cleartext !
  printf "sha2(%s): %s\n",$key,unpack('H*',$bindata) if $dbug;
}
# ----------------------------------------------------------------
our $wordlists;
my $etcdir = __FILE__; $etcdir =~ s,/bin/\w+$,/etc,;
my $DICT = (exists $ENV{DICT}) ? $ENV{DICT} : $etcdir; # '/usr/share/dict';
printf "// DICT=%s\n",$DICT if $dbug;

my $sha16 = unpack('H*',$bindata);
my $id7 = substr($sha16,0,7);
printf "id7: %s\n",$id7 if $all;
my $build = &word(unpack'n',$bindata);
printf "build: %s\n",$build if $all;

my $fnamelist = &load_wlist('fnames');
my $lnamelist = &load_wlist('lnames');

my @fullname = &fullname($bindata);
#printf "%s.\n",YAML::Syck::Dump(\@fullname) if $dbug;
if ($all) {
printf "fullname: %s %s. %s\n",$fullname[0],substr($fullname[1],0,1),$fullname[-2];
} else {
printf "%s %s. %s\n",$fullname[0],substr($fullname[1],0,1),$fullname[-2];
}
#printf "https://robohash.org/%s.png/set=set4&bgset=bg1&size=120x120&ignoreext=false\n",join'.',map { lc $_; } @fullname;

if ($all) {
   printf "ini: %s%s%s\n",uc(substr($fullname[0],0,1)),uc(substr($fullname[1],0,1)),uc(substr($fullname[-2],0,1));
   printf "user: %s%s\n",lc(substr($fullname[0],0,1)),lc($fullname[-2]);
   printf "email: %s%s+%s\@%s\n",lc(substr($fullname[0],0,1)),lc($fullname[-2]),$id7,'ydentity.ml';
}

exit $?;

# -----------------------------------------------------------------------
sub load_wlist {
   my $wlist = shift;
   if (! exists $wordlists->{$wlist}) {
      $wordlists->{$wlist} = [];
   }
   # ------------------------------
   my $wordlist = $wordlists->{$wlist};
   my $wl = scalar @$wordlist;
   if ($wl < 1) {
      my $file;
      if (-e $wlist) {
         $file = $wlist;
      } else { 
         $file = sprintf '%s/%s.txt',$DICT,$wlist;
         return undef if (! -e $file);
      }
      printf "dict: %s\n",$file if $dbug; 
      local *F; open F,'<',$file or die $!;
#local $/ = "\n"; @$wordlist = map { chomp($_); (split(' ',$_))[0] } <F>;
      local $/ = "\n"; @$wordlist = map { chomp($_); $_ } grep !/^#/, <F>;
      close F;
      $wl = scalar @$wordlist;
#printf "file: %s : %uw\n",$file,$wl;
   } 
  return $wordlist;
}
# -----------------------------------------------------------------------
sub fullname {
  my $bin = shift;
  my $funiq = substr($bin,1,6); # 6 char (except 1st)
  my $luniq = substr($bin,7,4);  # 4 char 
  my $flist = $wordlists->{fnames};
  my $llist = $wordlists->{lnames};
  my @first = map { $flist->[$_] } &encode_baser($funiq,5494);
  my @last = map { $llist->[$_] } &encode_baser($luniq,88799);
 
  return (@first,'.',@last);
}
# -----------------------------------------------------------------------
sub word { # 20^4 * 6^3 words (25bit worth of data ... 3.4bit per letter)
   use integer;
   my $n = $_[0];
   printf "n: %s\n",$n if $dbug;
   my $vo = [qw ( a e i o u y )]; # 6
   my $cs = [qw ( b c d f g h j k l m n p q r s t v w x z )]; # 20
   my $str = '';
   if (1 && $n < 26) {
      $str = chr(ord('a') +$n%26);
   } else {
      $n -= 6;
      while ($n >= 20) {
         my $c = $n % 20;
         $n /= 20;
         $str .= $cs->[$c];
         #print "cs: $n -> $c -> $str\n" if $dbug;
         my $c = $n % 6;
         $n /= 6;
         $str .= $vo->[$c];
         #print "vo: $n -> $c -> $str\n" if $dbug;
      }
      if ($n > 0) {
         $str .= $cs->[$n];
      }
   }
   return $str;
}
# -----------------------------------------------------------------------
sub encode_base58 {
  use Math::BigInt;
  use Encode::Base58::BigInt qw();
  my $bin = join'',@_;
  my $bint = Math::BigInt->from_bytes($bin);
  my $h58 = Encode::Base58::BigInt::encode_base58($bint);
  $h58 =~ tr/a-km-zA-HJ-NP-Z/A-HJ-NP-Za-km-z/;
  return $h58;
}
# --------------------------------------------
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
# --------------------------------------------
sub encode_base32 {
  use MIME::Base32 qw();
  my $mh32 = uc MIME::Base32::encode($_[0]);
  return $mh32;
}
sub decode_base32 {
  use MIME::Base32 qw();
  my $bin = MIME::Base32::decode($_[0]);
  return $bin;
}
# -----------------------------------------------------------------------
sub hashr {
   my $alg = shift;
   my $rnd = shift;
   my $tmp = join('',@_);
   use Digest qw();
   my $msg = Digest->new($alg) or die $!;
   for (1 .. $rnd) {
      $msg->add($tmp);
      $tmp = $msg->digest();
      $msg->reset;
   }
   return $tmp
}
# -----------------------------------------------------------------------
sub qmcontainer { # (cidv0)
   my $msg = shift;
   my $msize = length($msg);
   # Qm container are off format : { Data1: { f1 Data2 Tsize3 }}
   # QmPa5thw8vNXH7eZqcFX8j4cCkGokfQgnvbvJw88iMJDVJ
   # 00000000: 0a0e 0802 1208 6865 6c6c 6f20 210a 1808  ......hello !...
   # {"Links":[],"Data":"\u0008\u0002\u0012\u0008hello !\n\u0018\u0008"}
   # header:  0000_1010 : f1.t2 size=14 (0a0e)
   # payload: 0802_1208 ... 1808
   #          0000_1000 : f1.t0 varint=2 (0802)
   #          0001_0010 : f2.t2 size=8 ... (1208 ...)
   #          0001_1000 : f3.t0 varint=8 (1808)

   my $f1 = sprintf      '%s%s',pack('C',(1<<3|0)),&varint(2); # f1.t0 varint=2
      $data2 = sprintf '%s%s%s',pack('C',(2<<3|2)),&varint($msize),$msg; # f2.t2 msize msg
      $tsize3 = sprintf  '%s%s',pack('C',(3<<3|0)),&varint($msize); # f3.t0 msize
   my $payload = $f1 . $data2 . $tsize3;

   my $data = sprintf "%s%s%s",pack('C',(1<<3|2)),&varint(length($payload)),$payload; # f1.t2 size, payload
   return $data;
}
sub varint {
  my $i = shift;
  my $bin = pack'w',$i; # Perl BER compressed integer
  # reverse the order to make is compatible with IPFS varint !
  my @C = reverse unpack("C*",$bin);
  # clear msb on last nibble
  my $vint = pack'C*', map { ($_ == $#C) ? (0x7F & $C[$_]) : (0x80 | $C[$_]) } (0 .. $#C);
  return $vint;
}
# -----------------------------------------------------------------------
sub encode_baser {
  use Math::BigInt;
  my ($d,$radix) = @_;
  my $n = Math::BigInt->from_bytes($d);
  my @e = ();
  while ($n->bcmp(0) == +1)  {
    my $c = Math::BigInt->new();
    my ($n,$c) = $n->bdiv($radix);
    push @e, $c->numify;
  }
  return reverse @e;
}
# ---------------------------------------------------------
sub decode_baser (\@$) {
  use Math::BigInt;
  my ($s,$radix) = @_;
  my $n = Math::BigInt->new(0);
  my $j = Math::BigInt->new(1);
  foreach my $i (reverse @$s) { # for all digits
    return '' if ($i < 0);
    my $w = $j->copy();
    $w->bmul($i);
    $n->badd($w);
    $j->bmul($radix);
  }
  my $d = $n->as_bytes();
  return $d;

}
# -----------------------------------------------------------------------
1;
