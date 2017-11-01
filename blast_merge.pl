#!/usr/bin/perl -w

# Jennifer Meneghin
# 08/14/2007
# This script merges BLAST output from two "short" format files, by:
# 1) De-duping each of the two files. If there is more than one match for a particular sequence, keep only the "best" (sort by smallest e-value and then longest length)
# 2) Create 3 new files: sequences unique to file 1, sequences unique to file 2, and sequences found in both 1 and 2.
#    These 3 new files will be named Unique_<filename1> Unique_<filename2> and Common_<filename1>_<filename2>
# Usage: blast_merge.pl <filename1> <filename2> <output directory>

#-----------------------------------------------------------------------------------------------------------------------------------------
#Deal with passed parameters
#-----------------------------------------------------------------------------------------------------------------------------------------
#If no arguments are passed, show usage message and exit program.
if ($#ARGV == -1) {
    usage("BLAST MERGE 1.0 2007");
    exit;
}

#get the names of the input files (first and second arguments passed) and output directory (third argument passed)
$file1 = $ARGV[0];
$file2 = $ARGV[1];
$dir = $ARGV[2];

#Open the input files for reading.
#If either are unsuccessful, print an error message and exit program.
unless ( open(IN1, "$file1") ) {
    usage("Got a bad input file: $file1");
    exit;
}
unless ( open(IN2, "$file2") ) {
    usage("Got a bad input file: $file2");
    exit;
}

#get just the file names (without path information) from the input files
#(the following two lines say "remove everything up to and including the final forward slash").
$file1 =~ s/^.*\///g;
$file2 =~ s/^.*\///g;

#Open the three ouput files for writing.
#Write to the directory given, else (if no directory given) use the current directory.
#If any are unsuccessful, print an error message and exit program.
if ( $dir ) {
    unless ( open(OUT1, ">${dir}/Unique_${file1}") ) {
	usage("Got a bad output file: Unique_${file1}");
	exit;
    }
    unless ( open(OUT2, ">${dir}/Unique_${file2}") ) {
	usage("Got a bad output file: Unique_${file2}");
	exit;
    }
    unless ( open(OUT3, ">${dir}/Common_${file1}_${file2}") ) {
	usage("Got a bad output file: Common_${file1}_${file2}");
	exit;
    }
}
else {
    $dir = "";
    unless ( open(OUT1, ">Unique_${file1}") ) {
	usage("Got a bad output file: Unique_${file1}");
	exit;
    }
    unless ( open(OUT2, ">Unique_${file2}") ) {
	usage("Got a bad output file: Unique_${file2}");
	exit;
    }
    unless ( open(OUT3, ">Common_${file1}_${file2}") ) {
	usage("Got a bad output file: Common_${file1}_${file2}");
	exit;
    }
}

#Everything looks good. Print the parameters we've found.
print "Parameters:\nfile 1 = $file1\nfile 2 = $file2\noutput file 1 = Unique_${file1}\noutput file 2 = Unique_${file2}\noutput file 3 = Common_${file1}_${file2}\noutput directory = $dir\n\n";

#-----------------------------------------------------------------------------------------------------------------------------------------
#The main event
#-----------------------------------------------------------------------------------------------------------------------------------------

$counter1 = 0;
$counter2 = 0;

print "De-duplicating File 1\n";

#Pass the information from the first input file into an array of text lines.
@in1 = <IN1>;

#Do stuff for each line of text in the first input file.
foreach $line (@in1) {
    #if the line starts with a pound symbol, it is not real data, so skip this line.
    if ( $line =~ /^#/ ) {
	 next;
     }

    #The chomp commands removes any new line (and carriage return) characters from the end of the line.
    chomp($line);

    #Split up the tab delimited line, naming only the variables we are interested in.
    ($id, $orf, $percent_identity, $align, $mismatches, $gap, $qstart, $qend, $sstart, $send, $evalue, $bitscore) = split(/\t/, $line);

    #check to see if the id label is already in the first list of ids (called dedupe1)
    #if its not there, add it.
    if ( $dedupe1{$id} ) {
	#if it is, look at the old line to see if it is "better" than the new one.
	($list_id, $list_orf, $list_percent_identity, $list_align, $list_mismatches, $list_gap, $list_qstart, $list_qend, $list_sstart, $list_send, $list_evalue, $list_bitscore) = split(/\t/,$dedupe1{$id});

	#if the new evalue is better than the old one, change the value of this id to the new line.
	#otherwise, if the the new evalue is the same, and the percent_identity is better, change the value of this id to the new line.
	#otherwise, don't do anything (keep the old line).
	if ( $evalue < $list_evalue ) {
	    $dedupe1{$id} = $line;
	}
	elsif ( $evalue == $list_evalue ) {
	    if ( $percent_identity > $list_percent_identity ) {
		$dedupe1{$id} = $line;
	    }
	}
    }
    else {
	$dedupe1{$id} = $line;
	#count the number of non-duplicated lines we have in input file 1.
	$counter1++;
    }
}

