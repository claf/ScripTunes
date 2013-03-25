#!/opt/local/bin/perl

use strict;
use warnings;
use Local::Debug qw(debug debug_init);
use Local::Routines qw(version);

#allow is_integer and is_between :
use Data::Validate qw(:math);

# Now uses Getopt::Long instead of Getopt:Std :
use Getopt::Long qw{:config no_ignore_case no_auto_abbrev};

# Getopt::Long encourages the use of Pod::Usage to produce help messages :
use Pod::Usage;

my @progpath = split( /\//, $0 );
my $PROGNAME = $progpath[-1];
my $VER_NUM  = "0.1";

## If no arguments were given, then allow STDIN to be used only
## if it's not connected to a terminal (otherwise print usage)
pod2usage("$0: No files given.") if ( ( @ARGV == 0 ) && ( -t STDIN ) );

# iTunes XML Library :
my $library = '<stdin>';
if (@ARGV) {

    # don't use shift here becose '<>' seems to rely on @ARGV :
    $library = $ARGV[0];
}

while ( my $line = <> ) {
    if ( $line =~ /.*<key>Track ID<.*/ ) {
        print $line;
    }
    if ( $line =~ /.*<key>Location<.*/ ) {
        print $line;
    }
    if ( $line =~ /.*<key>Playlists<.*/ ) {
        last;
    }
}
