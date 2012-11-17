#!/opt/local/bin/perl

use strict;
use warnings;

# Nice
use lib $ENV{HOME} . "/bin/";

use File::Find;
use XML::Simple;
use Component;
use Data::Dumper;

my @progpath = split( /\//, $0 );
my $PROGNAME = $progpath[-1];

sub print_usage() {
    print "Usage : ./$PROGNAME iTuneLibrary.xml exportedLibrary.xml\n";
    print "\n\tAny existing xml file specified will be overwritten.\n";
    exit;
}

# iTunes XML Library :
my $importedLibrary;
my $exportedLibrary;

if ( scalar @ARGV < 2 ) {
    print_usage();
}
else {
    $importedLibrary = shift @ARGV;
    $exportedLibrary = shift @ARGV;

    print "In file : $importedLibrary\n Out file : $exportedLibrary\n";
}

# Parse this file :
# faire le push dans le new en fait
my $config = XMLin( $importedLibrary, ForceArray => 1 );

print Dumper($config);

exit;

#my $config = XMLin(undef, KeyAttr => { server => 'name' }, ForceArray => [ 'server', 'address' ]);
#
##  Decide wether to print output to console or file if $ARGV[1] exists :
#if (defined ($ARGV[1])) {
#  my ($file, $extension) = split /\./, $ARGV[1];
#  # Decide wether it's a dot file or a png file :
#  if ($extension eq "dot") {# dot file
#    open (DOTFILE, "> $ARGV[1]");
#    *OUTPUT = *DOTFILE;
#  } else {
#    # do something
#    $pngfile = $file.".png";
#    $dottmpfile = $file.".dot";
#    open (DOTTMPFILE, "> $dottmpfile");
#    *OUTPUT = *DOTTMPFILE;
#  }
#} else {
#  *OUTPUT = *STDOUT;
#}
#
#our $filehandle = *OUTPUT;
#
## Dump graph to output :
#$comp =~s/\//\./;
#print OUTPUT "digraph g {\n";
#foreach(keys %Component::components) {
#	if ($Component::components{$_}->{main} eq 1)
#	{
#		$Component::components{$_}->display(1);
#		last;
#	}
#}
#print OUTPUT "}\n";
#
## Close file if $ARGV[1] was provided :
#if (defined ($ARGV[1]))
#{
#  if ($extension eq "dot") {
#    close (DOTFILE);
#  } else {
#    close (DOTTMPFILE);
#  }
#}
#
## system usage :
##   1.  @args = ("command", "arg1", "arg2");
##   2. system(@args) == 0
##   3. or die "system @args failed: $?"
#
#
#if ( defined $pngfile and $pngfile ne '') {
#    my @args = (dot => '-Tpng', $dottmpfile, "-o$pngfile");
#    if ( system @args ) {
#        warn "'system @args' failed\n";
#        my $reason = $?;
#        if ( $reason == -1 ) {
#            die "Failed to execute: $!";
#        }
#        elsif ( $reason & 0x7f ) {
#            die sprintf(
#                'child died with signal %d, %s coredump',
#                ($reason & 0x7f),
#                ($reason & 0x80) ? 'with' : 'without'
#            );
#        }
#        else {
#            die sprintf('child exited with value %d', $reason >> 8);
#        }
#    }
##    warn "'system @args' executed successfully\n";
#    unlink $dottmpfile;
#}
