#!/usr/bin/perl -w
#############################
###   Jennifer Meneghin   ###
###   June 25, 2012       ###
#############################
#---------------------------------------------------------------------------------------------------------------------------
#Deal with passed parameters
#---------------------------------------------------------------------------------------------------------------------------
if ($#ARGV == -1) {
    &usage;
}
$in_file = "";
$out_file = "SortedSequences.fa";
$split_text = "";
%my_args = @ARGV;
for $i (sort keys %my_args) {
    if ($i eq "-i") {
	$in_file = $my_args{$i};
    }
    elsif ($i eq "-o") {
	$out_file = $my_args{$i};
    }
    elsif ($i eq "-s") {
	$split_text = $my_args{$i};
    }
    else {
	print "\nUnrecognized argument: $i\n\n";
	&usage;
    }
}
unless ( open(IN, "$in_file") ) {
    print "\nGot a bad sequence ID list file: $in_file\n\n";
    &usage;
}
unless ( open(OUT, ">$out_file") ) {
    print "\nGot a bad output file: $out_file\n\n";
    &usage;
}
print "Parameters:\nfasta file = $in_file\noutput file = $out_file\n\n";
#---------------------------------------------------------------------------------------------------------------------------
#The main event
#---------------------------------------------------------------------------------------------------------------------------
$seq = "";
$header = "";
while(<IN>) {
    chomp;
    if (/^>/) {	
	if (length($header) > 0) {
	    @parts = split(/$split_text/, $header);
	    @parts2 = split(/\//, $parts[1]);
	    unless ($parts2[0] =~ /^\d+$/) {
		print "This must be an integer for this sort: " . $parts[0] . "\n";
		&usage;
		exit(1);
	    }
	    $my_num = $parts2[0] . $parts2[1];
	    $seqs{$my_num} = $seq;
	    $headers{$my_num} = $header;
	    $header = "";
	    $seq = "";
	}
	$header = $_;
    }
    else {
	$seq = $seq . $_;
    }
}
if (length($header) > 0) {
    @parts = split(/Rec=/, $header);
    @parts2 = split(/\//, $parts[1]);
    unless ($parts2[0] =~ /^\d+$/) {
	print "This must be an integer for this sort: " . $parts[0] . "\n";
	&usage;
	exit(1);
    }
    $my_num = $parts2[0] . $parts2[1];
    $seqs{$my_num} = $seq;
    $headers{$my_num} = $header;
}
for $key (sort sort_by_num keys %headers) {
    print OUT "$headers{$key}\n";
    print OUT "$seqs{$key}\n";
}
close(IN);
close(OUT);
#-----------------------------------------------------------------------
sub sort_by_num {
    $a <=> $b;
}
#-----------------------------------------------------------------------
sub usage {
    print "\nUsage: sort_fasta.pl\n\n";
    print "Parameters:\n";
    print "-i input file\tA fasta file\n";
    print "-o output file\tA fasta file\n";
    print "-s text\t\tText to split on\n\n";
    print "This script sorts a paired end fasta file based on the header.\n";
    print "It will sort NUMERICALLY based on the header information that comes AFTER the text provided (-s).\n\n";
    print "Because it assumes paired ends, it assumes that the header ends with /1 or /2.\n";
    print "So, for this to work your headers should look something like:\n";
    print ">header text here:text to split on here:1234567890/1\n";
    print "\nJennifer Meneghin\n";
    print "July 2, 2012\n\n";
    exit;
}
#-----------------------------------------------------------------------
