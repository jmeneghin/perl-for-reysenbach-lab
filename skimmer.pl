#!/usr/bin/perl -w

# Jennifer Meneghin
# 04/05/2007
# This script "skims" BLAST output files in either "long" or "short" format, by extracting only the hits that are below the provided e-value cut-off
# and/or above the provided percent identity (short format only). The short format version of the blast output can be created using blastx ... and
# the long format version of the can be created using blastx ...

# Jennifer Meneghin
# 01/22/2009
# Added the ability to skim by "bit score"

# Jennifer Meneghin
# 08/06/2009
# changed parameter passing to "blast style" (cleaner and less confusing I think)

# Jennifer Meneghin
# 06/09/2010
# Changed the short format version so that instead of reading the entire file into an array and then looping through the array, I loop through the filehandle directly. So only one line is in memory at once, instead of the whole thing at once (I think). Helps significantly with very large files. (Much faster, doesn't crash). Should also be done for the long version at some point.

#---------------------------------------------------------------------------------------------------------------------------
#Some global variables
#---------------------------------------------------------------------------------------------------------------------------
$flag = "no flag found";
$evalue = -1;
$percent_identity = -1;
$bitscore = -1;
$conjunction_flag = "and";
$align = -1;
$in_file = "";
$out_file = "outfile";

$this_score = 0; #just so this junk field gets used twice, so Perl won't throw a stupid warning.

#---------------------------------------------------------------------------------------------------------------------------
#Deal with passed parameters
#---------------------------------------------------------------------------------------------------------------------------
#If no arguments are passed, show usage message and exit program.
if ($#ARGV == -1) {
    usage("SKIMMER 2.1 2009");
}

#Look for all arguments that start with a dash (can be in any order).
%my_args = @ARGV;
for $i (sort keys %my_args) {
    if ($i eq "-r") {
	if (lc($my_args{$i}) eq "s") {
	    $flag = "short";
	}
	elsif (lc($my_args{$i}) eq "l") {
	    $flag = "long";
	}
	else {
	    &usage("Unrecognized format parameter (-r): $my_args{$i}. Should be s (for short) or l (for long)");
	}
    }
    elsif ($i eq "-e") { 
	#if it is not a number in the form ne-m where n is an integer from 0 to 9 and m is an integer from 0 to 999,
	#print an error message and exit program.
	#otherwise, populate $evalue variable.
	$evalue = $my_args{$i};
	unless ( ($evalue =~ /^\de-\d+$/) || ($evalue =~ /^\d+\.?\d*$/) ) {
	    usage("Got a bad e-value: $evalue. Must be a number or in the form ne-m where n is an integer from 0 to 9 and m is an integer from 0 to 999");
	}
    }
    elsif ($i eq "-i") {
	#if it is not a number from 0.00 to 100.00, print an error message and exit program.
	#otherwise, populate $percent_identity variable.
	$percent_identity = $my_args{$i};
	unless ( $percent_identity =~ /^\d+\.?\d*$/ && $percent_identity >= 0 && $percent_identity <= 100 ) {
	    usage("Got a bad percent identity: $percent_identity. Must be a number from 0.00 to 100.00");
	}
    }
    elsif ($i eq "-b") {
	#if it is not a number from 0.00 to 1000.00, print an error message and exit program.
	#otherwise, populate $bitscore variable.
	$bitscore = $my_args{$i};
	unless ( $bitscore =~ /^\d+\.?\d*$/ && $bitscore >= 0 && $bitscore <= 1000 ) {
	    usage("Got a bad bit score: $bitscore. Must be a number from 0.00 to 1000.00");
	}
    }
    elsif ($i eq "-a") {
	#if it is not a whole number from 1 to 99999, print an error message and exit program.
	#otherwise, populate $align variable.
	$align = $my_args{$i};
	unless ( $align =~ /^\d*$/ && $align > 0 && $align <= 99999 ) {
	    usage("Got a alignment length: $align. Must be a whole number from 1 to 99999");
	}
    }
    elsif ($i eq "-c") {
	#if it is not "and" or "or", print an error message and exit program.
	#This argument is not case sensitive.
	#otherwise, populate $conjunction_flag variable.
	$conjunction_flag = lc($my_args{$i});
	unless ( $conjunction_flag eq "and" || $conjunction_flag eq "or" ) {
	    usage("Got a bad conjunction flag (-c): $conjunction_flag. Must be 'AND' or 'OR'");
	}
    }
    elsif ($i eq "-f") {
	#this should be a file, try and open it for reading. If cannot be opened, print an error message and exit program.
	$in_file = $my_args{$i};
	unless ( open(IN, "$in_file") ) {
	    usage("Got a bad input file: $in_file");
	}
    }
    elsif ($i eq "-o") {
	#if the character after the dash is a "o", get the information that comes after the -o and populate the $out_file variable.
	$out_file = $my_args{$i};
    }
    else {
	usage ("Unrecognized parameter: $i\n");
    }
}
#Try and open the ouput file for writing. If cannot be opened, print an error message and exit program.
unless ( open(OUT, ">$out_file") ) {
    usage("Got a bad output file: $out_file");
}
#if no -f parameter was passed, print an error message and exit program.
if ( $in_file eq "" ) {
    usage("Input file is required (-f<filename>).");
}
#if -e was not passed, and -i was not passed, print an error message and exit program.
if ( $evalue == -1 && $percent_identity == -1 && $bitscore == -1) {
    usage("The e-value, percent identity, and bit score cut offs have not been set. At least one of (-eN, -iN, -bN) is required to give this script something to do.");
}

