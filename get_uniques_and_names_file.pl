#!/usr/bin/perl -w
#############################
###   Jennifer Meneghin   ###
###   April 12, 2010      ###
#############################
#---------------------------------------------------------------------------------------------------------------------------
#Deal with passed parameters
#---------------------------------------------------------------------------------------------------------------------------
if ($#ARGV == -1) {
    &usage;
}
$in_file = "";
$fasta_file = "uniques.fasta";
$names_file = "names.txt";
%my_args = @ARGV;
for $i (sort keys %my_args) {
    if ($i eq "-i") {
	$in_file = $my_args{$i};
    }
    elsif ($i eq "-o") {
	$fasta_file = $my_args{$i};
    }
    elsif ($i eq "-n") {
	$names_file = $my_args{$i};
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
unless ( open(FASTA, ">$fasta_file") ) {
    print "\nGot a bad output file: $out_file\n\n";
    &usage;
}
unless ( open(NAMES, ">$names_file") ) {
    print "\nGot a bad output file: $out_file\n\n";
    &usage;
}
print "Parameters:\ninput file = $in_file\nfasta file = $fasta_file\nnames file = $names_file\n\n";
#---------------------------------------------------------------------------------------------------------------------------
#The main event
#---------------------------------------------------------------------------------------------------------------------------
$header = "";
$seq = "";
$unique_seqs = ();
$name_linker = ();
$seq_lengths = ();
while (<IN>) {
    chomp;
    s/\r//g;
    if (/^>/) {
	if (length($header) > 0) {
	    if ($unique_seqs{$seq}) {
		$unique_seqs{$seq} = $unique_seqs{$seq} . ", " . $header;	
	    }
	    else {
		$unique_seqs{$seq} = $header;
		$seq_lengths{$seq} = length($seq);
		$name_linker{$seq} = $header;
	    }
	}
	$header = $_;
	$header =~ s/^>//g;
	$seq = "";
    }
    else {
	$seq = $seq . $_;
    }
}
if (length($header) > 0) {
    if ($unique_seqs{$seq}) {
	$unique_seqs{$seq} = $unique_seqs{$seq} . ", " . $header;	
    }
    else {
	$unique_seqs{$seq} = $header;
	$seq_lengths{$seq} = length($seq);
	$name_linker{$seq} = $header;
    }
}
foreach $i (sort { $seq_lengths{$a} <=> $seq_lengths{$b} } keys %seq_lengths) {
    foreach $j (sort { $seq_lengths{$a} <=> $seq_lengths{$b} } keys %seq_lengths) {
	if ( ($i ne $j) && ($j =~ /$i/) ) {
	    print "FOLDING: $i\nINTO...: $j\n";
	    $unique_seqs{$j} = $unique_seqs{$j} . ", " . $unique_seqs{$i};
	    delete($unique_seqs{$i});
	    delete($seq_lengths{$i});
	    last;
	}
    }
}
for $i (sort keys %unique_seqs) {
    print "$name_linker{$i}\t$unique_seqs{$i}\n";
    print NAMES "$name_linker{$i}\t$unique_seqs{$i}\n";
    print FASTA ">$name_linker{$i}\n$i\n";
}
close(IN);
close(NAMES);
close(FASTA);
#-----------------------------------------------------------------------
sub usage {
    print "\nUSAGE: ./get_uniques_and_names_file.pl\n\n";
    print "Parameters:\n";
    print "-i <input file>\t\tA fasta file\n";
    print "-o <output file>\tThe new fasta file to create. Optional. If not provided, a file called uniques.fasta will be created.\n";
    print "-n <names file>\t\tThe new names file to create. Optional. If not provided, a file called names.txt will be created.\n\n";
    print "This script takes a fasta file and creates two new files: a new fasta file with only the unique records included, and a tabbed delimited file that matches up the records used in the new fasta file to their duplicates records. A unique sequence set here means any sequences that are exactly the same OR proper subsets of the original sequence.\n\n";
    print "Jennifer Meneghin\n";
    print "April 1, 2010\n\n";
    exit;
}
