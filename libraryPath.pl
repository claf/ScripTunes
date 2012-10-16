#!/usr/bin/perl

use strict;
use warnings;

my @progpath=split (/\//, $0);
my $PROGNAME=$progpath[-1];

sub print_usage()
{
  print "Usage : ./$PROGNAME bibliotheque.xml [/prefix]\n";
  print "\tcherche tous les chemins de niveau \"profondeur\" differents dans
  bibliotheque.xml\n";
  exit ();
}

my $input_directory;

my %newloc;
my $prefix = "localhost";

if (scalar @ARGV < 1)
{
  print_usage();
} else {
  $input_directory = shift @ARGV;
  if (scalar @ARGV == 2) {
    $prefix .= shift @ARGV;
  }

  #print $prefix;
}

  
  open(FILEHANDLER, $input_directory) or die $!;
  my $nb_mp3 = 0;

  while (my $line = <FILEHANDLER>)
  {
    if ($line =~ /.*<key>Location.*/)
    {
      #print $prefix . "    &&&    " . $line ."\n";
      if ($line =~ /.*$prefix.*/) {
      $nb_mp3++;
      #print $nb_mp3 . "\n";
      my @path = split (/\/\//, $line);
      #print $path[1] . "\n";
      my @path2 = split (/\//, $prefix);
      my $count = scalar @path2;
      
      my @path3 = split (/\//, $path[1]); 
      #print $path3[$count] . "    &&    " . $count . "\n";

      if ($newloc{$path3[$count]})
      {
        $newloc{$path3[$count]}++;
      } else {
        $newloc{$path3[$count]} = 1;
      }
    }
    }
  }
  
  foreach my $path_final ( sort keys %newloc) {
    print $path_final . " : " . $newloc{$path_final} . "\n";
  }

  close (FILEHANDLER);
