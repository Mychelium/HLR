#!/usr/bin/perl

# Note:
#   this work has been done w/ HoloSphere
#
# -- Copyleft HLR, 2019,2020 --
#

package YDs;
require Exporter;
@ISA = qw(Exporter);
# Subs we export by default.
@EXPORT = qw();
# Subs we will export if asked.
#@EXPORT_OK = qw(nickname);
@EXPORT_OK = grep { $_ !~ m/^_/ && defined &$_; } keys %{__PACKAGE__ . '::'};

use strict;

# The "use vars" and "$VERSION" statements seem to be required.
use vars qw/$dbug $VERSION/;
# ----------------------------------------------------
our $VERSION = sprintf "%d.%02d", q$Revision: 0.0 $ =~ /: (\d+)\.(\d+)/;
my ($State) = q$State: Exp $ =~ /: (\w+)/; our $dbug = ($State eq 'dbug')?1:0;
# ----------------------------------------------------
$VERSION = &version(__FILE__) unless ($VERSION ne '0.00');

if ($dbug) {
  eval "use YAML::Syck qw(Dump);";
}

our $fdow = &fdow($^T);
# =======================================================================
if (__FILE__ eq $0) {

}
# =======================================================================

# --------------------------------------------
sub get_peerkey {
 use YAML::Syck qw();
 our $nobodykey = 'QmcEAhNT1epnXAVzuaFmvHWrQYZkxiiwipsL3W4hL1pHY9';
 my $nickname = shift;
 printf "nickname: %s\n",$nickname;
 if ($nickname eq 'self') {
   return &get_peeridkey();
 }
 my $peerids_hash = &mfs_resolve('/my/friends/peerids.yml');
 printf "peerids_hash: %s\n",$peerids_hash;
 #my $buf = &get_hash_content($peerids_hash);
 my $buf = &mfs_read('/my/friends/peerids.yml');

 my $peerids_table = &YAML::Syck::Load($buf);
 printf "%s.\n",Dump($peerids_table) if $dbug;
 if (exists $peerids_table->{$nickname}) {
   return $peerids_table->{$nickname};
 } else {
   return $nobodykey;
 }
}
sub get_peeridkey {
  #my $mh = &ipms_api('config','Identity.PeerID');
  #printf qq'mh: %s.\n',YAML::Syck::Dump($mh);
  my $key = &ipms_api('config','Identity.PeerID')->{Value};
}
# --------------------------------------------
sub mfs_resolve {
  my $mfs_path = shift;
     $mfs_path =~ s/^mfs://;
  #printf "mfs: %s\n",$mfs_path;
  my $mh = &ipms_get_api('files/stat',$mfs_path,'&hash=1');
  #printf "%s: %s.\n",(caller(0))[3],Dump($mh) if $dbug;
  return '/ipfs/'.$mh->{Hash};
}
sub ipms_path_resolve {
  my $ipath = shift;
  my $mh = &ipms_get_api('resolve',$ipath);
  printf "%s.\n",Dump($mh) if $dbug;
  return $mh->{Path};
}
sub ipms_nick_resolve {
   my $nick = shift;
   my $key = &get_peerkey($nick);
   my $mh = &ipms_get_api('name/resolve',$key);
   return $mh;
}
# --------------------------------------------
sub mfs_append {
  my ($text,$mpath) = @_;
  my $buf = &ipms_get_api('files/read',$mpath);
  $buf .= "$text";
  $buf .= "\n" if ($text !~ m/\n$/);
  # http://localhost:5001/api/v0/files/write?arg=<path>&offset=<value>&create=<value>
  #  &parents=<value>&truncate=<value>&count=<value>&raw-leaves=<value>&cid-version=<value>&hash=<value>
  my $mh = &ipms_post_api('files/write',$mpath,$buf,'&create=true&truncate=true');
  my $mh = &ipms_get_api('files/stat',$mpath,'&hash=true');
  return $mh;
}
sub mfs_copy {
   my $src = shift;
   my $dst = shift;
   my $parent = $dst; $parent =~ s,[^/]*$,,;
   my $mh = &ipms_get_api('files/stat',"$dst",'&hash=1');
#  printf "stat: %s.\n",YAML::Syck::Dump($mh);
   if (exists $mh->{Hash}) { # mfs:$dst exists !
      my $mh = &ipms_get_api('files/rm',"$dst");
#     printf "rm: %s.\n",YAML::Syck::Dump($mh);
   } else { # create the folder
      my $mh = &ipms_get_api('files/mkdir',"$parent",'&parents=true');
#     printf "mkdir: %s.\n",YAML::Syck::Dump($mh);
   }
   my $mh = &ipms_get_api('files/cp',"$src","&arg=$dst");
#  printf "cp: %s.\n",YAML::Syck::Dump($mh);
   return $?;
}
sub mfs_write {
   my $data = shift;
   my $dst = shift;
   my $mh = &ipms_post_api('files/write',$dst,$data,'&create=true&truncate=true');
   my $mh = &ipms_get_api('files/stat',$dst,'&hash=true');
   return $mh;
}
sub mfs_read {
   my $mpath = shift;
   my $data = &ipms_get_api('files/read',$mpath);
   return $data;
}
# --------------------------------------------
sub read_file {
  local *F; open F,'<',$_[0];
  local $/ = undef; my $buf = <F>; close F;
  return $buf;
}
# ---------------
sub write_file {
  my $file = shift;
  local *F; open F,'>',$file;
  foreach (@_) {
    print F $_;
  }
  close F;
}
# --------------------------------------------
sub encode_base58 { # btc
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
sub hashr {
   my $alg = shift;
   my $rnd = shift; # number of round to run ...
   my $tmp = join('',@_);
   use Crypt::Digest qw();
   my $msg = Crypt::Digest->new($alg) or die $!;
   for (1 .. $rnd) {
      $msg->add($tmp);
      $tmp = $msg->digest();
      $msg->reset;
      #printf "#%d tmp: %s\n",$_,unpack'H*',$tmp;
   }
   return $tmp
}
# -----------------------------------------------------
sub ipms_get_api {
# ipms config Addresses.API
#  (assumed gateway at /ip4/127.0.0.1/tcp/5001/...)
   my ($apihost,$apiport) = &get_apihostport();
   my $api_url = sprintf'http://%s:%s/api/v0/%%s?arg=%%s%%s',$apihost,$apiport;
   my $url = sprintf $api_url,@_; # failed -w flag !
#  printf "X-api-url: %s\n",$url;
   my $content = '';
   use LWP::UserAgent qw();
   use MIME::Base64 qw(decode_base64);
   my $ua = LWP::UserAgent->new();
   my $realm='Restricted Content';
   if ($api_url =~ m/blockringtm\.ml/) {
      my $auth64 = &get_auth();
      my ($user,$pass) = split':',&decode_base64($auth64);
      $ua->credentials('ipfs.blockringtm.ml:443', $realm, $user, $pass);

#     printf "X-Creds: %s:%s\n",$ua->credentials('ipfs.blockringtm.ml:443', $realm);
   }
   my $resp = $ua->get($url);
   if ($resp->is_success) {
#     printf "X-Status: %s\n",$resp->status_line;
      $content = $resp->decoded_content;
   } else { # error ... 
      printf "X-api-url: %s\n",$url;
      printf "Status: %s\n",$resp->status_line;
      $content = $resp->decoded_content;
      local $/ = "\n";
      chomp($content);
      printf "Content: %s\n",$content;
   }
   if ($_[0] =~ m{^(?:cat|files/read)}) {
     return $content;
   } elsif ($content =~ m/^{/) { # }
      use JSON qw(decode_json);
      my $json = &decode_json($content);
      return $json;
   } else {
	   printf "Content: %s\n",$content if $dbug;
     if (0) {
        $content =~ s/"/\\"/g;
        $content =~ s/\x0a/\\n/g;
        $content = sprintf'{"content":"%s"}',$content;
     }
     return $content;
   }
}
# -----------------------------------------------------
sub ipms_post_api {
   use JSON qw(decode_json);
   use LWP::UserAgent qw();
   use HTTP::Request 6.07;
   my $cmd = shift;
   my $filename = shift;
   my $data = shift;
   my $opt = join'',@_;
   my $filepath = '/tmp/blob.data';
   my $api_url;
   # --------------------------------
   # selecting alternative endpoint :
   if ($ENV{HTTP_HOST} =~ m/heliohost/) {
      $api_url = sprintf'https://%s/api/v0/%%s?arg=%%s%%s','ipfs.blockringtm.ml';
   } else {
      my ($apihost,$apiport) = &get_apihostport();
      $api_url = sprintf'http://%s:%s/api/v0/%%s?arg=%%s%%s',$apihost,$apiport;
   }
   # --------------------------------
   if ($cmd =~ m/(?:add|write)$/) {
      my $url = sprintf $api_url,$cmd,$filename,$opt; # name of type="file"
      printf "url: %s\n",$url if $dbug;
      my $ua = LWP::UserAgent->new();
      if ($api_url =~ m/blockringtm\.ml/) {
         my $realm='Restricted Content';
         my $auth64 = &get_auth();
         my ($user,$pass) = split':',&decode_base64($auth64);
         $ua->credentials('ipfs.blockringtm.ml:443', $realm, $user, $pass);
#       printf "X-Creds: %s:%s\n",$ua->credentials('ipfs.blockringtm.ml:443', $realm);
      }
      my $form = [
#       You are allowed to use a CODE reference as content in the request object passed in.
#       The content function should return the content when called. The content can be returned
#       Content => [$filepath, $filename, Content => $data ]
#        'file-to-upload' => ["$filepath" => "$filename", Content => "$data" ]
         'file' => "$data"
      ];
      my $content = '5xx';
      my $resp = $ua->post($url,$form, 'Content-Type' => "multipart/form-data;boundary=immutable-file-boundary-$$");
      if ($resp->is_success) {
#       printf "X-Status: %s\n",$resp->status_line;
         $content = $resp->decoded_content;
#       printf qq'content: "%s"\n',$content;
      } else { # error ... 
         printf "X-api-url: %s\n",$url;
         printf "Status: %s\n",$resp->status_line;
         $content = $resp->decoded_content;
         local $/ = "\n";
         chomp($content);
         printf "Content: %s\n",$content;
      }
      if ($content =~ m/^{/) { # }
         my $json = &decode_json($content);
         return $json;
      } else {
         return $content;
      }


   } else {
      my $sha2 = &hashr('SHA256',1,$data);
      return 'z'.encode_base58(pack('H8','01551220').$sha2);
   }
}
# -----------------------------------------------------
sub get_apihostport {
  my $IPFS_PATH = $ENV{IPFS_PATH} || $ENV{HOME}.'/.ipfs';
  my $conff = $IPFS_PATH . '/config';
  local *CFG; open CFG,'<',$conff or warn $!;
  local $/ = undef; my $buf = <CFG>; close CFG;
  use JSON qw(decode_json);
  my $json = decode_json($buf);
  my $apiaddr = $json->{Addresses}{API};
  my (undef,undef,$apihost,undef,$apiport) = split'/',$apiaddr,5;
      $apihost = '127.0.0.1' if ($apihost eq '0.0.0.0');
  return ($apihost,$apiport);
}
# -----------------------------------------------------
sub get_auth {
  my $auth = '*';
  my $ASKPASS;
  if (exists $ENV{IPMS_ASKPASS}) {
    $ASKPASS=$ENV{IPMS_ASKPASS}
  } elsif (exists $ENV{SSH_ASKPASS}) {
    $ASKPASS=$ENV{SSH_ASKPASS}
  } elsif (exists $ENV{GIT_ASKPASS}) {
    $ASKPASS=$ENV{GIT_ASKPASS}
  }
  if ($ASKPASS) { 
     use MIME::Base64 qw(encode_base64);
     local *X; open X, sprintf"%s %s %s|",${ASKPASS},'blockRing™';
     local $/ = undef; my $pass = <X>; close X;
     $auth = encode_base64(sprintf('michelc:%s',$pass),'');
     return $auth;
  } elsif (exists $ENV{AUTH}) {
     return $ENV{AUTH};
  } else {
     return 'YW5vbnltb3VzOnBhc3N3b3JkCg==';
  }
}
# -----------------------------------------------------
# protobuf container :
#   f1=id: t0=varint
#   f2=data: t2=string
sub qmhash {
   my $algo = shift;
   my $msg = shift;
   my $msize = length($msg);
   my $mhfncode = { 'SHA256' => 0x12, 'SHA1' => 0x11, 'MD5' => 0xd5, 'ID' => 0x00};
   my $mhfnsize = { 'SHA256' => 256, 'GIT' => 160, 'MD5' => 128};
   
   
   #printf "msize: %u (%s)\n",$msize,unpack'H*',&varint($msize);
   printf "msg: %s%s\n",substr(&enc($msg),0,76),(length($msg)>76)?'...':'' if $dbug;
   # QmPa5thw8vNXH7eZqcFX8j4cCkGokfQgnvbvJw88iMJDVJ
   # 00000000: 0a0e 0802 1208 6865 6c6c 6f20 210a 1808  ......hello !...
   # {"Links":[],"Data":"\u0008\u0002\u0012\u0008hello !\n\u0018\u0008"}
   # 0000_1010 : f1.t2 size=14 (0a0e)
   # payload: 0802_1208 ... 1808
   #          0000_1000 : f1.t0 varint=2 (0802)
   #          0001_0010 : f2.t2 size=8 ... (1208 ...)
   #          0001_1000 : f3.t0 varint=8 (1808)
   my $payload = sprintf '%s%s',pack('C',(1<<3|0)),&varint(2);
   $payload .= sprintf '%s%s%s',pack('C',(2<<3|2)),&varint($msize),$msg;

   $payload .= sprintf '%s%s',pack('C',(3<<3|0)),&varint($msize);
   # { Data1: { f1 Data2 Tsize3 }}


   printf "payload: %s%s\n",unpack('H*',substr($payload,0,76/2)),((length($payload)>76/2)?'...':'') if $dbug;
   my $data = sprintf "%s%s%s",pack('C',(1<<3|2)),&varint(length($payload)),$payload;

   my $mh = pack'C',$mhfncode->{$algo}; # 0x12; 
   my $hsize = $mhfnsize->{$algo}/8; # 256/8
   my $hash = undef;
   if ($algo eq 'GIT') {
     my $hdr = sprintf 'blob %u\0',length($data);
     $hash = &hashr($algo,1,$hdr,$data);
   } else {
     $hash = &hashr($algo,1,$data);
   }
   my $mhash = join'',$mh,&varint($hsize),substr($hash,0,$hsize);
   printf "mh16: %s\n",unpack'H*',$mhash if $dbug;
   my $add = 0;
   if ($add) { # adding file to the repository
      my $mh32 = uc&encode_base32($mhash);
      # printf "MH32: %s\n",$mh32;
      if (exists $ENV{IPFS_PATH}) {
         my $split = substr($mh32,-3,2);
         my $objfile = sprintf '%s/blocks/%s/%s.data',$ENV{IPFS_PATH},$split,$mh32;
         if (! -e $objfile) { # create the record ... i.e. it is like adding it to IPFS !
            printf "%s created !\n",$objfile if $dbug;
            local *F; open F,'>',$objfile; binmode(F);
            print F $data; close F;
         } else {
            printf "-e %s\n",$objfile if $dbug;
         }
      }
   }
   my $cidv0 = &encode_base58($mhash);
   return $cidv0;
}
# -----------------------------------------------------
sub varint {
  my $i = shift;
  my $bin = pack'w',$i; # Perl BER compressed integer
  # reverse the order to make is compatible with IPFS varint !
  my @C = reverse unpack("C*",$bin);
  # clear msb on last nibble
  my $vint = pack'C*', map { ($_ == $#C) ? (0x7F & $C[$_]) : (0x80 | $C[$_]) } (0 .. $#C);
  return $vint;
}
# -----------------------------------------------------
sub uvarint {
  my $vint = shift;
  # reverse the order to make is compatible with perl's BER int !
  my @C = reverse unpack'C*',$vint;
  # msb = 1 except last
  my $wint = pack'C*', map { ($_ == $#C) ? (0x7F & $C[$_]) : (0x80 | $C[$_]) } (0 .. $#C);
  my $i = unpack'w',$wint;
  return $i;
}
# -----------------------------------------------------
sub fdow {
   my $tic = shift;
   use Time::Local qw(timelocal);
   ##     0    1     2    3    4     5     6     7
   #y ($sec,$min,$hour,$day,$mon,$year,$wday,$yday)
   my $year = (localtime($tic))[5]; my $yr4 = 1900 + $year ;
   my $first = timelocal(0,0,0,1,0,$yr4);
   $fdow = (localtime($first))[6];
   #printf "1st: %s -> fdow: %s\n",&hdate($first),$fdow;
   return $fdow;
}
# -----------------------------------------------------
sub version {
  #y ($atime,$mtime,$ctime) = (lstat($_[0]))[8,9,10];
  my @times = sort { $a <=> $b } (lstat($_[0]))[9,10]; # ctime,mtime
  my $vtime = $times[-1]; # biggest time...
  my $version = &rev($vtime);

  if (wantarray) {
     my $shk = &get_shake(160,$_[0]);
     print "$_[0] : shk:$shk\n" if $dbug;
     my $pn = unpack('n',substr($shk,-4)); # 16-bit
     my $build = &word($pn);
     return ($version, $build);
  } else {
     return sprintf '%g',$version;
  }
}
# -----------------------------------------------------
sub rev {
  my ($sec,$min,$hour,$mday,$mon,$yy,$wday,$yday) = (localtime($_[0]))[0..7];
  my $rweek=($yday+&fdow($_[0]))/7;
  my $rev_id = int($rweek) * 4;
  my $low_id = int(($wday+($hour/24)+$min/(24*60))*4/7);
  my $revision = ($rev_id + $low_id) / 100;
  return (wantarray) ? ($rev_id,$low_id) : $revision;
}
# -----------------------------------------------------
sub fname { # extract filename etc...
  my $f = shift;
  $f =~ s,\\,/,g; # *nix style !
  my $s = rindex($f,'/');
  my $fpath = '.';
  if ($s > 0) {
    $fpath = substr($f,0,$s);
  } else {
    use Cwd;
    $fpath = Cwd::getcwd();
  }
  my $file = substr($f,$s+1);

  if (-d $f) {
    return ($fpath,$file);
  } else {
  my $p = rindex($file,'.');
  my ($bname,$ext);
  if ($p > 0) {
    $bname = substr($file,0,$p);
    $ext = lc substr($file,$p+1);
    $ext =~ s/\~$//;
  } else {
    $bname = $file;
    $ext = &get_ext($f);
  }

  $bname =~ s/\s+\(\d+\)$//; # remove (1) in names ...

  return ($fpath,$file,$bname,$ext);

  }
}
# -----------------------------------------------------
sub get_ext {
  my $file = shift;
  my $ext = $1 if ($file =~ m/\.([^\.]+)/);
  if (! $ext) {
    my %ext = (
    text => 'txt',
    'application/octet-stream' => 'blob',
    'application/x-perl' => 'pl'
    );
    my $type = &get_type($file);
    if (exists $ext{$type}) {
       $ext = $ext{$type};
    } else {
      $ext = ($type =~ m'/(?:x-)?(\w+)') ? $1 : 'ukn';
    }
  }
  return $ext;
}
sub get_type { # to be expended with some AI and magic ...
  my $file = shift;
  use File::Type;
  my $ft = File::Type->new();
  my $type = $ft->checktype_filename($file);
  if ($type eq 'application/octet-stream') {
    my $p = rindex $file,'.';
    if ($p>0) {
     $type = 'files/'.substr($file,$p+1);
    }
  }
  return $type;
}
# -----------------------------------------------------
1; # $Source: /my/perl/modules/YDs.pm$
