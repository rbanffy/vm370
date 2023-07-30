# vm370

[![Docker Pulls](https://img.shields.io/docker/pulls/rbanffy/vm370.svg)](https://hub.docker.com/r/rbanffy/vm370/)
[![GitHub](https://img.shields.io/github/license/rbanffy/vm370.svg)](https://github.com/rbanffy/vm370)

This repo contains the files needed to build the Docker image for rbanffy/vm370.

![Screenshot](https://raw.githubusercontent.com/wiki/rbanffy/vm370/screenshot.png)

## Building the image

To build it:

```shell
docker build -t vm370 .
```

To run the image you just built, use:

```shell
docker run -it -p 3270:3270 -p 8081:8081 vm370
```

At this point, you can connect your terminals to localhost on port 3278. To
get to the web console, connect to http://localhost:8081 using the credentials
for the MAINT user (as published in the Sixpack documentation).

## Running from Docker Hub

To run this image without building it locally, use:

```shell
docker run -it -p 3270:3270 -p 8081:8081 rbanffy/vm370
```

## Deploying it to a Docker Swarm

This image is intended to run as a service on a cluster. To create a vm370
service on your cluster, run:

```shell
docker service create --name vm370 --publish 3270:3270 rbanffy/vm370
```

When the service is up and running, connecting a 3270 session to any node will
get you to the VM370 welcome screen.

### A warning

This functionality is not completely developed, however - there is no access
to the Hercules console (only 3270 terminals) and data is not persisted when
the workload is moved to a new node. Use it at your own peril (and, if you know
how, help improving it).
