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

# create or correct permissions of abuild config dir
sudo install -d -o builder -g builder "$HOME"/.abuild/

# set some abuild defaults on first run
if [ ! -f "$HOME/.abuild/abuild.conf" ]; then
	cat <<- EOF > "$HOME"/.abuild/abuild.conf
	export JOBS=\$(nproc)
	export MAKEFLAGS=-j\$JOBS
	EOF
fi

# generate new abuild key if not set
if ! grep -sq "^PACKAGER_PRIVKEY=" "$HOME"/.abuild/abuild.conf; then
	abuild-keygen -n -a
fi

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
