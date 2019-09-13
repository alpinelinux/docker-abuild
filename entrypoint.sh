#!/bin/sh

set -e

die () {
  printf >&2 "%s\n" "$@"
  exit 1
}

## debug
if [ "$DABUILD_DEBUG" = "true" ]; then
  set -x
  PS4='$LINENO: '
fi

## check can write to ~/.abuild
if [ ! -w "$HOME/.abuild/" ]; then
  die "Error: unwritable ~/.abuild [$(ls -lad ~/.abuild | cut -d " " -f 1)]"
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
