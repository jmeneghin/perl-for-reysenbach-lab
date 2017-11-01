#!/usr/bin/perl -w
#############################
###   Jennifer Meneghin   ###
###   June 14, 2010       ###
#############################
#---------------------------------------------------------------------------------------------------------------------------
#Deal with passed parameters
#---------------------------------------------------------------------------------------------------------------------------
if ($#ARGV == -1) {
    &usage;
}
$in_file = "";
%my_args = @ARGV;
for $i (sort keys %my_args) {
    if ($i eq "-i") {
	$in_file = $my_args{$i};
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
print "Parameters:\ninput file = $in_file\n\n";
#---------------------------------------------------------------------------------------------------------------------------
#The main event
#---------------------------------------------------------------------------------------------------------------------------
%file_lines = ();
%file_counts = ();
while (<IN>) {
    chomp;
    if ( /^File\(s\):/ ) {
	@fields = split(/\t/);
	@files = split(/\s/, $fields[1]);
    }
    elsif ( /^Sequences:/ ) {
	@fields = split(/\t/);
	@seq_nums = split(/\s/, $fields[1]);
	for $i (0..$#files) {
	    if (-e "$files[$i].clust") {
		print "\nERROR: File $files[$i].clust already exists.\n\n";
		&usage;
	    }
	    $fh = "HANDLE_" . $files[$i];
	    unless ( open($fh, ">$files[$i].clust") ) {
		print "\nERROR: Couldn't open $files[$i].clust for writing.\n\n";
		&usage;
	    }
	    print $fh "File(s):\t$files[$i] \n";
	    print $fh "Sequences:\t$seq_nums[$i] \n\n";
	}
    }
    elsif ( /^\d/ ) {
	    @fields = split(/\t/);
	    $this_file = $fields[1];
	    $count = $fields[2];
	    if ($count > 0) {
		#print $fh "$_\n";
		if ($file_lines{$this_file}) {
		    $file_lines{$this_file} = $file_lines{$this_file} . "\n" . $_;
		    $file_counts{$this_file}++;
		}
		else {
		    $file_lines{$this_file} = $_;
		    $file_counts{$this_file} = 1;
		}
	    }
	}
    elsif ( /^Total Clusters:/ ) {
	next;
    }
    elsif ( /^distance cutoff:/ ) {
	for $i (0..$#files) {
	    $fh = "HANDLE_" . $files[$i];
	    print $fh "$_\n";
	}
    }
    else {
	for $i (0..$#files) {
	    $this_file = $files[$i];
	    $fh = "HANDLE_" . $this_file;
	    if ($file_counts{$this_file}) {
		print $fh "Total Clusters:\t$file_counts{$this_file}\n";
		print $fh "$file_lines{$this_file}\n";
		print $fh "\n";
	    }
	}
	%file_lines = ();
	%file_counts = ();
    }
}
for $i (0..$#files) {
    $this_file = $files[$i];
    $fh = "HANDLE_" . $this_file;
    if ($file_counts{$this_file}) {
	print $fh "Total Clusters:\t$file_counts{$this_file}\n";
	print $fh "$file_lines{$this_file}\n";
    }
}
close(IN);
#-----------------------------------------------------------------------
sub usage {
    print "\nUsage: ./split_clusters_by_sample.pl\n\n";
    print "Parameters:\n";
    print "-i input file\tA Cluster file in the form output by RDP.\n\n";
    print "This script takes a cluster file output by RDP that was created using multiple files. It returns one cluster file for each file used in the original clustering. In other words, it will create a new file_name.clust for each file found in the first line of the original cluster file.\n\n";
    print "Jennifer Meneghin\n";
    print "June 14, 2010\n\n";
    exit;
}
#-----------------------------------------------------------------------
