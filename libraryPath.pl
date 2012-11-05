#!/opt/local/bin/perl

use strict;
use warnings;
use Path::Abstract;
use Routines qw(verbose_print verbose_init);

# On demand export :
#use Routines qw(dummy);
#dummy ();

# Now uses Getopt::Long instead of Getopt:Std :
use Getopt::Long qw{:config no_ignore_case no_auto_abbrev};

# Getopt::Long encourages the use of Pod::Usage to produce help messages :
use Pod::Usage;

my @progpath = split( /\//, $0 );
my $PROGNAME = $progpath[-1];
my $VER_NUM  = "0.2.1";

# Options :
my $man     = 0;
my $help    = 0;
my $verbose = '';
my $version = '';
my $count   = '';
my $prefix  = '/';

## Parse options and print usage if there is a syntax error,
## or if usage was explicitly requested.
GetOptions(
    'h|help|?'   => \$help,
    'm|man'      => \$man,
    'V|Verbose'  => \$verbose,
    'v|version'  => \$version,
    'c|count!'   => \$count,
    'p|prefix=s' => \$prefix
) or pod2usage(2);

pod2usage(1) if $help;
pod2usage( -verbose => 2 ) if $man;

# Handle different options :
if ($version) {
    print "$PROGNAME ver. $VER_NUM\n";
    exit;
}

## If no arguments were given, then allow STDIN to be used only
## if it's not connected to a terminal (otherwise print usage)
pod2usage("$0: No files given.") if ( ( @ARGV == 0 ) && ( -t STDIN ) );

verbose_init($verbose);

# iTunes XML Library :
my $library = '<stdin>';
if (@ARGV) {

    # don't use shift here becose '<>' seems to rely on @ARGV :
    $library = $ARGV[0];
}

# Hashmap containing new directories at given depth (see prefix) :
my %newloc;

verbose_print("Verbose output set to true\n");
verbose_print("Prefix set to : $prefix\n");
verbose_print("MP3 count set to : $count\n");
verbose_print("In Library file : $library\n");

my $nb_mp3 = 0;

# No more need to open the file since '<>':
#open(FILEHANDLER, $library) or die $!;
#while (my $line = <FILEHANDLER>)

while ( my $line = <> ) {
    if ( $line =~ /.*<key>Location.*/ ) {
        $line =~ s/%20/\ /g;

        if ( $line =~ /.*localhost$prefix.*/ ) {
            $nb_mp3++;
            my @path  = split( /\/\/localhost/, $line );
            my @path2 = split( /\//,            $prefix );
            my $count = scalar @path2;

            if ( $count == 0 ) {
                $count = 1;
            }
            my @path3 = split( /\//, $path[1] );

            if ( $newloc{ $path3[$count] } ) {
                $newloc{ $path3[$count] }++;
            }
            else {

                $newloc{ $path3[$count] } = 1;
            }
        }
    }
}

foreach my $path_final ( sort keys %newloc ) {
    print "$path_final\n";

    my $finalpath = Path::Abstract->new( $prefix . "/" . $path_final );

    print "$finalpath\t: " . $newloc{$path_final} . " tracks\n";
}

#close (FILEHANDLER);

__END__

=head1 NAME

libraryPath - let you find every path in a iTunes Library

=head1 SYNOPSIS

libraryPath [-Vvhmc] iTuneLibrary.xml [-p /prefix]

=head1 OPTIONS

=over 8

=item B<-h, --help>

Print a brief help message and exits.

=item B<-m, --man>

Prints the manual page and exits.

=item B<-V, --Verbose>

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
