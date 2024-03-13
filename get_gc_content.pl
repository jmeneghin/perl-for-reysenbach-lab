#!/usr/bin/perl
####################################################################################################
### Get GC Content                                                                               ###
### Usage: get_gc_content.pl <fasta file>                                                        ###
### This program takes a fasta file as it's first (and only) parameter.                          ###
###                                                                                              ###
### It returns a tab delimited file (gc_out.txt): column 1 = header ID (everything between ">"   ###
### and the first space in the header), and column 2 = gc content for the fasta entry.           ###
###                                                                                              ###
### Jennifer Meneghin                                                                            ###
### July 23, 2009                                                                                ###
###                                                                                              ###
### This script now works properly with sequences that contain spaces.                           ###
### September 20, 2010                                                                           ###
###                                                                                              ###
### This script now also returns the total nucleotide count, along with the number of            ###
### A's, G's, C's and T's for each fasta record.                                                 ###
### September 21, 2010                                                                           ###
####################################################################################################

use warnings;
use strict;
use v5.10;

#---------------------------------------------------------------------------------------------------------------------------
#Deal with passed parameters
#---------------------------------------------------------------------------------------------------------------------------
my $fasta_file = shift @ARGV;
usage() unless $fasta_file;

my $out_file = 'gc_out.txt';
open my $fh_in,  '<', $fasta_file or die "Can't open fasta file '$fasta_file': $!\n\n";
open my $fh_out, '>', $out_file   or die "Couldn't create $out_file: $!\n";

say <<"HEAD";
Parameters:
fasta file = $fasta_file
output file = $out_file
HEAD

#---------------------------------------------------------------------------------------------------------------------------
#The main event
#---------------------------------------------------------------------------------------------------------------------------
say $fh_out join "\t", 'ID', '% GCContent', 'Total Count', 'G Count', 'C Count',
    'A Count', 'T Count';
my $seq = q{};

while (<$fh_in>) {
    chomp;
    if (/^>/) {

        #finish up previous line.
        if (length($seq) > 0) {
            process_it($seq);
        }

        #start new line.
        my ($id) = /^>(\S+)/;    # removes leading >
        print $fh_out "$id\t";
    } else {
        $seq .= $_;
    }
}

#finish up last line.
process_it($seq);

close($fh_in);
close($fh_out);

exit;

sub usage {
    print <<USAGE;
Get GC Content
Usage: $0 <fasta file>
This program takes a fasta file as it's first (and only) parameter.

It returns a tab delimited file (gc_out.txt): column 1 = header ID (everything between ">"
and the first space in the header), and column 2 = gc content for the fasta entry.

Jennifer Meneghin
July 23, 2009

Updated September 20, 2010:
This script now works properly with sequences that contain spaces.

Updated September 21, 2010:
This script now also returns the total nucleotide count, along with the number of A's, G's, C's and T's for each fasta record.

USAGE
    exit;
}

sub process_it {
    my @letters = split //, lc shift;
    my ($gccount, $totalcount, $acount, $tcount, $gcount, $ccount) = (0) x 6;

    foreach my $i (@letters) {
        if ($i =~ /[a-z]/) { $totalcount++ }
        if ($i eq 'g' || $i eq 'c') { $gccount++ }
        if ($i eq 'a') { $acount++ }
        if ($i eq 't') { $tcount++ }
        if ($i eq 'g') { $gcount++ }
        if ($i eq 'c') { $ccount++ }
    }
    my $gccontent = $totalcount > 0
        ? (100 * $gccount / $totalcount)    # rounded to 3 decimals
        #? sprintf("%.3f", 100 * $gccount / $totalcount)    # rounded to 3 decimals
        : 0;

    say $fh_out join("\t", $gccontent, $totalcount, $gcount, $ccount, $acount, $tcount);
    $seq = q{};
}
