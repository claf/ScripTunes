#!/opt/local/bin/perl

package Local::Routines;
use strict;
use warnings;
use Time::HiRes q/gettimeofday/;
use POSIX q/strftime/;
use Local::Debug qw(debug);
use Mac::iTunes::Library::XML;

use Exporter qw (import);
our @EXPORT_OK =
  qw(version parse library_summary get_iso_date get_json_date get_rfc_date);

sub version {
    my $print   = shift;
    my $program = shift;
    my $version = shift;

    if ($print) {
        print "$program ver. $version\n";
        exit;
    }
}

sub parse {
    my $file = shift;
    debug( "Loading Library : '$file'...", 2 );
    my $lib = Mac::iTunes::Library::XML->parse($file);
    debug( "Loaded " . $lib->num() . " tracks from library $file.", 2 );
    return $lib;
}

sub library_infos {
    my $library = shift;
    debug( "############ Library Infos ############\n", -1 );
    print( $library->artists() );
    debug( "############ End Infos ############\n", -1 );
}

sub library_summary {
    my ( $title, $library ) = @_;
    my %artists = $library->artist();
    my %albums  = $library->albumArtist();
    debug( "############ Library Summary ############\n", -1 );
    print( "Number of artists: " . scalar( keys %artists ) . " artists.\n" );
    print( "Number of albums: " . scalar( keys %albums ) . " albums.\n" );
    print( "Number of tracks: " . $library->num() . " tracks.\n" );
    print( "Version: " . $library->version() . "\n" );
    print( "Total size of the library: " . $library->size() . "\n" );
    print( "Total time of the library: " . $library->time() . "\n" );
    debug( "############ End Summary ############\n", -1 );
}

sub get_iso_date {

    # TODO : if arg then $now = shift, else $now = gettimeofday ();
    my $now = gettimeofday();
    my $tz = strftime( "%z", localtime($now) );
    $tz =~ s/(\d{2})(\d{2})/$1:$2/;
    return strftime( "%Y-%m-%dT%H:%M:%S", localtime($now) ) . $tz;
}

sub get_json_date {
    my $now = gettimeofday();
    my $tz = strftime( "%z", localtime($now) );
    $tz =~ s/(\+)(\d{2})(\d{2})/$2/;
    return substr(
        strftime( q/%Y-%m-%dT%H:%M:%S./, localtime( $now - ( 3_600 * $tz ) ) )
          . (gettimeofday)[1]
          . q/00000/,
        0, 23
    ) . "Z";
}

sub get_rfc_date {
    my $now = gettimeofday();
    return strftime( "%a, %d %b %Y %H:%M:%S %z", localtime($now) );
}
1;
