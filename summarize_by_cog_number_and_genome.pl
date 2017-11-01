#!/usr/bin/perl -w
#############################
###   Jennifer Meneghin   ###
###   May 4, 2009         ###
#############################
#-----------------------------------------------------------------------------------------------------------------------------------------
#Deal with passed parameters
#-----------------------------------------------------------------------------------------------------------------------------------------
$in1_file = "calcite/mRNA/ynp_calcite_dna_2007_skim_best.summary";
$in2_file = "octopus/mRNA/ynp_octopus_dna_2007_skim_best.summary";
$out_file = "DNA_2007_cog_number.summary";
unless ( open(IN1, "$in1_file") ) {
    print "Got a bad input file: $in1_file\n";
    exit;
}
unless ( open(IN2, "$in2_file") ) {
    print "Got a bad input file: $in2_file\n";
    exit;
}
unless ( open(OUT, ">$out_file") ) {
    print "Got a bad output file: $out_file\n";
    exit;
}
#-----------------------------------------------------------------------------------------------------------------------------------------
#The main event
#-----------------------------------------------------------------------------------------------------------------------------------------
%cog_nums = ();
%organisms = ();
%calcite = ();
%octopus = ();
while (<IN1>) {
    chomp;
    @fields = split(/\t/);
    $count = 0;
    if (@fields > 1) {
	$count = $fields[1];
    }
    $organism = "UNKNOWN";
    if (@fields > 4) {
	$organism = $fields[4];
    }
    $cog_num = "UNKNOWN";
    if (@fields > 5) {
	$cog_num = $fields[5];
    }
    if (!$cog_nums{$cog_num}) {
	$cog_nums{$cog_num} = $cog_num;
    }
    if (!$organisms{$organism}) {
	$organisms{$organism} = $organism;
    }
    if ($calcite{$cog_num}{$organism}) {
	$calcite{$cog_num}{$organism} = $calcite{$cog_num}{$organism} + $count;
    }
    else {
	$calcite{$cog_num}{$organism} = $count;
    }
    #print "org = $organism cog = $cog_num count = $calcite{$cog_num}{$organism}\n";
}
while (<IN2>) {
    chomp;
    @fields = split(/\t/);
    $count = 0;
    if (@fields > 1) {
	$count = $fields[1];
    }
    $organism = "UNKNOWN";
    if (@fields > 4) {
	$organism = $fields[4];
    }
    $cog_num = "UNKNOWN";
    if (@fields > 5) {
	$cog_num = $fields[5];
    }
    if (!$cog_nums{$cog_num}) {
	$cog_nums{$cog_num} = $cog_num;
    }
    if (!$organisms{$organism}) {
	$organisms{$organism} = $organism;
    }
    if ($octopus{$cog_num}{$organism}) {
	$octopus{$cog_num}{$organism} = $octopus{$cog_num}{$organism} + $count;
    }
    else {
	$octopus{$cog_num}{$organism} = $count;
    }
    #print "org = $organism cog = $cog_num count = $octopus{$cog_num}{$organism}\n";
}
print OUT "COG Number";
foreach $j (sort keys %organisms) {
    print OUT "\tCalcite $organisms{$j}";
}
foreach $j (sort keys %organisms) {
    print OUT "\tOctopus $organisms{$j}";
}
print OUT "\n";
foreach $i (sort keys %cog_nums) {
    print "$i\n";
    print OUT "$i";
    if ($calcite{$i}) {
	foreach $j (sort keys %organisms) {
	    if ($calcite{$i}{$j}) {
		print OUT "\t$calcite{$i}{$j}";
	    }
	    else {
		print OUT "\t0";
	    }
	}
    }
    else {
	print OUT "\t0\t0\t0\t0\t0\t0\t0\t0\t0\t0\t0\t0\t0\t0";
    }
    if ($octopus{$i}) {
	foreach $j (sort keys %organisms) {
	    if ($octopus{$i}{$j}) {
		print OUT "\t$octopus{$i}{$j}";
	    }
	    else {
		print OUT "\t0";
	    }
	}
    }
    else {
	print OUT "\t0\t0\t0\t0\t0\t0\t0\t0\t0\t0\t0\t0\t0\t0";
    }
    print OUT "\n";
}
close(IN1);
close(IN2);
close(OUT);
