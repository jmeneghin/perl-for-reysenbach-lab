#!/usr/bin/perl -w
#############################
###   Jennifer Meneghin   ###
###   June 1, 2010        ###
#############################
#---------------------------------------------------------------------------------------------------------------------------
#Deal with passed parameters
#---------------------------------------------------------------------------------------------------------------------------
if ($#ARGV == -1) {
    &usage;
}
$in_file = "";
$out_file = "updated.fasta";
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
print "Parameters:\ninput file = $in_file\noutput file = $out_file\n\n";
#---------------------------------------------------------------------------------------------------------------------------
#The main event
#---------------------------------------------------------------------------------------------------------------------------
while (<IN>) {
    chomp;
    if (/>/) {
	$header = $_;
	$header =~ s/^(>.+?)\s.+$/$1/g;
	print OUT "$header\n";
    }
    else {
	print OUT "$_\n";
    }
}
close(IN);
close(OUT);
#-----------------------------------------------------------------------
sub usage {
    print "\nUSAGE: ./subtract_from_headers.pl\n\n";
    print "Parameters:\n";
    print "-i <input file>\t\tA fasta file\n";
    print "-o <output file>\tThe new fasta file to create (optional. If not provided, a file called updated.fasta will be created.)\n\n";
    print "This scripts deletes everything after the first space in the header of each fasta record.\n\n";
    print "Jennifer Meneghin\n";
    print "June 1, 2010\n\n";
    exit;
}
