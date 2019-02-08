# Helm 3 Registry Intro
This repo contains some commands for how to get started working with Helm 3 and registries.

## Getting Helm 3

Helm 3 currently exists on the dev-v3 branch of the official Helm repo. In order to get up and running, you will need a working Go 1.11+ dev environment.

First clone the Helm repo into `$GOPATH/src/k8s.io` (example shows dev-v3 branch only):
```
mkdir -p $GOPATH/src/k8s.io/
cd $GOPATH/src/k8s.io/
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
docker run -dp 5000:5000 --restart=always --name registry registry:2
```

This will start a registry server at `localhost:5000`.

Use `docker logs -f registry` to see the logs and `docker rm -f registry` to stop.

If you wish to persist storage, you can add `-v $(pwd)/registry:/var/lib/registry` to the command above.

For more configuration options, please see [the docs](https://docs.docker.com/registry/deploying/).

## Using the new commands

A new set of commands are available under `h3 chart` that allow you to work with registries and local cache.

### save

save a chart directory

```
$ h3 chart save mychart/ localhost:5000/myrepo/mychart:latest
3344059: Saving meta (216 B)
84059d7: Saving content (454 B)
Name: mychart
Version: 2.7.0
Meta: sha256:3344059bb81c49cc6f2599a379da0a6c14313cf969f7b821aca18e489ba3991b
Content: sha256:84059d7403f496a1c63caf97fdc5e939ea39e561adbd98d0aa864d1b9fc9653f
latest: saved
```

### list

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

### export

export a chart to directory

```
$ h3 chart export localhost:5000/myrepo/mychart:latest
Name: mychart
Version: 2.7.0
Meta: sha256:3344059bb81c49cc6f2599a379da0a6c14313cf969f7b821aca18e489ba3991b
Content: sha256:84059d7403f496a1c63caf97fdc5e939ea39e561adbd98d0aa864d1b9fc9653f
Exported to mychart/
```

### push

push a chart to remote

```
$ h3 chart push localhost:5000/myrepo/mychart:latest
The push refers to repository [localhost:5000/myrepo/mychart]
Name: mychart
Version: 2.7.0
Meta: sha256:3344059bb81c49cc6f2599a379da0a6c14313cf969f7b821aca18e489ba3991b
Content: sha256:84059d7403f496a1c63caf97fdc5e939ea39e561adbd98d0aa864d1b9fc9653f
latest: pushed to remote (2 layers, 670 B total)
```

### pull

pull a chart from remote

```
$ h3 chart pull localhost:5000/stable/wordpress:latest
latest: Pulling from localhost:5000/stable/wordpress
2c017c4: Saving meta (437 B)
8224586: Saving content (18.1 KiB)
Name: wordpress
Version: 5.1.2
Meta: sha256:2c017c46f229ef5faf021d54c2ca6df862169e4314ccdf324ee6faa23ebc585f
Content: sha256:8224586842c560dcbe3f98acd34aef243bb30233126af62efd3b2a82e4f3cae9
Status: Downloaded newer chart for localhost:5000/stable/wordpress:latest
```

### remove

```
$ h3 chart remove localhost:5000/myrepo/mychart:latest
latest: removed
```

## Authentication

Currently, the local Docker credentials are used by default.

Please run `docker login` in advance for any private registries.

## Where are my charts?

Charts stored using the commands above will be cached on disk at `~/.helm/registry` (or somewhere else depending on `$HELM_HOME`).

Chart content (tarball) and chart metadata (json) are stored as separate content-addressable blobs. They are joined together and converted back into regular chart format when using the `export` command.

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


## ⚠️ Warning

This is all subject to change in the near future! Things will probably look similar in Helm 3.0 but several details may change, including UX and backend implementation.

If you are interested in getting involved in this discussion, please join us in the [Kubernetes Slack](https://slack.k8s.io/) **#helm-dev** channel.





