#!/usr/bin/env perl

use Mojolicious::Lite;
use FindBin;
BEGIN { unshift @INC, "$FindBin::Bin/lib" }

plugin 'MojoDocs';

# Documentation
any '/:module' => {module => 'Mojolicious/Guides'} => [module => qr/[^.]+/] => app->perldoc;

app->start;
