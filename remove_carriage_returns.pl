#!/usr/bin/perl -w
###########################
###   Jennifer Meneghin ###
###   May 18, 2011      ###
###########################
#---------------------------------------------------------------------------------------------------------------------------
#Deal with passed parameters
#---------------------------------------------------------------------------------------------------------------------------
if ($#ARGV == -1) {
    &usage;
}
$in_file = "";
$out_file = "clean.txt";
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
print "Parameters:\ninput file = $in_file\nout file = $out_file\n\n";
#---------------------------------------------------------------------------------------------------------------------------
#The main event
#---------------------------------------------------------------------------------------------------------------------------
while (<IN>) {
    $line = $_;
    $line =~ s/\r//g;
    print OUT "$line";
}
close(IN);
close(OUT);
#-----------------------------------------------------------------------
sub usage {
    print "\nUSAGE: ./remove_carriage_returns.pl\n\n";
    print "Parameters:\n";
    print "-i <input file>\t\tA file\n";
    print "-o <output file>\tThe same file, with any annoying carriage returns removed.\n\n";
    print "This script takes a file and creates a copy of the file with the carriage returns removed. Essentially, it converts a Windows style text file to a Linux/UNIX style text file.\n\n";
    print "Jennifer Meneghin\n";
    print "May 18, 2011\n\n";
    exit;
}
