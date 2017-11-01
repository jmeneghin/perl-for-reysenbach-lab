#!/usr/bin/perl -w
############################
###   Jennifer Meneghin  ###
###   October 7, 2010    ###
############################
#---------------------------------------------------------------------------------------------------------------------------
#Deal with passed parameters
#---------------------------------------------------------------------------------------------------------------------------
if ($#ARGV == -1) {
    &usage;
}
$in_file = "";
$out_file = "Unifrac.txt";
$sample_delimiter = "_";
%my_args = @ARGV;
for $i (sort keys %my_args) {
    if ($i eq "-i") {
	$in_file = $my_args{$i};
    }
    elsif ($i eq "-d") {
	$sample_delimiter = $my_args{$i};
    }
    elsif ($i eq "-o") {
	$out_file = $my_args{$i};
    }
    else {
	print "\nUnrecognized argument: $i\n\n";
	&usage;
    }
}
unless ( open(CLUST, "$in_file") ) {
    print "\nGot a bad names file (created by get_uniques_and_names_file.pl): $in_file\n\n";
    &usage;
}
unless ( open(OUT, ">$out_file") ) {
    print "\nGot a bad output file: $out_file\n\n";
    &usage;
}
print "Parameters:\nsample delimiter = $sample_delimiter\nnames file = $in_file\noutput file = $out_file\n\n";
#---------------------------------------------------------------------------------------------------------------------------
#The main event
#---------------------------------------------------------------------------------------------------------------------------
while (<CLUST>) {
    chomp;
    @fields = split(/\t/);
    $label = $fields[0];
    @others = split(/, /, $fields[1]);
    %sample_counts = ();
    for $i (0..$#others) {
	@parts = split(/$sample_delimiter/, $others[$i]);
	$sample = $parts[1];
	if ($sample_counts{$sample}) {
	    $sample_counts{$sample} = $sample_counts{$sample} + 1;
	}
	else {
	    $sample_counts{$sample} = 1;
	}
    }
    for $i (sort keys %sample_counts) {
	print "$label $i $sample_counts{$i}\n";
	print OUT "$label $i $sample_counts{$i}\n";
    }
}
close(CLUST);
close(OUT);
#-----------------------------------------------------------------------
#***To DO:
sub usage {
    print "\nUsage: ./summarize_uniques.pl\n\n";
    print "Parameters:\n";
    print "-i input file\t\tA names file created by get_uniques_and_names.pl.\n";
    print "-d sample delimiter\tEach record in the names file must be in the format a fasta record name,\n";
    print "\t\t\ta delimiter, then the name of the sample this record came from (optional, Default is an underscore.)\n";
    print "-o output file\t\tThe name of the unifrac text file to create (optional, Default = Unifrac.txt)\n\n";
    print "This script takes a names file created by get_uniques_and_names.pl and returns a text file in the format unifrac expects. Use the fasta file created by get_uniques_and_names.pl with this file in unifrac.\n\n";
    print "Jennifer Meneghin\n";
    print "October 7, 2010\n\n";
    exit;
}
#-----------------------------------------------------------------------
