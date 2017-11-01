#!/usr/bin/perl -w
###################################
###   Spit Ribosomal            ###
###   Jennifer Meneghin         ###
###   July 26, 2009             ###
###################################
#---------------------------------------------------------------------------------------------------------------------------
#Deal with passed parameters
#---------------------------------------------------------------------------------------------------------------------------
#If no arguments are passed, show usage message and exit program.
if ($#ARGV == -1) {
    &usage;
}
#get the names of the input file (first argument passed) and output file (second argument passed)
$in_file = $ARGV[0];
$out_file = "summary.out";
if (@ARGV > 1) {
    $out_file = $ARGV[1];
}
#Open the input file for reading, open the output file for writing.
#If either are unsuccessful, print an error message and exit program.
unless ( open(IN, "$in_file") ) {
    print "Got a bad input file: $in_file\n";
    &usage;
}
unless ( open(OUT, ">$out_file") ) {
    print "Got a bad output file: $out_file\n";
    &usage;
}
unless ( open(SPIT, ">suspected_rrna.txt") ) {
    print "Got a bad output file: suspected_rrna.txt\n";
    &usage;
}
#Everything looks good. Print the parameters we've found.
print "Parameters:\ninput file = $in_file\noutput file = $out_file\n\n";
#---------------------------------------------------------------------------------------------------------------------------
#The main event
#---------------------------------------------------------------------------------------------------------------------------
while (<IN>) {
#    if (/5S ribosomal/ || /16S ribosomal/ || /23S ribosomal/ || /30S ribosomal/ || /50S ribosomal/) {
    if (/5S ribosomal RNA/ || /16S ribosomal RNA/ || /23S ribosomal RNA/ || /28S ribosomal RNA/ || /18S ribosomal RNA/) {
	print SPIT $_;
    }
    else {
	print OUT $_;
    }
}
close(IN);
close(OUT);
close(SPIT);
sub usage {
    print "\nSPIT RIBOSOMAL 1.0\n";
    print "Jennifer Meneghin\n";
    print "July 26, 2009\n\n";
    print "Usage: spit_ribosomal.pl <input file> <output file>\n\n";
    print "This program takes a tab delimmited file (typically a skimmed blast output file in short format, but not necessarily)";
    print " as it's input file,\n";
    print "and returns this same file with any lines that reference 5S, 16S, 23S, 30S or 50S rRNA removed.\n\n";
    exit;
}
