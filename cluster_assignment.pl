#!/usr/bin/perl -w
#############################
###   Jennifer Meneghin   ###
###   March 4, 2010       ###
#############################
#---------------------------------------------------------------------------------------------------------------------------
#Deal with passed parameters
#---------------------------------------------------------------------------------------------------------------------------
if ($#ARGV == -1) {
    &usage;
}
$in_file = "";
$in2_file = "";
$out_file = "ClusterAssignments.txt";
%my_args = @ARGV;
for $i (sort keys %my_args) {
    if ($i eq "-i") {
	$in_file = $my_args{$i};
    }
    elsif ($i eq "-o") {
	$out_file = $my_args{$i};
    }
    elsif ($i eq "-a") {
	$in2_file = $my_args{$i};
    }
    else {
	print "\nUnrecognized argument: $i\n\n";
	&usage;
    }
}
unless ( open(SUM, "$in_file") ) {
    print "\nGot a bad input file: $in_file\n\n";
    &usage;
}
unless ( open(OUT, ">$out_file") ) {
    print "\nGot a bad output file: $out_file\n\n";
    &usage;
}
unless ( open(TAX, "$in2_file") ) {
    print "\nGot a bad input file: $in2_file\n\n";
    &usage;
}
print "Parameters:\nRDP cluster summary file (created by summarize_clusters.pl) = $in_file\nRDP classifier assignment detail file = $in2_file\noutput file = $out_file\n";
#---------------------------------------------------------------------------------------------------------------------------
#The main event
#---------------------------------------------------------------------------------------------------------------------------
%fasta_tax = ();
while(<TAX>) {
    chomp;
    if ( /;\s\s;\sRoot;\s100%;\s/ ) {
	@fields = split(/;\s\s;\sRoot;\s100%;\s/);
	$fasta_tax{$fields[0]} = $fields[1];
    }
}
$count = 0;
%labels = ();
while(<SUM>) {
    chomp;
    @fields = split(/\t/);
    if ($count == 0) {
	$count++;
	for $i (0..$#fields) {
	    $labels{$i} = $fields[$i];
	}
    }
    else {
	$cluster = $fields[0];
	for $i (1..$#fields) {
	    if ( length($fields[$i]) > 0 && !($fields[$i] =~ /^\d+$/) ) {
		print "$cluster\t$labels{$i}\t$fields[$i]\t$fasta_tax{$fields[$i]}\n";
		print OUT "$cluster\t$labels{$i}\t$fields[$i]\t$fasta_tax{$fields[$i]}\n";
	    }
	}
    }
}
close(SUM);
close(TAX);
close(OUT);
#-----------------------------------------------------------------------
sub usage {
    print "\nUsage: ./cluster_assigment.pl\n\n";
    print "Parameters:\n";
    print "-i input file\tAn RDP cluster summary file created by summarize_clusters.pl\n";
    print "-a input file\tAn RDP classifier assignment detail file\n";
    print "-o output file\tThe name of the cluster assignment text file to create (optional, Default = ClusterAssignments.txt)\n\n";
    print "This script takes a cluster summary file created by summarize_clusters.pl and an RDP classifier assignment detail file. It returns a tab delimmited text file where each row contains a cluster number, a sample label, a representative fasta ID from this cluster and sample, and finally, the RDP assigment of the fasta record with this ID.\n\n";
    print "Jennifer Meneghin\n";
    print "March 4, 2010\n\n";
    exit;
}
#-----------------------------------------------------------------------
