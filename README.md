# docker-abuild

A Docker-ised `abuild` for invocation from within an `aports/` tree. Attempts to auto-detect which branch of `aports/` is checked out, and use an appropriately based container for running `abuild`.

## Configuration

The `abuild` script is generated from `abuild.in` on `make build`. This ensures synchronisation of volume names. By default, the `abuild` script then uses the Docker image `mor1/abuild`; set the `IMG` variable in the `Makefile` and `make build` to use a different image.

On invocation from within an `aports/` tree, the script will determine the root of the tree (`.../aports/`) and bind mount it into the container at `/home/builder/aports`. It also bind mounts `$HOME/.abuild` for configuration.

## Building without fetching

Per normal usage, if you use the `-K` switch, then the build, source, etc directories will be left alone on completion. If you then invoke as `abuild build`, then the source will not be re-fetched -- useful when you wish to edit the source to debug a package build.

## Caching

The script attempts to support caching via named volumes. To turn on caching, invoke as

``` shell
DOCKER_ABUILD_CACHE=true abuild [options]
```

To clean the cache before continuing, invoke as

``` shell
DOCKER_ABUILD_CACHE=true DOCKER_ABUILD_CLEAN=true abuild [options]
```
