#!/bin/sh

set -euo pipefail

readonly RELEASE_URL="https://alpinelinux.org/releases.json"
readonly RELEASES=$(curl -fs "$RELEASE_URL" | jq -r '.release_branches[].rel_branch')

template() {
	local release=$1
	cat <<- EOF
	build-$release:
	extends: .build
	script:
	  - ./make_images.sh build $release

	push-$release:
	extends: .push
	script:
	  - ./make_images.sh push $release

	manifest-$release:
	extends: .manifest
	script:
	  - ./make_images.sh manifest $release

	EOF
}

cat <<- EOF
image: alpinelinux/docker-cli

stages:
  - build
  - push
  - manifest
  - cleanup

.build:
  stage: build
  rules:
    - changes:
      - Dockerfile.in
      - make_images.sh
      - entrypoint.sh

.push:
  stage: push

.manifest:
  stage: manifest
  variables:
    DOCKER_CLI_EXPERIMENTAL: enabled

cleanup:
  stage: cleanup
  script:
    - docker system prune --force

EOF

for release in $RELEASES; do
	template $release
done
