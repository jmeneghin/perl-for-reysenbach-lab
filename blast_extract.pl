#!/usr/bin/perl -w
############################
###   Jennifer Meneghin  ###
###   August 9, 2010     ###
############################

#---------------------------------------------------------------------------------------------------------------------------
#Deal with passed parameters
#---------------------------------------------------------------------------------------------------------------------------
#If no arguments are passed, show usage message and exit program.
if ($#ARGV == -1) {
    &usage;
}
$in_file = "";
$fasta_file = "";
$out_file = "extracted.txt";
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
	print "Unrecognized argument: $i\n\n";
	&usage;
    }
}
unless ( open(IN, "$in_file") ) {
    print "Couldn't read input file: $in_file\n";
    &usage;
}
unless ( open(FASTA, "$fasta_file") ) {
    print "Couldn't read input file: $fasta_file\n";
    &usage;
}
unless ( open(OUT, ">$out_file") ) {
    print "Couldn't write to output file: $out_file\n";
    &usage;
}
print "Parameters:\nInput file = $in_file\nOutput file = $out_file\nFasta file = $fasta_file\n\n";
#-------------------------------------------------------------------------------------------------
#The main event
#-------------------------------------------------------------------------------------------------
$fasta_ids = ();
while(<FASTA>) {
    if (/^>/) {
	chomp;
	$id = $_;
	$id =~ s/^>(.+?)\s.+$/$1/g;
	$fasta_ids{$id} = $id;
    }
}
close(FASTA);
while (<IN>) {
    @fields = split(/\t/);
    if ($fasta_ids{$fields[0]}) {
	print "$_";
	print OUT "$_";
    }
}
close(IN);
close(OUT);
#-----------------------------------------------------------------------
sub usage {
    print "Jennifer Meneghin\n";
    print "August 9, 2010\n\n";
    print "Usage: blast_extract.pl -i <input file> -o <output file> -f <fasta file>\n\n";
    print "This program takes a fasta file and a blast output file, and it returns only the blast lines that are contained in the fasta file.\n\n";
    exit;
}
