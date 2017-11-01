#!/usr/bin/perl -w
#############################
###   Paste By Column     ###
###   Jennifer Meneghin   ###
###   October 12, 2010    ###
#############################
#---------------------------------------------------------------------------------------------------------------------------
#Deal with passed parameters
#---------------------------------------------------------------------------------------------------------------------------
#If no arguments are passed, show usage message and exit program.
if ($#ARGV < 3) {
    print "\nYou must supply at least two arguments: -in1 and -in2\n\n";
    usage();
}
$in_file1 = "";
$in_file2 = "";
$out_file = "matched.out";
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
    else {
	print "\nUnrecognized argument: $i\n\n";
	usage();
    }
}
unless ( open(IN1, "$in_file1") ) {
    print "\nCouldn't read input file 1: $in_file1\n";
    usage();
}
unless ( open(IN2, "$in_file2") ) {
    print "\nCouldn't read input file 2: $in_file2\n";
    usage();
}
print "\nParameters:\nInput file 1 = $in_file1\nInput file 2 = $in_file2\nOutput file = $out_file\n";
#---------------------------------------------------------------------------------------------------------------------------
#The main event
#---------------------------------------------------------------------------------------------------------------------------
@lines1 = 0;
@lines2 = <IN2>;
$count = 0;
$max_tab_count = 0;
while (<IN1>) {
    $lines1[$count] = $_;
    $count++;
    $tab_count = ($_ =~ tr/\t//);
    if ($tab_count > $max_tab_count) {
	$max_tab_count = $tab_count;
    }
}
close(IN1);
unless ( open(OUT, ">$out_file") ) {
    print "\nCouldn't write to output file: $out_file\n";
    usage();
}
for $i (0..$#lines1) {
    chomp($lines1[$i]);
    print OUT "$lines1[$i]";
    $tab_count = ($lines1[$i] =~ tr/\t/\t/);
    $filler = $max_tab_count - $tab_count;
    if ($filler > 0) {
	for $j (1..$filler) {
	    print OUT "\t";
	}
    }
    if ($i <= $#lines2) {
	print OUT "\t$lines2[$i]";
    }
    else {
	print OUT "\n";
    }
}
if ($#lines1 < $#lines2) {
    for $i ($#lines1+1..$#lines2) {
	for $j (1..$max_tab_count) {
	    print OUT "\t";
	}
	print OUT "\t$lines2[$i]";
    }
}
close(IN2);
close(OUT);

#------------------------------------------------------------------------------------------------------------------------
sub usage {
    print "Paste By Column\n";
    print "Jennifer Meneghin\n";
    print "October 12, 2010\n\n";
    print "Usage: paste_by_column.pl -in1 first_file -in2 second_file\n\n";
    print "Parameters:\n";
    print "-in1 first_file\t\tA tabbed delimited file.\n";
    print "-in2 second_file\tA tabbed delimited file.\n";
    print "-out file_name\t\tWrites the output to this file. If not provided, writes to a file called matched.out.\n\n";
    print "This script \"pastes\" together two tabbed delimited files side by side. The first file will be first, and the second file will be to the right of it. If file 1 is shorter than file 2, the appropriate tabs will be added so that all data stays in it's proper column. If file 1 has a variable number of columns, the data in file 2 will be to the left of the longest row in file 1. If you know your first file is longer than your second, AND you have a static number of columns, you don't need this script; you can use \'paste -d\"\\t\" file1 file2 >outfile\'. This script is for when you can't guarantee the size (or number of columns per row) of the files.\n\n";
    print "Note this script contains a little trick: if you use file 1 as -in1 and -out, file 1 will have the new columns added to it (instead of creating a third file). Please be cautious, but this can be quite handy if you are trying to paste a whole bunch of files together side by side.\n\n";
    exit();
}
