#!/usr/bin/perl -w

#----------
# Script snippets for future use
#----------


#-----------------------------
# DATABASES
#-----------------------------

# Use the DBI module to connect to a database
use DBD::Oracle;

# Read the password from prompt
use Term::ReadKey;
print "Enter DB password:";
ReadMode('noecho'); # don't echo
chomp(my $password = <STDIN>);
ReadMode(0);        # back to normal

# Connect to the database - for number of Quotes and Purchased Policies
my $db = DBI->connect("dbi:Oracle:<ORACLE SID>", '<SCHEMA>', $password, {RaiseError => 1, AutoCommit => 0}) || die "Can't connect to Oracle database: $DBI::errstr\n";

#SQL staement
$sql = "SELECT SYSDATE FROM DUAL";

# Prepare the SQL statement
unless ($select = $db->prepare("$sql")){
  print "\nCould not prepare statement: $DBI::errstr\n";
}

# Execute the SQL statement
unless ($select->execute){
  $db->rollback;
  $db->disconnect;
  print "\nCould not execute statement: $DBI::errstr\n";
}

# Perform a commit
$db->commit;

# Fetch the results into an array
@pwarray = $select->fetchrow_array;

# Finish and disconnect from the database
unless ($select->finish) {
  $db->rollback;
  $db->disconnect;
  print "Could not finish statement: $sql - $DBI::errstr";
}
unless ($db->disconnect) {
  print "Can't disconnect from Oracle database: $DBI::errstr";
}

output(1, $pwarray[0] . " " . $pwarray[1] . " " . $pwarray[2]);


#-----------------------------
# TIME/DATE
#-----------------------------

# Set up time variables
# Today
my(undef(), $todayEndMin, $todayEndHour, $todayEndDay, $todayEndMonth, $todayEndYear, undef(), undef(), undef()) = localtime();





#-----------------------------
# FILES
#-----------------------------

# File to open in browser once the file has been written to
$htmlreport = "C:/status.htm";

# Output message to waiting user
output(1, "\nReport should appear in a new window in under 10 seconds");

# Get the date and time for the report
$reportdate = nicedate();

# Open the output file for writing
open(HTML, ">$htmlreport") || output(1, "Can't open the html file\n$!");

# Output the html header data
print HTML <<HTMLOUT;
<html>
 <head>
  <title>Status</title>
 </head>
 <body>
  <h3>Report generated: $reportdate</h3>
HTMLOUT


# Print HTML footer
print HTML <<HTMLOUT;
 </body>
</html>
HTMLOUT

# Close the HTML file
close(HTML);

# Open the report in the browser
system("start \"null\" \"$htmlreport\"");

#####
# SUBROUTINES
#####

# Routine to handle output and fatal errors
# ARGUMENTS: <error number> <output message>
sub output {
    my $option = $_[0];
    my $msg    = $_[1];

    if ($option == 1) {
        ## Output to screen
        print "$msg\n";
    }
    elsif ($option == 2) {
        ## Output to log
        print LOGFILE "$msg\n";
    }
    elsif ($option == 3) {
        ## Output to both screen and log
        print "$msg\n";
        print LOGFILE "$msg\n";
    }
    elsif ($option == 9) {
        ## Output to both screen and log, then fail
        print "$msg\n";
        print "\n$!";
        print LOGFILE "$msg\n";
        print LOGFILE "\n$!";
        exit(1);
    }
}

# Routine to produce a nicely formatted date
# ARGUMENTS: NONE
sub nicedate {

    # Prepare the data arrays
    my @days = ('Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday');
    my @months = ('January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December');
    my($sec, $min, $hour, $day, $mon, $year, $wday, undef(), undef()) = localtime();

    # Add preceeding zeros to days
    if ($min < 10) {
        $min = "0" . $min;
    }
    $wday = $days[$wday];
    $mon  = $months[$mon];
    $year = $year + 1900;    ## The years output by localtime() are from 1900

    $nicedate = "$wday $day $mon $year $hour:$min";    
  return $nicedate;
}
