#!/usr/bin/perl -w
#############################
###   Jennifer Meneghin   ###
###   August 10, 2009     ###
#############################
#---------------------------------------------------------------------------------------------------------------------------
#Deal with passed parameters
#---------------------------------------------------------------------------------------------------------------------------
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
%fasta_lengths = ();
$seq = "";
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

while (<IN>) {
    @fields = split(/\t/);
    $id = $fields[0];
    $count = $fields[1];
    $rest = $_;
    $rest =~ s/^.+?\s(.+)$/$1/g;
    $per_kb = 0;
    if ($fasta_lengths{$id} > 0) {
	$per_kb = ($count * 1000) / $fasta_lengths{$id};
    }
    print OUT "$id\t$fasta_lengths{$id}\t$per_kb\t$rest";
}
close(IN);
close(OUT);
if (length($db_file) > 0) {
    close(DB);
}
sub usage {
    print "Jennifer Meneghin\n";
    print "August 10, 2009\n\n";
    print "Usage: blast_per_kb.pl\n\n";
    print "Parameters:\n";
    print "-i <input file>\t\t\tA BLAST summary file created by blast_summary.pl\n";
    print "-o <output file>\t\tThe new file to create. If not provided, a file called summary.out will be created.\n";
    print "-d <database file>\t\tThe database (in fasta format) used in the BLAST.\n";
    exit;
}
