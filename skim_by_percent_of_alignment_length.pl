#!/usr/bin/perl -w
# Jennifer Meneghin
# 10/28/2010

#---------------------------------------------------------------------------------------------------------------------------
#Deal with passed parameters
#---------------------------------------------------------------------------------------------------------------------------
#If no arguments are passed, show usage message and exit program.
if ($#ARGV == -1) {
    &usage;
    exit;
}
$in_file = "";
$fasta_file = "";
$out_file = "alignment_skimmed.txt";
$cutoff = 80;
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
    elsif ($i eq "-p") {
	if ($my_args{$i} =~ /^\d+$/) {
	    $cutoff = $my_args{$i};
	    if ($cutoff < 1) {
		print "Alignment Percentage cut-off must be greater than 1. You entered: $my_args{$i}\n\n";
		&usage;
	    }
	    elsif ($cutoff > 100) {
		print "Alignment Percentage cut-off must be less then 100. You entered: $my_args{$i}\n\n";
		&usage;
	    }
	}
	else {
	    print "Alignment Percentage cut-off must be between 0 and 100. You entered: $my_args{$i}\n\n";
	    &usage;
	}
    }
    else {
	print "Unrecognized argument: $i\n\n";
	&usage;
    }
}
#Open the input and fasta file for reading, open the output file for writing.
#If any are unsuccessful, print an error message and exit program.
unless ( open(IN, "$in_file") ) {
    print "Got a bad input file: $in_file";
    &usage;
}
unless ( open(FASTA, "$fasta_file") ) {
    print "Got a bad fasta file: $fasta_file";
    &usage;
}
unless ( open(OUT, ">$out_file") ) {
    print "Got a bad output file: $out_file";
    &usage;
}
#Everything looks good. Print the parameters we've found.
print "Parameters:\ninput file = $in_file\nfasta file = $fasta_file\noutput file = $out_file\npercent cut-off = ${cutoff}%\n\n";
#---------------------------------------------------------------------------------------------------------------------------
#The main event
#---------------------------------------------------------------------------------------------------------------------------
$cutoff = $cutoff * 0.01;
$id = "";
$seq = "";
%lengths = ();
while(<FASTA>) {
    $line = $_;
    chomp($line);
    if (/^>/) {
	if (length($seq) > 0) {
	    $lengths{$id} = length($seq);
	}
	$id = $line;
	$id =~ s/^>(.+?)\s.+$/$1/g;
	$seq = "";
    }
    else {
	$seq = $seq . $line;
    }
}
if (length($seq) > 0) {
    $lengths{$id} = length($seq);
}
close(FASTA);
while(<IN>) {
    $line = $_;
    chomp($line);
    if ( !($line =~ /^#/) ) {
	@fields = split(/\t/, $line);
	if ($fields[3] >= $cutoff * $lengths{$fields[0]}) {
	    print OUT "$line\t$lengths{$fields[0]}\n";
	}
    }
}
close(IN);
close(OUT);
print "Done.\n";
#---------------------------------------------------------------------------------------------------------------------------
#Subroutines
#---------------------------------------------------------------------------------------------------------------------------
sub usage {
    print "\nUsage: skim_by_percent_of_alignment_length.pl -i inputfile -f fastafile -o outputfile -p percent\n\n";
    print "Parameters:\n";
    print "-i inputfile\tA blast output file in short format\n";
    print "-f fastafile\tThe fasta file used as the query in the blast\n";
    print "-o outputfile\tThe new \"skimmed\" blast output file. Optional. default = alignment_skimmed.txt\n";
    print "-p percent\tThe percentage used for the alignment cut-off. Must an integer from 1 to 100. Optional. default = 80\n\n";
    print "This script first calculates the length of each record in the fasta file, then retains the blast hit if it the alignment length is at least X% of of the length of the fasta record length. Default is X = 80%\n\n";
    print "Jennifer Meneghin\n";
    print "10/28/2010\n\n";
    exit;
}

