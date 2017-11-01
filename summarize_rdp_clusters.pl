#!/usr/bin/perl -w
###############################
###   Jennifer Meneghin     ###
###   March 3, 2010         ###
###   Updated June 21, 2010 ###
###############################
#---------------------------------------------------------------------------------------------------------------------------
#Deal with passed parameters
#---------------------------------------------------------------------------------------------------------------------------
if ($#ARGV == -1) {
    &usage;
}
$in_file = "";
$in2_file = "";
$out_file = "ClusterCounts.txt";
$distance_cutoff = -1;
%my_args = @ARGV;
for $i (sort keys %my_args) {
    if ($i eq "-i") {
	$in_file = $my_args{$i};
    }
    elsif ($i eq "-a") {
	$in2_file = $my_args{$i};
    }
    elsif ($i eq "-o") {
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
unless ( open(CLUST, "$in_file") ) {
    print "\nGot a bad RDP cluster file: $in_file\n\n";
    &usage;
}
unless ( open(CLASS, "$in2_file") ) {
    print "\nGot a bad RDP classification assignment detail file: $in2_file\n\n";
    &usage;
}
unless ( open(OUT, ">$out_file") ) {
    print "\nGot a bad output file: $out_file\n\n";
    &usage;
}
print "Parameters:\ncluster file = $in_file\nclassification file = $in2_file\noutput file = $out_file\ndistance cut off = $distance_cutoff\n\n";
#---------------------------------------------------------------------------------------------------------------------------
#The main event
#---------------------------------------------------------------------------------------------------------------------------
$go_flag = 0;
%labels = ();
%clusts = ();
%counts = ();
%fastaids = ();
%classifications = ();
%rep_records = ();
while (<CLUST>) {
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
	    for $i (0..$#ids) {
		$fastaids{$ids[$i]} = $clust;
	    }
	}
    }
}
close(CLUST);
while (<CLASS>) {
    chomp;
    if (/; Root; 100%; /) {
	@fields = split(/; Root; 100%; /);
	$record = $fields[0];
	$taxo = $fields[1];
	$record =~ s/^(.+?);.+$/$1/g;
	$clust = $fastaids{$record};
	$classifications{$clust} = $taxo;
	$rep_records{$clust} = $record;
    } 
}
print OUT "Cluster ID\tFasta Record ID";
print "Cluster ID\tFasta Record ID";
for $i (sort keys %labels) {
    print OUT "\t$i";
    print "\t$i";
}
print OUT "\tRDP Classification";
print "\tRDP Classification";
print OUT "\n";
print "\n";
for $i (sort sort_by_num keys %clusts) {
    print OUT "$i\t$rep_records{$i}";
    print "$i\t$rep_records{$i}";
    for $j (sort keys %labels) {
	if ($counts{$i}{$j} > 0) {
	    print OUT "\t$counts{$i}{$j}";
	    print "\t$counts{$i}{$j}";
	}
	else {
	    print OUT "\t0";
	    print "\t0";
	}
    }
    print OUT "\t$classifications{$i}\n";
    print "$i\t$classifications{$i}\n";
}
close(CLASS);
close(OUT);
#-----------------------------------------------------------------------
sub sort_by_num {
    $a <=> $b;
}
#-----------------------------------------------------------------------
sub usage {
    print "\nUsage: ./summarize_rdp_clusters.pl\n\n";
    print "Parameters:\n";
    print "-i input file\t\tA Cluster file in the form output by RDP.\n";
    print "-a input file\t\tA Classifier Assignment Detail file output by RDP.\n";
    print "-o output file\t\tThe name of the summary text file to create (optional, Default = ClusterCounts.txt)\n";
    print "-d the distance cutoff\tThe distance cutoff to split. For example, 0.05. Must be in this form, with leading zero and no quotes.\n\n";
    print "This script takes a cluster and a classifier assignment detail file output by RDP. It creates a text file with the cluster counts for each fasta file referenced, along with the classification (Fasta files are columns, clusters (and classifications) are rows, counts are cells).\n\n";
    print "Jennifer Meneghin\n";
    print "March 3, 2010\n";
    print "Updated June 21, 2010\n\n";
    exit;
}
#-----------------------------------------------------------------------
