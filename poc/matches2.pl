#!/opt/local/bin/perl

use strict;
use warnings;
use Path::Abstract;
use Local::Debug qw(debug debug_init);
use Local::Routines
  qw(version print_library_header print_library_transition print_playlist_header print_playlist_bottom print_library_bottom);

#allow is_integer and is_between :
use Data::Validate qw(:math);

# On demand export :
#use Routines qw(dummy);
#dummy ();

# Now uses Getopt::Long instead of Getopt:Std :
use Getopt::Long qw{:config no_ignore_case no_auto_abbrev};

# Getopt::Long encourages the use of Pod::Usage to produce help messages :
use Pod::Usage;

my @progpath = split( /\//, $0 );
my $PROGNAME = $progpath[-1];
my $VER_NUM  = "0.1";

# Options :
my $man         = 0;
my $help        = 0;
my $debug       = 0;
my $version     = '';
my $count       = 0;
my $name        = '';
my $show_rating = 0;
my $show_dir    = 0;
my $found       = 0;

## Parse options and print usage if there is a syntax error,
## or if usage was explicitly requested.
GetOptions(
    'h|help|?'    => \$help,
    'm|man'       => \$man,
    'D|Debug+'    => \$debug,
    'v|version'   => \$version,
    'c|count'     => \$count,
    'n|name=i'    => \$name,
    'r|ratings'   => \$show_rating,
    'd|directory' => \$show_dir,
    'f|found'     => \$found
) or pod2usage(2);

pod2usage(1) if $help;
pod2usage( -verbose => 2 ) if $man;

# Handle different options :
version( $version, $PROGNAME, $VER_NUM );

## If no arguments were given, then allow STDIN to be used only
## if it's not connected to a terminal (otherwise print usage)
pod2usage("$0: No files given.") if ( ( @ARGV == 0 ) && ( -t STDIN ) );

debug_init($debug);

# iTunes XML Library :
my $library = '<stdin>';
if (@ARGV) {

    # don't use shift here becose '<>' seems to rely on @ARGV :
    $library = $ARGV[0];
}

# Hashmap containing new directories at given depth (see prefix) :
my %newloc;

debug("Debug output set to $debug");

#debug("Prefix set to : $prefix");
debug("MP3 count set to : $count");
debug("In Library file : $library");

my $nb_mp3 = 0;

# No more need to open the file since '<>':
#open(FILEHANDLER, $library) or die $!;
#while (my $line = <FILEHANDLER>)

# Wether or not we're looking for the next rated song (otherwhise we
# look for the location of the current rated track.
my $is_rating = 1;

# Rating of the current rated song :
my $rating = 0;

# TrackID of the current processed track :
my $trackID = 0;

my $total_nf  = 0;
my $total_dup = 0;

open( FILE, "striplib.xml" );
my @in = <FILE>;

my @Ids;
my %Loc;

while ( my $line = <> ) {
    chomp $line;
    my $found = 0;
    foreach my $location (@in) {

        # Remember track ID :
        if ( $location =~ /.*<key>Track ID<.*/ ) {
            $trackID = $location;
            $trackID =~ s/[^0-9]//g;
        }
        if ( $location =~ /\Q$line\E/ ) {
            $found++;

        #print "found ($found) " . $line . " matches $location with $trackID\n";
            if ( $found > 1 ) {
                print STDERR "Duplicate : " . $line . "\n";
                $total_dup++;
            }
            push( @Ids, $trackID );
            $Loc{$trackID} = $location;
        }
    }
    if ( $found == 0 ) {
        $total_nf++;
        print STDERR "Not Matched ($total_nf) : " . $line . "\n";
    }
}

print STDERR "Total tracks not found : $total_nf\n";
print STDERR "Total tracks duplicate : $total_dup\n";

sub print_track_keys {
    foreach my $id (@Ids) {
        print "     <key>$id</key>\n";
        print "       <dict>\n";
        print "           <key>Track ID</key><integer>$id</integer>\n";
        print $Loc{$id};
        print "       </dict>\n";
    }
}

sub print_track_id {
    foreach my $id (@Ids) {
        print "           <key>Track ID</key><integer>$id</integer>\n";
    }
}

my $rate = 30;

print_library_header();

print_track_keys();

print_library_transition();

print_playlist_header( $name . " stars" );
print_track_id();
print_playlist_bottom();

print_library_bottom();

close(FILE);

#foreach my $path_final ( sort keys %newloc ) {
#    my $finalpath = Path::Abstract->new( $prefix . "/" . $path_final );
#    print "$finalpath\t: " . $newloc{$path_final} . " tracks\n";
#}

#close (FILEHANDLER);

__END__

=head1 NAME

libraryPath - let you find every path in a iTunes Library

=head1 SYNOPSIS

libraryPath [-Dvhmc] iTuneLibrary.xml [-p /prefix]

=head1 OPTIONS

=over 8

=item B<-h, --help>

Print a brief help message and exits.

=item B<-m, --man>

Prints the manual page and exits.

=item B<-D, --Debug>

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

Permission is granted to copy, distribute and/or modify this  document
under the terms of the GNU Free Documentation  License, Version 1.2 or
any later version published by the  Free Software Foundation; with no
Invariant Sections, with  no Front-Cover Texts, and with no Back-Cover
Texts.

=cut
