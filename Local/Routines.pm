#!/opt/local/bin/perl

package Local::Routines;
use strict;
use warnings;
use Time::HiRes q/gettimeofday/;
use POSIX q/strftime/;
use Local::Debug qw(debug);
use Mac::iTunes::Library::XML;

use Exporter qw (import);
our @EXPORT_OK = qw(version parse get_iso_date get_json_date get_rfc_date);

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
