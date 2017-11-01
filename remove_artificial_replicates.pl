#!/usr/bin/perl -w
#####################################
### Remove Artificial Replicates  ###
### Jennifer Meneghin             ###
### August 11, 2010               ###
#####################################
#--------------------------------------------------------------------------------------------------------------------------
#Deal with passed parameters
#--------------------------------------------------------------------------------------------------------------------------
if ($#ARGV == -1) {
    &usage;
}
%my_args = @ARGV;
$fasta_file = "";
$out_file = "dereplicated.fasta";
for $i (sort keys %my_args) {
    if ($i eq "-f") {
	$fasta_file = $my_args{$i};
    }
    elsif ($i eq "-o") {
	$out_file = $my_args{$i};
    }
    else {
	print "\nUnrecognized paramater: $i $my_args{$i}\n\n";
	&usage;
    }
}
unless ( open(IN, "$fasta_file") ) {    
    print "\nGot a bad fasta file: $fasta_file\n\n";
    &usage;
}
if (-e $out_file) {
    print "\nCouldn't create $out_file because it already exists.\n";
    &usage;
}
unless ( open(OUT, ">$out_file") ) {
    print "\nCouldn't create $out_file\n";
    &usage;
}
print "Parameters:\nfasta file = $fasta_file\noutput file = $out_file\n\n";
#---------------------------------------------------------------------------------------------------------------------------
#The main event
#---------------------------------------------------------------------------------------------------------------------------
$seq = "";
$header = "";
#@new_fasta;
%good_seqs = ();
%first3s = ();
$count = 0;
while (<IN>) {
    chomp;
    if (/^>/) {
	&check_it;
	$header = $_;
    }
    else {
	$seq = $seq . $_;
    }
}
&check_it;
$count = 0;
for $i (0..$#new_fasta) {
    print OUT "$new_fasta[$i]\n";
    if ($new_fasta[$i] =~ /^>/) {
	$count++;
    }
}
print "TOTAL = $count\n";
close(IN);
close(OUT);
#---------------------------------------------------------------------------
# Subroutines.
#---------------------------------------------------------------------------
sub check_it {
    if (length($seq) > 0) {
	$flag = 0;
	$first_three = substr($seq, 0, 3);
	$len = length($seq);
	if ($good_seqs{$seq}) { #if it's an exact duplicate, we can keep it simple.
	    $flag = 1;
	}
	elsif ( $first3s{$first_three} ) {
	    @subset = split(/\t/, $first3s{$first_three});
	    for $i (0..$#subset) {
		if ( ($len >= length($subset[$i])-1) && ($len <= length($subset[$i]) + 1) ) {
		    $to_match = ($len * 99) / 100;
		    $does_match = 0;
		    @seq_nucs = split(//, $seq);
		    @list_nucs = split(//, $subset[$i]);
		    $num_to_check = $#seq_nucs;
		    if ($#list_nucs < $num_to_check) {
			$num_to_check = $#list_nucs;
		    }
		    for $j (0..$num_to_check) {
			if ($seq_nucs[$j] eq $list_nucs[$j]) {
			    $does_match++;
			}
		    }
		    if ( $does_match >= $to_match ) {
			$flag = 1;
			last;
		    }
		}
	    }
	}
	if ($flag == 0) {
	    $good_seqs{$seq} = $seq;
	    if ($first3s{$first_three}) {
		$first3s{$first_three} = $first3s{$first_three} . "\t" . $seq;
	    }
	    else {
		$first3s{$first_three} = $seq;
	    }
	    push(@new_fasta, $header);
	    push(@new_fasta, $seq);
	    $count++;
	    if ($count % 100 == 0) {
		print "$count\n";
	    }
	}
	$flag = 0;
	$seq = "";
    }
}

sub usage {
    print "\nUsage: remove_artificial_replicates.pl -f fasta_file -o out_file\n\n";
    print "Parameters:\n";
    print "-f fasta_file:\tThe fasta file to dereplicate.\n";
    print "-o out_file:\tThe name of the new fasta file to create (optional. Default = dereplicated.fasta)\n\n";
    print "This script takes a fasta file and returns a new fasta file with the artificial replicates removed\n\n";
    print "An artificial replicate is defined here as \"sequences differing by no more than 1 bp in length, sharing 99% nucleotide identity, and having identical start sites (first 3bp)\" (Stewart, F. J., Ottesen, E. A. & DeLong, E. F. (2010). Development and quantitative analysis of a universal rRNA-subtraction protocol for microbial metatranscriptomics. The ISME Journal, 4: 896-907).\n\n";
    print "Jennifer Meneghin\n";
    print "08/11/2010\n";
    exit;
}
