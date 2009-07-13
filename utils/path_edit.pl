#!/usr/bin/perl -w
#
# use it like this PATH=`path_edit.pl -/some/path +/some/other/path`
#     + apends to path
#     ++ prepends to path
#
# or better still like this-
#    PATH=`path_edit.pl +/appl/scripts || echo $PATH`
# so that if for some reason we die $PATH will retain it's original value...
#

use strict;
my $verbose = 0;

my %path;
my ($high, $low) = (0,0);
for (split /:/, $ENV{PATH} ){
    next if exists $path{$_};     # remove duplicates
    $path{$_} = $high;
    ++$high;
}

for (@ARGV){
    /^-(.*)/ and do { delete $path{$1} if exists $path{$1}; next;};
    /^\+/    and do { add_dir($_); next; };
    print STDERR "Do not know what to do with \"$_\"\n";
}

print join ":", sort { $path{$a} <=> $path{$b} } keys %path;
print "\n";
exit;

sub add_dir {
    my $dir = $_[0] || die "Did not get passed a dirname\n";
    my ($end, $msg);
    if ($dir =~ s/^\+\+//){
        --$low;
        $end = $low;
        $msg = "$dir will be prepended to path\n";
    }
    else {
        $dir =~ s/^\+//;
        ++$high;
        $end = $high;
        $msg = "$dir will be appended to path\n";
    }
    
    if (exists $path{$dir}){
        print STDERR "$dir is already in path\n";
        delete $path{$dir};
    }

    if ( ! -d $dir ){
        print STDERR "No such directory $dir\n";
        return;
    }
    print STDERR $msg if $verbose;
    $path{$dir} = $end;
}
