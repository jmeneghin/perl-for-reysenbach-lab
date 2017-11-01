#!/usr/bin/perl -w
#############################
###   Jennifer Meneghin   ###
###   August 6, 2009      ###
#############################
#-----------------------------------------------------------------------------------------------------------------------------------------
#Deal with passed parameters
#-----------------------------------------------------------------------------------------------------------------------------------------
if ($#ARGV == -1) {
    &usage;
    exit;
}
$in0_file = $ARGV[0];
#/vol/share/alrlab/jennifer/metagenome/2007_rna/calcite_a/mRNA/12bac_found_3/calcite_mrna_2007a_skimB30_best.summary";

$in1_file = "/vol/share/alrlab/DATA/genomes/open_reading_frames/nucleotides/Aquifex_aeolicus_VF5.fasta";
$in2_file = "/vol/share/alrlab/DATA/genomes/open_reading_frames/nucleotides/Hydrogenivirga_128-5-R1-1.fasta";
$in3_file = "/vol/share/alrlab/DATA/genomes/open_reading_frames/nucleotides/Hydrogenobaculum_Y04AAS1.fasta";
$in4_file = "/vol/share/alrlab/DATA/genomes/open_reading_frames/nucleotides/Persephonella_marina_EX-H1.fasta";
$in5_file = "/vol/share/alrlab/DATA/genomes/open_reading_frames/nucleotides/Thermotoga_maritima_MSB8.fasta";
$in6_file = "/vol/share/alrlab/DATA/genomes/open_reading_frames/nucleotides/Thermus_aquaticus_Y5.1MC23.fasta";
$in7_file = "/vol/share/alrlab/DATA/genomes/open_reading_frames/nucleotides/Thermus_thermophilus_HB27.fasta";
$in8_file = "/vol/share/alrlab/DATA/genomes/open_reading_frames/nucleotides/Thermus_thermophilus_HB8.fasta";
$in9_file = "/vol/share/alrlab/DATA/genomes/open_reading_frames/nucleotides/Thermodesulfovibrio_yellowstonii_DSM11347.fasta";
$in10_file = "/vol/share/alrlab/DATA/genomes/open_reading_frames/nucleotides/Sulfurihydrogenibium_azorense_Az-Fu1.fasta";
$in11_file = "/vol/share/alrlab/DATA/genomes/open_reading_frames/nucleotides/Sulfurihydrogenibium_Y03AOP1.fasta";
$in12_file = "/vol/share/alrlab/DATA/genomes/open_reading_frames/nucleotides/Sulfurihydrogenibium_yellowstonense.fasta";
$out_file = "genome_maps.txt";
unless ( open(IN0, "$in0_file") ) { print "Got a bad input file: $in0_file\n"; exit; }
unless ( open(IN1, "$in1_file") ) { print "Got a bad input file: $in1_file\n"; exit; }
unless ( open(IN2, "$in2_file") ) { print "Got a bad input file: $in2_file\n"; exit; }
unless ( open(IN3, "$in3_file") ) { print "Got a bad input file: $in3_file\n"; exit; }
unless ( open(IN4, "$in4_file") ) { print "Got a bad input file: $in4_file\n"; exit; }
unless ( open(IN5, "$in5_file") ) { print "Got a bad input file: $in5_file\n"; exit; }
unless ( open(IN6, "$in6_file") ) { print "Got a bad input file: $in6_file\n"; exit; }
unless ( open(IN7, "$in7_file") ) { print "Got a bad input file: $in7_file\n"; exit; }
unless ( open(IN8, "$in8_file") ) { print "Got a bad input file: $in8_file\n"; exit; }
unless ( open(IN9, "$in9_file") ) { print "Got a bad input file: $in9_file\n"; exit; }
unless ( open(IN10, "$in10_file") ) { print "Got a bad input file: $in10_file\n"; exit; }
unless ( open(IN11, "$in11_file") ) { print "Got a bad input file: $in11_file\n"; exit; }
unless ( open(IN12, "$in12_file") ) { print "Got a bad input file: $in12_file\n"; exit; }
unless ( open(OUT, ">$out_file") ) { print "Got a bad output file: $out_file\n"; exit; }
#-----------------------------------------------------------------------------------------------------------------------------------------
#The main event
#-----------------------------------------------------------------------------------------------------------------------------------------
@list = {};
@list_pi = {};
@names = ("", "Aquifex_aeolicus_VF5", "Hydrogenivirga_128-5-R1-1", "Hydrogenobaculum_Y04AAS1", "Persephonella_marina_EX-H1", 
	  "Thermotoga_maritima_MSB8", "Thermus_aquaticus_Y5.1MC23", "Thermus_thermophilus_HB27", "Thermus_thermophilus_HB8", 
	  "Thermodesulfovibrio_yellowstonii", "Sulfurihydrogenibium_azorense_Az-Fu1", "Sulfurihydrogenibium_Y03AOP1", "Sulfurihydrogenibium_yellowstonense");
