
  The [Mojolicious](http://mojolicious.org) website.

## Working Locally

  Clone the repository.

    $ git clone git://github.com/kraih/mojolicious.org.git
    $ cd mojolicious.org

  Install [Mojolicious](http://mojolicious.org).

    $ curl -L https://cpanmin.us | perl - -M https://cpan.metacpan.org -n Mojolicious

  Start hacking.

    $ morbo mojolicious.pl

## Deploying via Github Actions and Kubernetes

The workflow job requires an environment called `Build` with two secrets

* `KUBE_CONFIG_DATA` - a base64 encoded kube config file, `cat ~/.kube/config | base64`
* `WRITE_PACKAGES_TOKEN` - a Personal Access Token with permissions to write to the ghcr container repository

## Copyright And License

  Copyright (C) 2010-2020, Sebastian Riedel.

  Licensed under the CC-NC-ND License, Version 4.0
  [http://creativecommons.org/licenses/by-nc-nd/4.0](http://creativecommons.org/licenses/by-nc-nd/4.0).
