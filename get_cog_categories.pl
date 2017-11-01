#!/usr/bin/perl -w
#################################
###   Jennifer Meneghin       ###
###   March 31, 2009          ###
###   Updated August 3, 2010  ###
#################################
#---------------------------------------------------------------------------------------------------------------------------
#Deal with passed parameters
#---------------------------------------------------------------------------------------------------------------------------
#If no arguments are passed, show usage message and exit program.
if ($#ARGV == -1) {
    &usage;
    exit;
}
$in_file = "";
$cog_file = "";
$out_file = "cog_cats.txt";
$cog_column = 1;
%my_args = @ARGV;
for $i (sort keys %my_args) {
    if ($i eq "-i") {
	$in_file = $my_args{$i};
    }
    elsif ($i eq "-c") {
	$cog_file = $my_args{$i};
    }
    elsif ($i eq "-o") {
	$out_file = $my_args{$i};
    }
    elsif ($i eq "-n") {
	if ($my_args{$i} =~ /\d+/) {
	    $cog_column = $my_args{$i};
	}
	else {
	    print "\nThe -n parameter must be the column number of the COG numbers in your input file. You entered: $my_args{$i}\n\n";
	    &usage;
	}
    }
    else {
	print "\nUnrecognized argument: $i\n\n";
	&usage;
    }
}
unless ( open(IN, "$in_file") ) {
    print "\nCouldn't open input file: $in_file\n\n";
    &usage;
}
unless ( open(COG, "$cog_file") ) {
    print "\nCouldn't open COG matchup file: $cog_file\n\n";
    &usage;
}
if (-e $out_file) {
    print "\nCouldn't create output file because it already exists: $out_file\n\n";
    &usage;
}
unless ( open(OUT, ">$out_file") ) {
    print "\nCouldn't creat output file: $out_file\n\n";
    &usage;
}
print "Parameters:\ntab delimited file = $in_file\nCOG matchup file = $cog_file\noutput file = $out_file\nCOG # Column = $cog_column\n\n";
#---------------------------------------------------------------------------------------------------------------------------
#The main event
#---------------------------------------------------------------------------------------------------------------------------
%cog_set = ();
while (<COG>) {
    $line = $_;
    chomp($line);
    @fields = split(/\t/, $line);
    $id = $fields[0];
#    print "ID = $id\n";
    $cog_set{$id} = $line;   
}
close(COG);
while(<IN>) {  
    $line = $_;
    chomp($line);
    @fields = split(/\t/, $line);
    if ($cog_column - 1 <= $#fields) {
	$id2 = $fields[($cog_column-1)];
	print "ID2 = $id2\n";
	if (length($id2) > 0 && $cog_set{$id2}) {
	    print "$line\t$cog_set{$id2}\n";
	    print OUT "$line\t$cog_set{$id2}\n";
	}
	else {
	    #print "$line\n";
	    print OUT "$line\n";
	}
    }
    else {
	#print "$line\n";
	print OUT "$line\n";
    }
}
close(IN);
close(OUT);
#--------------------------------------------------
sub usage {
    print "\nUsage get_cog_categories.pl -i tab_delim_input_file -c cog_categories.txt -o output_file -n cog_number_column_number\n\n";
    print "-i input_file\t\tA tab delimited file with COG numbers\n";
    print "-c cog_categories.txt\tThe file output from update_cog_categories.pl\n";
    print "-o output_file\t\tThe output file. Optional. Default = cog_cats.txt\n";
    print "-n integer\t\tThe column number of the COG numbers in the input file\n\n";
    print "This script adds COG Categories to a tabbed delimited file that contains COG #s\n\n";
    print "Jennifer Meneghin\n";
    print "March 31, 2009\n";
    print "Updated August 12, 2010\n\n";
    exit;
}
