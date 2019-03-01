.PHONY: build
build:
	DOCKER_BUILDKIT=1 docker build $(DOCKER_FLAGS) -t mor1/abuild .

.PHONY: push
push: build
	docker push $(DOCKER_FLAGS) mor1/abuild
