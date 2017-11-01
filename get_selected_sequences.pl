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
$fasta_file = "";
$out_file = "SelectedSequences.fa";
%my_args = @ARGV;
for $i (sort keys %my_args) {
    if ($i eq "-i") {
	$in_file = $my_args{$i};
    }
    elsif ($i eq "-f") {
	$fasta_file = $my_args{$i};
    }
    elsif ($i eq "-o") {
	$out_file = $my_args{$i};
    }
    else {
	print "\nUnrecognized argument: $i\n\n";
	&usage;
    }
}
unless ( open(IN, "$in_file") ) {
    print "\nGot a bad sequence ID list file: $in_file\n\n";
    &usage;
}
unless ( open(FASTA, "$fasta_file") ) {
    print "\nGot a bad FASTA file: $fasta_file\n\n";
    &usage;
}
unless ( open(OUT, ">$out_file") ) {
    print "\nGot a bad output file: $out_file\n\n";
    &usage;
}
print "Parameters:\nsequence ID list file = $in_file\nFASTA file = $fasta_file\noutput file = $out_file\n\n";
#---------------------------------------------------------------------------------------------------------------------------
#The main event
#---------------------------------------------------------------------------------------------------------------------------
%records = ();
while (<IN>) {
    chomp;
    s/\r//g;
    $records{$_} = $_;
}
$seq = "";
$header = "";
while (<FASTA>) {
    if (/^>/) {
	if (length($header) > 0) {
	    if ($records{$header}) {
		print ">$header\n";
		print OUT ">$header\n";
		print OUT "$seq";
	    }
	    $header = "";
	    $seq = "";
	}
	$header = $_;
	$header =~ s/>//g;
	$header =~ s/^(.+?)\s.*$/$1/g;
	chomp($header);
    }
    else {
	$seq = $seq . $_;
    }
}
if (length($header) > 0) {
    if ($records{$header}) {
	print ">$header\n";
	print OUT ">$header\n";
	print OUT "$seq";
    }
}
close(IN);
close(FASTA);
close(OUT);
#-----------------------------------------------------------------------
sub usage {
    print "\nUsage: ./get_selected_sequences.pl\n\n";
    print "Parameters:\n";
    print "-i input file\tA Sequence ID List file that contains one sequence ID per line.\n";
    print "-f input file\tA FASTA file.\n";
    print "-o output file\tReturns a fasta file with only the selected sequences from the original FASTA sequence file.\n\n";
    print "This script selects the sequences (in the sequence id list file) from the original fasta file.\n\n";
    print "Jennifer Meneghin\n";
    print "April 12, 2010\n\n";
    exit;
}
#-----------------------------------------------------------------------
