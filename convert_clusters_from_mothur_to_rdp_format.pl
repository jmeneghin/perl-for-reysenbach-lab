#!/usr/bin/perl -w
#############################
###   Jennifer Meneghin   ###
###   June 24, 2010       ###
#############################
#---------------------------------------------------------------------------------------------------------------------------
#Deal with passed parameters
#---------------------------------------------------------------------------------------------------------------------------
if ($#ARGV == -1) {
    &usage;
}
$in_file = "";
$delimiter = "_";
$out_file = "HuseClustersConvertedToRDPFormat.clust";
%my_args = @ARGV;
for $i (sort keys %my_args) {
    if ($i eq "-i") {
	$in_file = $my_args{$i};
    }
    elsif ($i eq "-s") {
	$delimiter = $my_args{$i};
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
    print "\nGot a bad input file (.list from mothur output): $in_file\n\n";
    &usage;
}
unless ( open(OUT, ">$out_file") ) {
    print "\nGot a bad output file: $out_file\n\n";
    &usage;
}
print "Parameters:\ninput file = $in_file\nsample delimiter = $delimiter\noutput file = $out_file\n\n";
#---------------------------------------------------------------------------------------------------------------------------
#The main event
#---------------------------------------------------------------------------------------------------------------------------
%files = ();
$first_flag = 0;
while (<IN>) {
    chomp;
    @fields = split(/\t/);
    %rec_labels = ();
    %rec_counts = ();
    for $i (2..$#fields) {
	@recs = split(/,/, $fields[$i]);
	for $j (0..$#recs) {
	    $sample = $recs[$j];
	    @sample_parts = split(/$delimiter/, $sample);
	    $sample = $sample_parts[1];
	    if ($first_flag == 0) {
		if ($files{$sample}) {
		    $files{$sample} = $files{$sample} + 1;
		}
		else {
		    $files{$sample} = 1;
		}
	    }
	    $my_key = $i . "_" . $sample;
	    if ($rec_labels{$my_key}) {
		$rec_labels{$my_key} = $rec_labels{$my_key} . ' ' . $recs[$j];
		$rec_counts{$my_key} = $rec_counts{$my_key} + 1;;		
	    }
	    else {
		$rec_labels{$my_key} = $recs[$j];
		$rec_counts{$my_key} = 1;
	    }
	}
    }
    if ($first_flag == 0) {
	print OUT "File(s):\t";
	for $i (sort keys %files) {
	    print OUT "$i ";
	}
	print OUT "\nSequences:\t";
	for $i (sort keys %files) {
	    print OUT "$files{$i} ";
	}
	print OUT "\n";
    }
    $first_flag = 1;
    if ($fields[0] eq "unique") {
	$fields[0] = "0.0";
    }
    print OUT "\ndistance cutoff:\t$fields[0]\n";
    print OUT "Total Clusters: $fields[1]\n";

    $count = -1;
    $old_id = -1;
    for $j (sort keys %rec_labels) {
	@key_parts = split(/_/, $j);
	if ($key_parts[0] != $old_id) {
	    if ($count > -1) {
		for $k (sort keys %temp_files) {
		    print OUT "$count\t$k\t0\t\n";
		}
	    }
	    $old_id = $key_parts[0];
	    $count++;
	    %temp_files = %files;
	}
	print OUT "$count\t$key_parts[1]\t$rec_counts{$j}\t$rec_labels{$j} \n";
	delete($temp_files{$key_parts[1]});
    }
    for $k (sort keys %temp_files) {
	print OUT "$count\t$k\t0\t\n";
    }
}
sub usage {
    print "\nUsage: ./convert_clusters_from_mothur_to_rdp_format.pl\n\n";
    print "Parameters:\n";
    print "-i input file\t\t.list file from mothur clustering output\n";
    print "-s sample delimiter\tEach record in the mothur file must be in the format: a fasta record name, a delimiter,\n\t\t\tthen the name of the sample this record came from. (Optional. Default is an underscore.)\n";
    print "-o <output file>\tThe new RDP style cluster file to create. (Optional. Default = MothurClustersConvertedToRDPFormat.txt)\n\n";
    print "This script takes a .list style file output from mothur's clustering program and creates a new cluster file in the style output by RDP's clustering program.\n\n";
    print "Jennifer Meneghin\n";
    print "June 24, 2010\n\n";
    exit;
}
#-----------------------------------------------------------------------
