#!/usr/bin/perl
use strict;
# use module
use XML::Simple;
use Data::Dumper;

# usage:
#      perl gmap2txt.pl doc.kml > doc.txt
# doc.kml can be extracted from kmz file
&main();

#sub Unicode2Ascii
#{
#   my $string = shift;
#   $string =~ s/([^[:ascii:]]+)/unidecode($1)/ge;
#   return $string;
#}

sub NumberIndexToAlphabeta
{
   my $index = shift;
   $index = $index % 52;
   if( $index < 26)
   {
      return chr(65+$index);
   }
   else
   {
      return chr(97+$index-26);
   }
}

sub format_latitude
{
   my ($latitude) = @_;
   
   my @segs = split(/,/, $latitude);
   my @results = map({sprintf("%.5f", $_)} @segs);
   
   return $results[0].",".$results[1];
}

sub main
{
   my $xml = new XML::Simple;
   binmode STDOUT, ":utf8";

   # read XML file
   #my $data = $xml->XMLin("doc.kml", ForceArray => 1);
   my $data = $xml->XMLin( $ARGV[0], ForceArray => 1);

   foreach my $map (@{$data->{'Document'}})
   {
      #print Dumper($map);
      print "Map ".$map->{'name'}[0]."\n";
      foreach my $folder (@{ $map->{'Folder'}})
      {
         #print Dumper($folder);
         print "\nLayer ".$folder->{'name'}[0]."\n";

         my $style = $folder->{'Placemark'}[0]{'styleUrl'}[0];
         
         my $index = 0;
         foreach my $place (@{$folder->{'Placemark'}})
         {
            #print Dumper($place);         
            #my $style = $place->{'styleUrl'}[0];
            #if( $style =~ /(\d+)/  )
            #{
            #   $index = $1;
            #}
            my $description = '';
            if( exists $place->{'description'})
            {
               $description = $place->{'description'}[0];
            }

            print NumberIndexToAlphabeta($index);
            print " ";

            print $place->{'name'}[0]." ".format_latitude($place->{'Point'}[0]{'coordinates'}[0])."\n";
            if( $description =~ /\S+/)
            {
               $description =~ s/<br>/\n/gs;
               $description =~ s/\n/\t/gs;
               print "\t".$description."\n";
            }
            
            $index++;
         }
      }
   }
}
