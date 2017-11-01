#!/usr/bin/perl -w
#################################
###   Jennifer Meneghin       ###
###   March 31, 2009          ###
###   Updated August 4, 2010  ###
#################################
#---------------------------------------------------------------------------------------------------------------------------
#Deal with passed parameters
#---------------------------------------------------------------------------------------------------------------------------
#If no arguments are passed, show usage message and exit program.
if ($#ARGV == -1) {
    print "COG MATCHUP\n";
    print "Jennifer Meneghin\n";
    print "March 31, 2009\n";
    print "Updated August 4, 2010\n\n";
    print "Usage: cog_matchup.pl <blast best file> <matchup file>\n\n";
    exit;
}
$in_file = $ARGV[0];
if (@ARGV > 1) {
    $cog_file = $ARGV[1];
}
unless ( open(IN, "$in_file") ) {
    print "Got a bad input file: $in_file\n";
    exit;
}
unless ( open(COG, "$cog_file") ) {
    print "Got a bad COG matchup file: $cog_file\n";
    exit;
}
$out_file = "cog_matchup.txt";
if (-e $out_file) {
    print "Couldn't create output file because it already exists: $out_file\n";
    exit;
}
unless ( open(OUT, ">$out_file") ) {
    print "Couldn't create output file: $out_file\n";
    exit;
}
print "Parameters:\nsummary file = $in_file\nCOG matchup file = $cog_file\n\n";
#---------------------------------------------------------------------------------------------------------------------------
#The main event
#---------------------------------------------------------------------------------------------------------------------------
%lines = ();
while(<IN>) {
    chomp;
    @fields = split(/\t/);
    $lines{$fields[1]} = $_;
}
close(IN);
while(<COG>) {
    chomp;
    @cog_fields = split(/\t/);
    $cog_id = $cog_fields[0];
    $cog_num = $cog_fields[3];
    $cog_annot = $cog_fields[4];
    if ($lines{$cog_id}) {
	print "$lines{$cog_id}\t$cog_id\t$cog_num\t$cog_annot\n";
	print OUT "$lines{$cog_id}\t$cog_id\t$cog_num\t$cog_annot\n";
    }  
}
close(COG);
close(OUT);
