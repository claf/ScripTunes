#!/usr/bin/perl

use strict;
use warnings;


sub print_usage()
{
  print "Usage : ./scrit.pl bibliotheque.xml profondeur\n";
  print "\tcherche tous les chemins de niveau \"profondeur\" differents dans
  bibliotheque.xml\n";
  exit ();
}

my $input_directory;

my %newloc;
my $depth;

if (scalar @ARGV < 2)
{
  print_usage();
} else {
  $input_directory = shift @ARGV;
  $depth = shift @ARGV;
}

  
  open(FILEHANDLER, $input_directory) or die $!;
  my $nb_mp3 = 0;

  while (my $line = <FILEHANDLER>)
  {
    if ($line =~ /.*<key>Location.*/)
    {
      $nb_mp3++;
      #print $nb_mp3 . "\n";
      my @path = split (/\/\//, $line);
      #print $path[1] . "\n";
      my @path2 = split (/\//, $path[1]);
      if ($newloc{$path2[$depth]})
      {
        $newloc{$path2[$depth]}++;
      } else {
        $newloc{$path2[$depth]} = 1;
      }
    }
  }
  
  foreach my $path_final ( sort keys %newloc) {
    print $path_final . " : " . $newloc{$path_final} . "\n";
  }

  close (FILEHANDLER);
