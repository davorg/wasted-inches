package Wasted::Posts;

use strict;
use warnings;
use feature 'say';

use Moose;

use Wasted::Post;

has posts => (
  is => 'ro',
  isa => 'ArrayRef[Wasted::Post]',
  required => 1,
);

around BUILDARGS => sub {
  my $orig  = shift;
  my $class = shift;

  my %args;
  if (@_ == 1 and ref $_[0]) {
    %args = %{$_[0]};
  } else {
    %args = @_;
  }

  if ($args{dir}) {
    die "$args{dir} is not a directory\n" if ! -d $args{dir};

    opendir my $dh, $args{dir} or die $!;

    my @posts = map  { Wasted::Post->new_from_file("$args{dir}/$_") }
                grep { -f "$args{dir}/$_" } readdir $dh;

    @posts = sort { $a->date <=> $b->date } @posts;

    return $class->$orig({ posts => \@posts });
  } else {
    return $class->$orig( \%args );
  }
};

1;
