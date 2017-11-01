#!/usr/bin/perl -w
#############################
###   Jennifer Meneghin   ###
###   November 13, 2012   ###
#############################
#---------------------------------------------------------------------------------------------------------------------------
#Deal with passed parameters
#---------------------------------------------------------------------------------------------------------------------------
if ($#ARGV == -1) {
    &usage;
}
$fasta_file = "";
$out_file = "SelectedSequence.fasta";
$start = 0;
$end = 999;
%my_args = @ARGV;
for $i (sort keys %my_args) {
    if ($i eq "-f") {
	$fasta_file = $my_args{$i};
    }
    elsif ($i eq "-o") {
	$out_file = $my_args{$i};
    }
    elsif ($i eq "-s") {
	$start = $my_args{$i};
    }
    elsif ($i eq "-e") {
	$end = $my_args{$i};
    }
    else {
	print "\nUnrecognized argument: $i\n\n";
	&usage;
    }
}
unless ( open(FASTA, "$fasta_file") ) {
    print "\nGot a bad FASTA file: $fasta_file\n\n";
    &usage;
}
unless ( open(OUT, ">$out_file") ) {
    print "\nGot a bad output file: $out_file\n\n";
    &usage;
}
print "Parameters:\nFASTA file = $fasta_file\noutput file = $out_file\nStart = $start\nEnd = $end\n\n";
#---------------------------------------------------------------------------------------------------------------------------
#The main event
#---------------------------------------------------------------------------------------------------------------------------
$seq = "";
$header = "";
while (<FASTA>) {
    chomp;
    if (/^>/) {
	if ($header eq "") {
	    $header = $_;
	}
	else {
	    print "Only one record allowed in the fasta file for this script.\n\n";
	    &usage();
	}
    }
    else {
	$seq = $seq . $_;
    }
}
close(FASTA);
$seq_length = $end - $start + 1;
$new_seq = substr($seq, $start-1, $seq_length);
print OUT "$header SUBSEQUENCE = $start...$end\n";
print OUT "$new_seq\n";
close(OUT);
#-----------------------------------------------------------------------
sub usage {
    print "\nUsage: ./extract_sequence.pl\n\n";
    print "Parameters:\n";
    print "-f input file\tA FASTA file.\n";
    print "-o output file\tReturns a fasta file with only the selected sequence from the original FASTA file.\n";
    print "-s number\tWhere to start the extraction\n";
    print "-e number\tWhere to end the extraction\n\n";
    print "This script takes a fasta file with ONE record, extracts the sequence from start (-s) to end (-e),\n";
    print "and returns only this sequence in a new fasta file.\n\n";
    print "Jennifer Meneghin\n";
    print "November 13, 2012\n\n";
    exit;
}
#-----------------------------------------------------------------------
