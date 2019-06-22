# Copyright (C) 2019 Richard Mortier <mort@cantab.net>
# Licensed under the MIT License, https://opensource.org/licenses/MIT

.DEFAULT_GOAL := dabuild

ORG = alpinelinux
IMG = $(ORG)/docker-abuild
VOLS = bin etc lib sbin usr var
RELEASES ?= $(addprefix v2.,6 7) $(addprefix v3.,1 2 3 4 5 6 7 8 9 10) edge
ARCH := $(shell uname -m)

.PHONY: all
all: images dabuild

dabuild: dabuild.in
	sed 's!%%ABUILD_VOLUMES%%!$(VOLS)!;s!%%ABUILD_IMAGE%%!$(IMG)!' \
	  dabuild.in >| dabuild
	chmod +x dabuild

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
