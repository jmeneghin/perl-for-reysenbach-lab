#!/usr/bin/perl -w
#############################
###   Jennifer Meneghin   ###
###   January 28, 2010    ###
#############################
#---------------------------------------------------------------------------------------------------------------------------
#Deal with passed parameters
#---------------------------------------------------------------------------------------------------------------------------
if ($#ARGV == -1) {
    &usage;
}
$in_file = "";
$distance_cutoff = -1;
$file_name_front = "Cluster";
%my_args = @ARGV;
for $i (sort keys %my_args) {
    if ($i eq "-i") {
	$in_file = $my_args{$i};
    }
    elsif ($i eq "-a") {
	$file_name_front = $my_args{$i};
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
$file_dist = $distance_cutoff;
$file_dist =~ s/^0\.(\d\d)$/$1/g;

$sum_file = "${file_name_front}_${file_dist}.txt";
unless ( open(SUM, ">$sum_file") ) {
    print "\nGot a bad output file: $sum_file\n\n";
    &usage;
}
print "Parameters:\ninput file = $in_file\nfile name front = $file_name_front\ndistance cut off = $distance_cutoff\n\n";
#---------------------------------------------------------------------------------------------------------------------------
#The main event
#---------------------------------------------------------------------------------------------------------------------------
$go_flag = 0;
%main_counts = ();
%text_to_split_on = ();
%counts = ();
%clusts = ();
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
	$main_counts{$clust_num} = 0;
	$records_field = $fields[3];
	@records = split(/\s/, $records_field);
	for $i (0..$#records) {
	    @parts = split(/\_/, $records[$i]);
	    $text_to_split = $parts[1];
	    $text_to_split_on{$text_to_split} = $text_to_split;
	    if ($counts{$text_to_split}{$clust_num}) {
		$counts{$text_to_split}{$clust_num}++;
		$clusts{$text_to_split}{$clust_num} = $clusts{$text_to_split}{$clust_num} . " " . $records[$i];
	    }
	    else {
		$counts{$text_to_split}{$clust_num} = 1;
		    $clusts{$text_to_split}{$clust_num} = $records[$i];
	    }    
	    $main_counts{$clust_num}++;
	}
    }
}

#-------------------SUM FILE-------------------
for $i (sort keys %text_to_split_on) {
    print SUM "\t$i";
    print "\t$i";
}
print SUM "\n";
print "\n";
for $i (sort sort_by_num keys %main_counts) {
    print SUM "$i";
    print "$i";
    for $j (sort keys %text_to_split_on) {
	$text_to_split = $text_to_split_on{$j};
	if ($counts{$text_to_split}{$i}) {
	    print SUM "\t$counts{$text_to_split}{$i}";
	    print "\t$counts{$text_to_split}{$i}";
	}
	else {
	    print SUM "\t0";
	    print "\t0";
	}
    }
    print SUM "\n";
    print "\n";
}


#-------------------CLUST FILES-------------------
for $j (sort keys %text_to_split_on) {
    $text_to_split = $text_to_split_on{$j};
    $out_file = "${file_name_front}_${file_dist}_${text_to_split}.clust";
    unless ( open(OUT, ">$out_file") ) {
	print "\nGot a bad output file: $out_file\n\n";
	&usage;
    }
    for $i (sort sort_by_num keys %main_counts) {
	if ($counts{$text_to_split}{$i}) {
	    if ($counts{$text_to_split}{$i} > 0) {
		print OUT "$i\t$counts{$text_to_split}{$i}\t$clusts{$text_to_split}{$i}\n";
	    }
	}
    }
    close(OUT);
}


close(IN);
close(SUM);
#-----------------------------------------------------------------------
sub sort_by_num {
    $a <=> $b;
}

sub usage {
    print "\nUsage: ./split_clusters.pl\n\n";
    print "Parameters:\n";
    print "-i input file\t\tA Cluster file in the form output by RDP.\n";
    print "-d the distance cutoff\tThe distance cutoff to split. For example, 0.03. Must be in this form, with leading zero and no quotes.\n";
    print "-a front of file name\tOutput files will be named X_Y.txt and X_Y_Z.clust, where X = the text entered here (in quotes), Y = the distance cutoff entered, Z = each separate sample within the clust file.\n\t\t\t(Optional. \"Cluster\" is default.)\n\n";
    print "This script takes a cluster file output by RDP. It assumes the fasta records referenced in the file will have ONE underscore in the name, and that what follows the underscore designates which sample the record came from (Z above). The script creates a new cluster file for each separate sample, and one summary file with counts for all samples.\n\n";
    print "Jennifer Meneghin\n";
    print "February 8, 2010\n\n";
    exit;
}
#-----------------------------------------------------------------------