while (<IN0>) {
    chomp;
    @fields = split(/\t/);
    $id = $fields[0];
    $count = $fields[1];
    $percent_identity = $fields[2];
    $genome = "";
    if (@fields > 4) {
	$genome = $fields[4];
    }
    #Yes, I know I'm ignoring $list[0]. Its just for convenience/cleanness, and I can get away with it easily in lovely Perl. :)
    if ($genome eq "Aquifex aeolicus VF5") {
	$list[1]{$id} = $count;
	$list_pi[1]{$id} = $percent_identity;
    }
    elsif ($genome eq "Hydrogenivirga 128-5-R1-1") {
	$list[2]{$id} = $count;
	$list_pi[2]{$id} = $percent_identity;
    }
    elsif ($genome eq "Hydrogenobaculum Y04AAS1") {
	$list[3]{$id} = $count;
	$list_pi[3]{$id} = $percent_identity;
    }
    elsif ($genome eq "Persephonella marina EX-H1") {
	$list[4]{$id} = $count;
	$list_pi[4]{$id} = $percent_identity;
    }
    elsif ($genome eq "Thermotoga maritima MSB8") {
	$list[5]{$id} = $count;
	$list_pi[5]{$id} = $percent_identity;
    }
    elsif ($genome eq "Thermus aquaticus Y5.1MC23") {
	$list[6]{$id} = $count;
	$list_pi[6]{$id} = $percent_identity;
    }
    elsif ($genome eq "Thermus thermophilus HB27") {
	$list[7]{$id} = $count;
	$list_pi[7]{$id} = $percent_identity;
    }
    elsif ($genome eq "Thermus thermophilus HB8") {
	$list[8]{$id} = $count;
	$list_pi[8]{$id} = $percent_identity;
    }
    elsif ($genome eq "Thermodesulfovibrio yellowstonii") {
	$list[9]{$id} = $count;
	$list_pi[9]{$id} = $percent_identity;
    }
    elsif ($genome eq "Sulfurihydrogenibium azorense Az-Fu1") {
	$list[10]{$id} = $count;
	$list_pi[10]{$id} = $percent_identity;
    }
    elsif ($genome eq "Sulfurihydrogenibium Y03AOP1") {
	$list[11]{$id} = $count;
	$list_pi[11]{$id} = $percent_identity;
    }
    elsif ($genome eq "Sulfurihydrogenibium yellowstonense") {
	$list[12]{$id} = $count;
	$list_pi[12]{$id} = $percent_identity;
    }
    else {
	$list[13]{$id} = $count;
	$list_pi[13]{$id} = $percent_identity;
    }
}
for (my $i = 1; $i < 13; $i++) {
    print "$names[$i] ORF\t$names[$i] Count\t$names[$i] Avg. % Identity\n";
    print OUT "$names[$i] ORF\t$names[$i] Count\t$names[$i] Avg. % Identity\n";
    $file_handle = "IN" . $i;
    $genome_count = 0;
    while (<$file_handle>) {
	chomp;
	if (/^>/) {
	    $id = $_;
	    $id =~ s/^>(.+?)\s.+$/$1/g;
	    print "$id\t";
	    print OUT "$id\t";
	    if ($list[$i]{$id} && $list[$i]{$id} > 0) {
		print "$list[$i]{$id}\t$list_pi[$i]{$id}\n";
		print OUT "$list[$i]{$id}\t$list_pi[$i]{$id}\n";
		$genome_count = $genome_count + $list[$i]{$id};
	    }
	    else {
		print "0\n";
		print OUT "0\n";
	    }
	}
    }
    print "GENOME COUNT: $names[$i]\t$genome_count\n";
}
close(IN1);
close(IN2);
close(IN3);
close(IN4);
close(IN5);
close(IN6);
close(IN7);
close(IN8);
close(IN9);
close(IN10);
close(IN11);
close(IN12);
close(IN0);
close(OUT);
 
sub usage {
}
