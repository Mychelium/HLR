#!/usr/bin/perl

use lib $ENV{IPMS_HOME}.'/lib';
use IPMS qw(ipms_api);

use YAML::Syck qw(Dump);


#$ENV{HTTP_HOST} = 'iph.heliohost.org';
my $mh = &ipms_api('config','Identity.PeerID');
printf "%s.\n",Dump($mh);


exit $?;
1;
