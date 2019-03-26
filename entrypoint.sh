#!/bin/sh

set -e

## debug
if [ "$DOCKER_ABUILD_DEBUG" = "true" ]; then
  set -x
  PS4='$LINENO: '
fi

## generate signing keys on first run
if [ ! -r "$HOME/.abuild/abuild.conf" ]; then
  abuild-keygen -n -i -a
fi

abuild "$@"
