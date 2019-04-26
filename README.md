# docker-abuild

A Docker-ised `abuild` for invocation from within an `aports/` tree. Attempts to auto-detect which branch of `aports/` is checked out, and use an appropriately based container for running `abuild`.

## Configuration

The `dabuild` script is generated from `dabuild.in` on `make build`. This ensures synchronisation of volume names. By default, the `dabuild` script then uses the Docker image `mor1/abuild`. To use a different image, set the `IMG` variable in the `Makefile` and then `make build`.

On invocation from within an `aports/` tree, the script will determine the root of the tree (`.../aports/`) and bind mount it into the container at `/home/builder/aports`. It also bind mounts `$HOME/.abuild` for configuration and `.../aports/../packages` for `abuild` output packages.

## Building without fetching

Per normal usage, if you use the `-K` switch, then the build, source, etc directories will be left alone on completion. If you then invoke as `dabuild build`, then the source will not be re-fetched -- useful when you wish to edit the source to debug a package build.

## Caching

The script attempts to support caching via named volumes. To turn on caching, invoke as

``` shell
DABUILD_CACHE=true abuild [options]
```

To clean the cache before continuing, invoke as

``` shell
DABUILD_CACHE=true DABUILD_CLEAN=true abuild [options]
```
