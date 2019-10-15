#!/usr/bin/perl -w
################################
### Jennifer Meneghin        ###
### August 10, 2010          ###
### Updated January 25, 2011 ###
################################

#---------------------------------------------------------------------------------------------------------------------------
#Deal with passed parameters
#---------------------------------------------------------------------------------------------------------------------------
#If no arguments are passed, show usage message and exit program.
if ($#ARGV == -1) {
    &usage;
}
%my_args = @ARGV;
$fasta_file = "";
$minimum_sequence_length = 50;
$poly_length = 8;
$remove_chimera_flag = 0;
for $i (sort keys %my_args) {
    if ($i eq "-f") {
	$fasta_file = $my_args{$i};
    }
    elsif ($i eq "-m") {
	$minimum_sequence_length = $my_args{$i};
	if ( !($minimum_sequence_length =~ /\d+/) ) {
	    print "\nBad minimum sequence length; must be an integer: $minimum_sequence_length\n\n";
	    &usage;
	}
    }
    elsif ($i eq "-p") {
	$poly_length = $my_args{$i};
	if ( !($poly_length =~ /\d+/) ) {
	    print "\nBad minimum poly(A/T) sequence length; must be an integer: $poly_length\n\n";
	    &usage;
	}
    }
    elsif ($i eq "-c") {
	$remove_chimera_flag = $my_args{$i};
	if ($remove_chimera_flag != 0 && $remove_chimera_flag != 1) {
	    print "Bad flag: -c must be 1 or 0. Found: $remove_chimera_flag\n\n";
	    &usage;
	}
    }
    else {
	print "\nUnrecognized paramater: $i $my_args{$i}\n\n";
	&usage;
    }
}
unless ( open(FASTA, "$fasta_file") ) {    
    print "\nGot a bad fasta file: $fasta_file\n\n";
    &usage;
}
if ( -e "${fasta_file}.salvaged" ) {
    print "\nCouldn't create ${fasta_file}.salvaged file because it already exists.\n\n";
    &usage;
}
unless ( open(SALVAGED, ">${fasta_file}.salvaged") ) {
    print "\nCouldn't open ${fasta_file}.salvaged file for writing\n\n";
    &usage;
}
if ( -e "${fasta_file}.removed" ) {
    print "\nCouldn't create ${fasta_file}.removed file because it already exists.\n\n";
    &usage;
}
unless ( open(REMOVED, ">${fasta_file}.removed") ) {
    print "\nCouldn't open ${fasta_file}.removed file for writing\n\n";
    &usage;
}
#Everything looks good. Print the parameters we've found.
print "Parameters:\nfasta file = $fasta_file\nminimum sequence length = $minimum_sequence_length\nminimum Poly(A/T) length = $poly_length\n\n";
#---------------------------------------------------------
#The main event
#---------------------------------------------------------
$header = "";
$string = "";
$stringa = "(A|X|N){$poly_length}";
$stringt = "(T|X|N){$poly_length}";
$count_removed = 0;
$count_chimera = 0;
$count_too_short = 0;
$count_salvaged = 0;
$count_total = 0;
$count_trimmed = 0;

while(<FASTA>) {
    if (/^>/) {
	&trim_it;
	$string = "";
	$header = $_;
    }
    else {
	chomp;
	$string = $string . $_;
    }
}
&trim_it;

close(FASTA);
close(SALVAGED);
close(REMOVED);

print "REMOVED = $count_removed\n";
print "REMOVED TOO SHORT = $count_too_short\n";
if ($remove_chimera_flag == 1) {
    print "REMOVED CHIMERA = $count_chimera\n";
}
#else {
#    print "FOUND CHIMERA (not removed) = $count_chimera\n";
#}
print "SALVAGED = $count_salvaged\n";
print "TRIMMED = $count_trimmed\n";
print "TOTAL = $count_total\n";

