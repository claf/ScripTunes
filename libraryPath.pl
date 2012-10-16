#!/opt/local/bin/perl

use strict;
use warnings;
use Path::Abstract;



my @progpath=split (/\//, $0);
my $PROGNAME=$progpath[-1];

sub print_usage()
{
  print "Usage : ./$PROGNAME iTuneLibrary.xml [/prefix]\n";
  print "\n\tThis program allow an iTunes user to digg into an iTunes XML";
  print "\n\tfile. The output will list every folder containing music tracks";
  print "\n\t(together with the track count form a given parent folder";
  print "\n\t(prefix).\n";
  exit ();
}

# iTunes XML Library :
my $library;

# Hashmap containing new directories at given depth (see prefix) :
my %newloc;

# Default prefix if "localhost" :
my $prefix = "/";

if (scalar @ARGV < 1)
{
  print_usage();
} else {
  $library = shift @ARGV;
  if (scalar @ARGV == 1) {
    $prefix = shift @ARGV;
  }

  print "In file $library : \n\tprefix : $prefix\n";
}

  
  open(FILEHANDLER, $library) or die $!;
  my $nb_mp3 = 0;

  while (my $line = <FILEHANDLER>)
  {
    if ($line =~ /.*<key>Location.*/)
    {
      #print $prefix . "    &&&    " . $line ."\n";
      if ($line =~ /.*localhost$prefix.*/) {
      $nb_mp3++;
      #print $nb_mp3 . "\n";
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
