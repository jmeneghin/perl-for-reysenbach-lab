#!/usr/bin/perl -w
#############################
###   Jennifer Meneghin   ###
###   July 27, 2010    ###
#############################
#---------------------------------------------------------------------------------------------------------------------------
#Deal with passed parameters
#---------------------------------------------------------------------------------------------------------------------------
if ($#ARGV == -1) {
    &usage;
}
$in_file = "";
$out_file = "selected.fasta";
%my_args = @ARGV;
$wr_flag = 0;
for $i (sort keys %my_args) {
    if ($i eq "-i") {
	$in_file = $my_args{$i};
    }
    elsif ($i eq "-o") {
	$out_file = $my_args{$i};
    }
    elsif ($i eq "-n") {
	$num_to_select = $my_args{$i};
	if (!($num_to_select =~ /^\d+$/)) {
	    print "\nNumber of records to select must be an integer. You entered: $num_to_select\n\n";
	    &usage;
	}
    }
    elsif ($i eq "-w") {
	$wr_flag = 1;
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
print "Parameters:\ninput file = $in_file\noutput file = $out_file\nnumber to select = $num_to_select\n";
if ($wr_flag == 0) {
    print "Selecting without replacement\n\n";
}
else {
    print "Selecting with replacement\n\n";
}
#---------------------------------------------------------------------------------------------------------------------------
#The main event
#---------------------------------------------------------------------------------------------------------------------------
$file_size = `grep ">" $in_file | wc -l`;
chomp($file_size);
if ($file_size <= $num_to_select) {
    print "\nERROR: Number of records to select is greater or equal to than the number of records in the fasta file.\n";
    print "You entered: $num_to_select, but number of records in file is $file_size.\n\n";
    &usage;
}
if ($wr_flag == 0) {
    @randoms = `java Randoms $file_size $num_to_select`;
}
else {
    @randoms = `java Randoms $file_size $num_to_select wr`;
}
%nums = ();
for $i (0..$#randoms) {
    chomp($randoms[$i]);
    if ($nums{$randoms[$i]}) {
	$nums{$randoms[$i]}++;
    }
    else {
	$nums{$randoms[$i]} = 1;
    }
}
$holder = "";
$count = 0;
$flag = 0;
while (<IN>) {
    if (/^>/) {
	if ($flag > 0) {
	    for $i (1..$flag) {
		print OUT $holder;
	    }
	    $flag = 0;
	    $holder = "";
	}
	$count++;
	if ($nums{$count}) {
	    $holder = $_;
	    $flag = $nums{$count};
	}
	else {
	    $flag = 0;
	}
    }
    else {
	if ($flag > 0) {
	    $holder = $holder . $_;
	}
    }
}
if ($flag > 0) {
    for $i (1..$flag) {
	print OUT $holder;
    }
}
close(IN);
close(OUT);
sub usage {
    print "Usage: extract_fasta_records.pl\n\n";
    print "Parameters:\n";
    print "-i <input file>\t\tA fasta file\n";
    print "-o <output file>\tThe new file to create. Optional. If not provided, a file called selected.fasta will be created.\n";
    print "-n <number>\t\tThe number of records to randomly select.\n";
    print "-w r\t\t\tUse this flag to select with replacement. Optional. If not provided, it will select without replacement.\n\n";
    print "This program takes a fasta file (-i), and a number (-n)\n";
    print "and randomly selects (with a uniform distribution) this many records from the fasta file.\n\n";
    print "This script requires that Randoms.class also be in the same directory as this script.\n";
    print "It is equipped to deal with random selections with or without replacement.\n\n";
    print "Jennifer Meneghin\n";
    print "July 27, 2010\n\n";
    exit;
}
