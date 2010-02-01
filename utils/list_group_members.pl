#!/usr/bin/perl
#

=head1 NAME

 list_group_members.pl

=head1 SYNOPSIS

 list_group_members.pl [--usage --help --man --version] <groups>

=head1 DESCRIPTION

 Print out all the members of the specified group(s)

 We list both people who have the group as the primary group (ie gid field in
 passwd) and people who have the group as a secondary (ie member of group)

 You can list as many groups/gids as you like on the command line

 An invalid group name or gid will result in a warning not a failure.

 This is different to getent group <group name> insomuch as it lists the users
 who have <group name> as a primary group as well whereas getent group <group name>
 just lists users who have <group name> as a secondary group.

=head1 OPTIONS

=over 0

 --help
     Print this message
 --man
    Print the man page
 --version|-V
    Print the program version number

=back

=head1 BUGS

None that I know of :)  Use at your own risk!

=head1 TO DO


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

$VERSION = "0.5";

use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;
use File::Basename;

$|=1;

my $group;
GetOptions(
    'usage'     => sub { pod2usage(-verbose => 0, -exitval => 0) },
    'help|?'    => sub { pod2usage(-verbose => 1, -exitval => 0) },
    'man'       => sub { pod2usage(-verbose => 2, -exitval => 0) },
    'version|V' => sub { print basename($0), " $main::VERSION\n";  exit 0},
) or pod2usage(-verbose => 0) && exit 0;

if ( ! @ARGV ){
    pod2usage(
        -verbose => 1,
        -exitval => 1,
        -message => "Specify the group to list!\n",
    );
}

ARG:
for my $arg ( @ARGV ){
    my ($group, $gid) = ();
    if ( $arg =~ /^(\d+)$/) {
        $gid = $1;
        $group = getgrgid($gid);
    }
    else {
        # OK it's not numeric attempt to convert it to a gid
        $group = $arg;
        $gid = getgrnam($arg);
    }

    for my $thing ( $gid, $group ){
        if ( ! defined $thing ){
            warn "Invalid group \"$arg\"\n";
            next ARG;
        }
    }

    my %group_members = map {$_, 1} split /\s+/, (getgrgid($gid))[3];

    while ( my @entry = getpwent() ){
        ++$group_members{$entry[0]} if $entry[3] == $gid;
    }

    for (sort keys %group_members){
        my $gecos = get_user_gecos($_);
        print "${gid}:${group}: $_ $gecos\n";
    }
}

{
    my %cache;
    sub get_user_gecos {
        my $user = shift or die "Username parameter not passed\n";
        if ( defined $cache{$user} ){
            return $cache{$user};
        }

        my $gecos = (getpwnam($user))[6] || "UNKNOWN";
        $cache{$user} = $gecos;
        return $cache{$user};

    }
}


