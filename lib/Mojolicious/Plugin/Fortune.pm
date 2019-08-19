package Mojolicious::Plugin::Fortune;
use Mojo::Base 'Mojolicious::Plugin';

use Mojo::Collection 'c';

sub register {
  my ($self, $app, $config) = @_;

  my $lines = c(eval { split /\R/, Mojo::File->new($config->{path})->slurp });
  $lines = c('Missing fortunes. Reward: $1,000!') unless $lines->size;

  $app->helper(fortune => sub { return $lines->[int(rand($lines->size))] });
}

1;
