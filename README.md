# Helm 3 Registry Intro
This repo contains some commands for how to get started working with Helm 3 and registries.

## Getting Helm 3

Helm 3 currently exists on the dev-v3 branch of the official Helm repo. In order to get up and running, you will need a working Go 1.12+ dev environment.

First clone the Helm repo into `$GOPATH/src/helm.sh` (example shows dev-v3 branch only):
```
mkdir -p $GOPATH/src/helm.sh/
cd $GOPATH/src/helm.sh/
git clone --single-branch --branch dev-v3 git@github.com:helm/helm.git
cd helm/
```

Next, build the binary:
```
make build
```

The will create a Helm 3 binary at `bin/helm`. Since you probably already have a system-wide `helm` command installed, I recommend naming this something else like (such as `h3`) and copying it into your path:
```
sudo cp bin/helm /usr/local/bin/h3
```

You now have the latest version of Helm 3 installed, and you can use it with `h3`:
```
h3 --help
```

## Running a registry

Starting a registry for test purposes is trivial. As long as you have Docker installed, run the following command:
```
docker run -dp 5000:5000 --restart=always --name registry registry
```

This will start a registry server at `localhost:5000`.

Use `docker logs -f registry` to see the logs and `docker rm -f registry` to stop.

If you wish to persist storage, you can add `-v $(pwd)/registry:/var/lib/registry` to the command above.

For more configuration options, please see [the docs](https://docs.docker.com/registry/deploying/).

### Auth

If you wish to enable auth on the registry, you can do the following-

First, create file `auth.htpasswd` with username and password combo:
```
htpasswd -cB -b auth.htpasswd myuser mypass
```

Then, start the server, mounting that file and setting the `REGISTRY_AUTH` env var:
```
docker run -dp 5000:5000 --restart=always --name registry \
  -v $(pwd)/auth.htpasswd:/etc/docker/registry/auth.htpasswd \
  -e REGISTRY_AUTH="{htpasswd: {realm: localhost, path: /etc/docker/registry/auth.htpasswd}}" \
  registry
```


## Using the new commands

New sets of commands are available under both `h3 registry` and `h3 chart` that allow you to work with registries and local cache.

### The `registry` subcommand

#### `login`

login to a registry (with manual password entry)

```
$ h3 registry login -u myuser localhost:5000
Password:
Login succeeded
```

#### `logout`

logout from a registry

```
$ h3 registry logout localhost:5000
Logout succeeded
```

### The `chart` subcommand

#### `save`

save a chart directory to local cache

*Note: you can use the `mychart/` directory found in this repo (or another chart).
Just make sure `apiVersion: v1` is set in `Chart.yaml`.*

```
$ h3 chart save mychart/ localhost:5000/myrepo/mychart:latest
Name: mychart
Version: 2.7.0
Meta: sha256:ca9588a9340fb83a62777cd177dae4ba5ab52061a1618ce2e21930b86c412d9e
Content: sha256:a66666c6b35ee25aa8ecd7d0e871389b5a2a0576295d6c366aefe836001cb90d
latest: saved
```

#### `list`

list all saved charts

```
$ h3 chart list
REF                                                     NAME                    VERSION DIGEST  SIZE            CREATED
localhost:5000/myrepo/mychart:latest                    mychart                 2.7.1   84059d7 454 B           27 seconds
localhost:5000/stable/acs-engine-autoscaler:latest      acs-engine-autoscaler   2.2.2   d8d6762 4.3 KiB         2 hours
localhost:5000/stable/aerospike:latest                  aerospike               0.2.1   4aff638 3.7 KiB         2 hours
localhost:5000/stable/airflow:latest                    airflow                 0.13.0  c46cc43 28.1 KiB        2 hours
localhost:5000/stable/anchore-engine:latest             anchore-engine          0.10.0  3f3dcd7 34.3 KiB        2 hours
...
```

#### `export`

export a chart to directory

```
$ h3 chart export localhost:5000/myrepo/mychart:latest
Name: mychart
Version: 2.7.0
Meta: sha256:3344059bb81c49cc6f2599a379da0a6c14313cf969f7b821aca18e489ba3991b
Content: sha256:84059d7403f496a1c63caf97fdc5e939ea39e561adbd98d0aa864d1b9fc9653f
Exported to mychart/
```

#### `push`

push a chart to remote

```
$ h3 chart push localhost:5000/myrepo/mychart:latest
The push refers to repository [localhost:5000/myrepo/mychart]
Name: mychart
Version: 2.7.0
Meta: sha256:ca9588a9340fb83a62777cd177dae4ba5ab52061a1618ce2e21930b86c412d9e
Content: sha256:a66666c6b35ee25aa8ecd7d0e871389b5a2a0576295d6c366aefe836001cb90d
latest: pushed to remote (2 layers, 478 B total)
```

#### `remove`

remove a chart from cache

```
$ h3 chart remove localhost:5000/myrepo/mychart:latest
latest: removed
```

#### `pull`

pull a chart from remote

```
$ h3 chart pull localhost:5000/myrepo/mychart:latest
latest: Pulling from localhost:5000/myrepo/mychart
Name: mychart
Version: 2.7.0
Meta: sha256:ca9588a9340fb83a62777cd177dae4ba5ab52061a1618ce2e21930b86c412d9e
Content: sha256:a66666c6b35ee25aa8ecd7d0e871389b5a2a0576295d6c366aefe836001cb90d
Status: Chart is up to date for localhost:5000/myrepo/mychart:latest
```

## Where are my charts?

Charts stored using the commands above will be cached on disk at `~/.helm/registry` (or somewhere else depending on `$HELM_HOME`).

Chart content (tarball) and chart metadata (json) are stored as separate content-addressable blobs.  This prevents storing the same content twice when, for example, you are simply modifying some fields in `Chart.yaml`. They are joined together and converted back into regular chart format when using the `export` command.

The chart name and chart version are treated as "first-class" properties and stored separately. They are extracted out of `Chart.yaml` prior to building the metadata blob.

The following shows an example of a single chart stored in the cache (`localhost:5000/myrepo/mychart:latest`):
```
$ tree ~/.helm/registry
/Users/me/.helm/registry
├── blobs
│   └── sha256
│       ├── 3344059bb81c49cc6f2599a379da0a6c14313cf969f7b821aca18e489ba3991b
│       └── 84059d7403f496a1c63caf97fdc5e939ea39e561adbd98d0aa864d1b9fc9653f
├── charts
│   └── mychart
│       └── versions
│           └── 2.7.1
└── refs
    └── localhost_5000
        └── myrepo
            └── mychart
                └── tags
                    └── latest
                        ├── chart -> /Users/me/.helm/registry/charts/mychart/versions/2.7.1
                        ├── content -> /Users/me/.helm/registry/blobs/sha256/3344059bb81c49cc6f2599a379da0a6c14313cf969f7b821aca18e489ba3991b
                        └── meta -> /Users/me/.helm/registry/blobs/sha256/84059d7403f496a1c63caf97fdc5e939ea39e561adbd98d0aa864d1b9fc9653f
```

## Migrating from existing chart repos

Migrating charts from existing repos is as simple as a `helm fetch`, `h3 chart save`, `h3 chart push`.

Please see the [import-stable.sh](./import-stable.sh) script in this repo for example of how you can import the latest version of every chart in the stable repo into your registry.

## ⚠️ Warning

This is all subject to change in the near future! Things will probably look similar in Helm 3.0 but several details may change, including UX and backend implementation.

If you are interested in getting involved in this discussion, please join us in the [Kubernetes Slack](https://slack.k8s.io/) **#helm-dev** channel.
