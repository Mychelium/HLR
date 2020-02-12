#!/usr/bin/perl


use lib '.';
use YDs qw(mfs_append);

my $text = shift;
my $file = shift;

my $mh = &mfs_append($text,$file);

exit $?;
1;
