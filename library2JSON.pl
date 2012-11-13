#!/opt/local/bin/perl

use strict;
use warnings;
use Path::Abstract;
use Local::Debug qw(debug_init debug debug_switch);
use Local::Routines qw(version parse);

# Now uses Getopt::Long instead of Getopt:Std :
#use Getopt::Std;
use Getopt::Long qw{:config no_ignore_case no_auto_abbrev};

# Getopt::Long encourages the use of Pod::Usage to produce help messages :
use Pod::Usage;

use POSIX qw(strftime);

use Mac::iTunes::Library;
use Mac::iTunes::Library::XML;
use Mac::iTunes::Library::Item;

# Not Used :
#use Text::Wrap;

my @progpath = split( /\//, $0 );
my $PROGNAME = $progpath[-1];
my $VER_NUM  = "0.1";

# Options :
my $man     = 0;
my $help    = 0;
my $debug   = 0;
my $curl    = 0;
my $user    = '';
my $pass    = '';
my $version = '';
my $output  = '';

## Parse options and print usage if there is a syntax error,
## or if usage was explicitly requested.
GetOptions(
    'h|help|?'        => \$help,
    'm|man'           => \$man,
    'D|Debug+'        => \$debug,
    'c|curl'          => \$curl,
    'u|user=s'        => \$user,
    'p|pass=s'        => \$pass,
    'v|version'       => \$version,
    'o|output-file=s' => \$output
) or pod2usage(2);

pod2usage(1) if $help;
pod2usage( -verbose => 2 ) if $man;

## If no arguments were given, then allow STDIN to be used only
## if it's not connected to a terminal (otherwise print usage)
#pod2usage("$0: No files given.")  if ((@ARGV == 0) && (-t STDIN));

pod2usage("$0: No files given.") if ( @ARGV == 0 );

# Handle different options :
version( $version, $PROGNAME, $VER_NUM );

my $file = shift @ARGV;

debug_init($debug);
debug("Library is $file");

my $library = parse($file);

open( MYFILE, ">$output" );

use JSON::XS;
my $json = JSON::XS->new();

# Get the hash of items
my %items = $library->items();

my $now = time();

# We need to munge the timezone indicator to add a colon between the hour and minute part
my $tz = strftime( "%z", localtime($now) );
$tz =~ s/(\d{2})(\d{2})/$1:$2/;

# ISO8601
my $time = strftime( "%Y-%m-%dT%H:%M:%S", localtime($now) ) . $tz;

print MYFILE "{\n";
print MYFILE "\t\"library_file\" : \"$file\",\n";
print MYFILE "\t\"type\" : \"library\",\n";
print MYFILE "\t\"creation\" : \"$time\",\n";
print MYFILE "\t\"tracks\" : [\n";

my $number_id = 0;
my $json_init = 0;

foreach my $artist ( sort keys %items ) {
    debug( "foreach Artist : $artist", 2 );

    # $artistSongs is a hash-ref
    my $artistSongs = $items{$artist};

    # Dereference $artistSongs so that you can pass it to keys()
    # $songName is a key in the $artistSongs hash-ref
    foreach my $songName ( sort keys %$artistSongs ) {
        debug( "foreach Song Name $songName", 2 );

        # The songs are stored as an array, because there can
        # be multiple songs with identical names
        my $artistSongItems = $artistSongs->{$songName};

        # Go through all of the songs in the array-ref
        foreach my $song (@$artistSongItems) {

            #$number_id++;
            debug( "foreach Song $song (counter is $number_id)", 2 );

            if ( $json_init == 0 ) {
                $json_init = 1;

                #print MYFILE "\"$number_id\" : ";
                print MYFILE "\t\t"
                  . $json->allow_nonref->allow_blessed->convert_blessed
                  ->encode($song);
            }
            else {
                print MYFILE ",\n";

                #print MYFILE "\"$number_id\" : ";
                print MYFILE "\t\t"
                  . $json->allow_nonref->allow_blessed->convert_blessed
                  ->encode($song);
            }
        }
    }
}

print MYFILE "\n\t]\n}\n";

close(MYFILE);

debug("File $output created at $time.");

if ( $curl == 1 ) {
    my $cmd =
        'curl -X POST http://'
      . $user . ':'
      . $pass
      . '@scriptunes.netgrowing.net:5984/blogdb -d @'
      . $output
      . ' -H "Content-Type:application/json"';
    debug($cmd);

    #system $cmd;
}

__END__

=head1 NAME

library2JSON - let you extract an iTunes Library file into JSON format.

=head1 SYNOPSIS

library2JSON library.xml [-o file.json] [-c -u user -p pass]

=head1 OPTIONS

=over 8

=item B<-h, --help>

Print a brief help message and exits.

=item B<-m, --man>

Prints the manual page and exits.

=item B<-v, --version>

Print version number.

=item B<-c, --curl>

Create distant CouchDB document using curl.

=item B<-u, --user>

User name.

=item B<-p, --pass>

Password.

=item B<-o, --output-file file.json>

Write output to file.

=back

=head1 DESCRIPTION

This program generates a JSON output of an iTunes Library file.

=back

=head1 SEE ALSO

L<Mac::iTunes::Library::Item>.

=head1 COPYRIGHT

Copyright 2012 Christophe Laferriere.

Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.2 or
any later version published by the Free Software Foundation; with no
Invariant Sections, with no Front-Cover Texts, and with no Back-Cover
Texts.

=cut
