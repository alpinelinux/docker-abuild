#!/bin/sh

set -e

## debug
if [ "$DABUILD_DEBUG" = "true" ]; then
  set -x
  PS4='$LINENO: '
fi

## generate signing keys on first run
if [ ! -r "$HOME/.abuild/abuild.conf" ]; then
  abuild-keygen -n -i -a
fi

cp -v "$HOME"/.abuild/*.pub /etc/apk/keys/

exec "$(command -v abuild)" "$@"
