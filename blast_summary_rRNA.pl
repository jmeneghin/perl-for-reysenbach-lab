#!/usr/bin/perl -w
###################################
###   Summarize Blast Output    ###
###   Jennifer Meneghin         ###
###   February 4, 2009          ###
###   Updated March 12, 2009    ###
###   Updated July 29, 2010     ###
###   Updated August 9, 2010    ###
###################################

#-----------------------------------------------------------------------------------------------------------------------------------------
#Deal with passed parameters
#-----------------------------------------------------------------------------------------------------------------------------------------
if ($#ARGV == -1) {
    &usage;
}
$in_file = "";
$out_file = "summary.out";
$db_file = "";
$flag = -1;
%my_args = @ARGV;
for $i (sort keys %my_args) {
    if ($i eq "-i") {
	$in_file = $my_args{$i};
    }
    elsif ($i eq "-o") {
	$out_file = $my_args{$i};
    }
    elsif ($i eq "-d") {
	$db_file = $my_args{$i};
	$flag = 0;
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
if (length($db_file) > 0) {
    unless ( open(DB, "$db_file") ) {
	print "\nGot a bad database file: $db_file\n\n";
	&usage;
    }
}
print "Parameters:\ninput file = $in_file\noutput file = $out_file";
if (length($db_file) > 0) {
    print "\ndatabase file = $db_file";
}
print "\n\n";
#---------------------------------------------------------------------------------------------------------------------------
#The main event
#---------------------------------------------------------------------------------------------------------------------------
%genbank_percent = ();
%genbank_count = ();
%genomes = ();
while (<IN>) {
    if (/^#/) {
	next;
    }
    chomp;
    @fields = split(/\t/);
    $genbank_id = $fields[1];
    $percent_identity = $fields[2];
    if ( $genbank_count{$genbank_id} ) {
	$genbank_percent{$genbank_id} = $genbank_percent{$genbank_id} + $percent_identity;
	$genbank_count{$genbank_id} = $genbank_count{$genbank_id} + 1;
    }
    else {
	$genbank_percent{$genbank_id} = $percent_identity;
	$genbank_count{$genbank_id} = 1;
    }
}
if (length($db_file) > 0 && $flag == 0) {
    while (<DB>) {
	$line = $_;
	if ($line =~ /^>/) {
	    chomp($line);
	    $id = $line;
	    $id =~ s/^>(.+?)\s\|\s.+$/$1/g;
	    if ($genbank_count{$id}) {
		$genome = $line;
		$genome =~ s/^>.+?\s\|\s(.+)$/$1/g;
		$genomes{$id} = $genome;
	    }
	}
    }
}
print OUT "ID\tCount\tAvg. % Identity\tGenome\n";
foreach $i (sort by_id keys %genbank_count) {
    $average = $genbank_percent{$i} / $genbank_count{$i};
    #print "$i\t$genbank_count{$i}\t$average";
    print OUT "$i\t$genbank_count{$i}\t$average";
    if (length($db_file) > 0) {
	#print "\t$genomes{$i}";
	print OUT "\t$genomes{$i}";
    }
    #print "\n";
    print OUT "\n";
}
close(IN);
close(OUT);
if (length($db_file) > 0) {
    close(DB);
}
sub by_id { $a cmp $b; }
sub usage {
    print "BLAST SUMMARY rRNA 2.0\n";
    print "Jennifer Meneghin\n";
    print "March 12, 2009\n\n";
    print "Last updated August 9, 2010\n\n";
    print "Usage: blast_summary_rRNA.pl\n\n";
    print "Parameters:\n";
    print "-i <input file>\t\t\tA BLAST output file in short format\n";
    print "-o <output file>\t\tThe new file to create. If not provided, a file called summary.out will be created.\n";
    print "-d <database file>\t\tThe database (in fasta format) used in the BLAST (optional).\n";
    print "This program takes a blast output file in short format as it's input file,\n";
    print "and returns a tab delimmited list of unique database IDs found, the number of times each appeared,\n";
    print "and the average percent identity found for each.\n\n";
    print "If a database file (in fasta format) is provided, any extra header information (organisim name) will be included.\n";
    print "Currently this script assumes the database is ssu-parc.fasta (downloaded from SILVA www.arb-silva.de), lsu-parc.fasta (also from SILVA site), or these two files concatenated together (SILVA.fasta)\n\n";
    exit;
}
