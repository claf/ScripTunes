#!/opt/local/bin/perl

package Local::Debug;
use strict;
use warnings;

use Exporter qw (import);
our @EXPORT_OK = qw(debug_init debug debug_switch);

our $debug_value;

sub debug_init {
    $debug_value = shift;
}

sub debug_switch {
    my $switch_value = shift;
    $debug_value = $switch_value;
    return $switch_value;
}

sub debug {
    my $message     = shift;
    my $debug_level = shift;

    if ( not defined $debug_value ) {
        $debug_value = 0;
    }

    if ( not defined $debug_level ) {
        $debug_level = 1;
    }

    if ( $debug_value >= $debug_level ) {
        print "[DEBUG::$debug_level] : $message\n";
        return $message;
    }
}
1;
