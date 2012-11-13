#!/opt/local/bin/perl

package Local::Routines;
use strict;
use warnings;
use Local::Debug qw(debug);
use Mac::iTunes::Library::XML;

use Exporter qw (import);
our @EXPORT_OK = qw(version parse);

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
1;
