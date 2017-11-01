#!/usr/bin/perl -w
#############################
###   Jennifer Meneghin   ###
###   Janurary 24, 2011   ###
#############################
#---------------------------------------------------------------------------------------------------------------------------
#Deal with passed parameters
#---------------------------------------------------------------------------------------------------------------------------
if ($#ARGV == -1) {
    &usage;
}
$big_fasta_file = "";
$sub_fasta_file = "";
$out_file = "RemainingSequences.fa";
%my_args = @ARGV;
for $i (sort keys %my_args) {
    if ($i eq "-i") {
	$sub_fasta_file = $my_args{$i};
    }
    elsif ($i eq "-f") {
	$big_fasta_file = $my_args{$i};
    }
    elsif ($i eq "-o") {
	$out_file = $my_args{$i};
    }
    else {
	print "\nUnrecognized argument: $i\n\n";
	&usage;
    }
}
unless ( open(IN, "$sub_fasta_file") ) {
    print "\nGot a bad small fasta file: $sub_fasta_file\n\n";
    &usage;
}
unless ( open(FASTA, "$big_fasta_file") ) {
    print "\nGot a bad big fasta file: $big_fasta_file\n\n";
    &usage;
}
unless ( open(OUT, ">$out_file") ) {
    print "\nGot a bad output file: $out_file\n\n";
    &usage;
}
print "Parameters:\nRemove this fasta file = $sub_fasta_file\nFrom this fasta file = $big_fasta_file\nAnd put the results in this file = $out_file\n\n";
#---------------------------------------------------------------------------------------------------------------------------
#The main event
#---------------------------------------------------------------------------------------------------------------------------
%records = ();
while (<IN>) {
    if (/^>/) {
	chomp;
	s/^(.+?)\s.*$/$1/g;
	s/\r//g;
	s/>//g;
	$records{$_} = $_;
    }
}
$seq = "";
$header = "";
while (<FASTA>) {
    if (/^>/) {
	if (length($header) > 0) {
	    if (!$records{$header}) {
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
    if (!$records{$header}) {
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
    print "\nUsage: ./remove_fasta_from_fasta.pl\n\n";
    print "Parameters:\n";
    print "-i input file\tA small fasta file.\n";
    print "-f input file\tA big fasta file.\n";
    print "-o output file\tReturns the big fasta file with records found in the small fasta file removed\n";
    print "\t\t(Optional. If not provide the output will be in a file called RemainingSequences.fasta)\n\n";
    print "This script removes any of the small fasta file records found in the big fasta file and returns the results.\n";
    print "(Note that the \"big\" file can actually be larger than the \"small\" file if you want.)\n\n";
    print "Jennifer Meneghin\n";
    print "January 24, 2011\n\n";
    exit;
}
#-----------------------------------------------------------------------
