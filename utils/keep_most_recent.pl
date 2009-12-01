#!/usr/bin/perl

$VERSION = 0.1;

use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;
use Digest::MD5;

my $keep;
my $removedups;
my $debug = 0;

GetOptions(
    'removedups' => \$removedups,
    'keep=i'     => \$keep,
    'debug'      => \$debug,
    'usage'      => sub { pod2usage(-verbose => 0, -exitval => 0) }, 
    'help|?'     => sub { pod2usage(-verbose => 1, -exitval => 0) }, 
    'man'        => sub { pod2usage(-verbose => 2, -exitval => 0) }, 
    'version|V'  => sub { print basename($0), " v$main::VERSION\n";  exit 0}, 
) or pod2usage(-verbose => 0, -exitval => 0);

if ( ! defined $keep ){
    pod2usage(-verbose => 0, -exitval => 0, -message => "Specify number of files to keep!\n",);
}

if ( ! @ARGV ){
    die "No files specified\n";
}

my $print_stuff = 0;
$print_stuff = 1 if $debug or -t;

# ye old schwartzian transform rendering a sorted list of files...
my @files = map { $_->[0] } sort { $b->[1] <=> $a->[1] } map { [$_,( stat($_) )[9]] } @ARGV;

if ( $removedups ){
    my @dups = @files;
    my $removed = 0;
    # if two consecutive files are the same remove the older one...
    my $last;
    for ( 0..$#dups ){
        my $file = $dups[$_];

        # if the file expansion on the command line doesn't result in any files
        # then we get errors, because this script gets handed ie /path/to/pattern/<something>.* 
        # which doesn't exist.  So we just step over those ones.
        next if ! -e $file;

        my $md5 = md5sum($file);
        if ( ! $last ){
            $last = $md5;
            next;
        }
        if ( $md5 eq $last ){
            warn "Removing duplicate $file\n" if $print_stuff;
            if ( ! $debug ){
                unlink($file) or die "Could not unlink $file: $!";
            }
            splice @files, $_-$removed, 1;
            ++$removed;
            next;
        }    
        $last = $md5;
    }
}

if ( $keep <= ($#files) ){
    my @delete = splice @files, $keep;
    for (@delete){
        warn "Removing $_\n" if $print_stuff;
        if ( ! $debug ){
            unlink($_) or die "Could not unlink $_: $!";
        }
    }
}

exit;

sub md5sum{

    my $file = shift;
    my $digest = "";

    open(FILE, $file) or die "Can't open file $file: $!";
    my $ctx = Digest::MD5->new;
    $ctx->addfile(*FILE);
    $digest = $ctx->hexdigest;
    close(FILE);

    return $digest;
}

=head1 NAME

    keep_most_recent.pl

=head1 SYNOPSIS

    keep_most_recent.pl -keep <x> [-removedups] <list of files>

=head1 DESCRIPTION
    throw me a list of files and I'll remove all except the most recent <x>
  
 Example:
    keep_most_recent.pl -keep 7 -removedups /path/to/files/<hostname>.*
 
=head1 OPTIONS

=over 6

 --keep <x>
    number of files to keep
 --removedups
    if two consecutive files are identical then remove the older one
    this step happens before the keep step so there may be nothing to do when
    we get to the keep stage
 --debug
    Say what we are going to do but don't do it.
 --help 
     Print this message.
 --man
     Print the man page.
 --version|-V
     Print the program version number.

=back

=head1 BUGS

None that I know of :-)

=head1 AUTHOR

Murray Barton - murray.barton@gmail.com

=cut

