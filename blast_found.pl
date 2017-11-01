#!/usr/bin/perl -w
####################################################################################################
### BLAST FOUND 1.0                                                                              ###
### Usage: blast_found.pl <blast output file> <query file>                                       ###
### This program takes a blast output file in short format as it's first parameter,              ###
### and the query file (in fasta format) as it's second parameter.                               ###
### It returns two fasta files, one with all records found by blast, and one with all not found. ###
###                                                                                              ###
### Jennifer Meneghin                                                                            ###
### January 28, 2009                                                                             ###
###                                                                                              ###
### BLAST FOUND 2.0                                                                              ###
### Usage: blast_found.pl -i blast_output_file -f fasta_query_file -n n                          ###
### Updates:                                                                                     ###
### Changed the how the parameters work to be more consistent with other scripts                 ###
### Added a new optional flag which should be either: -n y -n n                                  ###
###    -n y means returns the two fasta files as before (default)                                ###
###    -n n means return only the records found, but not the records not found (one file only)   ###
###                                                                                              ###
### Jennifer Meneghin                                                                            ###
### August 4, 2010                                                                               ###
####################################################################################################

#--------------------------------------------------------------------------------------------------------------------------
#Deal with passed parameters
#--------------------------------------------------------------------------------------------------------------------------
#If no arguments are passed, show usage message and exit program.
if ($#ARGV == -1) {
    usage();
    exit;
}
$blast_file = "";
$query_file = "";
$flag = 0;
%my_args = @ARGV;
for $i (sort keys %my_args) {
    if ($i eq "-i") {
	$blast_file = $my_args{$i};
    }
    elsif ($i eq "-f") {
	$query_file = $my_args{$i};
    }
    elsif ($i eq "-n") {
	if ($my_args{$i} eq "n") {
	    $flag = 1;
	}
	elsif ($my_args{$i} eq "y") {
	    $flag = 0;
	}
	else {
	    print "\nThe -n parameter must be 'y' (print both files) or 'n' (print one file). You entered: $my_args{$i}\n\n";
	    &usage;
	}
    }
    else {
	print "\nUnrecognized argument: $i\n\n";
	&usage;
    }
}

#Open files. If unsuccessful, print an error message and exit program.
unless ( open(BLAST, "$blast_file") ) {    
    print "Got a bad blast file: $blast_file\n\n";
    exit;
}
unless ( open(QUERY, "$query_file") ) {
    print "Got a bad fasta query file: $query_file\n";
    exit;
}
$matches_file = "matches.fasta";
if (-e $matches_file) {
    print "\nCouldn't create output file $matches_file because it already exists.\n\n";
    &usage;
}
unless ( open(MATCHES, ">$matches_file") ) {
    print "\nCouldn't create output file: $matches_file\n\n";
    &usage;
}
if ($flag == 0) {
    $notmatches_file = "notmatches.fasta";
    $notmatches_file =~ s/(.+)\.(.+)$/$1_notmatches\.$2/g;
    if (-e $notmatches_file) {
	print "\nCouldn't create output file $notmatches_file because it already exists.\n\n";
	&usage;
    }
    unless ( open(NOTMATCHES, ">$notmatches_file") ) {
	print "\nCouldn't create output file: $notmatches_file\n\n";
	&usage;
    }
}
#Everything looks good. Print the parameters we've found.
print "Parameters:\nblast file = $blast_file\nquery file = $query_file\nmatches file = $matches_file\n";
if ($flag == 0) {
    print "not-matches file = $notmatches_file\n\n";
}
else {
    print "\n";
}
#---------------------------------------------------------------------------------------------------------------------------
#The main event
#---------------------------------------------------------------------------------------------------------------------------
%ids = ();
while (<BLAST>) {
    @fields = split(/\t/);
    $id = $fields[0];
    print "ID = $id\n";
    if (!$ids{$id}) {
	$ids{$id} = $id;
    }
}
close(BLAST);
$match_flag = 0;
while (<QUERY>) {
    $line = $_;
    if ($line =~ /^>/) {
	$id = $line;
	$id =~ s/^>(.+?)\s.+$/$1/g;
	chomp($id);
	if ($ids{$id}) {
	    $match_flag = 1;
	    print "Found $id\n";
	    print MATCHES "$line";
	}
	else {
	    $match_flag = 0;
	    if ($flag == 0) {
		print "Not Found $id\n";
		print NOTMATCHES "$line";
	    }
	}
    }
    else {
	if ($match_flag == 1) {
	    print MATCHES "$line";
	}
	else {
	    if ($flag == 0) {
		print NOTMATCHES "$line";
	    }
	}
    }
}
close(QUERY);
close(MATCHES);
if ($flag == 0) {
    close(NOTMATCHES);
}
sub usage {
    print "BLAST FOUND 2.0\n";
    print "Usage: blast_found.pl -i blast_output_file -f fasta_query_file -n n\n\n";
    print "This program takes (-i) a blast output file in short format (or any tabbed delimited file with fasta IDs\n";
    print "in the first column), and (-f) a query file (in fasta format).\n\n";
    print "If -n y, it returns two fasta files, one with all records found by blast (matches.fasta), and one with all not found (notmatches.fasta).\n";
    print "If -n n, it returns one fasta file, with all records found in the blast file (matches.fasta).\n";
    print "-n is optional; -n y is the default.\n\n";
    print "Jennifer Meneghin\n";
    print "January 28, 2009\n\n";
    print "Updated:\n";
    print "Jennifer Meneghin\n";
    print "August 4, 2010\n\n"
}
