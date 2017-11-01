#!/usr/bin/perl -w
#############################
###   Jennifer Meneghin   ###
###   October 23, 2012    ###
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
$header = "";
$seq = "";
while (<FASTA>) {
    if (/^>/) {
	if (length($header) > 0) {
	    $records{$header} = $seq;
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
    $records{$header} = $seq;
}
while (<IN>) {
    chomp;
    s/\r//g;
    if (/\t/) {
	@fields = split(/\t/);
	$header = $fields[0];
    }
    else {
	$header = $_;
    }
    print OUT ">$header\n";
    print OUT "$records{$header}\n";
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
    print "-o output file\tReturns a fasta file.\n\n";
    print "Returns a fasta file with only the selected sequences from the original FASTA sequence file, in the order found in the list file.\n";
    print "This one is only meant for 'reasonably' sized files.\n\n";
    print "Jennifer Meneghin\n";
    print "October 23, 2012\n\n";
    exit;
}
#-----------------------------------------------------------------------
