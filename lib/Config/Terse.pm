##############################################################################
#
#  Config::Terse is laconic configuration files parser.
#  Vladi Belperchinov-Shabanski "Cade" <cade@biscom.net> <cade@datamax.bg>
#
#  DISTRIBUTED UNDER GPLv2
#
##############################################################################
package Config::Terse;
use Exporter;
use Carp qw( cluck );
use Data::Dumper;
use strict;

our @ISA = qw( Exporter );

our @EXPORT = qw(
                  terse_config_load
                );

our $VERSION = '0.01';

##############################################################################

sub terse_config_load
{
  my $fn  = shift;
  my %opt = @_;

  my %h;

  my $section = 'main';

  my $lh = $h{ $section } = {}; # last section hash
  
  open( my $if, $fn );
  while( my $line = <$if> )
    {
    next if $line =~ /^\s*[#;]/; # skip comments
    $line =~ s/[\r\n]+$//;       # trip trailing cr/lf
    next unless $line =~ /\S/;   # skip empty lines
    
    if( $line =~ /^\s*=(\S+)(.*)/ )
      {
      my $section = uc $1;
      $h{ $section } ||= {};
      $lh = $h{ $section }; # keep last used section hash

      my $args = $2;
      my @args = split /\s+/, $args;

      my $lg; # last group
      for my $arg ( @args )
        {
        if( $arg =~ /^\+(\S+)/ )
          {
          my $is = $1; # inherit section
          my $ih;
          if( $lg )
            {
            cluck "section [$section] cannot inherit from [$is] does not exist" unless exists $h{ $is };
            $ih = $h{ $is };
            }
          else
            {
            $h{ $lg }{ $section } ||= {};
            $ih = $h{ $lg }{ $section };
            }  
          %$lh = ( %$lh, %$ih );
          next;
          }
        if( $arg =~ /^\@(\S+)/ )
          {
          my $lg = $1;
          $h{ $lg }{ $section } = $h{ $section };
          }
        }

      next;
      # end section code
      }
    if( $line =~ /^\s*(\S+)\s*(.*)/ )
      {
      my $k = $1; # key
      my $v = $2; # value
      $lh->{ $k } = $v;
      next;
      # end key=value code
      }  
    }
  close( $if );

  return \%h;
}

##############################################################################

=pod

=head1 NAME

Config::Terse is laconic configuration files parser.

=head1 SYNOPSIS

    #!/usr/bin/perl
    use strict;

=head1 DESCRIPTION

Config::Terse parses configuration files which use very compact syntax, which 
may seem rude or unfriendly. It provides sections with keyword/value pairs, 
sections inheritance and named lists of sections.

Each line in the config file contains whitespace-delimited key and value:

  key         value
  anotherkey  other value
  koe         ne se chete

Sections begin with equal sign on new line, followed by the section name:

  =newsection
  
  sectionkey1  value
  newkey       value

Sections may inherit other sections. Inherited sections are specified with 
plus sign and name after the section name:

  =newsection  +othersection1  +othersection2  ...

Sections may be grouped in groupss. Group names are specified with "at" sign (@)
followed by the group name, after the section name:

  =apple  @fruits
  
Inheritance and groups can be combined but order is important! All inherited
sections specified before group is taken from the main (root) sections.
Inherited sections after group name is taken from the same group (if such
exists. Here is an example:

  =green
    color  green
    
  =tree  @fruits
    isatree  yes
    
  =apple +greeen  @fruits  +tree
    name  this is a green apple tree
    
The "apple" section will inherit "green" section, then will be put in the
"fruits" group and finally will inherit the "tree" section from "fruits".

=head1 GITHUB REPOSITORY

  https://github.com/cade-vs/perl-config-terse
  
  git clone git://github.com/cade-vs/perl-config-terse.git

=head1 AUTHOR

  Vladi Belperchinov-Shabanski "Cade"

  <cade@biscom.net> <cade@datamax.bg> <cade@cpan.org>

  http://cade.datamax.bg

=cut

1;
