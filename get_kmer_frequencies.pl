#!/usr/bin/perl
###########################################################################
### Get kmer Frequencies                                                ###
### Usage: get_kmer_frequencies.pl <fasta file>                         ###
### This program takes a fasta file, k and a prefix as it's parameters. ###
###                                                                     ###
### It returns a tab delimited file                                     ###
###                                                                     ###
### Jennifer Meneghin                                                   ###
### May 11, 2015                                                        ###
###                                                                     ###
### Updated. Now it returns results with summed reverse compliments     ###
### Jennifer Meneghin                                                   ###
### February 10, 2016                                                   ###
###########################################################################
#---------------------------------------------------------------------------------------------------------------------------
#Deal with passed parameters
#---------------------------------------------------------------------------------------------------------------------------
if ($#ARGV == -1) {
    usage();
    exit;
}
$fasta_file = $ARGV[0];
#$prefix = "Ta";
$k = $ARGV[1];
$prefix = $ARGV[2];
$out_file = "${prefix}_kmers.txt";
unless ( open(IN, "$fasta_file") ) {    
    print "Got a bad fasta file: $fasta_file\n\n";
    exit;
}
unless ( open(OUT, ">$out_file") ) {
    print "Couldn't create $out_file\n";
    exit;
}
print "Parameters:\nfasta file = $fasta_file\noutput file = $out_file\nk = $k\n";


#---------------------------------------------------------------------------------------------------------------------------
#The main event
#---------------------------------------------------------------------------------------------------------------------------

$start = time();

$seq = "";
$pc = 0;
$linecount = 0;
while (<IN>) {
    chomp;
    if (/^>/) {
	#finish up previous line.
	if (length($seq) > 0) {
	    &process_it;
	}
	#start new line.
	$id = $_;
	$id =~ s/^>//g;
	$pc++;
	if ($pc % 100 == 0) {
	    print "count = $pc\n";
	}
    }
    else {
	$seq = $seq . uc($_);
    }
    $linecount++;
    if ($linecount % 10000 == 0) {
	print "line count = $linecount\n";
    }
}

#finish up last line.
&process_it;

print "Sorting...\n";
%kmers;
%records;
for $i (sort keys %knucs) {
    @parts = split(/\t/, $i);
    $record = $parts[0];
    $kmer = $parts[1];
    if ($kmers{$kmer}) {
	$kmers{$kmer} = $kmers{$kmer} + 1;
    }
    else {
	$kmers{$kmer} = 1;
    }
    if ($records{$record}) {
	$records{$record} = $records{$record} + 1;
    }
    else {
	$records{$record} = 1;
    }
}

print "Printing...\n";
print OUT "${k}-mer";
for $j (sort keys %records) {
    print OUT "\t$prefix_$j";
}
print OUT "\n";
$testsum = 0;
for $i (sort keys %kmers) {
    print OUT "$i";
    for $j (sort keys %records) {
	$key = $j . "\t" . $i;
	if ($knucs{$key}) {
	    print OUT "\t$knucs{$key}";
	    $testsum = $testsum + $knucs{$key};
	}
	else {
	    print OUT "\t0";
	}
    }
    print OUT "\n";
}
#print "TEST SUM = $testsum\n";
close(IN);
close(OUT);

$stop = time();
$total_time = $stop - $start;
print "Total time to run = $total_time\n";
    

sub usage {
    print "Get kmer Frequencies\n";
    print "Usage: get_kmer_frequencies.pl <fasta file>\n";
    print "This program takes a fasta file, k and prefix as it's parameters.\n\n";
    print "It returns a tab delimited file (knucs_out.txt) of kmer counts. (columns = records, rows = kmer counts.)\n\n";
    print "Jennifer Meneghin\n";
    print "May 11, 2015\n\n";
    print "Updated. Now results are returned with summed reverse compliments\n";
    print "Jennifer Meneghin\n";
    print "February 10, 2016\n\n";
}

sub process_it {
    @letters = split(//, $seq);
    $end = $#letters - $k + 1;
    for $i (0..$end) {
	$thiskmer = "";
	for $j ($i..($i+$k-1)) {
	    $thiskmer = $thiskmer . $letters[$j];
	}
	$rckmer = &rc_seq($thiskmer);
	#print "$id\tthiskmer = $thiskmer\n";
	#print "$id\trc  kmer = $rckmer\n";
	if ($thiskmer le $rckmer) {
	    $key = $id . "\t" . $thiskmer;
	}
	else { #count goes in rckmer bin instead
	    $key = $id . "\t" . $rckmer;
	}
	if ($knucs{$key}) {
	    $knucs{$key} = $knucs{$key} + 1;
	}
	else {
	    $knucs{$key} = 1;
	}
    }
    $seq = "";
    $id = "";
}

sub rc_seq {
    my ($mykmer) = @_;    
    my @myletters = split(//,$mykmer);
    my (@rcmykmer);
    for $i (0..$k-1) {
	if ($myletters[$i] eq "A") {
	    $rcmykmer[$k-$i-1] = "T"
	}
	elsif ($myletters[$i] eq "C") {
	    $rcmykmer[$k-$i-1] = "G"
	}
	elsif ($myletters[$i] eq "G") {
	    $rcmykmer[$k-$i-1] = "C"
	}
	elsif ($myletters[$i] eq "T") {
	    $rcmykmer[$k-$i-1] = "A"
	}
	else {
	    $rcmykmer[$k-$i-1] = $myletters[$i]; #No swap of Ns and such
	}
    }
    $thisrcmykmer = "";
    for $i (0..$k-1) {
	$thisrcmykmer = $thisrcmykmer . $rcmykmer[$i];
    }
    return $thisrcmykmer;
}
