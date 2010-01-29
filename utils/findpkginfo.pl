#!/usr/bin/perl
#

=head1 NAME

 findpkginfo.pl 

=head1 SYNOPSIS

 findpkginfo.pl -f <filename> <search string>
 pkginfo -l | findpkginfo.pl - <search string>

=head1 DESCRIPTION

 Solaris's pkginfo -l command is not very search friendly
 findpkginfo.pl is to fix that.  Prints out the full output
 for pkginfo -l for any package that matches the search string
 in package identifier (PKGINST), package name (NAME) 
 or description (DESC)

 find package info in the output of pkginfo -l from either a pipe or a file
 <search string> can be any valid perl regular expression

=head1 OPTIONS

 -
    read pkginfo from STDIN 
    ie pkginfo -l | findpkginfo.pl -
 -f <filename>
    read pkginfo from <filename>
 --help 
     Print this message
 --man
    Print the man page
 --version|-V
    Print the program version number

=head1 BUGS

None that I know of :)  Use at your own risk! 

=head1 Credits

Juerd for "POD in 5 minutes" <http://perlmonks.org/?node_id=252477> and
ybiC for "The Dynamic Duo" <http://perlmonks.org/?node_id=155288>

=head1 AUTHOR

Murray Barton
email: murray.barton at gmail.com
http://incommunique.blogspot.com

=head1 COPYRIGHT

Copyright (c) 2003. Murray Barton. All rights reserved.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

See http://www.perl.com/perl/misc/Artistic.html

=head1 DISCLAIMER

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty
 of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

=cut

$VERSION = '0.3.1';

use strict;
use warnings;
use File::Basename;
use Getopt::Long;
use Pod::Usage;
$| = 1;

my ( $stdio, $filename );

GetOptions(
    ''       => \$stdio,      # lone dash read from stdio!
    'f=s'    => \$filename,
    'usage'  => sub { pod2usage( -verbose => 0, -exitval => 1 ) },
    'help|?' => sub { pod2usage( -verbose => 1, -exitval => 1 ) },
    'man'    => sub { pod2usage( -verbose => 2, -exitval => 1 ) },
    'version|V' => sub { print basename($0), " $main::VERSION\n"; exit 0 },
) or pod2usage( -verbose => 0, -exitval => 1 );

if ( ( !$stdio and !$filename ) or ( $stdio and $filename ) ) {

    # neither or both...
    pod2usage(
        -verbose => 1,
        -exitval => 1,
        -message => "You must specify either -f <filename> or -\n",
    ) && exit;
}

my $find = $ARGV[0] || ".*";

my $fh;
if ( defined $filename ) {
    open( $fh, "<", $filename ) or die "Could not open $filename: $!";
}
elsif ($stdio) {
    $fh = \*STDIN;
}

my $tag;
my $first = 1;
my $rec   = ();
while (<$fh>) {
    s/^\s*//;
    s/\s*$//;
    next if /^\s*$/;
    chomp;
    my $value = $_;    # $value overwritten if a tag found
    /^([A-Z]+):\s*(.*)$/;
    if ($1) {
        $tag = $1;
        $value = $2 || '';
        if ( $tag eq "PKGINST" ) {    # next package starting
            if ( !$first ) {          # save previous package
                print_pkg($rec) if check_pkg_rec($rec);
            }
            $rec   = ();
            $first = 0;
        }
    }

    # next if ($ignore_tags{$tag});
    if ( $rec->{$tag} ) {
        $rec->{$tag} = join "\n", $rec->{$tag}, $value;
    }
    else {
        $rec->{$tag} = $value;
    }
}
close $fh;

if ( $rec ){
    print_pkg($rec) if check_pkg_rec($rec);
}

sub check_pkg_rec {
    my $rec = shift or die "Package record parameter not passed\n";

    for ( qw(PKGINST NAME DESC) ){
        if ( defined $rec->{$_} and $rec->{$_} =~ /$find/i ){
            return 1;
        }
    }
    return 0;
}

sub print_pkg {
    my @print_order = qw( PKGINST NAME CATEGORY ARCH VERSION BASEDIR
                          VENDOR DESC PSTAMP INSTDATE EMAIL STATUS FILES  );
    my $rec = shift || die "package record paramater not passed :(\n";
    for my $key (@print_order) {
        my $gap = $key eq "PKGINST" ? "" : "    ";
        my $value = $rec->{$key} || '';
        print "$gap $key: $value\n";
    }
}


