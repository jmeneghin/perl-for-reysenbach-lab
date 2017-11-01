#!/usr/bin/perl

##########################
### Jennifer Meneaghin ###
### July 2, 2012       ###
##########################

use strict;

my $usage = "Use: $0 input.fastq\n";

if (scalar @ARGV != 1) { 
    &usage;
    exit(1);
}
if (! (open (IN, "<$ARGV[0]"))) {
    print "\nCan't open $ARGV[0]: $!\n";
    &usage;
    exit(1);
}
if (-e "$ARGV[0].fasta") {
    print "\n$ARGV[0].fasta extists - please remove or rename\n";
    &usage;
    exit(1);    
}
if (-e "$ARGV[0].qual") {
    print "\n$ARGV[0].qual extists - please remove or rename\n";
    &usage;
    exit(1);    
}
if (! (open (FASTA, ">$ARGV[0].fasta"))) {
    print "\nCan't write to $ARGV[0].fasta: $!\n";
    &usage;
    exit(1);    
}
if (! (open (QUAL, ">$ARGV[0].qual"))) {
    print "\nCan't write to $ARGV[0].qual: $!\n";
    &usage;
    exit(1);    
}

my $seqnext = 0;
my $qualnext = 0;
my $line = "";
while (<IN>) {
    $line = $_;
    if ($seqnext == 1) {
	print FASTA $line;
	$seqnext = 0;
    }
    elsif ($qualnext == 1) {
	print QUAL $line;
	$qualnext = 0;	
    }
    elsif ($line =~ s/^\@//o) { #Yes, the qual score can also begin with an at symbol, but if that is the case, qualnext should already be set to one.
	print FASTA ">$line";
	print QUAL ">$line";
	$seqnext = 1;
    }
    elsif ($line =~ s/^\+//o) {
	$qualnext = 1;
    }
}

sub usage {
    print "\nUSAGE: fastq_to_fasta.pl file.fastq\n\n";
    print "This program takes a fastq file and returns a fasta file (the original filename with .fasta appended)\n";
    print "and a quality score file (the original filename with .qual appended).\n\n";
    print "Jennifer Meneghin\n";
    print "07/02/2012\n\n";
}
	  
