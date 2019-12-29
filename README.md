# docker-abuild

[![Build Status](https://cloud.drone.io/api/badges/alpinelinux/docker-abuild/status.svg)](https://cloud.drone.io/alpinelinux/docker-abuild)

A Docker-ised `abuild` for invocation from within an `aports/` tree. Attempts to auto-detect which branch of `aports/` is checked out, and use an appropriately based container for running `abuild`.

## Invocation

When invoked, `dabuild` simply passes any flags through to `abuild` running in an Alpine container. The invocation of `dabuild` itself can be controlled to some extent via environment variables prefixed `DABUILD_`:

  * `DABUILD_ARCH=x86|x86_64|aarch64|armhf|armv7`. Specifies architecture for build container. Default: `$(uname -m)`.
  * `DABUILD_ARGS=...`. Passed through to the container `run` command line.
  * `DABUILD_CACHE=true|...`. Create and use Docker named volumes as caches for the running container, persisting changes across invocations. Default: `false`.
  * `DABUILD_CLEAN=true`. If set while `DABUILD_CACHE=true` then remove and recreate the volumes acting as caches. Default: `false`.
  * `DABUILD_DEBUG=true`. Spew debug output to `stdout`. Default: `false`.
  * `DABUILD_DOCKER=docker|podman`. Sets the CLI tool to use to run the container. Default: `docker`.
  * `DABUILD_PACKAGES=...`. Sets the output packages directory (must be writable). Defaults to `.../aports/packages/$DABUILD_VERSION` (cf. below).
  * `DABUILD_RM=false|...`. Do not remove intermediate containers if set to `false`. Default: `true`.
  * `DABUILD_VERSION=...`. Sets the Alpine version of the container in which the `abuild` invocation takes place. Default: extracted from the current branch, either  `N.N-stable` or `edge`.

## Supported architectures

Currently supported architectures are (as reported by `uname -m`):

  * `x86`
  * `x86_64`
  * `aarch64`
  * `armv6`
  * `armv7`
  * `armv7l`
  * `armv8`

## Configuration

The `dabuild` script is generated from `dabuild.in` on `make dabuild`. This ensures synchronisation of volume names. By default, the `dabuild` script then uses the Docker image `mor1/dabuild`. To use a different image, set the `IMG` variable in the `Makefile` and then `make dabuild`.

On invocation from within an `aports/` tree, the script will determine the root of the tree (`.../aports/`) and bind mount it into the container at `/home/builder/aports`. It also bind mounts `$HOME/.abuild` for configuration and `.../aports/../packages` for `abuild` to output packages.

## Building without fetching

Per normal usage, if you use the `-K` switch, then the build, source, etc directories will be left alone on completion. If you then invoke as `dabuild build`, then the source will not be re-fetched -- useful when you wish to edit the source to debug a package build.

## `sudo: effective uid is not 0`

If you see an error such as

``` shell
sudo: effective uid is not 0, is /usr/bin/sudo on a file system with the 'nosuid' option set or an NFS file system without root privileges
```

...when running on a non-native architecture, then it is likely that the configuration flags for `binfmt_misc` (by which Docker automatically invokes `qemu` to support non-native architecture containers) are not correct. Edit the `binfmt` configuration, `/usr/bin/binfmt.d/${arch}.conf` (<https://en.wikipedia.org/wiki/Binfmt_misc>) to change the flag to `OCF`.

Observed on ArchLinux by `@z3ntu`, reported and fixed [docker-abuild#47](https://github.com/alpinelinux/docker-abuild/issues/47).

## Known Issues

  * Docker doesn't support IPv6 well, so if a package's tests make use of IPv6 they may well fail. Observed with `community/libgdata` and [fixed](https://github.com/alpinelinux/aports/pull/7597).
  * Due to what appears to be an issue with Docker for Desktop (at least on OSX), packages that untar symlinks to files that appear later in the tarball fail after untarring. Observed with `main/bash`. Workaround: just rerun the build, leaving the untarred files in place. [Issue raised](https://github.com/alpinelinux/docker-abuild/issues/21).
