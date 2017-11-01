#!/usr/bin/perl -w
#############################
###   Jennifer Meneghin   ###
###   September 1, 2009   ###
#############################
#---------------------------------------------------------------------------------------------------------------------------
#Deal with passed parameters
#---------------------------------------------------------------------------------------------------------------------------
if ($#ARGV == -1) {
    &usage;
}
$in_file = "";
$out_file = "selected.out";
$nums_file = "";
%my_args = @ARGV;
for $i (sort keys %my_args) {
    if ($i eq "-i") {
	$in_file = $my_args{$i};
    }
    elsif ($i eq "-o") {
	$out_file = $my_args{$i};
    }
    elsif ($i eq "-n") {
	$nums_file = $my_args{$i};
    }
    else {
	print "\nUnrecognized argument: $i\n\n";
	&usage;
    }
}
unless ( open(IN, "$in_file") ) {
    print "\nGot a bad input file: $in_file\n\n";
    &usage;
}
unless ( open(OUT, ">$out_file") ) {
    print "\nGot a bad output file: $out_file\n\n";
    &usage;
}
unless ( open(NUMS, "$nums_file") ) {
    print "\nGot a bad database file: $nums_file\n\n";
    &usage;
}

print "Parameters:\ninput file = $in_file\noutput file = $out_file\nfile of lines = $nums_file\n\n";
#---------------------------------------------------------------------------------------------------------------------------
#The main event
#---------------------------------------------------------------------------------------------------------------------------
%nums = ();
while (<NUMS>) {
    chomp;
    if ($nums{$_}) {
	$nums{$_}++;
    }
    else {
	$nums{$_} = 1;
    }
}
$count = 0;
while (<IN>) {
    $count++;
    if ($nums{$count}) {
	for $i (1..$nums{$count}) {
	    print $_;
	    print OUT $_;
	}
    }
}
close(IN);
close(OUT);
close(NUMS);
sub usage {
    print "Jennifer Meneghin\n";
    print "September 1, 2009\n\n";
    print "Usage: extract_lines.pl\n\n";
    print "Parameters:\n";
    print "-i <input file>\t\t\tA tabbed delimmeted file (often a BLAST output file in short format)\n";
    print "-o <output file>\t\tThe new file to create. If not provided, a file called selected.out will be created.\n";
    print "-n <database file>\t\tThe file of line numbers to extract.\n\n";
    print "This program takes a tabbed delimmeted file (-i), and a file of line numbers with one number per line (-n).\n";
    print "It returns the tabbed delimmeted file with only the lines found in the file of line numbers.\n\n";
    print "Any numbers greater than the number of the lines in the file, less than zero, or any non-integers will be ignored.\n\n";
    print "This file can be used with the Randoms.java/class script.\n";
    print "It is equipped to deal with random selections with or without replacement.\n";
    print "Therefore, any duplicate numbers will cause the program to add that line to the output file multiple times.\n\n";
    exit;
}
