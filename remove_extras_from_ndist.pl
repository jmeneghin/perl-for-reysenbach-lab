#!/usr/bin/perl -w
#############################
###   Jennifer Meneghin   ###
###   April 7, 2010       ###
#############################
#---------------------------------------------------------------------------------------------------------------------------
#Deal with passed parameters
#---------------------------------------------------------------------------------------------------------------------------
if ($#ARGV == -1) {
    &usage;
}
$in_file = "";
$names_file = "";
$new_ndist_file = "new_ndist.txt";
%my_args = @ARGV;
for $i (sort keys %my_args) {
    if ($i eq "-i") {
	$in_file = $my_args{$i};
    }
    elsif ($i eq "-n") {
	$names_file = $my_args{$i};
    }
    elsif ($i eq "-o") {
	$new_ndist_file = $my_args{$i};
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
unless ( open(NAMES, "$names_file") ) {
    print "\nGot a bad names file: $names_file\n\n";
    &usage;
}
unless ( open(OUT, ">$new_ndist_file") ) {
    print "\nGot a bad new names file: $new_ndist_file\n\n";
    &usage;
}
print "Parameters:\ninput file = $in_file\nnames file = $names_file\nnames file = $new_ndist_file\n\n";
#---------------------------------------------------------------------------------------------------------------------------
#The main event
#---------------------------------------------------------------------------------------------------------------------------
%names = ();
while (<NAMES>) {
    @fields = split(/\t/);
    $names{$fields[0]} = $fields[0];
}
while (<IN>) {
    $_ =~ s/\r//g;
    @fields = split(/\t/);
    $fields[0] =~ s/\r//g;
    $fields[1] =~ s/\r//g;
    if ($names{$fields[0]} && $names{$fields[1]}) {
	#print $_;
	print OUT $_;
    }
}
close(IN);
close(OUT);
close(NAMES);
#-----------------------------------------------------------------------
sub usage {
    print "\nUSAGE: ./remove_extras_from_ndist.pl\n\n";
    print "Parameters:\n";
    print "-i <input file>\t\tThe ndist file output from esprit, with indices replaced by names (using match_names_to_ndist.pl)\n";
    print "-n <input file>\t\tThe names file output from slp.pl\n";
    print "-o <output file>\tThe new ndist file to create. Optional. If not provided, a file called new_ndist.txt will be created.\n\n";
    print"This program takes the .ndist file output from esprit with indices replaced with names and the .slp.names file output from slp.pl, and creates a new .ndist file that only contains the distances between the representative sequences chosen by slp.pl.\n\n";
    print "Jennifer Meneghin\n";
    print "April 7, 2010\n\n";
    exit;
}
