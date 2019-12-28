# Copyright (C) 2019 Richard Mortier <mort@cantab.net>
# Licensed under the MIT License, https://opensource.org/licenses/MIT

.DEFAULT_GOAL := dabuild

ORG = alpinelinux
IMG = $(ORG)/docker-abuild
VOLS = bin etc lib sbin usr var home/builder/.ccache
# BRANCHES := $(shell \
#	curl -s https://api.github.com/repos/alpinelinux/aports/branches \
#	| jq -r '.[].name' \
# )
# TAGS := $(shell \
#	curl -s https://registry.hub.docker.com/v1/repositories/alpine/tags \
#	| jq -r '.[].name' \
# )
## let's just manually specify some tags for now
RELEASES ?= v2.6 v2.7 v3.1 v3.2 v3.3 v3.4 v3.5 v3.6 v3.7 v3.8 v3.9 v3.10 v3.11 edge
ARCH := $(shell uname -m)

dabuild: dabuild.in
	sed 's!%%ABUILD_VOLUMES%%!$(VOLS)!;s!%%ABUILD_IMAGE%%!$(IMG)!' \
	  dabuild.in >| dabuild
	chmod +x dabuild

.PHONY: all
all: images dabuild

.drone.yml: .drone.jsonnet
	docker run --rm -v '$(shell pwd):/pwd' -w /pwd \
	  drone/cli jsonnet --format --stream --source '$<' --target '$@.tmp' \
	  && test -s '$@.tmp' \
	  && install '$@.tmp' '$@' \
	  ; _rc=$$? \
	  ; $(RM) '$@.tmp' \
	  ; exit $$_rc

.PHONY: images
images: $(patsubst %, build-%, $(RELEASES))

.PHONY: build-%
build-%:
	sed 's!%%ALPINE_TAG%%!$(subst v,,$*)!;s!%%ALPINE_REL%%!$*!' \
		Dockerfile.in >| Dockerfile
# XXX probably because I'm on an edge release of Docker for Mac with a beta
# engine, DOCKER_BUILDKIT appears to have some strange behaviour so turning
# it off for now
	DOCKER_BUILDKIT=0 docker build $$DOCKER_FLAGS \
	  -t $(IMG):$(subst v,,$*)-$(ARCH) .
	$(RM) Dockerfile

.PHONY: push
push:
	docker push $(DOCKER_FLAGS) $(IMG)

.PHONY: clean
clean:
	docker rmi -f $$(docker images -q $(IMG)) || true
	$(RM) Dockerfile dabuild

.PHONY: distclean
distclean: clean
	docker rmi -f $$(docker images -q $(IMG)) || true
	docker rmi $$(docker volume ls --filter 'name=alpine-' -q) || true
