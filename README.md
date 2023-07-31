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

To run, use:

```shell
docker run -it -p 3270:3270 -p 8081:8081 rbanffy/vm370
```

And connect your terminals to localhost on port 3278. To get to the web console, connect
to http://localhost:8081 using the credentials for the MAINT user (as published in the
Sixpack documentation).
