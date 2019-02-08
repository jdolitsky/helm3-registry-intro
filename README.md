# Helm 3 Registry Intro
This repo contains some commands for how to get started working with Helm 3 and registries.

## Getting Helm 3

Helm 3 currently exists on the dev-v3 branch of the official Helm. In order to get up and running, you will need a working Go 1.11+ environment.

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
