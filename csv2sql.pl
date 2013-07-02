#!/usr/bin/perl

###############################################################################
#                                                                             #
# Writen by: g33k                                                             #
# Contacts:  g33k@seznam.cz                                                   #
#            g33k@jabber.org                                                  #
# Date:      16.12.2008                                                         #
#                                                                             #
# This program is free software; you can redistribute it and/or               #
# modify it under the terms of the GNU General Public License                 #
# as published by the Free Software Foundation; either version 2              #
# of the License, or (at your option) any later version.                      #
#                                                                             #
# For bug reports and suggestions or if you just want to talk to me please    #
# contact me at g33k@seznam.cz                                                #
#                                                                             #
###############################################################################

use Getopt::Long;

sub usage {
    local ($errMsg);
    $errMsg = @_[0];
    
    print $errMsg;
    print "
---------------------------------------------
      $NAME $VERSION
---------------------------------------------
usage:

$NAME [--csv FILENAME] [--sql FILENAME] [--separator CHARACTER] [--table TABLENAME]
[--help] [--version] 

--csv <input file> - path to file you want process.  
--sql <output file> - path to output file.
--table <tabel name> - name of the sql table.
--separator character - you can specifi own separation character, like ; or : 
                        because ,(comma) is used mostly in windows envinment.          
--version - print version
--help - print short help (you exactly looking at those help)         
\n";
  die;
}

#csv2html
#--------
#Input parametr(s): global variable @lines
#Output: modified global variable @lines
#Modifi @lines from form comma separated to html table.
sub csv2sql {
  foreach $line (@lines) {
    $line =~ s/\n//g;
    $line =~ s/$SP$//g;
    @splitedline = split ("$SP",$line);
    foreach $col (@splitedline) {
      if (!($col =~ /^([0-9])*$/)) {
        $col = "\'".$col."\'";
      }
      elsif ($col == '') {
        $col = 'NULL';
      }
    }
    $line = join ($SP,@splitedline);
    $line =~ s/$SP/,/g;
    $line = "INSERT INTO $table_name VALUES ($line);\n";
  }
}

#MAIN PROGRAM

$NAME="csv2sql";
$VERSION="1.0";
$sql_file=undef;
$csv_file=undef;
#SP=separator
$SP=",";
  
# Parse and process options
if (!GetOptions(\%optctl,
	'sql=s', 'csv=s', 'separator=s', 'table=s', 
  'help', 'version',
	)
	|| $optctl{help} == 1 || $optctl{version} == 1 )
{
    if ($optctl{version} == 1)
    {
		  print "$NAME version $VERSION (csv to sql)\n\t writen by g33k\@seznam.cz\n\n";
      exit;
    }
    elsif ($optctl{help} == 1) {
      &usage();
    }     
}

#Handel input/outputfiles check them and if something is wrong end with error message
if (defined($optctl{'sql'})) { $sql_file = $optctl{'sql'}; }
if (defined($optctl{'csv'})) { $csv_file = $optctl{'csv'}; }
if (defined($optctl{'separator'})) { $SP = $optctl{'separator'}; }

#check if input is standard or file
if (defined($csv_file)) {
  open(CSVFILE, $csv_file) or usage("Can't open $filename: $!");
  @lines=<CSVFILE>;
  close(CSVFILE);
}
else {
  @lines=<STDIN>;
}

&csv2sql();

#check if output is standar or file
if (defined($sql_file)) {
  open(OUTPUT, ">$sql_file") or usage("Can't open $filename: $!");
  print OUTPUT @lines;
  close(OUTPUT);
}
else {
  print @lines;
}
