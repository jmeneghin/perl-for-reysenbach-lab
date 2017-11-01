#!/usr/bin/perl -w
###################################
###   Annotate Blast Output     ###
###   Jennifer Meneghin         ###
###   July 26, 2009             ###
###################################
#---------------------------------------------------------------------------------------------------------------------------
#Deal with passed parameters
#---------------------------------------------------------------------------------------------------------------------------
#If no arguments are passed, show usage message and exit program.
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
else {
    print "\nPlease provide a database file in fasta format or a tab delimmited file.\n\n";
    &usage;
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
%functions = ();
%genomes = ();
if (length($db_file) > 0 && $flag == 0) { #if fasta
    while (<DB>) {
	$line = $_;
	if ($line =~ /^>/) {
	    $id = $line;
	    $id =~ s/^>(.+?)\s.+$/$1/g;
	    chomp($id);
	    $id =~ s/^>(.+)$/$1/g;

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

	    #print "ID: $id FUNCTION: $function GENOME: $genome\n";
	    $functions{$id} = $function;
	    $genomes{$id} = $genome;
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
	#print "TEXT ID = $id\n";
	$functions{$id} = $rest;
    }
}
#print "QUERY ID\tDATABASE ID\tPERCENT IDENTITY\\n";
print OUT "QUERY ID\tDATABASE ID\tPERCENT IDENTITY\n";
while(<IN>) {
    if (/^#/) {
	next;
    }
    chomp;
    @fields = split(/\t/);
    $fasta_id = $fields[0];
    $genbank_id = $fields[1];
    $percent_identity = $fields[2];
    #print "$fasta_id\t$genbank_id\t$percent_identity";
    print OUT "$fasta_id\t$genbank_id\t$percent_identity";
    if (length($db_file) > 0) {
	if ($flag == 0) {
	    if ($genomes{$genbank_id}) {
		#print "\t$genomes{$genbank_id}";
		print OUT "\t$genomes{$genbank_id}";
	    }
	}
	if ($functions{$genbank_id}) {
	    #print "\t$functions{$genbank_id}";
	    print OUT "\t$functions{$genbank_id}";
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
sub usage {
    print "BLAST MATCH UP 2.1\n";
    print "Jennifer Meneghin\n";
    print "August 6, 2009\n\n";
    print "Usage: blast_matchup.pl\n\n";
    print "Paramters:\n";
    print "-i <input file>\t\t\tA blast output file in short format\n";
    print "-o <output file>\t\tThe new file to create (optional). If not provided, a file called summary.out will be created.\n";
    print "-d <database file>\t\tThe database (in fasta format) used in the blast (optional).\n";
    print "-t <tab delimmited file>\tA tab delimmited file with the database IDs in the first column and gene annotation information (optional).\n\n";
    print "This program takes a blast output file in short format as it's input file.\n";
    print "It returns a file with query ID, database ID, percent identity, any annotation information found.\n\n";
    print "If a database file (in fasta format) is provided, it will attempt to fill in gene annotation where it can.\n";
    print "If a tabbed delimmited file is provided, it will attempt to fill in gene annotation where it can.\n\n";
    print "You can use a database file or a tabbed file, but not both at this time.\n";
    print "If you do not provide a database file or a tabbed delimmited file, this script doesn't do anything.\n\n";
    print "Updated July 7, 2010 by Jennifer Meneghin:\n";
    print "Can now be used with the new /vol/share/biology/ncbi/peptides/fastas/microbial.refseq.protein.headers database.\n";
    print "Also fixed the script so it is not ever trying to read the entire fasta database into memory, instead it only reads one line at a time.\n\n";
    exit;
}

