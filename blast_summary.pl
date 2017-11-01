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
	if (length($db_file) > 0) {
	    print "\nThis program can accept a fasta file or a tabbed delimmited file, but not both at this time.\n\n";
	    &usage;
	}
	$db_file = $my_args{$i};
	$flag = 0;
    }
    elsif ($i eq "-t") {
	if (length($db_file) > 0) {
	    print "\nThis program can accept a fasta file or a tabbed delimmited file, but not both at this time.\n\n";
	    &usage;
	}
	$db_file = $my_args{$i};
	$flag = 1;
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
	print "\nGot a bad database or tab delimmited file: $db_file\n\n";
	&usage;
    }
}
print "Parameters:\ninput file = $in_file\noutput file = $out_file";
if (length($db_file) > 0) {
    if($flag == 0) {
	print "\ndatabase file = $db_file";
    }
    else {
	print "\ntabbed delimmited file = $db_file";
    }
}
print "\n\n";
#---------------------------------------------------------------------------------------------------------------------------
#The main event
#---------------------------------------------------------------------------------------------------------------------------
%genbank_percent = ();
%genbank_count = ();
%functions = ();
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
	    $id =~ s/^>(.+?)\s.+$/$1/g;
	    if ($genbank_count{$id}) {
		$genome = $line;
		if ($genome =~ /\{/) { #special case for Aquifex.
		    $genome =~ s/^>.+\{(.+?)\}$/$1/g;
		}
		else {
		    $genome =~ s/^>.+\[(.+?)\]$/$1/g;
		}
		chomp($genome);
		
		$function = $line;
		if ($genome eq "Thermotoga maritima MSB8" || $genome eq "Thermus thermophilus HB8" || $genome eq "Thermus thermophilus HB27") {
		    $function =~ s/^>.+?\s(.+?)\d+\.\..+$/$1/g;
		    chomp($function);
		}
		elsif ($function =~ /^>\d+/) {
		    $function =~ s/^>.+?\s.+?\s(.+?)\d+\.\..+$/$1/g;
		    chomp($function);
		}
		elsif ($function =~ /^>gi/) { #a database from genbank: refseq, nr or nt.
		    $function =~ s/^>.+?\s(.+?)\[.+$/$1/g;
		}
		else {
		    $function = "Could not find annotation in database file";
		}
		chomp($function);
		$functions{$id} = $function;
		$genomes{$id} = $genome;
	    }
	}
    }
}
elsif (length($db_file) > 0 && $flag == 1) {
    while (<DB>) {
	$line = $_;
	chomp($line);
	@tab_fields = split(/\t/, $line);
	$id = $tab_fields[0];
	$rest = $line;
	$rest =~ s/^.+?\t(.+)$/$1/;
	if ($genbank_count{$id}) {
	    $functions{$id} = $rest;
	}
    }
}
print OUT "ID\tCount\tAvg. % Identity\tGenome\tAnnotation\n";
foreach $i (sort by_id keys %genbank_count) {
    $average = $genbank_percent{$i} / $genbank_count{$i};
    #print "$i\t$genbank_count{$i}\t$average";
    print OUT "$i\t$genbank_count{$i}\t$average";
    if (length($db_file) > 0) {
	if ($functions{$i}) {
	    #print "\t$genomes{$i}\t$functions{$i}";
	    print OUT "\t$genomes{$i}\t$functions{$i}";
	}
	else {
	    #print "\tCould not find annotation in database file";
	    print OUT "\tCould not find annotation in database file";
	}
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
    print "BLAST SUMMARY 3.2\n";
    print "Jennifer Meneghin\n";
    print "March 12, 2009\n\n";
    print "Last updated August 9, 2010\n\n";
    print "Usage: blast_summary.pl\n\n";
    print "Parameters:\n";
    print "-i <input file>\t\t\tA BLAST output file in short format\n";
    print "-o <output file>\t\tThe new file to create. If not provided, a file called summary.out will be created.\n";
    print "-d <database file>\t\tThe database (in fasta format) used in the BLAST (optional).\n";
    print "-t <tab delimmited file>\tA tab delimmited file with the database IDs in the first column (optional).\n\n";
    print "This program takes a blast output file in short format as it's input file,\n";
    print "and returns a tab delimmited list of unique database IDs found, the number of times each appeared,\n";
    print "and the average percent identity found for each.\n\n";
    print "If a database file (in fasta format) is provided, any extra header information (often annotations) will be included.\n";
    print "If a tabbed delimmited file is provided, with database (fasta) IDs as it's first column, this information will also be included.\n\n";
    print "Note: you can use a database file OR a tabbed file (or neither), but not both at this time.\n\n";
    exit;
}
