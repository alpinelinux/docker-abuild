TAGS := $(shell \
	curl -s https://registry.hub.docker.com/v1/repositories/alpine/tags \
	| jq -r '.[].name' \
)

.PHONY: build
build: $(patsubst %, build-%, $(TAGS))

.PHONY: build-%
build-%:
	sed 's/%%ALPINE_TAG%%/$*/' Dockerfile.in >| Dockerfile
	DOCKER_BUILDKIT=1 docker build $$DOCKER_FLAGS -t mor1/abuild:$* .
	$(RM) Dockerfile

.PHONY: push
push: build
	docker push $(DOCKER_FLAGS) mor1/abuild

.PHONY: clean
clean:
	$(RM) Dockerfile
