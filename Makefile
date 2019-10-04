APP_NAME := expansion
ENTRY_POINT = ./src/$(APP_NAME).cr

.PHONY: build-docker
build-docker:
	docker pull alpine:edge
	docker build -t $(APP_NAME)-crystal .

.PHONY: install
install: build-docker

.PHONY: build
build:
	mkdir -p build
	./crystal build $(ENTRY_POINT) --release --no-debug --static -o build/$(APP_NAME)

.PHONY: run
run: format
	./crystal run $(ENTRY_POINT)

.PHONY: format
format:
	./crystal tool format ./src ./spec

.PHONY: spec
spec: format
	./crystal spec --no-debug --warnings all --error-on-warnings --error-trace