#--------------------------------------------------------
#Subroutines
#--------------------------------------------------------
sub trim_it {
    if (length($header) > 0 && length($string) > 0) {
	if ($string =~ /$stringa/ || $string =~ /$stringt/) {
	    #print "FOUND A POLY(A/T): $string\n";
	    if ($string =~ /^$stringa/) {
		@letters = split(//, $string);
		for $i (0..$#letters) {
		    if ($letters[$i] ne "A" && $letters[$i] ne "N" && $letters[$i] ne "X") {
			$string = substr $string, $i;
			#print "substr $string $i\n";
			last;
		    }
		}
		$count_trimmed++;
		print "trimmed front Poly(A): $header\n";
		#print "NEW STRING: $string\n";
	    }
	    if ($string =~ /^$stringt/) {
		@letters = split(//, $string);
		for $i (0..$#letters) {
		    if ($letters[$i] ne "T" && $letters[$i] ne "N" && $letters[$i] ne "X") {
			$string = substr $string, $i;
			#print "substr $string $i\n";
			last;
		    }
		}
		$count_trimmed++;
		print "trimmed front Poly(T): $header\n";
		#print "NEW STRING: $string\n";
	    }
	    if ($string =~ /$stringa$/) {
		@letters = split(//, $string);
		$length = length($string);
		for $i (0..$#letters) {
		    if ($letters[$#letters-$i] ne "A" && $letters[$#letters-$i] ne "N" && $letters[$#letters-$i] ne "X") {
			$string = substr $string, 0, $length;
			#print "substr $string 0 $length\n";
			last;
		    }
		    $length--;
		}
		$count_trimmed++;
		print "trimmed end Poly(A): $header\n";
		#print "NEW STRING: $string\n";
	    }
	    if ($string =~ /$stringt$/) {
		@letters = split(//, $string);
		$length = length($string);
		for $i (0..$#letters) {
		    if ($letters[$#letters-$i] ne "T" && $letters[$#letters-$i] ne "N" && $letters[$#letters-$i] ne "X") {
			$string = substr $string, 0, $length;
			#print "substr $string 0 $length\n";
			last;
		    }
		    $length--;
		}
		$count_trimmed++;
		print "trimmed end Poly(T): $header\n";
		#print "NEW STRING: $string\n";
	    }
	    if ( length($string) < $minimum_sequence_length) {
		print REMOVED $header;
		print REMOVED "$string\n";
		print "Removed too short: $header\n";
		$count_removed++;
		$count_too_short++;
		$count_total++;
	    }
	    elsif ( ($string =~ /$stringa/) || ($string =~ /$stringt/) ) {
		if ($remove_chimera_flag == 1) {
 		    print REMOVED $header;
		    print REMOVED "$string\n";
		    print "Removed as chimera (Poly(A/T) in middle): $header\n";
		    $count_removed++;
		    $count_chimera++;
		    $count_total++;
		}
		else {
 		    print SALVAGED $header;
		    print SALVAGED "$string\n";
		    #print "Found chimera (Poly(A/T) in middle). Did not remove: $header\n";
		    $count_salvaged++;
		    $count_chimera++;
		    $count_total++;
		}
	    }
	    else {
		print SALVAGED $header;
		print SALVAGED "$string\n";
		print "Salvaged after trim: $header\n";
		$count_salvaged++;
		$count_total++;;
	    }
	    #print "\n";
	}
	else {
	    print SALVAGED $header;
	    print SALVAGED "$string\n";
	    $count_salvaged++;
	    $count_total++;;
	}	    
    }
}

sub usage {
    print "Usage: trim_fasta.pl -f fasta_file -m integer -p integer -c 1\n\n";
    print "Parameters:\n";
    print "-f fasta_file:\tThe fasta file to trim.\n";
    print "-m integer:\tThe minimum length allowed for a fasta record. (Optional. Default is 50.)\n";
    print "-p integer:\tThe minimum length of a Poly(A/T) sequence. (Optional. Default is 8.)\n";
    print "-c 1\t\t1 = Remove sequences with Poly(A/T) in the middle of the sequence, 0 = Don't remove.\n";
    print "\t\t(Optional. Default is 0 = Don't remove.)\n\n";
    print "This script trims any Poly(A/T) tails from the beginning and end of each sequence,\n";
    print "then removes the sequence if it's length is less than the minimum number provided (-m integer).\n";
    print "If -c is set to 1, it also removes any sequences with a Poly(A/T) sequence in the middle of the sequence (assumed to be chimera).\n\n";
    print "A Poly(A/T) sequence is defined as a Poly(A) or a Poly(T) sequence.\n";
    print "A Poly(A) sequence is defined as (-p integer) or more consecutive As, Xs or Ns.\n";
    print "A Poly(T) sequence is defined as (-p integer) or more consecutive Ts, Xs or Ns.\n";
    print "Please run homopolymer_count.pl to help you decide the most appropriate length of Poly(A/T) sequence for your dataset.\n\n";
    print "It returns two new fasta files: one with the removed sequences (fasta_file.removed), and one with the salvaged sequences (fasta_file.salvaged).\n\n";
    print "Jennifer Meneghin\n";
    print "08/10/2010\n";
    print "Updated 01/25/2011\n\n";
    exit;
}
