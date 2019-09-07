#!/bin/sh

set -e

## debug
if [ "$DABUILD_DEBUG" = "true" ]; then
  set -x
  PS4='$LINENO: '
fi

## generate signing keys on first run
if [ ! -r "$HOME/.abuild/abuild.conf" ]; then
  abuild-keygen -n -a
fi

(
  . "$HOME/.abuild/abuild.conf"
  if [ ! -s "$PACKAGER_PRIVKEY" ]; then
    abuild-keygen -n -a
  fi
)

sudo cp -v "$HOME"/.abuild/*.rsa.pub /etc/apk/keys/
sudo apk -U upgrade -a

exec "$(command -v abuild)" "$@"
