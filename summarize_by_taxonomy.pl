#!/usr/bin/perl -w
#############################
###   Jennifer Meneghin   ###
###   March 31, 2010      ###
#############################
#---------------------------------------------------------------------------------------------------------------------------
#Deal with passed parameters
#---------------------------------------------------------------------------------------------------------------------------
if ($#ARGV == -1) {
    &usage;
}
$in_file = "";
$in2_file = "";
$out_file = "SummarizedAssignmentsByTaxonomy.txt";
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
    else {
	print "\nUnrecognized argument: $i\n\n";
	&usage;
    }
}
unless ( open(CCF, "$in_file") ) {
    print "\nGot a bad input file: $in_file\n\n";
    &usage;
}
unless ( open(SAF, "$in2_file") ) {
    print "\nGot a bad input file: $in2_file\n\n";
    &usage;
}
unless ( open(OUT, ">$out_file") ) {
    print "\nGot a bad output file: $out_file\n\n";
    &usage;
}
print "Parameters:\nCluster Counts File = $in_file\nSummarized Assigments File = $in2_file\noutput file = $out_file\n";
#---------------------------------------------------------------------------------------------------------------------------
#The main event
#---------------------------------------------------------------------------------------------------------------------------
%cc_hash = ();
%sa_hash = ();
%taxo_hash = ();
%ccount_hash = ();
while (<CCF>) {
    chomp;
    @fields = split(/\t/);
    $cluster = $fields[0];
    if ($cluster eq "") {
	@titles = @fields;
    }
    elsif ($cluster >= 0) {
	$cc_hash{$cluster} = $_;
    }
}
while (<SAF>) {
    chomp;
    @fields = split(/\t/);
    $cluster = $fields[0];
    $taxo = $fields[1];
    $taxo =~ s/"//g;
    if ($cluster >= 0) {
	$sa_hash{$cluster} = $taxo;
    }
}
for $i (sort sort_by_num keys %cc_hash) {
    $cluster = $i;
    $taxo_key = $sa_hash{$i};
    $count_line = $cc_hash{$i};
    @count_fields = split(/\t/, $count_line);
    if ($taxo_hash{$taxo_key}) {
	$this_value = $taxo_hash{$taxo_key};
	@value_fields = split(/\t/, $this_value);
	$taxo_value = $value_fields[0] . "|" . $count_fields[0];
	for $j (1..$#count_fields) {
	    if ($count_fields[$j] =~ /^\d+$/) {
		$taxo_value = $taxo_value . "\t" . ($value_fields[$j] + $count_fields[$j]);
	    }
	}
	$taxo_hash{$taxo_key} = $taxo_value;
        $ccount_hash{$taxo_key} = $ccount_hash{$taxo_key} + 1;
    }
    else {
	$taxo_value = $count_fields[0];
	for $j (1..$#count_fields) {
	    if ($count_fields[$j] =~ /^\d+$/) {
		$taxo_value = $taxo_value . "\t" . $count_fields[$j];
	    }
	}
	$taxo_hash{$taxo_key} = $taxo_value;
        $ccount_hash{$taxo_key} = 1;
    }
}
print "Number of Clusters";
print OUT "Number of Clusters";
for $i (0..$#titles) {
    print "\t$titles[$i]";
    print OUT "\t$titles[$i]";
}
print "\n";
print OUT "\n";
for $i (sort keys %taxo_hash) {
    print "$ccount_hash{$i}";
    print OUT "$ccount_hash{$i}";
    @value_fields = split(/\t/, $taxo_hash{$i});
    print "\t$value_fields[0]";
    print OUT "\t$value_fields[0]";
    $row_total = 0;
    for $j (1..$#value_fields) {
	print "\t$value_fields[$j]";
	print OUT "\t$value_fields[$j]";
	$row_total = $row_total + $value_fields[$j];
    }
    print "\t$row_total";
    print OUT "\t$row_total";
    $i =~ s/^;//g;
    @key_fields = split(/;/, $i);
    for $j (0..$#key_fields) {
	print "\t$key_fields[$j]";
	print OUT "\t$key_fields[$j]";
    }
    print "\n";
    print OUT "\n";
}
close(CCF);
close(SAF);
close(OUT);
#-----------------------------------------------------------------------
sub usage {
    print "\nUsage: ./summarize_by_taxonomy.pl\n\n";
    print "Parameters:\n";
    print "-i input file\tA cluster counts file (created by summarize_clusters.pl)\n";
    print "-a input file\tA summarized assigment file (created by summarize_assigment.pl)\n";
    print "-o output file\tThe name of the new summarized assignment text file to create (optional, Default = SummarizedAssignmentsByTaxonomy.txt)\n\n";
    print "This script takes a summarized assignment file created by summarize_assignment.pl and cluster counts file created by summarize_clusters.pl. It returns a tab delimmited text file where each row contains counts for each unique taxonomic classifications found, along with cluster numbers included in the classification and the number of clusters included.\n\n";
    print "Jennifer Meneghin\n";
    print "March 31, 2010\n\n";
    exit;
}
#-----------------------------------------------------------------------
sub sort_by_num {
    $a <=> $b;
}
#-----------------------------------------------------------------------
