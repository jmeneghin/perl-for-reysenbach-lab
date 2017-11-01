#!/usr/bin/perl
# Jennifer Meneghin
# May 12, 2009

#-----------------------------------------------------------------------------------------------------------------------------------------
#Deal with passed parameters
#-----------------------------------------------------------------------------------------------------------------------------------------
#get the names of the input file (first argument passed) and output file (second argument passed)
$in_file = $ARGV[0];
$out_file = "flipped.out";
if (@ARGV > 1) {
    $out_file = $ARGV[1];
}
unless ( open(IN, "$in_file") ) {
    print "Got a bad input file: $in_file\n";
    &usage;
}
unless ( open(OUT, ">$out_file") ) {
    print "Couldn't create output file: $out_file\n";
    &usage
}
print "Parameters:\ninput file = $in_file\noutput file = $out_file\n\n";
#-----------------------------------------------------------------------------------------------------------------------------------------
#The main event
#-----------------------------------------------------------------------------------------------------------------------------------------
@matrix = ();
$count = 0;
$colcount = 0;
while (<IN>) {
    @row = split(/\s/);
    for $i (@row) {
	$matrix[$colcount][$count] = $i;
 	$colcount++;
   }
    $count++;
    $colcount = 0;
}
foreach $i (@matrix) {
    foreach $j (@$i) {
	#print "$j\t";
	print OUT "$j\t";
    }
    #print "\n";
    print OUT "\n";
}
close(IN);
close(OUT);

sub usage {
    print "\nUsage: flip.pl <tab delimmited file>\n\n";
    print "This program takes a tab delimmited file and transposes the matrix (i.e., converts rows to columns).\n";
    print "It is especially handy if your file has too many rows or columns for excel to handle.\n\n";
    print "It returns a file in the current directory called flipped.out.\n\n";
    print "Jennifer Meneghin\n";
    print "05/12/2009\n\n";
    exit;
}
