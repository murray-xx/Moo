#!/usr/bin/perl
# 
# rename.pl
#
# originally by Larry Wall in the Perl Cookbook
# modified by Murray Barton
#    email: murray.barton at gmail.com
#    http://incommunique.blogspot.com
# breakage and stupidities are no doubt my fault and not Larry's :)
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty
# of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#
#

use strict;
use warnings;
use Getopt::Std;

my $useage=<<USEAGE;
Usage: rename expr [-hp] [files]
    -h print this screen
    -p preview mode, say what would happen but don't do it
    eg. rename "s/job00001./williams./" job00001.*
    lowercase filenames: rename "s/(.*)/lc(\$1)/e" *
USEAGE

my $preview=0;
{
  my %args;
  getopts( "ph", \%args ); 
  $preview = 1 if $args{p};
  print $useage and exit if $args{h};
}

my $op = shift or die $useage;

print "regular expression is: [$op]\n" if $preview;

chomp (@ARGV = <STDIN>) unless @ARGV;
for (@ARGV) {
	my $was = $_;
	eval $op;
	die $@ if $@;
	next if $was eq $_;
	print $was, " to ", $_, "\n";
    next if $preview;
	rename($was, $_) or die "Could not rename $was to $_: $!\n";
}
