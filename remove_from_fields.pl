#!/usr/bin/perl -w
#############################
###   Jennifer Meneghin   ###
###   January 19, 2011    ###
#############################
#------------------------------------------------------------------------------------------------------------------
#Deal with passed parameters
#------------------------------------------------------------------------------------------------------------------
if ($#ARGV == -1) {
    &usage;
}
$in_file = "";
$out_file = "updated.txt";
$delete_column = 1;
$from_column = 2;
%my_args = @ARGV;
for $i (sort keys %my_args) {
    if ($i eq "-i") {
	$in_file = $my_args{$i};
    }
    elsif ($i eq "-o") {
	$out_file = $my_args{$i};
    }
    elsif ($i eq "-d") {
	$delete_column = $my_args{$i};
	unless ($delete_column =~ /^\d+$/) {
	    print "\nGot a bad column number (must be an integer > 0): $delete_column.\n";
	    &usage;
	}
	unless ($delete_column >= 1){
	    print "\nGot a bad column number (must be an integer > 0): $delete_column.\n";
	    &usage;
	}
    }
    elsif ($i eq "-s") {
	$from_column = $my_args{$i};
	unless ($from_column =~ /^\d+$/) {
	    print "\nGot a bad column number (must be an integer > 0): $from_column.\n";
	    &usage;
	}
	unless ($from_column >= 1){
	    print "\nGot a bad column number (must be an integer > 0): $from_column.\n";
	    &usage;
	}
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
if (-e $out_file) {
    print "\nFile $out_file already exists, so I can't create it.";
    print "(Please move or re-name or choose a new output file name)\n\n";
    &usage;
}
unless ( open(OUT, ">$out_file") ) {
    print "\nGot a bad output file: $out_file\n\n";
    &usage;
}
print "Parameters:\nin file = $in_file\nnoutput file = $out_file\n";
print "column with text to remove = $delete_column\ncolumn with text to be searched for removal = $from_column\n\n";
#-----------------------------------------------------------------------------------------------------------------
#The main event
#-----------------------------------------------------------------------------------------------------------------
while(<IN>) {
    chomp;
    @fields = split(/\t/);
    if ($delete_column - 1 <= $#fields) {
	$to_delete = $fields[$delete_column-1];
	$to_delete =~ s/\|/\\\|/g;
    }
    if ($from_column -1 <= $#fields) {
	$from_field = $fields[$from_column-1];
    }
    if ($from_field =~ /$to_delete, /) {      #If it's a comma separated list, assume they want the comma and space gone too
	$from_field =~ s/$to_delete, //g;
    }
    elsif ($from_field =~ /$to_delete/) {
	$from_field =~ s/$to_delete//g;
    }
    for $i (0..$#fields-1) {
	if ($i == $from_column-1) {
	    print OUT "$from_field\t";
	}
	else {
	    print OUT "$fields[$i]\t";
	}
    }
    if ($#fields == $from_column-1) {
	print OUT "$from_field\t";
    }
    else {
	print OUT "$fields[$#fields]\t";
    }
    print OUT "\n";
}
close(IN);
close(OUT);
sub usage {
    print "\nUsage: remove_from_fields.pl -i in_file -o out_file -d column_number -s column_number\n\n";
    print "Parameters:\n";
    print "-i in_file\tA tabbed delimited file that contains one field with text to delete, and another column with text to search.\n";
    print "-o out_file\tThe new file to create. Optional. If not provided, a file called updated.txt will be created.\n";
    print "-d column\tThe column with the text to be deleted. Optional. If not provided, the first column will be used.\n";
    print "-s column\tThe column with the text to be searched. Optional. If not provided, the second column will be searched.\n\n";
    print "This script reads the in_file, removes the text found in the -d column from the -s column (line by line) and writes the results to the out_file\n\n";
    print "Jennifer Meneghin\n";
    print "January 19, 2011\n\n";
    exit;
}
