#!/usr/bin/perl
##############################
###   Jennifer Meneghin    ###
###   January 28, 2010     ###
###                        ###
###   Jennifer Meneghin    ###
###   Updated July 2, 2012 ###
##############################
#---------------------------------------------------------------------------------------------------------------------------
#Deal with passed parameters
#---------------------------------------------------------------------------------------------------------------------------

use v5.10;   # "say" is print with a \n
use warnings;
use strict;
use autodie; # builtins succeed or die
use Getopt::Long;

usage() unless @ARGV;

my ($in_file, $text_to_add, $verbose, );
my $out_file = "updated.fasta";

GetOptions(
    'i|in=s'   => \$in_file,
    'out|o=s'  => \$out_file,
    'text|a=s' => \$text_to_add,
    'v|verbose' => \$verbose,
) or die("Error in command line arguments\n");

open my $in_fh, '<', $in_file;
open my $out_fh, '>', $out_file;

unless ( length($text_to_add) > 0 ) {
    say "\nPlease enter the text to add onto each record.\n";
    usage();
}
say "Parameters:\ninput file = $in_file\noutput file = $out_file\n" if $verbose;
say "Ignoring ", @ARGV if @ARGV;
#---------------------------------------------------------------------------------------------------------------------------
#The main event
#---------------------------------------------------------------------------------------------------------------------------
my ($text1, $text2, $count, );

if ($text_to_add =~ /COUNT/) {
    ($text1, $text2) = split "COUNT", $text_to_add;
    $count = 0;
}

while (<$in_fh>) {
    chomp;
    if (/>/) {
	    print $out_fh $_;

	    if ($text_to_add =~ /COUNT/) {
	        $count++;
	        print $out_fh $text1, $count;
	        if ($text2 && length($text2) > 0) {
		        say $out_fh $text2;
	        }
	        else {
		        print $out_fh "\n";
	        }
	    }
	    else {
	        say $out_fh $text_to_add;
	    }
    }
    else {
	    say $out_fh $_;
    }
}

close($in_fh);
close($out_fh);
exit;

#-----------------------------------------------------------------------
sub usage {
    say <<MSG;

USAGE: ./add_to_headers.pl

Parameters:
-i <input file>\t\tA fasta file
-o <output file>\tThe new fasta file to create. Optional. If not provided, a file called updated.fasta will be created.
-a <some text>\t\tThe text to add on to the end of each header in the file.
-v \t\t\tMakes the program a little more verbose.

This scripts adds a bit of text (-a) onto the end of each header in the file provided (-i).

Jennifer Meneghin
January 28, 2010

NEW: if you use the word COUNT (in all caps) in your text to add, this will be replaced by the record count.

Jennifer Meneghin
July 2, 2012
MSG
    exit;
}
