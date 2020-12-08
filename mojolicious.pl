#!/usr/bin/env perl

use Mojolicious::Lite;
use FindBin;
BEGIN { unshift @INC, "$FindBin::Bin/lib" }

plugin Fortune => {path                   => app->home->child('fortune.txt')};
plugin Mount   => {'docs.mojolicious.org' => app->home->child('mojodocs.pl')};

# Redirect "mojolicio.us" to "mojolicious.org"
hook before_dispatch => sub {
  my $c = shift;
  return unless ($c->req->url->base->host // '') =~ /^(.*)mojolicio.us$/;
  $c->res->code(301);
  $c->redirect_to($c->req->url->to_abs->host("$1mojolicious.org"));
};

# Redirect old documentation links to "docs.mojolicious.org"
any '/perldoc/:module' => {module => 'Mojolicious/Guides'} => [module => qr/[^.]+/] => sub {
  my $c      = shift;
  my $module = $c->param('module');
  $c->redirect_to("https://docs.mojolicious.org/$module");
};

# Welcome to Mojolicious
get '/' => sub {
  my $c = shift;

  if ((my $host = $c->req->url->base->host // '') ne 'mojolicious.org') {

    # Shortcut for "book.mojolicious.org"
    return $c->redirect_to('https://leanpub.com/mojo_web_clients/') if $host =~ /^book\./;

    # Shortcut for "forum.mojolicious.org"
    return $c->redirect_to('https://github.com/mojolicious/mojo/discussions') if $host =~ /^forum\./;

    # Shortcut for "conduct.mojolicious.org"
    return $c->redirect_to('https://mojolicious.org/perldoc/Mojolicious/Guides/Contributing#CODE-OF-CONDUCT')
      if $host =~ /^conduct\./;

    # Shortcut for "kraih.com"
    return $c->redirect_to('https://github.com/kraih') if $host =~ /kraih.com$/;

    # Shortcut for "minion.pm"
    return $c->redirect_to('https://github.com/mojolicious/minion') if $host =~ /minion.pm$/;
  }

  # Frontpage
  $c->render('mojolicious/index');
};

app->start;
