#!/usr/bin/perl

our $dbug=1;

my $url = shift || '/ipfs/zz38RTafUtxY';
my $buf = &get_ipfs_content($url);
printf qq'buf: "%s"\n',$buf;
exit $?;
# -----------------------------------------------------------------------
sub get_ipfs_content {
  my $ipath=shift;
  use LWP::UserAgent qw();
  my ($gwhost,$gwport) = &get_gwhostport();
  my $proto = ($gwport == 443) ? 'https' : 'http';
  my $url = sprintf'%s://%s:%s%s',$proto,$gwhost,$gwport,$ipath;
  printf "url: %s\n",$url if $::dbug;
  my $ua = LWP::UserAgent->new();
  my $resp = $ua->get($url);
  if ($resp->is_success) {
    my $content = $resp->decoded_content;
    return $content;
  } else {
    return undef;
  }
}
# -----------------------------------------------------------------------
sub get_gwhostport {
  use LWP::UserAgent qw();
  use JSON qw(decode_json);

  my $IPFS_PATH = $ENV{IPFS_PATH} || $ENV{HOME}.'/.ipfs';
  my $conff = $IPFS_PATH . '/config';
  local *CFG; open CFG,'<',$conff or warn $!;
  local $/ = undef; my $buf = <CFG>; close CFG;
  my $json = decode_json($buf);
  my $gwaddr = $json->{Addresses}{Gateway};
  my (undef,undef,$gwhost,undef,$gwport) = split'/',$gwaddr,5;
      $gwhost = '127.0.0.1' if ($gwhost eq '0.0.0.0');
  my $url = sprintf'http://%s:%s/ipfs/zz38RTafUtxY',$gwhost,$gwport;
  my $ua = LWP::UserAgent->new();
  my $resp = $ua->get($url);
  if ($resp->is_success) {
    return ($gwhost,$gwport);
  } else {
    return ('ipfs.blockringtm.ml',443);
  }
}
# -----------------------------------------------------------------------
1;

