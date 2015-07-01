#!/usr/bin/env perl
use strict;
use warnings;
use YAML::XS;
use String::Scanf;
use Text::Template;
use Data::Dumper;
use Path::Tiny qw( path );

my $templatefile = $ARGV[0];
my $njobs = $ARGV[1];
my $config   = $ARGV[2];

my $w = length(sprintf("%d", $njobs-1));

my %unitsize = ();
$unitsize{"KB"}=10e3;
$unitsize{"MB"}=10e6;
$unitsize{"GB"}=10e9;

my $template = Text::Template->new(SOURCE => $templatefile, DELIMITERS => [qw(<% %>)])
  or die "Couldn't construct template: $Text::Template::ERROR";

open my $fh, '<', $config
  or die "can't open config file: $!";

# convert YAML file to perl hash ref (and cast to a hash)
my %vars = %{YAML::XS::LoadFile($fh)};

# Convert memory request to MB
my $val;
my $unit;
($val,$unit) = sscanf("%d%s",$vars{ "request_memory" });
my $bytes = $val*$unitsize{ $unit } . "\n";
$vars{ "MEM_MB" } = $bytes / $unitsize{ "MB" };

# Convert disk request to KB
($val,$unit) = sscanf("%d%s",$vars{ "request_disk" });
$bytes = $val*$unitsize{ $unit } . "\n";
$vars{ "DISK_KB" } = $bytes / $unitsize{ "KB" };

# Turn shared dir into an absolute path
$vars{SHAREDIR} = path($vars{SHAREDIR})->absolute->stringify;
$vars{WRAPPER} = path($vars{WRAPPER})->absolute->stringify;

for ( my $i=0; $i < $njobs; $i++ ) {
  # Fill in the template
  my $jobcode = sprintf("%0${w}d", $i);
  my $jobdir =  path($jobcode)->absolute->stringify;
  $vars{ "JOB" } = $jobcode;
  $vars{ "JOBDIR" } = $jobdir;
  $vars{ "SUBMITFILE" } = path("$jobcode/process.sub")->absolute->stringify;

# Uncomment to print hashes to stout
#  print Dumper(\%vars);
  my $result = $template->fill_in(HASH => \%vars);

  if ( not -d $jobdir ) {
    mkdir $jobdir;
  };

  my $filename = sprintf("%s/process.sub", $jobcode);
  open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
  if (not defined $result) { die "Couldn't fill in template: $Text::Template::ERROR" };
  print $fh $result;
  close $fh;
}
