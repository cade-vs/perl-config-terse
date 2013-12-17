#!/usr/bin/perl
use strict;
use Config::Terse;
use Data::Dumper;

my $cfg = terse_config_load( 'try.cfg' );

print Dumper( $cfg );
