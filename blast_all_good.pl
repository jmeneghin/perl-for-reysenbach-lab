#!/usr/bin/perl -w

# Jennifer Meneghin
# 10/09/2012
# This script removes all non-comments from a "short" format BLAST+ output file, and keeps all the hits
# Usage: blast_all_good.pl <input file> <output file>

#-----------------------------------------------------------------------------------------------------------------------------------------
#Deal with passed parameters
#-----------------------------------------------------------------------------------------------------------------------------------------
#If no arguments are passed, show usage message and exit program.
if ($#ARGV == -1) {
    usage("BLAST ALL GOOD 1.0 2012");
    exit;
}

#get the names of the input file (first argument passed) and output file (second argument passed)
$in_file = $ARGV[0];
$out_file = $ARGV[1];

#Open the input file for reading, open the output file for writing.
#If either are unsuccessful, print an error message and exit program.
unless ( open(IN, "$in_file") ) {
    usage("Got a bad input file: $in_file");
    exit;
}
unless ( open(OUT, ">$out_file") ) {
    usage("Got a bad output file: $out_file");
    exit;
}

#Everything looks good. Print the parameters we've found.
print "Parameters:\ninput file = $in_file\noutput file = $out_file\n\n";

#-----------------------------------------------------------------------------------------------------------------------------------------
#The main event
#-----------------------------------------------------------------------------------------------------------------------------------------
while(<IN>) {
    if (!/^#/) {
	print OUT $_;
    }
}
close(IN);
close(OUT);
print "Done.\n";
#-----------------------------------------------------------------------------------------------------------------------------------------
#Subroutines
#-----------------------------------------------------------------------------------------------------------------------------------------
sub usage {
    my($message) = @_;
    print "\n$message\n";

    print "\nThis script removes comments from a \"short\" format BLAST+ output file, and keeps only the good hits.\n";
    print "Usage: blast_best.pl <input file> <output file>\n";
    print "\nJennifer Meneghin\n";
    print "10/09/2012\n";
}

