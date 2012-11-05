#!/opt/local/bin/perl

package Routines;
use strict;
use warnings;

use Exporter qw (import);
our @EXPORT_OK = qw(verbose_print verbose_init);

my $verbose;

sub dummy {
    print "Dummy function to check for on demand export!\n";
}

sub verbose_init {
    $verbose = shift;
}

sub verbose_print {
    my $string = shift;
    if ($verbose) {
        print $string;
    }
}

1;
