#!/opt/local/bin/perl

use strict;
use warnings;
use Path::Abstract;

# Now uses Getopt::Long instead of Getopt:Std :
#use Getopt::Std;
use Getopt::Long qw{:config no_ignore_case no_auto_abbrev};

# Getopt::Long encourages the use of Pod::Usage to produce help messages :
use Pod::Usage;

# Not Used :
#use Text::Wrap;

my @progpath=split (/\//, $0);
my $PROGNAME=$progpath[-1];
my $VER_NUM="0.2";

my $man = 0;
my $help = 0;

# Options :
my $verbose = '';
my $version = '';
my $count = '';
my $prefix = '/';

sub verbose_print
{
    my $string = shift;
    if ($verbose)
    {
	print $string;
    }
}

## Configuring Text::Wrap :
#$Text::Wrap::columns = 72;

# Get every option on the command line :
#my %opts = ();
#getopts('Vvhnp:',\%opts) or print_usage();


## Parse options and print usage if there is a syntax error,
## or if usage was explicitly requested.
GetOptions ('h|help|?'  => \$help,
	    'm|man'     => \$man,
	    'V|Verbose' => \$verbose,
	    'v|version' => \$version,
	    'c|count!'  => \$count,
	    'p|prefix=s'=> \$prefix) or pod2usage(2);

pod2usage(1) if $help;
# garanty there will be something on the command line :
pod2usage(-verbose => 0) unless @ARGV;
pod2usage(-verbose => 2) if $man;

## If no arguments were given, then allow STDIN to be used only
## if it's not connected to a terminal (otherwise print usage)
#pod2usage("$0: No files given.")  if ((@ARGV == 0) && (-t STDIN));


# Handle different options :
if ($version)
{
    print "$PROGNAME ver. $VER_NUM\n";
    exit;
}

# iTunes XML Library :
my $library;

# Hashmap containing new directories at given depth (see prefix) :
my %newloc;

if (scalar @ARGV != 1)
{
  pod2usage(-verbose => 0);
} else {
  $library = shift @ARGV;
}

verbose_print ("Verbose output set to true\n");
verbose_print ("Prefix set to : $prefix\n");
verbose_print ("MP3 count set to : $count\n");
verbose_print ("In Library file : $library\n");

open(FILEHANDLER, $library) or die $!;
my $nb_mp3 = 0;

while (my $line = <FILEHANDLER>)
{
    if ($line =~ /.*<key>Location.*/)
    {
      verbose_print ($prefix . "    &&&    " . $line ."\n");

      if ($line =~ /.*localhost$prefix.*/)
      {
	  $nb_mp3++;
	  my @path = split (/\/\/localhost/, $line);
	  #print $path[1] . "\n";
	  my @path2 = split (/\//, $prefix);
	  my $count = scalar @path2;
	  if ($count == 0 ) {
        $count = 1;
      }
      my @path3 = split (/\//, $path[1]); 
      #print $path3[$count] . "    &&    " . $count . "\n";

      if ($newloc{$path3[$count]})
      {
        $newloc{$path3[$count]}++;
      } else {
        #print "Adding new location : $path3[$count] (count = $count)\n";
        $newloc{$path3[$count]} = 1;
      }
    }
    }
  }

  foreach my $path_final ( sort keys %newloc) {
    #my $nicepath = trim (/localhost/, $$path_final);
    my $finalpath = Path::Abstract->new( $prefix . "/" . $path_final );

    print "$finalpath : " . $newloc{$path_final} . " tracks\n";
}

close (FILEHANDLER);

__END__

=head1 NAME

libraryPath - let you find every path in a iTunes Library

=head1 SYNOPSIS

libraryPath [-Vvhmc] iTuneLibrary.xml [-p /prefix]

=head1 OPTIONS

=over 8

=item B<-h, --help>

Print a brief help message and exits.

=item B<-m, --man>

Prints the manual page and exits.

=item B<-V, --Verbose>

Print more informations during execution.

=item B<-v, --version>

Print version number.

=item B<-c, --count>

Print the number of tracks in parent folder.

=item B<-p, --prefix path>

Use prefix as path to digg into XML file.

=back

=head1 DESCRIPTION

This program allow an iTunes user to digg into an iTunes XML file. The
output will list every folder containing music tracks (together with
the track count form a given parent folder (prefix).

=head1 SEE ALSO

L<perlpod>, L<perldoc>, L<Getopt::Long>, L<Pod::Usage>.

=head1 COPYRIGHT

Copyright 2012 Christophe Laferriere.

Permission is granted to copy, distribute and/or modify this 
document under the terms of the GNU Free Documentation 
License, Version 1.2 or any later version published by the 
Free Software Foundation; with no Invariant Sections, with 
no Front-Cover Texts, and with no Back-Cover Texts.

=cut
