#!/usr/bin/env perl
use strict;
use warnings;
use YAML::XS;
use String::Scanf;
use Text::Template;
use Path::Tiny qw( path );

my $templatefile = $ARGV[0];
my $njobs = $ARGV[1];
my $w = length(sprintf("%d", $njobs-1));

my $template = Text::Template->new(SOURCE => $templatefile, DELIMITERS => [qw(<% %>)])
  or die "Couldn't construct template: $Text::Template::ERROR";

my %vars;
if ( @ARGV > 2 ) {
  my $config   = $ARGV[2];
  open my $fh, '<', $config
    or die "can't open config file: $!";

  # convert YAML file to perl hash ref (and cast to a hash)
  %vars = %{YAML::XS::LoadFile($fh)};
}

$vars{ "UNIQUE" } = "0";
$vars{ "JOBDIR" } = path("0")->absolute->stringify;
$vars{ "SUBMITFILE" } = path("0/process.sub")->absolute->stringify;

my $sweepdag = "sweep.dag";
open(my $fhsweep, '>', $sweepdag) or die "Could not open file '$sweepdag' $!";
for ( my $i=0; $i < $njobs; $i++ ) {
  # Fill in the template
  my $jobcode = sprintf("%0${w}d", $i);
  $vars{ "UNIQUE" } = $jobcode;
  $vars{ "JOBDIR" } = path($jobcode)->absolute->stringify;
  $vars{ "SUBMITFILE" } = path("$jobcode/process.sub")->absolute->stringify;
  my $result = $template->fill_in(HASH => \%vars);

  mkdir $vars{ "JOBDIR" };
  my $filename = sprintf("%s/%s.dag", $jobcode, $jobcode);
  open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
  if (not defined $result) { die "Couldn't fill in template: $Text::Template::ERROR" };
  print $fh $result;
  close $fh;
  printf $fhsweep "SPLICE %0${w}d %s\n",$i,path($filename)->absolute->stringify
}
close $fhsweep;
