#!/usr/bin/perl -w
#############################
###   Jennifer Meneghin   ###
###   April 7, 2010       ###
#############################
#---------------------------------------------------------------------------------------------------------------------------
#Deal with passed parameters
#---------------------------------------------------------------------------------------------------------------------------
if ($#ARGV == -1) {
    &usage;
}
$in_file = "";
$fasta_file = "";
$new_ndist_file = "new_ndist.txt";
%my_args = @ARGV;
for $i (sort keys %my_args) {
    if ($i eq "-i") {
	$in_file = $my_args{$i};
    }
    elsif ($i eq "-f") {
	$fasta_file = $my_args{$i};
    }
    elsif ($i eq "-o") {
	$new_ndist_file = $my_args{$i};
    }
    else {
	print "\nUnrecognized argument: $i\n\n";
	&usage;
    }
}
unless ( open(IN, "$in_file") ) {
    print "\nGot a bad input file: $in_file\n\n";
    &usage;
}
unless ( open(FASTA, "$fasta_file") ) {
    print "\nGot a bad fasta file: $fasta_file\n\n";
    &usage;
}
unless ( open(OUT, ">$new_ndist_file") ) {
    print "\nGot a bad new names file: $new_ndist_file\n\n";
    &usage;
}
print "Parameters:\ninput file = $in_file\nfasta file = $fasta_file\nnames file = $new_ndist_file\n\n";
#---------------------------------------------------------------------------------------------------------------------------
#The main event
#---------------------------------------------------------------------------------------------------------------------------
$unique_seqs = ();
$count = 0;
while (<FASTA>) {
    chomp;
    if (/^>/) {
	s/^>//g;
	$unique_seqs{$count} = $_;
	#print "US: $count\t$_\n";
	$count++;
    }
}
while (<IN>) {
    chomp;
    @fields = split(/\s+/);
    if ($unique_seqs{$fields[0]} && $unique_seqs{$fields[1]}) {
	#print "$unique_seqs{$fields[0]}\t$unique_seqs{$fields[1]}\t$fields[2]\n";
	print OUT "$unique_seqs{$fields[0]}\t$unique_seqs{$fields[1]}\t$fields[2]\n";
    }
    else {
	print "ERROR AT: $fields[0] $fields[1] $fields[2]\n";
    }
}
close(IN);
close(OUT);
close(FASTA);
#-----------------------------------------------------------------------
sub usage {
    print "\nUSAGE: ./get_clean_names.pl\n\n";
    print "Parameters:\n";
    print "-i <input file>\t\tThe filename.ndist file output from esprit\n";
    print "-f <input file>\t\tThe filename_Clean.fa file output from esprit\n";
    print "-o <output file>\tThe new ndist file to create. Optional. If not provided, a file called new_ndist.txt will be created.\n\n";
    print"This program takes the .ndist file and the _Clean.fa file output from esprit and replaces the fasta record indices in the .ndist file with the fasta record names.\n\n";
    print "Jennifer Meneghin\n";
    print "April 7, 2010\n\n";
    exit;
}
