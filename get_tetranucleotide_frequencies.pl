#!/usr/bin/perl
####################################################################################################
### Get Tetranucleotide Frequencies                                                              ###
### Usage: get_tetranucleotide_frequencies.pl <fasta file>                                       ###
### This program takes a fasta file as it's first (and only) parameter.                          ###
###                                                                                              ###
### It returns a tab delimited file (tetranucs_out.txt)                                          ###
###                                                                                              ###
### Jennifer Meneghin                                                                            ###
### July 31, 2012                                                                                ###
####################################################################################################
#---------------------------------------------------------------------------------------------------------------------------
#Deal with passed parameters
#---------------------------------------------------------------------------------------------------------------------------
if ($#ARGV == -1) {
    usage();
    exit;
}
$fasta_file = $ARGV[0];
$out_file = "tetranucs_out.txt";
unless ( open(IN, "$fasta_file") ) {    
    print "Got a bad fasta file: $fasta_file\n\n";
    exit;
}
unless ( open(OUT, ">$out_file") ) {
    print "Couldn't create $out_file\n";
    exit;
}
print "Parameters:\nfasta file = $fasta_file\noutput file = $out_file\n\n";
#---------------------------------------------------------------------------------------------------------------------------
#The main event
#---------------------------------------------------------------------------------------------------------------------------
$seq = "";
while (<IN>) {
    chomp;
    if (/^>/) {
	#finish up previous line.
	if (length($seq) > 0) {
	    &process_it;
	}
	#start new line.
	$id = $_;
	$id =~ s/^>(.+?)\s.+$/$1/g;
	print "ID = $id\n";
    }
    else {
	$seq = $seq . uc($_);
    }
}

#finish up last line.
&process_it;

print "Sorting...";

%fourmers;
%records;
for $i (sort keys %tetranucs) {
    @parts = split(/\t/, $i);
    $record = $parts[0];
    $fourmer = $parts[1];
    if ($fourmers{$fourmer}) {
	$fourmers{$fourmer} = $fourmers{$fourmer} + 1;
    }
    else {
	$fourmers{$fourmer} = 1;
    }
    if ($records{$record}) {
	$records{$record} = $records{$record} + 1;
    }
    else {
	$records{$record} = 1;
    }
}

print "Printing...";

print OUT "Tetranucleotide";
for $j (sort keys %records) {
    print OUT "\t$j";
}
print OUT "\n";
for $i (sort keys %fourmers) {
    print OUT "$i";
    for $j (sort keys %records) {
	$key = $j . "\t" . $i;
	if ($tetranucs{$key}) {
	    print OUT "\t$tetranucs{$key}";
	}
	else {
	    print OUT "\t0";
	}
    }
    print OUT "\n";
}

close(IN);
close(OUT);

sub usage {
    print "Get Tetranucleotide Frequencies\n";
    print "Usage: get_tetranucleotide_frequencies.pl <fasta file>\n";
    print "This program takes a fasta file as it's first (and only) parameter.\n\n";
    print "It returns a tab delimited file (tetranucs_out.txt) of tetranucleotides. (columns = records, rows = tetranucleotide counts.)\n\n";
    print "Jennifer Meneghin\n";
    print "July 31, 2012\n\n";
}

sub process_it {
    @letters = split(//, $seq);
    for $i (0..$#letters-3) {
	$tetra = $letters[$i] . $letters[$i+1] . $letters[$i+2] . $letters[$i+3];
	$key = $id . "\t" . $tetra;
	if ($tetranucs{$key}) {
	    $tetranucs{$key} = $tetranucs{$key} + 1;
	}
	else {
	    $tetranucs{$key} = 1;
	}
    }
    $seq = "";
    $id = "";
}
