#!/usr/bin/perl -w
##################################
###   Jennifer Meneghin        ###
###   July 29, 2010            ###
##    Updated August 12, 2010  ###
##################################
#---------------------------------------------------------------------------------------------------------------------------
#Deal with passed parameters
#---------------------------------------------------------------------------------------------------------------------------
if ($#ARGV == -1) {
    &usage;
}
$whog_file = "whog";
$fun_file = "fun.txt";
$cog_file = "cog_categories.txt";
%my_args = @ARGV;
for $i (sort keys %my_args) {
    if ($i eq "-w") {
	$whog_file = $my_args{$i};
    }
    elsif ($i eq "-f") {
	$fun_file = $my_args{$i};
    }
    elsif ($i eq "-o") {
	$cog_file = $my_args{$i};
    }
    else {
	print "\nUnrecognized argument: $i\n";
	&usage;
    }
}
unless ( open(WHOG, "$whog_file") ) {
    print "\nCouldn't open $whog_file\n";
    &usage;
}
unless ( open(FUN, "$fun_file") ) {
    print "\nCouldn't open $fun_file\n";
    &usage;
}
if (-e $cog_file) {
    print "\nCouldn't create new $cog_file, because it already exists.\n";
    &usage;
}
unless ( open(COG, ">$cog_file") ) {
    print "\nCouldn't create new $cog_file\n";
    &usage;
}
#---------------------------------------------------------------------------------------------------------------------------
#The main event
#---------------------------------------------------------------------------------------------------------------------------
%numbers_to_letters = ();
while (<WHOG>) {
    if (/^\[/) {
	chomp($_);
	$letter = $_;
	$letter =~ s/^\[(.+?)\].+$/$1/g;
	$number = $_;
	$number =~ s/^\[.+?\] (.+?) .+$/$1/g;
	$numbers_to_letters{$number} = $letter;
	print "1. $number $letter\n";
    }
}
close(WHOG);
%letters_to_categories = ();
while (<FUN>) {
    if (/^ \[/) {
	chomp($_);
	$letter = $_;
	$letter =~ s/^ \[(.+?)\] .+$/$1/g;
	$category = $_;
	$category =~ s/^ \[.+?\] (.+)$/$1/g;
	$letters_to_categories{$letter} = $category;
	print "2. $letter $category\n";
    }
}
close(FUN);
for $i (sort keys %numbers_to_letters) {
    @letters = split(//, $numbers_to_letters{$i});
    for $j (0..$#letters) {
	if ($letters_to_categories{$letters[$j]}) {
	    print "$i\t$letters[$j]\t$letters_to_categories{$letters[$j]}\n";
	    print COG "$i\t$letters[$j]\t$letters_to_categories{$letters[$j]}\n";
	}
	else {
	    print "$i\t$letters[$j]\n";
	    print COG "$i\t$letters[$j]\n";
	}
    }
}
close(COG);

sub usage {
    print "\nUsage update_cog_categories.pl -w whog -f fun.txt -o out_file\n\n";
    print "-w whog\t\tThe whog file, a list that relates COG numbers to COG letters, downloaded from NCBI's ftp site\n";
    print "-f fun.txt\tThe fun.txt file, a list of COG letters and categories, downloaded from NCBI's ftp site\n";
    print "-o output_file\tThe output file. Optional. Default = cog_categories.txt\n\n";
    print "This script takes the whog file and fun.txt file from NCBI and returns a tabbed delimited file of COG numbers (column 1), COG letters (column 2), and COG categories (column 3).\n\n";
    print "Jennifer Meneghin\n";
    print "August 12, 2010\n\n";
    exit;
}
