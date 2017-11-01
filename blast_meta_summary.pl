#!/usr/bin/perl -w
####################################
###   Summarize Blast Output     ###
###   Jennifer Meneghin          ###
###   June 15, 2009              ###
###   Updated September 09, 2009 ###
###   Updated August 18, 2010    ###
####################################
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
$perkb = 0;
$spit = 0;
$text_file = "/vol/share/biology/cog/COG_12Bacteria.txt";
$sum_col = 3;
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
	$perkb = 1;
    }
    elsif ($i eq "-s") {
	if (lc($my_args{$i}) eq "y") {
	    $spit = 1;
	}
	else {
	    $spit = 0;
	}
    }
    elsif ($i eq "-t") {
	$text_file = $my_args{$i};
    }
    elsif ($i eq "-c") {
	$sum_col = $my_args{$i};
	if (!($sum_col =~ /^\d+$/)) {
	    print "\nSummary column must be an integer: $sum_col\n";
	    &usage;
	}
	if ($sum_col < 1) {
	    print "\nSummary column must be a postive integer (> 0): $sum_col\n";
	    &usage;
	}
    }
    else {
	print "\nUnrecognized argument: $i\n\n";
	&usage;
    }
}
unless ( open(TEXT, "$text_file") ) {
    print "\nGot a bad text file: $text_file\n\n";
    &usage;
}
unless ( open(IN, "$in_file") ) {
    print "\nGot a bad input file: $in_file\n\n";
    &usage;
}
unless ( open(OUT, ">$out_file") ) {
    print "\nGot a bad output file: $out_file\n\n";
    &usage;
}
if ($perkb == 1 && length($db_file) > 0) {
    unless ( open(DB, "$db_file") ) {
	print "\nGot a bad database file: $db_file\n\n";
	&usage;
    }
}
if ($spit == 1) {
    unless ( open(SPIT, ">suspected_rrna.txt") ) {
	print "Got a bad output file: suspected_rrna.txt\n";
	exit;
    }
}
#Everything looks good. Print the parameters we've found.
print "Parameters:\ninput file = $in_file\noutput file = $out_file";
if ($perkb == 1 && length($db_file) > 0) {
    print "\ndatabase file = $db_file";
}
if ($spit == 1) {
    print "\nspit file = suspected_rrna.txt\n";
}
print "\n\n";
#-----------------------------------------------------------------------------------------------------------------------------------------
#The main event
#-----------------------------------------------------------------------------------------------------------------------------------------
%genbank_percent = ();
%genbank_count = ();
%functions = ();
while (<IN>) {
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
while (<TEXT>) {
    $line = $_;
    chomp($line);
    @tab_fields = split(/\t/, $line);
    $id = $tab_fields[0];
    $cog = "Unkown";
    if ($#tab_fields >= ($sum_col-1)) {
	$cog = $tab_fields[$sum_col-1];
    }
    $cog =~ s/"//g;
    $rest = $line;
    $rest =~ s/^.+?\t(.+)$/$1/;
    if ($genbank_count{$id}) {
	$functions{$cog}{$id} = $rest;
    }
}
%fasta_lengths = ();
$seq = "";
if ($perkb == 1) {
    while (<DB>) {
	chomp;
	if (/^>/) {
	    #finish up previous line.
	    if (length($seq) > 0) {
		$fasta_lengths{$id} = length($seq);
	    }
	    $id = $_;
	    $id =~ s/^>(.+?)\s.+$/$1/g;
	    $seq = "";
	}
	else {
	    $seq = $seq . $_;
	}
    }
    $fasta_lengths{$id} = length($seq);
}
if ($perkb == 1) {
    print "CATEGORY\tCOUNT\tCOUNT PER KB\tAVERAGE PERCENT IDENTITY\n";
    print OUT "CATEGORY\tCOUNT\tCOUNT PER KB\tAVERAGE PERCENT IDENTITY\n";
}
else {
    print "CATEGORY\tCOUNT\tAVERAGE PERCENT IDENTITY\n";
    print OUT "CATEGORY\tCOUNT\tAVERAGE PERCENT IDENTITY\n";
}
foreach $j (sort by_id keys %functions) {
    $gb_count_sum = 0;
    $gb_percent_sum = 0;
    $gb_count_perkb_sum = 0;
    foreach $i (sort by_id keys %genbank_count) {
	if ($functions{$j}{$i}) {
	    if ($spit == 1) {
		if ($functions{$j}{$i} =~ /5S ribosomal RNA/ || 
		    $functions{$j}{$i} =~ /16S ribosomal RNA/ || 
		    $functions{$j}{$i} =~ /23S ribosomal RNA/ || 
		    $functions{$j}{$i} =~ /28S ribosomal RNA/ || 
		    $functions{$j}{$i} =~ /18S ribosomal RNA/) {
		    $average = $genbank_percent{$i} / $genbank_count{$i};
		    #print "$i\t$genbank_count{$i}\t$average\t$functions{$j}{$i}\n";
		    print SPIT "$i\t$genbank_count{$i}\t$average\t$functions{$j}{$i}\n";
		}
		else {
		    $gb_count_sum = $gb_count_sum + $genbank_count{$i};
		    $gb_percent_sum = $gb_percent_sum + $genbank_percent{$i};
		    if ($perkb == 1 && $fasta_lengths{$i} > 0) {
			$gb_count_perkb_sum = $gb_count_perkb_sum + (($genbank_count{$i}*1000)/$fasta_lengths{$i});
		    }
		    elsif ($perkb == 1) {
			print "gotta bad fasta length?!\n";
		    }
		}
	    }
	    else {
		$gb_count_sum = $gb_count_sum + $genbank_count{$i};
		$gb_percent_sum = $gb_percent_sum + $genbank_percent{$i};
		if ($perkb == 1 && $fasta_lengths{$i} > 0) {
		    $gb_count_perkb_sum = $gb_count_perkb_sum + (($genbank_count{$i}*1000)/$fasta_lengths{$i});
		}
		elsif ($perkb == 1) {
		    print "gotta bad fasta length?!\n";
		}
	    }
	}
    }
    $average = 0;
    if ($gb_count_sum > 0) {
	$average = $gb_percent_sum / $gb_count_sum;
    }
    if ($perkb == 1) {
	print "$j\t$gb_count_sum\t$gb_count_perkb_sum\t$average\n";
	print OUT "$j\t$gb_count_sum\t$gb_count_perkb_sum\t$average\n";
    }
    else {
	print "$j\t$gb_count_sum\t$average\n";
	print OUT "$j\t$gb_count_sum\t$average\n";
    }

}
close(TEXT);
close(IN);
close(OUT);
if (length($db_file) > 0) {
    close(DB);
}
sub by_id { $a cmp $b; }
sub usage {
    print "\nBLAST META SUMMARY 4.3\n";
    print "Jennifer Meneghin\n";
    print "August 18, 2010\n\n";
    print "Usage: blast_meta_summary.pl\n\n";
    print "Parameters:\n";
    print "-i input_file\tThe blast output file in short format\n";
    print "-o output_file\tThe output file to create (optional. Default = summary.out)\n";
    print "-d fasta_file\tIf you want to calculate count per KB, you need to provide the fasta file used as the blast database\n";
    print "\t\t(optional. Should be a copy of 12bacteria.fasta if you are using COG_12Bacteria.txt)\n";
    print "-s y/n\t\ty if you want to \"spit\" the ribosomal lines, n if you do not (optional. Default = n)\n";
    print "-t text_file\tA tabbed delimmited file with BLAST database fasta ID in the first column\n";
    print "\t\t(optional. Default = /vol/share/biology/cog/COG_12Bacteria.txt on the research server.)\n";
    print "-c N\t\tThe column to summarize by in the text_file (optional. Default = 3)\n\n";
    print "This program takes a skimmed BLAST output file in short format as it's input file,\n";
    print "and returns a tab delimmited list of unique categories found, the number of times each appeared,\n";
    print "and the average percent identity found for each.\n\n";
    print "If a text_file is not provided this script requires /vol/share/biology/cog/COG_12Bacteria.txt in order to work properly.\n";
    print "If COG_12Bacteria.txt is used, -c 3 (the default) will summarize by organism, -c 7 will summarize by COG category, and -c 4 will summarize by COG number.\n\n";
    print "If the database file used in the BLAST (in fasta format) is provided, it will also report the count per KB.\n\n";
    exit;
}
