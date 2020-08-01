#!/usr/bin/env perl

use Mojolicious::Lite;
use FindBin;
BEGIN { unshift @INC, "$FindBin::Bin/lib" }

plugin 'MojoDocs';
plugin 'Fortune' => {path => app->home->child('fortune.txt')};

# Redirect to main site
hook before_dispatch => sub {
  my $c = shift;
  return unless ($c->req->url->base->host // '') =~ /^(.*)mojolicio.us$/;
  $c->res->code(301);
  $c->redirect_to($c->req->url->to_abs->host("$1mojolicious.org"));
};

# Documentation
any '/perldoc/:module' => {module => 'Mojolicious/Guides'} => [module => qr/[^.]+/] => app->perldoc;
any '/:module' => {module => 'Mojolicious/Guides'} => [module => qr/[^.]+/] => (host => qr/^docs\./) => app->perldoc;

# Welcome to Mojolicious
get '/' => sub {
  my $c = shift;

  # Shortcut for "book.mojolicious.org"
  my $host = $c->req->url->base->host // '';
  return $c->redirect_to('https://leanpub.com/mojo_web_clients/') if $host =~ /^book\./;

  # Shortcut for "conduct.mojolicious.org"
  return $c->redirect_to('https://mojolicious.org/perldoc/Mojolicious/Guides/Contributing#CODE-OF-CONDUCT')
    if $host =~ /^conduct\./;

  # Shortcut for "kraih.com"
  return $c->redirect_to('https://github.com/kraih') if $host =~ /kraih.com$/;

  # Shortcut for "minion.pm"
  return $c->redirect_to('https://github.com/mojolicious/minion') if $host =~ /minion.pm$/;

  # Frontpage
  $c->render('mojolicious/index');
};

app->start;
