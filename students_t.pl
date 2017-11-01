#!/usr/bin/perl -w
############################
###   Student's t        ###
###   Jennifer Meneghin  ###
###   August 2, 2010     ###
############################
#----------------------------------------------------------------------------------------------------------------------
#Deal with passed parameters
#----------------------------------------------------------------------------------------------------------------------
if ($#ARGV == -1) {
    &usage;
}
$in_file = "";
$out_file = "students_t.txt";
%my_args = @ARGV;
for $i (sort keys %my_args) {
    if ($i eq "-i") {
	$in_file = $my_args{$i};
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
    print "\nGot a bad input file: $in_file\n\n";
    &usage;
}
if (-e $out_file) {
    print "\nOutput file $out_file already exists.\n\n";
    &usage;
}
unless ( open(OUT, ">$out_file") ) {
    print "\nGot a bad output file: $out_file\n\n";
    &usage;
}
print "Parameters:\ninput file = $in_file\noutput file = $out_file\n\n";
#-----------------------------------------------------------------------------------------------------------------
#The main event
#-----------------------------------------------------------------------------------------------------------------
%b_coefficients = ();
%standard_errors = ();
while (<IN>) {
    chomp;
    @fields = split(/\t/);
    $b_coefficients{$fields[0]} = $fields[1];
    $standard_errors{$fields[0]} = $fields[2];  
}
close(IN);
print OUT "Label 1\tLabel 2\tStudent's t\n";
foreach $i (sort keys %b_coefficients) {
    foreach $j (sort keys %b_coefficients) {
	if ($i lt $j) {
	    $se_sum_of_squares = $standard_errors{$i}**2 + $standard_errors{$j}**2;
	    $std_error_of_difference = sqrt($se_sum_of_squares);
	    if ($std_error_of_difference != 0) {
		$students_t = ($b_coefficients{$i} - $b_coefficients{$j}) / $std_error_of_difference;
	    }
	    else {
		$students_t = "ERROR: Can't divide by 0.";
	    }
	    print "$i\t$j\t$students_t\n";
	    print OUT "$i\t$j\t$students_t\n";
	}
    }
}
close(OUT);
sub usage {
    print "\nUsage: students_t.pl -i inputfile.txt -o outputfile.txt\n\n";
    print "Parameters:\n";
    print "-i input file\tA tabbed delimited file with column 1 = label, column 2 = b coefficients,\n";
    print "\t\tand column 3 = standard error (with no header line).\n\n";
    print "-o output file\tA new tabbed delimited file with column 1 = label 1, column 2 = label 2,\n";
    print "\t\tcolumn 3 = student's t test statistic, for all possible combinations found in the input file.\n";
    print "\t\t(Optional. Default = students_t.txt)\n\n";
    print "This program takes a tabbed delimited file with column 1 = label, column 2 = b coefficient,\n";
    print "and column 3 = standard error and returns a tab delimited file with column 1 = label 1,\n";
    print "column 2 = label 2, column 3 = student's t test statistic, for all possible combinations found\n";
    print "in the input file.\n\n";
    print "Jennifer Meneghin\n";
    print "August 2, 2010\n\n";
    exit;
}
