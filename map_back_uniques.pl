#!/usr/bin/perl -w
#############################
###   Jennifer Meneghin   ###
###   February 9, 2011    ###
#############################
#---------------------------------------------------------------------------------------------------------------------------
#Deal with passed parameters
#---------------------------------------------------------------------------------------------------------------------------
if ($#ARGV == -1) {
    &usage;
}
$in_file = "";
$fasta_file = "";
$out_file = "updated.fasta";
%my_args = @ARGV;
for $i (sort keys %my_args) {
    if ($i eq "-i") {
	$in_file = $my_args{$i};
    }
    elsif ($i eq "-f") {
	$fasta_file = $my_args{$i};
    }
    elsif ($i eq "-o") {
	$out_file = $my_args{$i};
    }
    else {
	print "\nUnrecognized argument: $i\n\n";
	&usage;
    }
}
unless ( open(IN, "$in_file") ) {
    print "\nGot a bad mapping file: $in_file\n\n";
    &usage;
}
unless ( open(FASTA, "$fasta_file") ) {
    print "\nGot a bad fasta file: $fasta_file\n\n";
    &usage;
}
if (-e $out_file) {
    print "\nOutput file $out_file already exists. Please delete it or choose a new output file.\n\n";
    &usage;
}
unless ( open(OUT, ">$out_file") ) {
    print "\nGot a bad output file: $out_file\n\n";
    &usage;
}
print "Parameters:\ninput file = $in_file\nfasta file = $fasta_file\noutput file = $out_file\n\n";
#---------------------------------------------------------------------------------------------------------------------------
#The main event
#---------------------------------------------------------------------------------------------------------------------------
while (<IN>) {
    chomp;
    @fields = split(/\s/);
    push(@lines, $fields[1]);
}
$i = 0;
$seq = "";
$total_num = 0;
$total_recs = 0;
while (<FASTA>) {
    chomp;
    if (/>/) {
	if (length($seq) > 0) {
	    @labels = split(/,/, $lines[$i]);
	    for $j (0..$#labels) {
#		print OUT ">$labels[$j] $header\n";
		print OUT ">$labels[$j]\n";
		print OUT "$seq\n";
		$total_recs++;
	    }
	    $i++;
	}
	$seq = "";
	$header = $_;
	$header =~ s/^>(.+)$/$1/g;
	$num = $header;
	$num =~ s/^.+_(\d+)/$1/g;
	$total_num = $total_num + $num;
    }
    else {
	$seq = $seq . $_;
    }
}
if (length($seq) > 0) {
    @labels = split(/,/, $lines[$i]);
    for $j (0..$#labels) {
	print OUT "$labels[$j] $header\n";
	print OUT "$seq\n";
	$total_recs++;
    }
}
print "Total expected number of records in new fasta file = $total_num\n";
print "Total number of records written to the new fasta file = $total_recs\n";
print "(These numbers should match... if they don't there is a problem with your files.)\n";
close(IN);
close(OUT);
close(FASTA);
#-----------------------------------------------------------------------
sub usage {
    print "\nUSAGE: ./map_back_uniques.pl\n\n";
    print "Parameters:\n";
    print "-i <input file>\t\tA mapping file output from AmpliconNoise\n";
    print "-f <fasta file>\t\tA fasta file output from AmpliconNoise\n";
    print "-o <output file>\tThe new fasta file to create (optional. If not provided,\n";
    print "\t\t\ta file called updated.fasta will be created.)\n\n";
    print "This script creates a new \"de-uniqued\" fasta file from the fasta file of uniques and the file that maps the original names to the uniques. It also updates the headers so that they start with the original labels (found in the mapping file.)\n\n";
    print "Jennifer Meneghin\n";
    print "February 9, 2011\n\n";
    exit;
}
