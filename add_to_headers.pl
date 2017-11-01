#!/usr/bin/perl -w
##############################
###   Jennifer Meneghin    ###
###   January 28, 2010     ###
###                        ###
###   Jennifer Meneghin    ###
###   Updated July 2, 2012 ###
##############################
#---------------------------------------------------------------------------------------------------------------------------
#Deal with passed parameters
#---------------------------------------------------------------------------------------------------------------------------
if ($#ARGV == -1) {
    &usage;
}
$in_file = "";
$out_file = "updated.fasta";
$text_to_add = "";
%my_args = @ARGV;
for $i (sort keys %my_args) {
    if ($i eq "-i") {
	$in_file = $my_args{$i};
    }
    elsif ($i eq "-o") {
	$out_file = $my_args{$i};
    }
    elsif ($i eq "-a") {
	$text_to_add = $my_args{$i};
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
unless ( length($text_to_add) > 0 ) {
    print "\nPlease enter the text to add onto each record.\n\n";
    &usage;
}
print "Parameters:\ninput file = $in_file\noutput file = $out_file\n\n";
#---------------------------------------------------------------------------------------------------------------------------
#The main event
#---------------------------------------------------------------------------------------------------------------------------

if ($text_to_add =~ /COUNT/) {
    @text = split("COUNT", $text_to_add);
    $text1 = $text[0];
    $text2 = $text[1];
    $count = 0;
}
while (<IN>) {
    chomp;
    if (/>/) {
	print OUT "$_";
	if ($text_to_add =~ /COUNT/) {
	    $count++;
	    print OUT "$text1";
	    print OUT "$count";
	    if ($text2 && length($text2) > 0) {
		print OUT "$text2\n";
	    }
	    else {
		print OUT "\n";
	    }
	}
	else {
	    print OUT "$text_to_add\n";
	}
    }
    else {
	print OUT "$_\n";
    }
}
close(IN);
close(OUT);
#-----------------------------------------------------------------------
sub usage {
    print "\nUSAGE: ./add_to_headers.pl\n\n";
    print "Parameters:\n";
    print "-i <input file>\t\tA fasta file\n";
    print "-o <output file>\tThe new fasta file to create. Optional. If not provided, a file called updated.fasta will be created.\n";
    print "-a <some text>\t\tThe text to add on to the end of each header in the file.\n\n";
    print "This scripts adds a bit of text (-a) onto the end of each header in the file provided (-i).\n\n";
    print "Jennifer Meneghin\n";
    print "January 28, 2010\n\n";
    print "NEW: if you use the word COUNT (in all caps) in your text to add, this will be replaced by the record count.\n\n";
    print "Jennifer Meneghin\n";
    print "July 2, 2012\n\n";
    exit;
}
