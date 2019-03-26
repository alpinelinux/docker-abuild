.DEFAULT: build

IMG = mor1/abuild
VOLS = bin etc lib sbin usr var
TAGS := $(shell \
	curl -s https://registry.hub.docker.com/v1/repositories/alpine/tags \
	| jq -r '.[].name' \
)
TAGS = edge

.PHONY: build
build: $(patsubst %, build-%, $(TAGS))
	sed 's/%%ALPINE_VOLUMES%%/$(VOLS)/' abuild.in >| abuild

.PHONY: build-%
build-%:
	sed 's/%%ALPINE_TAG%%/$*/' Dockerfile.in >| Dockerfile
	for v in $(VOLS) ; do docker volume create alpine-$*-$$v ; done
	DOCKER_BUILDKIT=1 docker build $$DOCKER_FLAGS -t $(IMG):$* .
	$(RM) Dockerfile

.PHONY: push
push: build
	docker push $(DOCKER_FLAGS) $(IMG)

.PHONY: clean
clean:
	$(RM) Dockerfile

.PHONY: distclean
distclean: clean
	docker rmi -f $$(docker images -q $(IMG))
