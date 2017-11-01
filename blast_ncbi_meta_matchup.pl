#!/usr/bin/perl -w
###########################################################
###   Matchup NCBI Blast Output to Available Meta Info  ###
###   Jennifer Meneghin                                 ###
###   July 27, 2010                                     ###
###########################################################
#---------------------------------------------------------------------------------------------------------------------------
#Deal with passed parameters
#---------------------------------------------------------------------------------------------------------------------------
#If no arguments are passed, show usage message and exit program.
if ($#ARGV == -1) {
    &usage;
}
$in_file = "";
$out_file = "ncbi_kegg_matchup.txt";
$gi_list_file = "";
$ko_list_file = "";
$ko_file = "";
$column = 1;
%my_args = @ARGV;
for $i (sort keys %my_args) {
    if ($i eq "-i") {
	$in_file = $my_args{$i};
    }
    elsif ($i eq "-o") {
	$out_file = $my_args{$i};
    }
    elsif ($i eq "-g") {
	$gi_list_file = $my_args{$i};
    }
    elsif ($i eq "-l") {
	$ko_list_file = $my_args{$i};
    }
    elsif ($i eq "-k") {
	$ko_file = $my_args{$i};
    }
    elsif ($i eq "-c") {
	if ($my_args{$i} =~ /\d+/) {
	    $column = $my_args{$i};
	}
	else {
	    print "\nUnrecognized column number: $my_args{$i}. Must be an integer.\n\n";
	    &usage;
	}
    }
    else {
	print "\nUnrecognized argument: $i\n\n";
	&usage;
    }
}
unless ( open(GIL, "$gi_list_file") ) {
    print "\nCouldn't open file: $gi_list_file\n\n";
    &usage;
}
unless ( open(KOL, "$ko_list_file") ) {
    print "\nCouldn't open file: $ko_list_file\n\n";
    &usage;
}
unless ( open(KO, "$ko_file") ) {
    print "\nCouldn't open file: $ko_file\n\n";
    &usage;
}
unless ( open(IN, "$in_file") ) {
    print "\nGot a bad input file: $in_file\n\n";
    &usage;
}
if (-e $out_file) {
    print "\nCouldn't create $out_file, because it already exists\n\n";
    &usage;
}
unless ( open(OUT, ">$out_file") ) {
    print "\nGot a bad output file: $out_file\n\n";
    &usage;
}
print "Parameters:\ninput file = $in_file\noutput file = $out_file\n\ngi list file = $gi_list_file\nko list file = $ko_list_file\nko file = $ko_file\ncolumn to match on = $column\n\n";
#---------------------------------------------------------------------------------------------------------------------------
#The main event
#---------------------------------------------------------------------------------------------------------------------------
%summary = ();
$cols = 0;
while (<IN>) {
    chomp;
    @fields = split(/\t/);
    $genbank = $fields[($column-1)];
    if ($genbank =~ /^gi/) {
#	$genbank =~ s/^gi\|(\d+)\|ref.+$/$1/g;
	$genbank =~ s/^gi\|(\d+)\|.+$/$1/g;
	$summary{$genbank} = $_;
	print "in: $genbank\n";
    }
    if ($#fields > $cols) {
	$cols = $#fields;
    }
}
close(IN);

%names = ();
%gis = ();
while (<GIL>) {
    @fields = split(/\t/);
    $gi = $fields[1];
    $gi =~ s/^ncbi-gi:(\d+)$/$1/g;
    if ($summary{$gi}) {
	$names{$fields[0]} = $gi;
	$gis{$gi} = $fields[0];
    }
}
close(GIL);

%kos = ();
while (<KOL>) {
    chomp;
    @fields = split(/\t/);

    $ko = $fields[1];
    $ko =~ s/^ko:(.+)$/$1/g;
    $name = $fields[0];
    if ($names{$name}) {
	if ($kos{$ko}) {
	    $kos{$ko} = $kos{$ko} . "|" . $names{$fields[0]};
	}
	else {
	    $kos{$ko} = $names{$fields[0]};
	}
	print "ko: $names{$fields[0]}\t$ko\n";
    }
}
close(KOL);

