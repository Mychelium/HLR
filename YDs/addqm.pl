#!/usr/bin/perl

# This script take a yml file and add its qm hash at the end
# for integrity check

use lib '.';
use YDs qw(qmhash fname);

my $file = shift;


my $buf = &read_file($file);
# remove signature 
my $p = rindex($buf,'---');
   $p = length($buf) if $p <= 0;
print "X-Length: $p\n";
my $payload = substr($buf,0,$p);
&write_file('/tmp/payload.txt',$payload);


my $algo = 'SHA256';
my $mh58 = &qmhash($algo,$payload);
printf "X-qmhash: %s\n",$mh58;

my $bdir = $ENV{HOME}.'/.vim/backups';
my ($fpath,$fname) = &fname($file);
my $bfile = $bdir.'/'.$fname.'~';
if (-e $file.'~0') {
  unlink $bfile;
} elsif (-e $bfile) {
  rename $bfile, $file.'~0';
}
rename $file, $bfile;
&write_file($file , $payload,"---\nqm: $mh58\n");

exit $?;

sub read_file {
  local *F; open F,'<',$_[0];
  local $/ = undef; my $buf = <F>; close F;
  return $buf;
}
sub write_file {
  my $file = shift;
  local *F; open F,'>',$file;
  foreach (@_) {
    print F $_;
  }
  close F;
}
1; # $Source: /my/perl/scripts/addqm.pl$