#if -s was not passed, and -l was not passed, print an error message and exit program.
unless ( $flag eq "short" || $flag eq "long" ) {
    usage("Got a bad format flag: $flag. Must be '-s' or '-l'.");
}

#Print a warning if -a and -l parameters are found (-a does not work with the long format.)
if ( $flag eq "long" && $align > 0 ) {
    print "Warning: alignment length is non-functional with long format. The -a value will be ignored.\n";
}

#Everything looks good. Print the parameters we've found.
print "format flag = '$flag'\ne-value = '$evalue'\npercent identity = '$percent_identity'\nbit score = '$bitscore'\nconjunction flag = '$conjunction_flag'\nalignment length = '$align'\ninput file = '$in_file'\noutput file = '$out_file'\n";


#---------------------------------------------------------------------------------------------------------------------------
#The main event
#---------------------------------------------------------------------------------------------------------------------------
$timestamp = localtime(time);
print "start: $timestamp\n";
#Pass the information from the blast input file into an array of text lines.

#if its in short format
if ( $flag eq "short" ) {

    #Do stuff for each line of text in the blast input file.
    while (<IN>) {
	$line = $_;
	#if the line starts with a pound symbol, it is not real data, so skip this line.
	if ( $line =~ /^#/ ) {
	     #print OUT $line;
	     next;
	}
	chomp($line);
	($id, $orf, $this_percent_identity, $this_align, $mismatches, $gap, $qstart, $qend, $sstart, $send, $this_evalue, $this_bitscore) = split(/\t/, $line);

	if ( $percent_identity == -1 && $bitscore == -1) {
	    if ( ($this_align == -1 || $this_align >= $align) && $this_evalue <= $evalue ) { #return all the lines with evalues LESS than (or equal to) this one
		print OUT "$id\t$orf\t$this_percent_identity\t$this_align\t$mismatches\t$gap\t$qstart\t$qend\t$sstart\t$send\t$this_evalue\t$this_bitscore\n";
	    }
	}
	elsif ( $evalue == -1 && $bitscore == -1) {
	    if ( ($this_align == -1 || $this_align >= $align) && $this_percent_identity >= $percent_identity ) { #return all the lines with percent identities GREATER (or equal to) than this one
		print OUT "$id\t$orf\t$this_percent_identity\t$this_align\t$mismatches\t$gap\t$qstart\t$qend\t$sstart\t$send\t$this_evalue\t$this_bitscore\n";
	    }
	}
	elsif ( $percent_identity == -1 && $evalue == -1) {
	    if ( ($this_align == -1 || $this_align >= $align) && $this_bitscore >= $bitscore ) { #return all the lines with bit scores GREATER (or equal to) than this one
		print OUT "$id\t$orf\t$this_percent_identity\t$this_align\t$mismatches\t$gap\t$qstart\t$qend\t$sstart\t$send\t$this_evalue\t$this_bitscore\n";
	    }
	}
	elsif ( $bitscore == -1 && $conjunction_flag eq "or") {
	    if ( ($this_align == -1 || $this_align >= $align) && (($this_percent_identity >= $percent_identity) || ($this_evalue <= $evalue)) ) {
		print OUT "$id\t$orf\t$this_percent_identity\t$this_align\t$mismatches\t$gap\t$qstart\t$qend\t$sstart\t$send\t$this_evalue\t$this_bitscore\n";
	    }
	}
	elsif ($bitscore == -1)  {
	    if ( ($this_align == -1 || $this_align >= $align) && ($this_percent_identity >= $percent_identity) && ($this_evalue <= $evalue) ) {
		print OUT "$id\t$orf\t$this_percent_identity\t$this_align\t$mismatches\t$gap\t$qstart\t$qend\t$sstart\t$send\t$this_evalue\t$this_bitscore\n";
	    }
	}
	elsif ( $evalue == -1 && $conjunction_flag eq "or") {
	    if ( ($this_align == -1 || $this_align >= $align) && (($this_percent_identity >= $percent_identity) || ($this_bitscore >= $bitscore)) ) {
		print OUT "$id\t$orf\t$this_percent_identity\t$this_align\t$mismatches\t$gap\t$qstart\t$qend\t$sstart\t$send\t$this_evalue\t$this_bitscore\n";
	    }
	}
	elsif ( $evalue == -1 ) {
	    if ( ($this_align == -1 || $this_align >= $align) && ($this_percent_identity >= $percent_identity) && ($this_bitscore >= $bitscore) ) {
		print OUT "$id\t$orf\t$this_percent_identity\t$this_align\t$mismatches\t$gap\t$qstart\t$qend\t$sstart\t$send\t$this_evalue\t$this_bitscore\n";
	    }
	}
	elsif ( $percent_identity == -1 && $conjunction_flag eq "or") {
	    if ( ($this_align == -1 || $this_align >= $align) && (($this_bitscore >= $bitscore) || ($this_evalue <= $evalue)) ) {
		print OUT "$id\t$orf\t$this_percent_identity\t$this_align\t$mismatches\t$gap\t$qstart\t$qend\t$sstart\t$send\t$this_evalue\t$this_bitscore\n";
	    }
	}
	elsif ( $percent_identity == -1 ) {
	    if ( ($this_align == -1 || $this_align >= $align) && ($this_bitscore >= $bitscore) && ($this_evalue <= $evalue) ) {
		print OUT "$id\t$orf\t$this_percent_identity\t$this_align\t$mismatches\t$gap\t$qstart\t$qend\t$sstart\t$send\t$this_evalue\t$this_bitscore\n";
	    }
	}
	elsif ($conjunction_flag eq "or") {
	    if ( ($this_align == -1 || $this_align >= $align) && (($this_percent_identity >= $percent_identity) || ($this_bitscore >= $bitscore) || ($this_evalue <= $evalue)) ) {
		print OUT "$id\t$orf\t$this_percent_identity\t$this_align\t$mismatches\t$gap\t$qstart\t$qend\t$sstart\t$send\t$this_evalue\t$this_bitscore\n";
	    }
	}
	else {
	    if ( ($this_align == -1 || $this_align >= $align) && (($this_percent_identity >= $percent_identity) && ($this_bitscore >= $bitscore) && ($this_evalue <= $evalue)) ) {
		print OUT "$id\t$orf\t$this_percent_identity\t$this_align\t$mismatches\t$gap\t$qstart\t$qend\t$sstart\t$send\t$this_evalue\t$this_bitscore\n";
	    }
	}
    }
}
#if its in long format
elsif ( $flag eq "long") {
    @in = <IN>;
    #only run the program if -e is set, and -i is not. Otherwise, print the usage message and exit the program.
    if ( $percent_identity == -1 && $bitscore == -1) {
	#Loop through the lines in the input file.
	$i = 0;
	while ( $i < $#in ) {

	    #If the line starts with BLASTX or BLASTN, its the beginning of a new section:
	    if ( $in[$i] =~ /^BLASTX/ || $in[$i] =~ /^BLASTN/ ) { #section 1 (repeats)
		#make sure the list of ORFs is empty
		if ( $#ORFs >= 0 ) {
		    print "ERROR: ORF list isn't empty but it should be.\n";
		}
		@ORFs = ();

		#Then print out this line and any lines following it that start with the word "Query",
		#Until we get to a line that starts with "ORF" or contains the phrase "No hits found"
		while ( !($in[$i] =~ /^ORF/ || $in[$i] =~ /No hits found/) ) {
		    if ( $in[$i] =~ /^Query/ ) {
			print OUT $in[$i];
		    }
		    $i++;
		}

		#if its the phrase "No hits found", no hits to print. Skip the next three lines.
		if ($in[$i] =~ /No hits found/) {
		    $i = $i+3;
		}
	    }
	    #If the line starts with "ORF", we're in the next section.
	    elsif ( $in[$i] =~ /^ORF/ ) { #section 2 (repeats)
		#loop through lines until a line starting with ">" is reached.
		while ( !($in[$i] =~ /^>/) ) {
		    #if its a blank line, ignore it.
		    if ( $in[$i] =~ /^\n/ ) {
			#print OUT $in[$i];
		    }
		    else {
			#otherwise, if the line has an e-value <= the passed e-value, save it in the good ORF list, and print out the line.
			#Note: to the get the e-value we need to split on "one or more white space characters" = \s+
			#Note: if the the evalue starts with e, a 1 is added to the front so perl can recognize it as a number (e.g. e-20 becomes 1e-20).
			#The chomp commands removes any new line (and carriage return) characters from the end of the line.
			($this_ORF, $this_score, $this_evalue) = split(/\s+/, $in[$i]);
			if ( $this_evalue =~ /^e/ ) {
			    $this_evalue = 1 . $this_evalue;
			}
			chomp($this_evalue);
			if ( $this_evalue <= $evalue ) {
			    print OUT $in[$i];
			    push(@ORFs, $this_ORF);
			}
		    }
		    $i++;
		}
	    }
	    #If the line starts with ">" we're in the third section.
	    elsif ( $in[$i] =~ /^>/ ) { #section 3 (repeats)

		#get the ORF label after the ">" character (stripping off any "white space")
		$ORF = substr($in[$i],1);
		chomp($ORF);
		$ORF =~ s/\s+//g;

		#if this ORF label is in the ORF list, it has a good e-value;
		#Print this line and all of the lines until the next ">" or until "  Database:" (which is at the end of the file)
		#And delete it from the list.
		#When this section is completed, the ORF list should be empty.
		if ( isAMember($ORF, @ORFs) ) {
		    print OUT $in[$i];
		    @ORFs = grep(!/^$ORF/, @ORFs); #delete this one orf
		    $i++;
		    while ( !( ($in[$i] =~ /^>/) || ($in[$i] =~ /^\s\sDatabase:/) || ($in[$i] =~ /^BLASTX/ || $in[$i] =~ /^BLASTN/) ) ) {
			print OUT $in[$i];
			$i++;
		    }
		}
		#Otherwise, just loop through until the next ">" or until "  Database:" (which is at the end of the file)
		else {
		    $i++;
		    while ( !( ($in[$i] =~ /^>/) || ($in[$i] =~ /^\s\sDatabase:/) || ($in[$i] =~ /^BLASTX/ || $in[$i] =~ /^BLASTN/) ) ) {
			$i++;
		    }
		}
	    }
	    #End of the file. Print out the stuff at the bottom.
	    elsif ($in[$i] =~ /^\s\sDatabase:/) {
		print OUT $in[$i];
		$i++;
		if ( $in[$i] =~ /^\s\s\s\sPosted date:/ ) {
		    while ( $i < $#in ) {
			print OUT $in[$i];
			$i++;
		    }
		}
	    }
	    #Just in case something unexpected happens. (Pretty much any corruption in the file will cause this error to come up.)
	    else {
		print "Error: Found a weird (unexpected) line: $in[$i]\n";
		$i++;
	    }
	}
    }
    elsif ( $evalue == -1 ) {
	usage("Skimmer for long file format with -i or -b is not functional.");
    }
    elsif ( $conjunction_flag eq "or" ) {
	usage("Skimmer for long file format with -i or -b is not functional.");
    }
    else {
	usage("Skimmer for long file format with -i or -b is not functional.");
    }
}