print "De-duplicating File 2\n";

#Pass the information from the second input file into an array of text lines.
@in2 = <IN2>;

#Do stuff for each line of text in the second input file.
foreach $line (@in2) {
    #if the line starts with a pound symbol, it is not real data, so skip this line.
    if ( $line =~ /^#/ ) {
	 next;
     }

    #The chomp commands removes any new line (and carriage return) characters from the end of the line.
    chomp($line);

    #Split up the tab delimited line, naming only the variables we are interested in.
    ($id, $orf, $percent_identity, $align, $mismatches, $gap, $qstart, $qend, $sstart, $send, $evalue, $bitscore) = split(/\t/, $line);

    #check to see if the id label is already in the second list of ids (called dedupe2)
    #if its not there, add it.
    if ( $dedupe2{$id} ) {
	#if it is, look at the old line to see if it is still "better" than the new one.
	($list_id, $list_orf, $list_percent_identity, $list_align, $list_mismatches, $list_gap, $list_qstart, $list_qend, $list_sstart, $list_send, $list_evalue, $list_bitscore) = split(/\t/,$dedupe2{$id});

	#if the new evalue is better than the old one, change the value of this id to the new line.
	#otherwise, if the the new evalue is the same, and the percent_identity is better, change the value of this id to the new line.
	#otherwise, don't do anything (keep the old line).
	if ( $evalue < $list_evalue ) {
	    $dedupe2{$id} = $line;
	}
	elsif ( $evalue == $list_evalue ) {
	    if ( $percent_identity > $list_percent_identity ) {
		$dedupe2{$id} = $line;
	    }
	}
    }
    else {
	$dedupe2{$id} = $line;
	#count the number of non-duplicated lines we have in input file 1.
	$counter2++;
    }
}
print "File 1 de-dupe total = $counter1\n";
print "File 2 de-dupe total = $counter2\n";

$counter_unique1 = 0;
$counter_unique2 = 0;
$counter_common = 0;

#Write to first unique output file and common file\n";
#For each unique line in the first input file
foreach $id (keys %dedupe1) {
    #if it is in the second input file; write it to the common file, delete it from the second input list, and update the counter
    #if it is not in the second input file: write it to the first unique file and update the counter
    if ( $dedupe2{$id} ) {
	print OUT3 "$dedupe1{$id}\t$dedupe2{$id}\n";
	delete($dedupe2{$id});
	$counter_common++;
    }
    else {
	print OUT1 "$dedupe1{$id}\n";
	$counter_unique1++;
    }
}

#Everything left in the second input file list is unique (all common lines have been deleted previously).
#Write all of these lines to the second unique file and update the counter.
foreach $id (keys %dedupe2) {
    print OUT2 "$dedupe2{$id}\n";
    $counter_unique2++;
}
print "File 1 unique = $counter_unique1\n";
print "File 2 unique = $counter_unique2\n";
print "Common to both = $counter_common\n";

#close all the files.
close(IN1);
close(IN2);
close(OUT1);
close(OUT2);
close(OUT3);
print "Done.\n";

#-----------------------------------------------------------------------------------------------------------------------------------------
#Subroutines
#-----------------------------------------------------------------------------------------------------------------------------------------
sub usage {
    my($message) = @_;
    print "\n$message\n";
    print "\nThis script merges BLAST output from two \"short\" format files, by:\n";
    print "1) De-duping each of the two files. If there is more than one match for a particular sequence, keep only the \"best\" (sorts by smallest e-value and then biggest percent identity)\n";
    print "2) Creating 3 new files: sequences unique to file 1, sequences unique to file 2, and sequences found in both 1 and 2.\n";
    print "   These 3 new files will be named Unique_<filename1> Unique_<filename2> and Common_<filename1>_<filename2>\n";
    print "\nUsage: blast_merge.pl <filename1> <filename2> <output directory>\n";
    print "\nJennifer Meneghin\n";
    print "08/14/2007\n";
}
