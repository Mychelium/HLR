#!/usr/bin/perl

my $core='hlrings';
my $pp=substr($core,0,2);
BEGIN {
my $rootdir = __FILE__; $rootdir =~ s,[^/]*$,..,;
our $libdir = $rootdir.'/ipms/lib';
}
# -----------------------------------------------------------------
our $dbug=0;
use lib $libdir;
use IPMS qw(get_spot mfs_copy mfs_append mfs_read ipms_api ipms_post_api);
#understand variable=value on the command line...
eval "\$$1='$2'"while $ARGV[0] =~ /^(\w+)=(.*)/ && shift;
if ($dbug) {
 eval "use YAML::Syck qw(Dump);";
}
# -----------------------------------------------------------------
print "--- # spot\n";

# get you space and time location (memory drop point)
my $time = int($^T / 61) * 59;
my $spot = &get_spot($time,@ARGV);
printf "spot: %s\n",$spot;

# archive the spot !
my $spotdata = sprintf <<"EOT",$ENV{USER},$^T,$spot, join',',@ARGV;
--- # spot for %s
tic: %s
spot:%s
argv: [%s]
EOT
my $mh = &ipms_post_api('files/write','/etc/spot.yml',$spotdata,'&create=1&truncate=1');
my $qm = &ipms_api('files/stat','/etc/spot.yml')->{Hash};
printf "qmspot: %s\n",$qm;
my $etc = &ipms_api('files/stat','/etc');
printf "etc: https://gateway.ipfs.io/ipfs/%s\n",$etc->{Hash};
# --------------------------------------------------------
my $por = sprintf '/.%s/published/%sindex.log',$core,$pp;
my $mh = &mfs_append("$etc->{Hash}: /etc",$por);
printf "por: %s\n",$por;
printf "qmpor %s\n",$mh->{Hash};
#printf "mh: %s.\n",YAML::Syck::Dump($mh) if $dbug;
if ($dbug) {
  my $buf=&mfs_read($por);
  printf "%sindex.log:\n%s.\n",$pp,$buf;
}
# --------------------------------------------------------

exit $?;
1;
