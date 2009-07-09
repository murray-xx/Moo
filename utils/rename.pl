#!/usr/bin/perl -w
#
# originally by Larry Wall in the Perl Cookbook
# modified randomly by Murray Barton
#

use Getopt::Std;

my $useage=<<USEAGE;
Usage: rename expr [-hp] [files]
    -h print this screen
    -p preview mode, say what would happen but don't do it
    eg. rename "s/job00001./kord70m./" job00001.*
    lowercase filenames: rename "s/(.*)/lc(\$1)/e" *
USEAGE

my $preview=0;
{
  my %args;
  getopts( "ph", \%args ); 
  $preview = 1 if $args{p};
  print $useage and exit if $args{h};
}

$op = shift or die $useage;

print "regular expression is: [$op]\n" if $preview;

chomp (@ARGV = <STDIN>) unless @ARGV;
for (@ARGV) {
	$was = $_;
	eval $op;
	die $@ if $@;
	next if $was eq $_;
	print $was, " to ", $_, "\n";
  next if $preview;
	rename($was, $_) or die "Could not rename $was to $_: $!\n";
}
