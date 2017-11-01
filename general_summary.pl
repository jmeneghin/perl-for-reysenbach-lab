#!/usr/bin/perl -w
#########################################
###   Jennifer Meneghin               ###
###   August 18, 2009                 ###
###   Updated November 27, 2012       ###
#########################################

#-----------------------------------------------------------------------------------------------------------------------------------------
#Deal with passed parameters
#-----------------------------------------------------------------------------------------------------------------------------------------
#If no arguments are passed, show usage message and exit program.
if ($#ARGV == -1) {
    &usage;
}
$in_file = "";
$out_file = "summary.out";
$sum_col = 1;
$count_col = 2;
%my_args = @ARGV;
for $i (sort keys %my_args) {
    if ($i eq "-i") {
	$in_file = $my_args{$i};
    }
    elsif ($i eq "-o") {
	$out_file = $my_args{$i};
    }
    elsif ($i eq "-c") {
	$count_col = $my_args{$i};
	if (!($count_col =~ /^\d+$/)) {
	    print "-c (column to count) does not appear to be an integer.\n\n";
	    &usage;
	}
    }
    elsif ($i eq "-s") {
	$sum_col = $my_args{$i};
	if (!($sum_col =~ /^\d+$/)) {
	    print "-s (column to summarize) does not appear to be an integer.\n\n";
	    &usage;
	}
    }
    else {
	print "Unrecognized argument: $i\n\n";
	&usage;
    }
}
unless ( open(IN, "$in_file") ) {
    print "Couldn't read input file: $in_file\n";
    &usage;
}
unless ( open(OUT, ">$out_file") ) {
    print "Couldn't write to output file: $out_file\n";
    &usage;
}
print "Parameters:\nInput file = $in_file\nOutput file = $out_file\n";
print "Count column = $count_col\nSummarize column = $sum_col\n\n";
#-----------------------------------------------------------------------------------------------------------------------------------------
#The main event
#-----------------------------------------------------------------------------------------------------------------------------------------
%counts = ();
while (<IN>) {
    chomp;
    @fields = split(/\t/);
    if ($count_col == 0) {
	$count = 1;
    }
    else {
	$count = $fields[$count_col - 1];
    }
    $summarize = $fields[$sum_col - 1];
    if ($counts{$summarize}) {
	$counts{$summarize} = $counts{$summarize} + $count;
    }
    else {
	$counts{$summarize} = $count;
    }
}
print "SUMMARY\tCOUNT\n";
print OUT "SUMMARY\tCOUNT\n";
foreach $i (sort { $counts{$b} <=> $counts{$a} } keys %counts) {
    print "$i\t$counts{$i}\n";
    print OUT "$i\t$counts{$i}\n";
}
close(IN);
close(OUT);
#-----------------------------------------------------------------------
sub usage {
    print "Jennifer Meneghin\n";
    print "August 18, 2009\n";
    print "Updated November 27, 2012\n\n";
    print "Usage: general_summary.pl -i <input file> -o <output file> -c <count column> -s <summarize column>\n\n";
    print "This program takes a tabbed delimmited file as it's input file, and returns a tab delimmited file,\n";
    print "with colunn 1 = summarize column (summarized) and colunn 2 = counts.\n\n";
    print "If count column = 0, the column to summarize will be summarized as if the count column = 1 for all rows.\n\n";
    print "Defaults:\n";
    print "output file = summary.out\n";
    print "column to summarize = 1\n";
    print "column to count = 2\n";
    print "input file is required\n\n";
    exit;
}