#Close the files.
close(IN);
close(OUT);
$timestamp = localtime(time);
print "stop: $timestamp\n";
print "Done.\n";

#-----------------------------------------------------------------------------------------------------------------------------------------
#Subroutines
#-----------------------------------------------------------------------------------------------------------------------------------------
sub usage {
    my($message) = @_;
    print "\n$message\n";
    print "\nThis script \"skims\" BLAST output files in either \"long\" or \"short\" format, by extracting only\n";
    print "the hits that are below the provided e-value cut-off and/or above the provided percent identity\n";
    print "(short format only). The long format version of the blast output is created using the default blastall\n";
    print "and the short format version of the can be created by using blastall with the -m 9 parameter\n";
    print "\nUsage: skimmer.pl [-r l, -r s] [-e N, -i M, -b X -a A] [-c AND, -c OR] -f <filename> -o <output filename>\n";
    print "-r l = long format\n";
    print "-r s = short format\n";
    print "-e N, where N is the e-value cut off in the form ne-m where n is an integer from 0 to 9 and m is an integer from 0 to 999\n";
    print "-i M, where M is the percent identity cut off (0.00-100.00)\n";
    print "-b X, where X is the bit score (0.00-1000.00)\n";
    print "-a A, where A is the alignment length cut off (1-99999)\n";
    print "-c AND = e-value <= N AND percent identity >= M (-c is optional, -cAND is the default if both -e and -i are provided)\n";
    print "-c OR = e-value <= N OR percent identity >= M\n";
    print "Note: the (optional) -a value is always \"ANDed\" with -e and/or -i value(s)\n\n";
    print "-f <input filename> = the input file\n";
    print "-o <output filename> = the output file (optional. File name = 'outfile' is the default)\n\n";
    print "New to Version 2.1: parameters are now passed \"BLAST style\".\n";
    print "                    old version: -ffilename\n";
    print "                    new version: -f filename\n";
    print "                    old version: -s (for short format)\n";
    print "                    new version: -r s (for short format)\n";
    print "                    old version: -l (for long format)\n";
    print "                    new version: -r l (for long format)\n\n";
    print "Jennifer Meneghin\n";
    print "August 6, 2009\n";
    print "Last updated June 9, 2010\n";
    print "Last updated August 13, 2012\n";
    exit;
}

sub isAMember {
    my($element, @list) = @_;
    my($j);
    for $j (0..$#list) {
	if ($element eq $list[$j]) {
	    return 1;
	}
    }
    return 0;
}
