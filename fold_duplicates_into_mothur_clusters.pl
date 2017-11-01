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
$names_file = "";
$out_file = "MothurClustersCombined.txt";
%my_args = @ARGV;
for $i (sort keys %my_args) {
    if ($i eq "-i") {
	$in_file = $my_args{$i};
    }
    elsif ($i eq "-n") {
	$names_file = $my_args{$i};
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
unless ( open(NAMES, "$names_file") ) {
    print "\nGot a bad input file (...names.txt from get_uniqes_and_names_file.pl): $in_file\n\n";
    &usage;
}
unless ( open(OUT, ">$out_file") ) {
    print "\nGot a bad output file: $out_file\n\n";
    &usage;
}
print "Parameters:\ninput file = $in_file\noriginal names file = $names_file\noutput file = $out_file\n\n";
#---------------------------------------------------------------------------------------------------------------------------
#The main event
#---------------------------------------------------------------------------------------------------------------------------
%preclusts = ();
while (<NAMES>) {
    chomp;
    @fields = split(/\t/);
    $fields[1] =~ s/\,\s/\,/g;
    $preclusts{$fields[0]} = $fields[1];
#    print "dups: key = |$fields[0]| value = $fields[1]\n";
}
while (<IN>) {
    chomp;
    @fields = split(/\t/);
    print "$fields[0]\t$fields[1]";
    print OUT "$fields[0]\t$fields[1]";
    for $i (2..$#fields) {
	chomp($fields[$i]);
	$fields[$i] =~ s/\r//g;
	if ($fields[$i] =~ m/\,/) {
#	    print "\t";
	    print OUT "\t";
	    @recs = split(/\,/, $fields[$i]);
	    if ($preclusts{$recs[0]}) {
#		print "$preclusts{$recs[0]}";
		print OUT "$preclusts{$recs[0]}";
	    }
	    else {
#		print "$recs[0]";
		print OUT "$recs[0]";
	    }
	    for $j (1..$#recs) {
		if ($preclusts{$recs[$j]}) {
#		    print ",$preclusts{$recs[$j]}";
		    print OUT ",$preclusts{$recs[$j]}";
		}
		else {
#		    print ",$recs[$j]";
		    print OUT ",$recs[$j]";
		}
	    }
	}
	else {
	    if ($preclusts{$fields[$i]}) {
#		print "\t$preclusts{$fields[$i]}";
		print OUT "\t$preclusts{$fields[$i]}";
	    }
	    else {
#		print "\t$fields[$i]";
		print OUT "\t$fields[$i]";
	    }
	}
    }
    print "\n";
    print OUT "\n";
}
sub usage {
    print "\nUsage: ./fold_duplicates_into_mothur_clusters.pl\n\n";
    print "Parameters:\n";
    print "-i input file\t\t.list file from mothur clustering output\n";
    print "-n input file\t\tnames.txt file output from get_uniques_and_names_file.pl\n";
    print "-o <output file>\tThe new combined .list file to create. (Optional. Default = MothurClustersCombined.txt)\n\n";
    print "This script takes a .list file output from mothur's clustering program and the names.txt file output from get_uniques_and_names_file.pl and creates a new .list cluster file with all of the original duplicates included (i.e. it combines the two files back into one).\n\n";
    print "Jennifer Meneghin\n";
    print "June 24, 2010\n\n";
    exit;
}
#-----------------------------------------------------------------------
