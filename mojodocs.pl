#!/usr/bin/env perl

use Mojolicious::Lite;
use FindBin;
BEGIN { unshift @INC, "$FindBin::Bin/lib" }

plugin 'MojoDocs';

# Documentation
any '/:module' => {module => 'Mojolicious/Guides', format => undef} => [module => qr/[^.]+/, format => ['txt']] =>
  app->perldoc;

app->start;
