#!/usr/bin/perl

use lib '.';
use Crypt::OpenSSL::RSA;
use MIME::Base64 qw( decode_base64 encode_base64 );
use YDs qw(read_file write_file);

my $keyf = shift;
my $file = shift;

my $keystring = &read_file ($keyf);
my $privatekey = Crypt::OpenSSL::RSA->new_private_key($keystring);

my $buf = &read_file($file);
# remove signature 
my $p = rindex($buf,'sig: ');
   $p = length($buf) if $p <= 0;
my $datatosign = substr($buf,0,$p);
&write_file('/tmp/cleartext.yml',$datatosign,'EOF');

# --- MD5 signature ---
   $privatekey->use_md5_hash; # /!\ MD5 is insecure

my $signature = $privatekey->sign($datatosign);
my $base64 = encode_base64($signature,'');
print "Signature:\n";
print "$base64\n";

unlink $file.'~';
rename $file, $file.'~';
&write_file($file , $datatosign,"sig: $base64\n...\n");


exit $?;

1;
