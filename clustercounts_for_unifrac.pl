#!/usr/bin/perl -w
#############################
###   Jennifer Meneghin   ###
###   June 21, 2010       ###
#############################
#---------------------------------------------------------------------------------------------------------------------------
#Deal with passed parameters
#---------------------------------------------------------------------------------------------------------------------------
if ($#ARGV == -1) {
    &usage;
}
$in_file = "";
$out_file = "Unifrac.txt";
%my_args = @ARGV;
for $i (sort keys %my_args) {
    if ($i eq "-i") {
	$in_file = $my_args{$i};
    }
    elsif ($i eq "-o") {
	$out_file = $my_args{$i};
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
unless ( open(OUT, ">$out_file") ) {
    print "\nGot a bad output file: $out_file\n\n";
    &usage;
}
print "Parameters:\ninput file = $in_file\noutput file (unifrac format) = $out_file\n\n";
#---------------------------------------------------------------------------------------------------------------------------
#The main event
#---------------------------------------------------------------------------------------------------------------------------
$firstflag = 0;
while (<IN>) {
    chomp;
    @fields = split(/\t/);
    if ($firstflag == 0) {
	@columns = @fields;
	$firstflag = 1;
	next;
    }
    @counts = ();
    $label = $fields[1];
    push(@counts, "placeholder");
    push(@counts, "placeholder");
    for $i (2..$#fields) { #skip the cluster number (0)
	if ($fields[$i] =~ /^\d+$/) {
	    push(@counts, $fields[$i]);
	}
    }
    for $i (2..$#counts) {
	if ($counts[$i] > 0) {
	    print "$label $columns[$i] $counts[$i]\n";
	    print OUT "$label $columns[$i] $counts[$i]\n";
	}
    }
    
}
close(IN);
close(OUT);
#-----------------------------------------------------------------------
sub usage {
    print "\nUsage: ./split_clusters.pl\n\n";
    print "Parameters:\n";
    print "-i input file\t\tA ClusterCounts.txt file output by summarize_clusters.pl.\n";
    print "-o output file\t\tThe name of the unifrac text file to create (optional, Default = Unifrac.txt)\n";
    print "This script takes a cluster counts file output by summarize_clusters.pl. It creates a text file in the format unifrac expects.\n\n";
    print "Jennifer Meneghin\n";
    print "June 21, 2010\n\n";
    exit;
}
#-----------------------------------------------------------------------
