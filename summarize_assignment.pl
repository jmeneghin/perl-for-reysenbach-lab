#!/usr/bin/perl -w
#############################
###   Jennifer Meneghin   ###
###   March 30, 2010      ###
#############################
#---------------------------------------------------------------------------------------------------------------------------
#Deal with passed parameters
#---------------------------------------------------------------------------------------------------------------------------

$BOOT_STRAP = 50;

if ($#ARGV == -1) {
    &usage;
}
$in_file = "";
$out_file = "SummarizedAssignments.txt";
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
print "Parameters:\nCluster assigment file (created by cluster_assigment.pl) = $in_file\noutput file = $out_file\n";
#---------------------------------------------------------------------------------------------------------------------------
#The main event
#---------------------------------------------------------------------------------------------------------------------------
$curr_cluster = -1;
$curr_taxo = "";
while(<IN>) {
    chomp;
    @fields = split(/\t/);
    $cluster = $fields[0];
    @taxos = split(/;/, $fields[3]);
    $taxo = "";
    if ($cluster != $curr_cluster) {
	if ($curr_taxo eq "") {
	    $curr_taxo = "Unknown";
	}
	unless ( $curr_cluster == -1 ) {
	    print OUT "$curr_cluster\t$curr_taxo\n";
	}
	$curr_cluster = $cluster;
	$curr_taxo = "";
	$i = 0;
	while ($i < $#taxos) {
	    $taxos[$i+1] =~ s/%//g;
	    if ($taxos[$i+1] >= $BOOT_STRAP) {
		$curr_taxo = $curr_taxo . ";" . $taxos[$i];
	    }
	    $i = $i + 2;
	}
    }
    $i = 0;
    while ($i < $#taxos) {
	$taxos[$i+1] =~ s/%//g;
	if ($taxos[$i+1] >= $BOOT_STRAP) {
	    $taxo = $taxo . ";" . $taxos[$i];
	}
	$i = $i + 2;
    }
    $taxo =~ s/^;//g;
    $curr_taxo =~ s/^;//g;
    @taxos = split(/;/, $taxo);
    @curr_taxos = split(/;/, $curr_taxo);
    $shortest = 0;
    if ($#taxos < $#curr_taxos) {
	$shortest = $#taxos;
    }
    else {
	$shortest = $#curr_taxos;
    }
    $curr_taxo = "";
    for $i (0..$shortest) {
	if ($curr_taxos[$i] eq $taxos[$i]) {
	    $curr_taxo = $curr_taxo . ";" . $curr_taxos[$i];
	}
    }
}
if ($curr_taxo eq "") {
    $curr_taxo = "Unknown";
}
print OUT "$curr_cluster\t$curr_taxo\n";
close(IN);
close(OUT);
#-----------------------------------------------------------------------
sub usage {
    print "\nUsage: ./summarize_assigment.pl\n\n";
    print "Parameters:\n";
    print "-i input file\tA cluster assigment file (created by cluster_assigment.pl)\n";
    print "-o output file\tThe name of the new cluster assignment text file to create (optional, Default = SummarizedAssignments.txt)\n\n";
    print "This script takes a cluster assignment file created by cluster_assignment.pl. It returns a tab delimmited text file where each row contains a cluster number and the agreed on taxonomy for the cluster (i.e. the taxonomy to the point of disagreement, if any). In addition, any assigments with scores < 50% are stripped out.\n\n";
    print "Jennifer Meneghin\n";
    print "March 30, 2010\n\n";
    exit;
}
#-----------------------------------------------------------------------
