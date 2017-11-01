#!/usr/bin/perl -w
#############################
###   Jennifer Meneghin   ###
###   March 3, 2010       ###
#############################
#---------------------------------------------------------------------------------------------------------------------------
#Deal with passed parameters
#---------------------------------------------------------------------------------------------------------------------------
if ($#ARGV == -1) {
    &usage;
}
$in_file = "";
$out_file = "ClusterCounts.txt";
$out2_file = "RepresentativeClusterIDs.txt";
$distance_cutoff = -1;
%my_args = @ARGV;
for $i (sort keys %my_args) {
    if ($i eq "-i") {
	$in_file = $my_args{$i};
    }
    elsif ($i eq "-o") {
	$out_file = $my_args{$i};
    }
    elsif ($i eq "-r") {
	$out_file = $my_args{$i};
    }
    elsif ($i eq "-d") {
	$distance_cutoff = $my_args{$i};
	if (!($distance_cutoff =~ /^0\.\d\d$/)) {
	    print "\n\nError: distance cutoff must be of the form 0.NN where N is a digit. You entered: $distance_cutoff.\n\n";
	    &usage;
	}
    }
    else {
	print "\nUnrecognized argument: $i\n\n";
	&usage;
    }
}
if ($distance_cutoff < 0) {
    print "\n\nError: distance cutoff required (-d) and must be of the form 0.NN where N is a digit. (Found: $distance_cutoff)\n\n";
    &usage;
}
unless ( open(IN, "$in_file") ) {
    print "\nGot a bad input file: $in_file\n\n";
    &usage;
}
unless ( open(OUT, ">$out_file") ) {
    print "\nGot a bad output file: $out_file\n\n";
    &usage;
}
unless ( open(IDS, ">$out2_file") ) {
    print "\nGot a bad output file: $out2_file\n\n";
    &usage;
}
print "Parameters:\ninput file = $in_file\noutput file = $out_file\nfasta ID output file = $out2_file\ndistance cut off = $distance_cutoff\n\n";
#---------------------------------------------------------------------------------------------------------------------------
#The main event
#---------------------------------------------------------------------------------------------------------------------------
$go_flag = 0;
%labels = ();
%clusts = ();
%counts = ();
%fastaids = ();
while (<IN>) {
    chomp;
    @fields = split(/\t/);
    if ($#fields < 1) {
	next;
    }
    $clust_num = $fields[0];
    if (!($clust_num =~ m/^\d+$/)) {
	if ($clust_num eq "distance cutoff:") {
	    $this_cutoff = $fields[1];
	    if ($this_cutoff == $distance_cutoff) {
		$go_flag = 1;
	    }
	    else {
		$go_flag = 0;
	    }
	}
	next;
    }
    if ($go_flag == 1) {
	$clust = $fields[0];
	$label = $fields[1];
	$count = $fields[2];
	$labels{$label} = $label;
	$clusts{$clust} = $clust;
	$counts{$clust}{$label} = $count;
	if ($count > 0) {
	    @ids = split(/\s/, $fields[3]);
	    $fastaids{$clust}{$label} = $ids[0];
	}
    }
}
for $i (sort keys %labels) {
    print OUT "\t$i";
    print "\t$i";
}
for $i (sort keys %labels) {
    print OUT "\t$i";
    print "\t$i";
}
print OUT "\n";
print "\n";
for $i (sort sort_by_num keys %clusts) {
    print OUT "$i";
    print "$i";
    for $j (sort keys %labels) {
	print OUT "\t$counts{$i}{$j}";
	print "\t$counts{$i}{$j}";
    }
    for $j (sort keys %labels) {
	if ($fastaids{$i}{$j}) {
	    print OUT "\t$fastaids{$i}{$j}";
	    print "\t$fastaids{$i}{$j}";
	    print IDS "$fastaids{$i}{$j}\n";
	}
	else {
	    print OUT "\t";
	    print "\t";
	}
    }
    print OUT "\n";
    print "\n";
}
close(IN);
close(OUT);
#-----------------------------------------------------------------------
sub sort_by_num {
    $a <=> $b;
}
#-----------------------------------------------------------------------
sub usage {
    print "\nUsage: ./split_clusters.pl\n\n";
    print "Parameters:\n";
    print "-i input file\t\tA Cluster file in the form output by RDP.\n";
    print "-o output file\t\tThe name of the summary text file to create (optional, Default = ClusterCounts.txt)\n";
    print "-r output file\t\tThe name of the fasta ID text file to create (optional, Default = RepresentativeClusterIDs.txt)\n";
    print "-d the distance cutoff\tThe distance cutoff to split. For example, 0.03. Must be in this form, with leading zero and no quotes.\n\n";
    print "This script takes a cluster file output by RDP. It creates a text file with the cluster counts for each fasta file referenced, and also returns one fastaID for each count > 0 (Fasta files are columns, clusters are rows, counts and fasta IDs are cells). It also returns a second text file with all of the fastaIDs in a single columns\n\n";
    print "Jennifer Meneghin\n";
    print "March 3, 2010\n\n";
    exit;
}
#-----------------------------------------------------------------------
