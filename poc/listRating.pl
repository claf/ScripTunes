#!/opt/local/bin/perl

use strict;
use warnings;

#use Path::Abstract;
use Local::Debug qw(debug debug_init);
use Local::Routines qw(version);

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
my $summarize   = 0;
my $count       = 0;
my $nice_output = 0;
my $show_rating = 0;
my $show_dir    = 0;
my $given_rate  = 0;

## Parse options and print usage if there is a syntax error,
## or if usage was explicitly requested.
GetOptions(
    'h|help|?'       => \$help,
    'm|man'          => \$man,
    'D|Debug+'       => \$debug,
    'v|version'      => \$version,
    's|summary'      => \$summarize,
    'c|count'        => \$count,
    'h|human'        => \$nice_output,
    'r|ratings'      => \$show_rating,
    'g|given-rate=i' => \$given_rate,
    'd|directory'    => \$show_dir
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

debug("Debug output set to $debug");
debug("In Library file : $library");
debug("Print total count : $count");
debug("Summarize output : $summarize");
debug("Given Rate : $given_rate");
debug("Print human readable names : $nice_output");
debug("Print song rating : $show_rating");
debug("Print song directory : $show_dir");

# Wether or not we're looking for the next rated song (otherwhise we
# look for the location of the current rated track.
my $is_rating = 1;

# Rating of the current rated song :
my $rating = 0;

# TrackID of the current processed track :
my $trackID = 0;

# Total rated tracks :
my $total = 0;

# Hash of rates :
my %rates;

while ( my $line = <> ) {
    if ( $is_rating == 1 ) {
        if ( $line =~ /.*<key>Rating<.*/ ) {
            $line =~ s/[^0-9]//g;
            $rating = $line;

            if ( defined( is_integer($rating) ) ) {
                if ( !is_between( $rating, 0, 100 ) ) {
                    die "Weird rating : $rating\n";
                }
                else {
                    if ( defined( $rates{$rating} ) ) {
                        $rates{$rating}++;
                    }
                    else {
                        $rates{$rating} = 1;
                    }
                }
            }
            else {
                die "No rating? : $rating\n";
            }

            if ( $given_rate == 0 || $given_rate == $rating ) {
                $is_rating = 0;
            }
        }
    }
    else {
        while ( my $line = <> ) {
            if ( $line =~ /.*<key>Location<.*/ ) {
                my @path  = split( /\/\/localhost/, $line );
                my @path3 = split( /\//,            $path[1] );

                my $directory = @path3[ scalar(@path3) - 3 ];
                my $filename  = @path3[ scalar(@path3) - 2 ];

                if ( $nice_output == 1 ) {
                    $directory =~ s/%20/\ /g;
                    $filename  =~ s/%20/\ /g;
                }

                chop($filename);

                if ( $given_rate == 0 || $given_rate == $rating ) {
                    if ( $show_rating == 1 ) {
                        print "$rating : ";
                    }

                    if ( $show_dir == 1 ) {
                        print "$directory/";
                    }

                    if ( $summarize == 0 ) {
                        print "$filename\n";
                    }
                }

                $is_rating = 1;
                $total += 1;
                last;
            }
            if ( $line =~ /.*<key>Rating<.*/ ) {
                print STDERR "Probleme with a rating $line\n";
            }
        }
    }

    #     if ( $line =~ /.*localhost$prefix.*/ ) {
    #         $nb_mp3++;
    #         my @path  = split( /\/\/localhost/, $line );
    #         my @path2 = split( /\//,            $prefix );
    #         my $count = scalar @path2;

    #         if ( $count == 0 ) {
    #             $count = 1;
    #         }
    #         my @path3 = split( /\//, $path[1] );

    #         if ( $newloc{ $path3[$count] } ) {
    #             $newloc{ $path3[$count] }++;
    #         }
    #         else {

    #             $newloc{ $path3[$count] } = 1;
    #         }
    #     }
    # }
}

if ( $summarize == 1 ) {
    foreach my $rate ( sort { $a <=> $b } keys %rates ) {
        my $stars = $rate / 20;
        print "$stars Stars : $rates{$rate}\n";
    }
}

if ( $count == 1 ) {
    print "Total rated tracks : $total\n";
}

__END__

=head1 NAME

listRating.pl - let you find every rated track in a iTunes Library

=head1 SYNOPSIS

listRating.pl [-Dvhmdcrhs] iTuneLibrary.xml

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

=item B<-s, --summary>

Print differents rates and how many rated tracks with a given rate.

=item B<-c, --count>

Print the total number of rated tracks in library.

=item B<-d, --directory>

Also print directory.

=item B<-h, --human>

Print human readable filenames.

=item B<-r, --ratings>

Print each track's rating.

=back

=head1 DESCRIPTION

This program allow an iTunes user to digg into an iTunes XML file. The
output will list every rated tracks.

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
