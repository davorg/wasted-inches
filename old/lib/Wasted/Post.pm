package Wasted::Post;

use strict;
use warnings;

use Moose;
use Moose::Util::TypeConstraints;
use DateTime;
use DateTime::Format::Strptime;

subtype 'Wasted::Date',
  as 'DateTime';

coerce 'Wasted::Date',
  from 'Str',
  via {
    DateTime::Format::Strptime->new(
      pattern => '%Y-%m-%d',
    )->parse_datetime($_);
  };

has [qw(title text commentary)] => (
  is => 'ro',
  isa => 'Str',
);

has date => (
  is => 'ro',
  isa => 'Wasted::Date',
  required => 0,
  coerce => 1,
);

sub new_from_file {
  my $class = shift;

  my ($file) = @_;

  die "Invalid file '$file'\n" unless -e -f -r -s $file;

  open my $fh, '<', $file
    or die "Can't open '$file': $!\n";

  my ($data, $curr_field);

  while (<$fh>) {
    if (/(\w+)\s*:\s*(.*)$/) {
      chomp;
      if ($2) {
        $data->{$1} = $2;
        next;
      }
      $curr_field = $1;

      my $line = <$fh>;
      while (defined $line and $line !~ /\w+\s*:\s*$/) {
        $data->{$curr_field} .= $line;
        $line = <$fh>;
      }
      if (defined $line and $line =~ /(\w+)\s*:/) {
        $curr_field = $1;
      }
    } else {
      $data->{$curr_field} .= $_;
    }
  }

  return $class->new($data);
}

sub slug {
  my $self = shift;

  my $slug = lc $self->title;
  $slug =~ s/[[:punct:]]//g;
  $slug =~ s/\s+/-/g;

  return $slug;
}

sub path {
  my $self = shift;

  return join '/', $self->date->strftime('%Y/%m'), $self->slug;
}

1;
