package Mojolicious::Plugin::MojoDocs;
use Mojo::Base 'Mojolicious::Plugin', -signatures;

use Mojo::Asset::File;
use Mojo::ByteStream;
use Mojo::DOM;
use Mojo::File 'path';
use Mojo::URL;
use Pod::Simple::XHTML;
use Pod::Simple::Search;

sub register ($self, $app, $conf) {
  $app->helper(perldoc => sub { \&_perldoc });
}

sub _indentation ($pod) {
  (sort map {/^(\s+)/} @$pod)[0];
}

sub _html ($c, $src, $mod_path) {

  # Rewrite links
  my $dom     = Mojo::DOM->new(_pod_to_html($src));
  my $perldoc = $c->url_for(module => undef)->to_abs;
  my $path    = $perldoc->path;
  $path->trailing_slash(1) if @$path;
  $_->{href} =~ s!^https://metacpan\.org/pod/!$perldoc! and $_->{href} =~ s!::!/!gi
    for $dom->find('a[href]')->map('attr')->each;

  # Rewrite code blocks for syntax highlighting and correct indentation
  for my $e ($dom->find('pre > code')->each) {
    next if $e->content !~ /^\s*(?:\$|Usage:)\s+/m and $e->content =~ /[\$\@\%]\w|-&gt;\w|^use\s+\w|^#|^&lt;|^\[/m;
    my $class = $e->attr->{class};
    $e->attr->{class} = defined $class ? "$class nohighlight" : 'nohighlight';
  }

  # Rewrite headers
  my $toc = Mojo::URL->new->fragment('toc');
  my $parent;
  my @parts;
  for my $e ($dom->find('h1, h2, h3, h4')->each) {

    # Detect parent class
    my $text = $e->all_text;
    if ($text =~ /methods/i && (my $next = $e->next)) {
      $parent = $1 if $next->all_text =~ /inherits all methods from ([A-Za-z0-9\:]+)/i;
    }

    push @parts, [] if $e->tag eq 'h1' || !@parts;
    my $link = Mojo::URL->new->fragment($e->{id});
    push @{$parts[-1]}, $text, $link;
    my $permalink = $c->link_to('#' => $link, class => 'permalink');
    $e->content($permalink . $c->link_to($text => $toc));
  }

  # Try to find a title
  my $title = 'Perldoc';
  $dom->find('h1 + p')->first(sub { $title = $_->text });

  # Combine everything to a proper response
  my $is_doc = $mod_path =~ /pod$/i;
  $c->content_for(perldoc => "$dom");
  $c->render('mojodocs/mojodocs', title => $title, parts => \@parts, parent => $parent, is_doc => $is_doc);
}

sub _perldoc ($c) {

  # Find module or redirect to CPAN
  my $module = join '::', split('/', $c->param('module'));
  $c->stash(cpan => "https://metacpan.org/pod/$module");
  my $path = Pod::Simple::Search->new->find($module, map { $_, "$_/pods" } @INC);
  return $c->redirect_to($c->stash('cpan')) unless $path && -r $path;

  my $src = path($path)->slurp;
  $c->respond_to(txt => {data => $src}, html => sub { _html($c, $src, $path) });
}

sub _pod_to_html {
  return '' unless defined(my $pod = ref $_[0] eq 'CODE' ? shift->() : shift);

  my $parser = Pod::Simple::XHTML->new;
  $parser->perldoc_url_prefix('https://metacpan.org/pod/');
  $parser->$_('') for qw(html_header html_footer);
  $parser->anchor_items(1);
  $parser->strip_verbatim_indent(\&_indentation);
  $parser->output_string(\(my $output));
  return $@ unless eval { $parser->parse_string_document("$pod"); 1 };

  return $output;
}

1;
