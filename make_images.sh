#!/bin/sh

set -eu

readonly NAMESPACE="${NAMESPACE:=alpinelinux}"
readonly PROJECT="${PROJECT:=docker-abuild}"
readonly ARCHES="${ARCHES:=x86 x86_64 armhf armv7 aarch64 ppc64le s390x}"
readonly TEMPLATE="Dockerfile.in"

readonly OPERATION="$1"
readonly RELEASE="$2"

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
		ppc64le) echo ppc64le ;;
		s390x) echo s390x ;;
		*) die "Unknown arch detected: \"$1\""
	esac
}

build() {
	for arch in $ARCHES; do
		[ "$RELEASE" = "v3.8" ] && [ "$arch" = "armv7" ] && continue
		sed -e "s/%%ALPINE_IMG%%/$(arch_to_image $arch)/" \
			-e "s/%%ALPINE_TAG%%/${RELEASE/v/}/" \
			-e "s/%%ALPINE_REL%%/$RELEASE/" "$TEMPLATE" > Dockerfile
		docker build --no-cache -t "$NAMESPACE/$PROJECT:${RELEASE/v/}-$arch" . || \
			die "Failed to build docker-abuild:${RELEASE/v/}-$arch"
	done
}

push() {
	printf "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" \
		--password-stdin || die "Failed to login to docker hub"

	for arch in $ARCHES; do
		[ "$RELEASE" = "v3.8" ] && [ "$arch" = "armv7" ] && continue
		docker push "$NAMESPACE/$PROJECT:${RELEASE/v/}-$arch" || \
			die "Failed to push docker-abuild:${RELEASE/v/}-$arch"
	done
}

manifest() {
	local images= arch=

	printf "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" \
        --password-stdin || die "Failed to login to docker hub"

	for arch in $ARCHES; do
		[ "$RELEASE" = "v3.8" ] && [ "$arch" = "armv7" ] && continue
		images="$images $NAMESPACE/$PROJECT:${RELEASE/v/}-$arch"
	done

	docker manifest create --amend "$NAMESPACE/$PROJECT" $images || \
		die "Failed to create manifest"
	docker manifest push --purge "$NAMESPACE/$PROJECT" || \
		die "Failed to push manifest"
}

[ "$RELEASE" ] || die "Second argument needs to be a alpine release"

case $OPERATION in
	build) build ;;
	push) push ;;
	manifest) manifest ;;
	*) die "First argument needs to be build|push|manifest" ;;
esac

