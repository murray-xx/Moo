#!/usr/bin/perl
#

=head1 NAME

dynamic_dns.pl

=head1 SYNOPSIS

dynamic_dns.pl [options]

=head1 DESCRIPTION
    
 automagically update zone edit's DNS if your ADSL IP address changes

 edit the values for $zone_edit_username, $zone_edit_passwd and $dynamic_domain as appropriate
 and create a cronjob such as
     
    */5 * * * * /path/to/dynamic_dns.pl >> /var/log/dynamic_dns.log 2>&1

 that's it

 zone edit gets the IP address from the connection IP of the script, run this script where you run 
 the webserver

=head1 OPTIONS

 -x
    where "x" is a number: list the most recent x files
 --help
    Print this message.
 --man
    Print the man page.
 --version|-V
    Print the program version number.

=head1 BUGS

None that I know of :-)

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

my $zone_edit_username = 'your_zone_edit_username';
my $zone_edit_passwd   = 'your_zone_edit_password';
my $dynamic_domain     = "your_domain";
my $debug              = 0;      # set to zero to make the output quieter
$VERSION               = '2.0';

use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;
use File::Basename;
use LWP::UserAgent;
use Socket;
use POSIX 'strftime';

GetOptions(
    'debug'      => \$debug,
    'usage'      => sub { pod2usage(-verbose => 0, -exitval => 0) }, 
    'help|?'     => sub { pod2usage(-verbose => 1, -exitval => 0) }, 
    'man'        => sub { pod2usage(-verbose => 2, -exitval => 0) }, 
    'version|V'  => sub { print basename($0), " v$main::VERSION\n";  exit 0}, 
) or pod2usage( -verbose => 0, -exitval => 1);

$| = 1;

my $now = strftime('%Y-%m-%d %H:%M:%S', localtime(time));
 
my $ua = LWP::UserAgent->new;
$ua->timeout(10);
 
my $allocated_ip = get_allocated_ip("http://dynamic.zoneedit.com/checkip.html");

my $dns_ip = get_ip($dynamic_domain);
print "$now DNS has [$dns_ip]\n" if $debug;

if ( $allocated_ip ne $dns_ip ){
    # they've changed!  Let's do an update!
    update_dynamic_dns();
}
else {
    print "$now Nothing to do here, move along\n" if $debug;
}

exit;

sub update_dynamic_dns {

    # wget -O - --http-user=username --http-passwd=password \
    #   'http://dynamic.zoneedit.com/auth/dynamic.html?host=www.mydomain.com'
    #

    my $req = HTTP::Request->new(
        GET => "http://dynamic.zoneedit.com/auth/dynamic.html?host=$dynamic_domain"
    );
    $req->authorization_basic($zone_edit_username, $zone_edit_passwd);
    my $res = $ua->request($req);

    # check the outcome
    if ($res->is_success) {
        print $res->decoded_content;
    }
    else {
        print "$now Error: " . $res->status_line . "\n";
    }

}

sub get_allocated_ip {
    my $url = shift or die "URL for checking IP address not passed\n";
    my $response = $ua->get($url);
 
    my $content;
    if ($response->is_success) {
         $content = $response->decoded_content;
    }
    else {
         die "$now Error: " . $response->status_line . "\n";
    }

    my @content =  map { s/\r//g; $_} split /\n/, $content;
    chomp @content;

    (my $ipline) = grep /^Current IP Address:/, @content;

    my $ip = ( split /\s*:\s*/, $ipline )[1];
    print "$now Current ip allocated [$ip]\n" if $debug;
    return $ip;
}

sub get_ip {
    my $host = shift;
    die "Hostname parameter not passed\n" if ! defined $host;
    my $iaddr = gethostbyname($host) || '';
    my $ip = $iaddr ? inet_ntoa($iaddr) : undef;
    return $ip;
}

