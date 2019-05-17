#!/bin/sh

set -e

## debug
if [ "$DABUILD_DEBUG" = "true" ]; then
  set -x
  PS4='$LINENO: '
fi

## generate signing keys on first run
if [ ! -r "$HOME"/.abuild/dabuilder.rsa ]; then
  abuild-keygen -i -a <<- EOF
	"$HOME"/.abuild/dabuilder.rsa
	EOF
fi

sudo cp -v "$HOME"/.abuild/dabuilder.rsa.pub /etc/apk/keys/

exec "$(command -v abuild)" "$@"
