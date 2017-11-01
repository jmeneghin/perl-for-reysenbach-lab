#!/usr/bin/perl
#########################
### Jennifer Meneghin ###
### December 30, 2008 ###
#########################

print "This program converts a directory of sequence files into fasta format (with file name used as \">\" label, if it is not included in the file).\n";
print "Please enter the path of the directory that contains your sequences:\n";
$dir_name = <STDIN>;
chomp($dir_name);
if (!(-d $dir_name)) {
    print "$dir_name does not exist or is not a directory.\n";
    exit(1);
}
@files = <${dir_name}/*>;

print "Please enter the name (and path, if not current directory) of the fasta file to create:\n";
$out_file_name = <STDIN>;
chomp($out_file_name);
open(OUT, ">$out_file_name");

print "Is \">\" already included in the file? (y/n)\n";
$included = <STDIN>;
chomp($included);

if (!(lc($included) eq "y" || lc($included) eq "n")) {
    print "Please enter y or n.\n";
    exit(1);
}

foreach $file (@files) {
    $filename = $file;
    $filename =~ s/.+\/(.+)$/$1/g;
    print "adding $filename\n";
    if (lc($included) eq "n") {
      print OUT ">$filename\r\n";
    }
    open(IN, "$file");
    @fasta_lines = <IN>;
    foreach $fasta_line (@fasta_lines) {
	if (lc($included) eq "n" && $fasta_line =~ /^>/) {
	    next;
	}
	chomp($fasta_line);
	print OUT "$fasta_line\n";
    }
}
print "\nDone.\n";
close(OUT);


