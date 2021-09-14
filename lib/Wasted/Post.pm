package Wasted::Post;

use strict;
use warnings;

use Moose;

has [qw(title text commentary)] => (
  is => 'ro',
  isa => 'Str',
);

has date => (
  is => 'ro',
  isa => 'Str',
  required => 0,
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

1;
