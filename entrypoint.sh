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

# enable ccache if requested
[ "$DABUILD_CCACHE" = "true" ] && export USE_CCACHE=1

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

# make sure distfiles has correct permissions
sudo install -d -m 775 -g abuild /var/cache/distfiles

# correct permissions of user volumes
for vpath in /home/builder/.ccache /home/builder/.abuild \
	/home/builder/packages
do
	[ -d "$vpath" ] && sudo chown builder:builder "$vpath"
done

sudo cp -v "$HOME"/.abuild/*.rsa.pub /etc/apk/keys/
sudo apk -U upgrade -a

exec "$(command -v abuild)" "$@"
