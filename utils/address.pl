#!/usr/bin/perl
#

=head1 NAME

address.pl

=head1 SYNOPSIS

address.pl [-s -p -a --usage --help -? -man -version -V] [search_pattern]

=head1 DESCRIPTION

Simple command line search of the CSV file export of my GMail contacts

Why? Because it's easier to type "address.pl andrew" than to point and click
my way through gmail's contacts (or any other GUI for that matter, this
isn't a complaint about gmail)

=head1 OPTIONS

-s|-a
    search all fields

-p
    print all fields with values for matching records

-d
    print some debugging information

--help|-?
    Print this message

--man
    Print the man page

--usage
    print the usage line

--version|-V
    Print the program version number

=head1 BUGS

None that I know of :)  Use at your own risk!

=head1 To Do/Wishlist


=head1 Credits

Juerd for "POD in 5 minutes" <http://perlmonks.org/?node_id=252477> and
ybiC for "The Dynamic Duo" <http://perlmonks.org/?node_id=155288>

Damian Conway for writing Perl Best Practices which prompted me to learn
Getopt::Long and do a better job of handling command line arguments.  Any bugs 
in implementation are still mine.

All the very cool module authors on CPAN, THANK-YOU!

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

$VERSION = '0.8.2';

use strict;
use warnings;
use Getopt::Long qw(:config no_ignore_case);
use Pod::Usage;
use File::Basename;
use Data::Dumper;
use Text::xSV;

$| = 1;

my $settings = {
    debug             => 0,
    search_all_fields => 0,
    print_all_fields  => 0,
};

GetOptions(
    's|a'       => \$settings->{search_all_fields},
    'p'         => \$settings->{print_all_fields},
    'd'         => \$settings->{debug},
    'f=s'       => \$settings->{file},
    'usage'     => sub { pod2usage( -verbose => 0 ) && exit 0 },
    'help|?'    => sub { pod2usage( -verbose => 1 ) && exit 0 },
    'man'       => sub { pod2usage( -verbose => 2 ) && exit 0 },
    'version|V' => sub { print basename($0), " $main::VERSION\n"; exit 0 },
) or pod2usage( -verbose => 0 ) && exit 0;

if ( !defined $settings->{file} ) {
    my $dir = dirname($0);
    $settings->{file} = "$dir/contacts.csv";
}

my $pattern = $ARGV[0] || '*';
$pattern = glob2pat($pattern);
$pattern = '\b' . $pattern;

print "[$pattern]\n" if $settings->{debug};

%{ $settings->{print_fields} } = map { $_, 1 } "E-mail Address", "Mobile Phone",
  "Business Phone", "Home Phone", "E-mail 2 Address", "E-mail 3 Address";
%{ $settings->{never_print} } = map { $_, 1 } 'Priority';
@{ $settings->{name_fields} } =
  ( 'First Name', 'Middle Name', 'Last Name', 'Company' );
print Data::Dumper->Dump( [ \$settings ], [qw(*settings)] )
  if $settings->{debug};

my $csv = new Text::xSV;
$csv->open_file( $settings->{file} );
$csv->read_header();

$csv->set_row_size(89);

ROW:
while ( $csv->get_row() ) {
    my %record = $csv->extract_hash();

    #print Data::Dumper->Dump([\%record], [qw(*record)]);

    if ( $settings->{search_all_fields} ) {
      FIELD:
        for my $field ( keys %record ) {
            if ( defined $record{$field} and $record{$field} =~ /$pattern/i ) {
                print_record(%record);

                # it matched, we printed it, no need to look any futher!
                last FIELD;
            }
        }
    }
    else {
        for my $field ( @{ $settings->{name_fields} } ) {
            if ( defined $record{$field} and $record{$field} =~ /$pattern/i ) {
                print_record(%record);
                # jump to the next row otherwise if multiple fields
                # match we will pring the record multiple times == suckage!
                next ROW;
            }
        }
    }

}

exit;

sub print_record {
    my %record    = @_;
    my $full_name = "";
    my %name_fields;

    for ( @{ $settings->{name_fields} } ) {
        ++$name_fields{$_};
        if ( defined $record{$_} ) {
            if ( !length $full_name ) {
                $full_name = $record{$_};
            }
            else {
                $full_name .= " $record{$_}";
            }
        }
    }

    print "$full_name:\n";

    for my $field ( sort { special_sort() } keys %record ) {
        next if ( defined $name_fields{$field} );
        if ( !$settings->{print_all_fields} ) {
            next unless defined $settings->{print_fields}->{$field};
        }
        next if defined $settings->{never_print}->{$field};

        my $value = $record{$field};
        if ($value) {
            $value =~ s/\n/\n                            : /g;
            printf "\t%-20s: %s\n", $field, $value;
        }
    }
}

sub glob2pat {

 # gleefully stolen from Recipe 6.9. Matching Shell Globs as Regular Expressions
 # of the Perl Cookbook :-)

    my $globstr = shift;
    my %patmap  = (
        '*' => '.*',
        '?' => '.',
        '[' => '[',
        ']' => ']',
    );
    $globstr =~ s{(.)} { $patmap{$1} || "\Q$1" }ge;
    return $globstr;
}

sub special_sort {

    # we want phone records first
    # email address next
    ( ( $a =~ /e-mail/i ) <=> ( $b =~ /e-mail/i ) )
      || ( ( $a =~ /e-mail \d/i ) <=> ( $b =~ /e-mail \d/i ) )
      || $a cmp $b;
}


