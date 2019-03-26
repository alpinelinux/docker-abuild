.DEFAULT: build

IMG = mor1/abuild
VOLS = bin etc lib sbin usr var home/builder/packages
# BRANCHES := $(shell \
# 	curl -s https://api.github.com/repos/alpinelinux/aports/branches \
# 	| jq -r '.[].name' \
# )
# TAGS := $(shell \
# 	curl -s https://registry.hub.docker.com/v1/repositories/alpine/tags \
# 	| jq -r '.[].name' \
# )
## let's just manually specify some tags for now
TAGS = 2.6 2.7 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 edge

.PHONY: build
build: $(patsubst %, build-%, $(TAGS))
	sed 's!%%ABUILD_VOLUMES%%!$(VOLS)!;s!%%ABUILD_IMAGE%%!$(IMG)!' abuild.in >| abuild
	chmod +x abuild

.PHONY: build-%
build-%:
	sed 's/%%ALPINE_TAG%%/$*/' Dockerfile.in >| Dockerfile
	DOCKER_BUILDKIT=1 docker build $$DOCKER_FLAGS -t $(IMG):$* .
	for v in $(VOLS) ; do docker volume create abuild-$*-$${v//\//_} ; done
	$(RM) Dockerfile

.PHONY: push
push:
	docker push $(DOCKER_FLAGS) $(IMG)

.PHONY: clean
clean:
	docker rmi -f $$(docker images -q $(IMG))
	$(RM) Dockerfile

.PHONY: distclean
distclean: clean
	docker rmi -f $$(docker images -q $(IMG))
	docker rmi $$(docker volume ls --filter 'name=alpine-' -q)
