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
  qw(version parse get_iso_date get_json_date get_rfc_date print_library_header print_library_transition print_playlist_header print_playlist_bottom print_library_bottom);

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

# A playlist is composed with :
# - a header,
# - a list of track keys,
# - a transition to playlist,
#  - a playlist header,
#  - a list of track id in this playlist,
#  - a playlist bottom,
# - a bottom.
sub print_library_header {
    print <<EOF;
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Major Version</key><integer>1</integer>
  <key>Minor Version</key><integer>1</integer>
  <key>Date</key><date>2013-03-23T19:04:19Z</date>
  <key>Application Version</key><string>11.0.2</string>
  <key>Features</key><integer>5</integer>
  <key>Show Content Ratings</key><true/>
  <key>Music Folder</key><string>file://localhost/Volumes/Black%20Box/Musique/Clean%20iTunes%20Library/iTunes%20Medi\
a/</string>
  <key>Library Persistent ID</key><string>02D9E46CD2385F44</string>
  <key>Tracks</key>
  <dict>
EOF
}

sub print_library_transition {
    print <<EOF;
  </dict>
  <key>Playlists</key>
  <array>
EOF
}

sub print_playlist_header {
    my $playlist_name = shift;
    print <<EOF;
    <dict>
      <key>Name</key><string>$playlist_name</string>
      <key>Playlist Items</key>
      <array>
        <dict>
EOF
}

sub print_playlist_bottom {
    print <<EOF;
        </dict>
      </array>
    </dict>
EOF
}

sub print_library_bottom {
    print <<EOF;
  </array>
</dict>
</plist>
EOF
}

1;
