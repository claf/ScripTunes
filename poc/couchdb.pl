#!/opt/local/bin/perl

use Store::CouchDB;
use Data::Dumper;

my $db = Store::CouchDB->new( { debug => '1' } );

$db->config(
    { host => 'scriptunes.netgrowing.net', port => '5984', db => 'blogdb' } );

my $couch = { view => 'sofa/tracks', };

my $status = $db->get_array_view($couch);

my $doc = $db->get_doc( { id => '362195f75f58a7760219936bb302ddea' } );

print Dumper $status;
print $db->error();
