#!/opt/local/bin/perl

use Getopt::Long;
use Pod::Usage;

my $man  = 0;
my $help = 0;
## Parse options and print usage if there is a syntax error,
## or if usage was explicitly requested.
GetOptions( 'help|?' => \$help, man => \$man ) or pod2usage(2);
pod2usage(1) if $help;
pod2usage( -verbose => 2 ) if $man;

## If no arguments were given, then allow STDIN to be used only
## if it's not connected to a terminal (otherwise print usage)
pod2usage("$0: No files given.") if ( ( @ARGV == 0 ) && ( -t STDIN ) );
__END__

=head1 NAME

podsample - A sample pod document

=head1 SYNOPSIS

    $here->isa(Piece::Of::Code);
    print <<"END";
    This indented block will not be scanned for formatting
    codes or directives, and spacing will be preserved.
    END

=head1 DESCRIPTION

Here's some normal text.  It includes text that is B<bolded>,
I<italicized>, underlined seems not to work, and  C<$code>-formatted.

=head2 An Example List

=over 4

=item * This is a bulleted list.

=item * Here's another item.

=back

=begin html

<img src="Example.png" align="right" alt="Figure 1." /> <p>     Here's
some embedded HTML.  In this block I can      include images, apply
<span style="color: green">     styles</span>, or do anything else I
can do with     HTML.  pod parsers that aren't outputting HTML will    
completely ignore it. </p>

=end html

=head1 SEE ALSO

L<perlpod>, L<perldoc>, L<Pod::Parser>.

=head1 COPYRIGHT

Copyright 2005 J. Random Hacker.

Permission is granted to copy, distribute and/or modify this  document
under the terms of the GNU Free Documentation  License, Version 1.2 or
any later version published by the  Free Software Foundation; with no
Invariant Sections, with  no Front-Cover Texts, and with no Back-Cover
Texts.

=cut
