#!/usr/bin/perl -w
#############################
###   Jennifer Meneghin   ###
###   June 1, 2010      ###
#############################
#---------------------------------------------------------------------------------------------------------------------------
#Deal with passed parameters
#---------------------------------------------------------------------------------------------------------------------------
if ($#ARGV == -1) {
    &usage;
}
$in_file = "";
$out_file = "SelectedSequences.fa";
$lte = 80;
%my_args = @ARGV;
for $i (sort keys %my_args) {
    if ($i eq "-i") {
	$in_file = $my_args{$i};
    }
    elsif ($i eq "-o") {
	$out_file = $my_args{$i};
    }
    elsif ($i eq "-n") {
	$lte = $my_args{$i};
	if (!($lte =~ /^\d+$/)) {
	    print "\nUpper length limit must be an integer. You entered: $lte\n\n";
	    &usage;
	}
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
unless ( open(OUT, ">$out_file") ) {
    print "\nGot a bad output file: $out_file\n\n";
    &usage;
}
print "Parameters:\nfasta file = $in_file\noutput file = $out_file\n\n";
#---------------------------------------------------------------------------------------------------------------------------
#The main event
#---------------------------------------------------------------------------------------------------------------------------
$seq = "";
$header = "";
while (<IN>) {
    chomp;
    if (/^>/) {
	if (length($header) > 0) {
	    if (length($seq) <= $lte) {
		print ">$header\n";
		print OUT ">$header\n";
		#print OUT "$seq";
		print OUT "$seq\n";
	    }
	    $header = "";
	    $seq = "";
	}
	$header = $_;
	$header =~ s/>//g;
	#chomp($header);
    }
    else {
	$seq = $seq . $_;
    }
}
if (length($header) > 0) {
    if (length($seq) <= $lte) {
	print ">$header\n";
	print OUT ">$header\n";
	#print OUT "$seq";
	print OUT "$seq\n";
    }
}
close(IN);
close(OUT);
#-----------------------------------------------------------------------
sub usage {
    print "Usage: get_seqs_lte_length.pl\n\n";
    print "Parameters:\n";
    print "-i input file\tA fasta file\n";
    print "-o output file\tThe new fasta file with only records less than or equal to the length provided\n";
    print "-n a number\tIn the new fasta file, include sequences less than or equal to this number\n\n";
    print "This script takes a fasta file (-i) and an integer (-n) and returns a new fasta file that contains only those records that are of length less than or equal to the number provided.\n\n";
    print "Jennifer Meneghin\n";
    print "June 1, 2010\n\n";
    exit;
}
#-----------------------------------------------------------------------
