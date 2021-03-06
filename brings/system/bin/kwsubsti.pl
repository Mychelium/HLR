#!/usr/bin/perl
# $Name: kwsubsti.pl$
# $Source: /.brings/files/bin/kwsubsti.pl$

# $Date: 12/12/19$
# $tic: 1576163731$
# $qm: z6t$
# $Previous: QmUmeXP7TdYQGMnL7GddRUQRHyrYwkPvAHTDx7rFvaCCaN$
#
use YAML::Syck qw(LoadFile);
my $yamlf=shift;
my $yml = LoadFile($yamlf);
my $file=$ARGV[0];

local $/ = undef;
my $buf = <>;
$buf =~ s/\$qm: [^\$]*\s*\$$/\$qm: ~\$/m;
my $qm = 'z'.&encode_base58(pack('H4','01551220').&hashr('SHA256',1,$buf));
$buf =~ s/\$qm: [^\$]*\s*\$$/\$qm: $qm\$/m;


$buf =~ s/\$tic: [^\$]*\s*\$$/\$tic: $^T\$/m;
foreach my $kw (reverse sort keys %{$yml}) {
 #printf "%s: %s\n",$kw,$yml->{$kw};
 my $KW = $kw; $KW =~ s/.*/\u$&/;
 printf "%s: %s\n",$kw,$yml->{$kw};
 # \$$ to avoid substituting comments 
 $buf =~ s/\$$KW: [^\$]*\s*\$$/\$$KW: $yml->{$kw}\$/gm;
}

print "buf: ",$buf if $dbug;

local *F;
open F,'>',$file;
print F $buf;
close F;

exit $?;

sub encode_base58 { # btc
  use Math::BigInt;
  use Encode::Base58::BigInt qw();
  my $bin = join'',@_;
  my $bint = Math::BigInt->from_bytes($bin);
  my $h58 = Encode::Base58::BigInt::encode_base58($bint);
  $h58 =~ tr/a-km-zA-HJ-NP-Z/A-HJ-NP-Za-km-z/;
  return $h58;
}
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

1;
