#!/bin/sh

TEMPLATE="Dockerfile.in"
RELEASES="v3.6 v3.7 v3.8 v3.9 v3.10 v3.11 edge"
ARCHS="x86 x86_64 armhf armv7 aarch64"

die() {
	echo "$1" >&2
	exit 1
}

arch_to_image() {
	case $1 in
		armv7) echo arm32v7 ;;
		aarch64) echo arm64v8 ;;
		x86_64) echo amd64 ;;
		armhf) echo arm32v6 ;;
		x86) echo i386 ;;
		*) die "Unknown arch detected: \"$1\""
	esac
}

rm -rf Dockerfiles

for REL in $RELEASES; do
	for ARCH in $ARCHS; do
		mkdir -p Dockerfiles/$REL/$ARCH
		cat "$TEMPLATE" |
			sed -e "s/%%ALPINE_IMG%%/$(arch_to_image $ARCH)/" \
			-e "s/%%ALPINE_TAG%%/${REL/v/}/" \
			-e "s/%%ALPINE_REL%%/$REL/" > \
			Dockerfiles/$REL/$ARCH/Dockerfile
	done
done
