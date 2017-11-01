#!/usr/bin/perl -w
##########################
### Jennifer Meneghin  ###
### August 4, 2009     ###
##########################
#-----------------------------------------------------------------------------------------------------------------------------------------
#Deal with passed parameters
#-----------------------------------------------------------------------------------------------------------------------------------------
#If no arguments are passed, show usage message and exit program.
if ($#ARGV == -1) {
    &usage;
}
#get the names of the blast file (first argument) and query file (second argument)
$fasta_file = $ARGV[0];
unless ( open(IN, "$fasta_file") ) {
    print "Got a bad fasta fasta file: $fasta_file\n";
    &usage;
}
unless ( open(OUT, ">open_reading_frames.fasta") ) {
    print "Couldn't create new fasta file: open_reading_frames.fasta\n";
    &usage;
}
print "Parameters:\nfasta file = $fasta_file\nopen reading frames = open_reading_frames.fasta\n\n";
#-----------------------------------------------------------------------------------------------------------------------------------------
#The main event
#-----------------------------------------------------------------------------------------------------------------------------------------
%scaffolds = ();
$sequence = "";
$header = "";
while (<IN>) {
    chomp;
    if (/^>/) {
	if (length($sequence) > 0) {
	    $scaffolds{$header} = $sequence;
	}
	$header = $_;
	$sequence = "";
    }
    else {
	$sequence = $sequence . $_;
    }
}
if (length($sequence) > 0) {
    $scaffolds{$header} = $sequence;
}
$last_index = 0;
$bad_counter = 0;
$good_counter = 0;
foreach $i (sort keys %scaffolds) {
    $seq = $scaffolds{$i};
    @bases = split(//, $seq);
    $counter = 0;
    foreach $j (0..$#bases) {
	if ($j+2 <= $#bases) {
	    $codon = $bases[$j] . $bases[$j+1] . $bases[$j+2];
	    if ($codon eq "TAG" || $codon eq "TGA" || $codon eq "TAA") {
		if ($j-$last_index > 99) {
		    print ".";
		    $counter++;
		    $scaffold_id = $i;
		    $scaffold_id =~ s/>(.+?)\s.+$/$1/g;
		    print OUT ">${scaffold_id}_${counter}\n";
		    foreach $k ($last_index..$j-1) {
			print OUT "$bases[$k]";
		    }
		    print OUT "\n";
		    $last_index = $j+3;
		    $good_counter++;
		}
		else {
		    $bad_counter++;
		}
	    }
	}
    }
}
print "\nGOOD = $good_counter\n";
print "BAD = $bad_counter\n";

sub usage {
    print "\nUSAGE: break_scaffolds_into_orfs.pl <scaffold fasta file>\n\n";
    print "This program breaks a fasta file of scaffolds into open reading frames*,\n";
    print "and returns a fasta file of all ORFs found in each scaffold with a minimum length of 99bp.\n\n";
    print "* An open reading frame is defined as the nucleotides between to two stop codons.\n\n";
    print "Jennifer Meneghin\n";
    print "08/06/2009\n\n";
    exit;
}
