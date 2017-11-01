#!/usr/bin/perl -w
###################################
###   Match Files by ID         ###
###   Jennifer Meneghin         ###
###   July 26, 2009             ###
###################################
#-----------------------------------------------------------------------------------------------------------------------------------------
#Deal with passed parameters
#-----------------------------------------------------------------------------------------------------------------------------------------
#If no arguments are passed, show usage message and exit program.
if ($#ARGV < 3) {
    print "You must supply at least two arguments: -in1 and -in2\n\n";
    usage();
}
if ($#ARGV > 10) {
    print "Too many arguments.\n\n";
    usage();
}
$in_file1 = "";
$in_file2 = "";
$out_file = "matched.out";
$col1 = 1;
$col2 = 1;
%my_args = @ARGV;
for $i (sort keys %my_args) {
    if ($i eq "-in1") {
	$in_file1 = $my_args{$i};
    }
    elsif ($i eq "-in2") {
	$in_file2 = $my_args{$i};
    }
    elsif ($i eq "-out") {
	$out_file = $my_args{$i};
    }
    elsif ($i eq "-id1") {
	$col1 = $my_args{$i};
	if (!($col1 =~ /^\d+$/)) {
	    print "-id1 (column from first file) does not appear to be an integer.\n\n";
	    usage();
	}
    }
    elsif ($i eq "-id2") {
	$col2 = $my_args{$i};
	if (!($col2 =~ /^\d+$/)) {
	    print "-id2 (column from second file) does not appear to be an integer.\n\n";
	    usage();
	}
    }
    else {
	print "Unrecognized argument: $i\n\n";
	usage();
    }
}
unless ( open(IN1, "$in_file1") ) {
    print "Couldn't read input file 1: $in_file1\n";
    usage();
}
unless ( open(IN2, "$in_file2") ) {
    print "Couldn't read input file 2: $in_file2\n";
    usage();
}
unless ( open(OUT, ">$out_file") ) {
    print "Couldn't write to output file: $out_file\n";
    usage();
}
print "Parameters:\nInput file 1 = $in_file1\nInput file 2 = $in_file2\nOutput file = $out_file\n";
print "Match column for file 1 = $col1\nMatch column for file 2 = $col2\n\n";
#-----------------------------------------------------------------------------------------------------------------------------------------
#The main event
#-----------------------------------------------------------------------------------------------------------------------------------------
%in1 = ();
%in2 = ();
$max_tabs = 0;
#$count1 = 0;
#$count2 = 0;
while (<IN1>) {
    chomp;
    @fields = split(/\t/);
    $id1 = $fields[$col1 - 1];
    $in1{$id1} = $_;
    #$count1++;
    if ($#fields > $max_tabs) {
	$max_tabs = $#fields;
    }
}
while (<IN2>) {
    chomp;
    @fields = split(/\t/);
    $id2 = $fields[$col2 - 1];
    $in2{$id2} = $_;
    #$count2++;
}
#$size1 = keys %in1;
#$size2 = keys %in2;
#print "in1 size =$size1 count=$count1\n";
#print "in2 size =$size2 count=$count2\n";

foreach $i (sort keys %in1) {
    print OUT "$in1{$i}\t";
    if ($in2{$i}) {
	print OUT "$in2{$i}";
	delete($in2{$i});
    }
    print OUT "\n";
}
foreach $i (sort keys %in2) {
    for $j (0..$max_tabs) {
	$j = $j;
	print OUT "\t";
    }
    print OUT "$in2{$i}\n";
}
close(IN1);
close(IN2);
close(OUT);
sub usage {
    print "MATCH FILES BY ID 1.0\n";
    print "Jennifer Meneghin\n";
    print "July 26, 2009\n\n";
    print "Usage: blast_matchup.pl -in1 <first input file> -in2 <second input file>\n\n";
    print "Other optional parameters:\n";
    print "-out <file name>\tWrites the output to this file. If not provided, writes to a file called matched.out.\n";
    print "-id1 <column number>\tThe column to match from the first input file. Default is column 1.\n";
    print "-id2 <column number>\tThe column to match from the second input file. Default is column 1.\n\n";
    print "Note: this program assumes both input files are TAB delimmited.\n";
    print "If you need to match up different kinds of files, please contact the author: Jennifer Meneghin (jennifercwd\@yahoo.com)\n\n";
    print "Note: the output will be sorted by the first input file provided.\n\n";
    exit(1);
}
