#!/usr/bin/perl -w
###################################
###   Jennifer Meneghin         ###
###   December 13, 2010         ###
###   Update January 18, 2011   ###
###################################
#------------------------------------------------------------------------------------------------------------------
#Deal with passed parameters
#------------------------------------------------------------------------------------------------------------------
if ($#ARGV == -1) {
    &usage;
}
$list_file = "";
$search_file = "";
$column = 1;
$out_file = "extracted.txt";
$flag = 0;
%my_args = @ARGV;
for $i (sort keys %my_args) {
    if ($i eq "-s") {
	$list_file = $my_args{$i};
    }
    elsif ($i eq "-i") {
	$search_file = $my_args{$i};
    }
    elsif ($i eq "-o") {
	$out_file = $my_args{$i};
    }
    elsif ($i eq "-c") {
	$column = $my_args{$i};
	unless ($column =~ /^\d+$/) {
	    print "\nGot a bad column number (must be an integer > 0): $column.\n";
	    &usage;
	}
	unless ($column >= 1){
	    print "\nGot a bad column number (must be an integer > 0): $column.\n";
	    &usage;
	}
    }
    elsif ($i eq "-f") {
	$flag = $my_args{$i};
	unless ($flag == 1 || $flag == 0) {
	    print "\nGot a bad Flag. Must be 0 or 1. Found $flag\n";
	    &usage;
	}
    }
    else {
	print "\nUnrecognized argument: $i\n\n";
	&usage;
    }
}
unless ( open(LIST, "$list_file") ) {
    print "\nGot a bad input (list) file: $list_file\n\n";
    &usage;
}
unless ( open(SEARCH, "$search_file") ) {
    print "\nGot a bad input (search) file: $search_file\n\n";
    &usage;
}
if (-e $out_file) {
    print "\nFile $out_file already exists, so I can't create it. (Please move or re-name or choose a new output file name)\n\n";
    &usage;
}
unless ( open(OUT, ">$out_file") ) {
    print "\nGot a bad output file: $out_file\n\n";
    &usage;
}
print "Parameters:\nlist file = $list_file\nsearch file = $search_file\noutput file = $out_file";
print "\n\n";
#-----------------------------------------------------------------------------------------------------------------
#The main event
#-----------------------------------------------------------------------------------------------------------------
%searchfields = ();
while (<LIST>) {
    chomp;
    s/\r//g;
    if ( /\t/ ) {
	@fields = split(/\t/);
	for $i (0..$#fields) {
	    $fields[$i] =~ s/\|/\\\|/g;
	    $searchfields{$fields[$i]} = $fields[$i];
	    print "search for: $fields[$i]\n";
	}
    }
    else {
	$_ =~ s/\|/\\\|/g;
	$searchfields{$_} = $_;
	print "search for: $_\n";
    }
}
close(LIST);
while (<SEARCH>) {
    chomp;
    @fields = split(/\t/);
    if ($column - 1 <= $#fields) {
	$this_field = $fields[$column - 1];
	for $i (sort keys %searchfields) {
	    if ($this_field =~ /$i/) {
		if ($flag == 1) {
		    $i =~ s/\\\|/\|/g;
		    print OUT "$_\t$i\n";
		}
		else {
		    print OUT "$_\n";
		}
	    }
	}
    }
}
close(SEARCH);
close(OUT);
sub usage {
    print "Usage: get_selected_lines.pl -s list_file -i search_file -c column -o out_file -f 1\n\n";
    print "Parameters:\n";
    print "-s list_file\tA tabbed delimited file that contains ONLY the text to be searched for in the search file.\n";
    print "\t\t(This can be one search item per line with no tabs, or there can be multiple search items per line,\n";
    print "\t\teach separarted by a tab.)\n\n";
    print "-i search_file\tA tab delimited file with the desired text (from the list_file) in a column.\n\n";
    print "-c column\tThe column with the desired text. Optional. If not provided, the first column will be searched.\n\n";
    print "-o out_file\tThe new file to create. Optional. If not provided, a file called extracted.txt will be created.\n\n";
    print "-f 1\t\tFlag. 1 = add the search term found in the list file to a separate tab at the end of the line.\n";
    print "\t\t0 = do not do this. Optional. Default is Flag = 0.\n\n";
    print "Jennifer Meneghin\n";
    print "December 13, 2010\n";
    print "Updated January 18, 2011 (added Flag and improved efficiency.)\n\n";
    exit;
}
