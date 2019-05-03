# Copyright (C) 2019 Richard Mortier <mort@cantab.net>
# Licensed under the MIT License, https://opensource.org/licenses/MIT

.DEFAULT_GOAL := dabuild

ORG = mor1
IMG = $(ORG)/dabuild
VOLS = bin etc lib sbin usr var
# BRANCHES := $(shell \
#	curl -s https://api.github.com/repos/alpinelinux/aports/branches \
#	| jq -r '.[].name' \
# )
# TAGS := $(shell \
#	curl -s https://registry.hub.docker.com/v1/repositories/alpine/tags \
#	| jq -r '.[].name' \
# )
## let's just manually specify some tags for now
TAGS = 2.6 2.7 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 edge

.PHONY: all
all: images dabuild

dabuild: dabuild.in
	sed 's!%%ABUILD_VOLUMES%%!$(VOLS)!;s!%%ABUILD_IMAGE%%!$(IMG)!' \
	  dabuild.in >| dabuild
	chmod +x dabuild

.PHONY: images
images: $(patsubst %, build-%, $(TAGS)) push

.PHONY: build-%
build-%:
	sed 's/%%ALPINE_TAG%%/$*/' Dockerfile.in >| Dockerfile
# XXX probably because I'm on an edge release of Docker for Mac with a beta
# engine, DOCKER_BUILDKIT appears to have some strange behaviour so turning
# it off for now
	DOCKER_BUILDKIT=0 docker build $$DOCKER_FLAGS -t $(IMG):$* .
	for v in $(VOLS) ; do docker volume create abuild-$*-$${v//\//_} ; done
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
