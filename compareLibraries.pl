#!/opt/local/bin/perl

use strict;
use warnings;
use Path::Abstract;

# Perl Threads :
use threads;

# Now uses Getopt::Long instead of Getopt:Std :
#use Getopt::Std;
use Getopt::Long qw{:config no_ignore_case no_auto_abbrev};

# Getopt::Long encourages the use of Pod::Usage to produce help messages :
use Pod::Usage;

use Mac::iTunes::Library;
use Mac::iTunes::Library::XML;
use Mac::iTunes::Library::Item;

# Not Used :
#use Text::Wrap;

my @progpath=split (/\//, $0);
my $PROGNAME=$progpath[-1];
my $VER_NUM="0.2";

my $man = 0;
my $help = 0;

# Options :
my $verbose = '';
my $version = '';

my $matched_list = '';
my $interactive = '';
my $intelligent_matching = '';
my $reference_orphelin = '';
my $candidate_orphelin = '';
my $reference_path = '';
my $candidate_path = '';
my $reference_file = '';
my $candidate_file = '';

sub verbose_print
{
    my $string = shift;
    if ($verbose)
    {
	print $string . "\n";
    }
}

## Configuring Text::Wrap :
#$Text::Wrap::columns = 72;

# Get every option on the command line :
#my %opts = ();
#getopts('Vvhnp:',\%opts) or print_usage();


## Parse options and print usage if there is a syntax error,
## or if usage was explicitly requested.
GetOptions ('h|help|?'               => \$help,
	    'm|man'                  => \$man,
	    'V|Verbose'              => \$verbose,
	    'v|version'              => \$version,
	    'ml|matched-list'        => \$matched_list,
	    'I|interactive'          => \$interactive,
	    'i|intelligent-matching' => \$intelligent_matching,
	    'ro|reference-orphelin'  => \$reference_orphelin,
	    'co|candidate-orphelin'  => \$candidate_orphelin,
	    'rp|reference-path=s'    => \$reference_path,
	    'cp|candidate-path=s'    => \$candidate_path,
	    'rl|reference-file=s' => \$reference_file,
	    'cl|candidate-file=s' => \$candidate_file) or pod2usage(2);

pod2usage(1) if $help;
pod2usage(-verbose => 2) if $man;
pod2usage("-rl and -cl are mandatory") unless $reference_file and $candidate_file;
pod2usage("-ml and -ro are exclusive") if $matched_list and $reference_orphelin;
pod2usage("-ml and -co are exclusive") if $matched_list and $candidate_orphelin;
pod2usage("-co and -ro are exclusive") if $candidate_orphelin and $reference_orphelin;


## If no arguments were given, then allow STDIN to be used only
## if it's not connected to a terminal (otherwise print usage)
#pod2usage("$0: No files given.")  if ((@ARGV == 0) && (-t STDIN));


# Handle different options :
if ($version)
{
    print "$PROGNAME ver. $VER_NUM\n";
    exit;
}

# Hashmap containing new directories at given depth (see prefix) :
my %newloc;

verbose_print ("Verbose output set to true");
verbose_print ("matched-list : $matched_list");
verbose_print ("interactive : $interactive");
verbose_print ("intelligent-matching : $intelligent_matching");
verbose_print ("reference-orphelin : $reference_orphelin");
verbose_print ("candidate-orphelin : $candidate_orphelin");
verbose_print ("reference-path=s : $reference_path");
verbose_print ("candidate-path=s : $candidate_path");
verbose_print ("reference-file=s : $reference_file");
verbose_print ("candidate-file=s : $candidate_file");

sub parse {
    my $file = shift;
    print "Loading Library : '$file'...";
    my $lib = Mac::iTunes::Library::XML->parse($file);
    print " loaded " . $lib->num() . " items.\n"; 
    return $lib;
}


my $reference_thread = threads->new(\&parse, $reference_file);
my $candidate_thread = threads->new(\&parse, $candidate_file);

my @ref_ar = $reference_thread->join;
my @can_ar = $candidate_thread->join;



__END__

=head1 NAME

compareLibraries - let you compare two iTunes Libraries

=head1 SYNOPSIS

compareLibraries [-hmVviI] [-ml|-ro|-co] [-rp] [-cp] -rl r.xml -cl c.xml

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

=item B<-ml, --matched-list>

Output TrackId of matched tracks (ref_trackid,can_trackid).

=item B<-I, --interactive>

User have access to the prompt to manipulate libraries.

=item B<-i, --intelligent-matching>

Use Intelligent Matching (in developpement).

=item B<-ro, --reference-orphelin>

Output list of track not matched in candidate library.

=item B<-co, --candidate-orphelin>

Output list of track not matched in reference library.

=item B<-rp, --reference-path path>

Use path as prefix in the reference library.

=item B<-cp, --candidate-path path>

Use path as prefix in the candidate library.

=item B<-rl, --reference-library reference.xml>

Use reference.xml as reference library.

=item B<-cl, --candidate-library candidate.xml>

Use candidate.xml as candidate library.

=back

=head1 DESCRIPTION

This program allow to compara reference library and candidate one.

=head2 Script features

=over 4

=item * "Intelligent" matching (file name, track infos, etc).

=item * Output orphelin in reference or candidate libraries.

=item * Output matched list.

=back

=head1 SEE ALSO

L<perlpod>, L<perldoc>, L<Getopt::Long>, L<Pod::Usage>.

=head1 COPYRIGHT

Copyright 2012 Christophe Laferriere.

Permission is granted to copy, distribute and/or modify this
document under the terms of the GNU Free Documentation
License, Version 1.2 or any later version published by the
Free Software Foundation; with no Invariant Sections, with
no Front-Cover Texts, and with no Back-Cover Texts.

=cut
