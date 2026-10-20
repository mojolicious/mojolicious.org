
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

The workflow job requires an environment called `Build` with one secret:

* `KUBE_CONFIG_DATA` - a base64 encoded kube config file for the `github-deployer`
  ServiceAccount from [k8s/github-deployer.yaml](k8s/github-deployer.yaml). Its token
  does not expire and may only restart the site deployments. Build the kube config
  from the `github-deployer-token` Secret in the `mojolicious` namespace.

## Copyright And License

  Copyright (C) 2010-2023, Sebastian Riedel.

  Licensed under the CC-NC-ND License, Version 4.0
  [http://creativecommons.org/licenses/by-nc-nd/4.0](http://creativecommons.org/licenses/by-nc-nd/4.0).