$flag = 0;
for $i (0..$cols) {
    print "\t";
    print OUT "\t";
}
print "Name\tKEGG Information\n";
print OUT "Name\tKEGG Information\n";
while (<KO>) {
    chomp;
    if (/^ENTRY/) {
	$knum = $_;
	$knum =~ s/^ENTRY\s+(K\d+?)\s.+$/$1/g;
	if ( $kos{$knum} ) {
	    $flag = 1;
	    if ( $kos{$knum} =~ /\|/) {
		@genbanks = split(/\|/, $kos{$knum});
		for $i (0..$#genbanks-1) {
		    print "$summary{$genbanks[$i]}\t$gis{$genbanks[$i]}\t$knum\n";
		    print OUT "$summary{$genbanks[$i]}\t$gis{$genbanks[$i]}\t$knum\n";
		    delete($summary{$genbanks[$i]});
		}
		print "$summary{$genbanks[$#genbanks]}\t$gis{$genbanks[$#genbanks]}\t$knum\t";
		print OUT "$summary{$genbanks[$#genbanks]}\t$gis{$genbanks[$#genbanks]}\t$knum\t";
		delete($summary{$genbanks[$#genbanks]});
	    }
	    else {
		print "$summary{$kos{$knum}}\t$gis{$kos{$knum}}\t$knum\t";
		print OUT "$summary{$kos{$knum}}\t$gis{$kos{$knum}}\t$knum\t";
		delete($summary{$kos{$knum}});
	    }
	}
	else {
	    $flag = 0;
	}
    }
    elsif (/^GENES/ || /^\/\/\//) {
	$flag = 0;
    }
    elsif ($flag == 1) {
	print "$_\n";
	print OUT "$_\n";
	$flag = 2;
    }
    elsif ($flag == 2) {
	for $i (0..$cols) {
	    print "\t";
	    print OUT "\t";
	}
	print "\t\t$_\n";
	print OUT "\t\t$_\n";
    }
}
for $i (sort keys %summary) {
    if ($gis{$i}) {
	print "$summary{$i}\t$gis{$i}\tNo KEGG information found\n";
	print OUT "$summary{$i}\t$gis{$i}\tNo KEGG information found\n";
    }
    else {
	print "$summary{$i}\tNo Name Found\tNo KEGG information found\n";
	print OUT "$summary{$i}\tNo Name Found\tNo KEGG information found\n";
    }
}
close(KO);
close(OUT);
sub usage {
    print "Usage: blast_ncbi_meta_matchup.pl\n\n";
    print "Parameters:\n";
    print "-i input_file\t\tA tabbed delimited file with NCBI IDs\n";
    print "-k ko\t\t\tThe ko file downloaded from KEGG with pathway (and other) information for KO numbers\n";
    print "-g genes_ncbi-gi.list\tThe genes_ncbi-gi.list file downloaded from KEGG that relates NCBI IDs to KEGG IDs\n";
    print "-l genes_ko.list\tThe genes_ko.list file downloaded from KEGG that relates KEGG IDs to KEGG numbers\n";
    print "-o output_file\t\tThe output file to create (optional. Default = ncbi_kegg_matchup.txt)\n";
    print "-c integer\t\tThe column number of the NCBI ID (optional. Default = 1)\n\n";
    print "This program takes a BLAST output file in short format, a summarized (by blast_summary.pl) BLAST output\n";
    print "file in short format, or any other tab delimited file with a field for NCBI ID as it's input file,\n";
    print "and returns this file with additional KEGG information found.\n\n";
    print "Assumption: BLAST was performed on NCBI files. IDs must start with \"gi|\".\n\n";
    print "Jennifer Meneghin\n";
    print "July 27, 2010\n";
    print "Updated August 12, 2010\n\n";
    exit;
}
