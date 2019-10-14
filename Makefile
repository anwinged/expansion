PATH := tools:$(PATH)
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
	crystal build $(ENTRY_POINT) --release --no-debug --static -o build/$(APP_NAME)

.PHONY: format
format:
	crystal tool format ./src ./spec

.PHONY: run
run: format
	crystal run $(ENTRY_POINT)

.PHONY: spec
spec: format
	crystal spec --warnings all --error-on-warnings --error-trace

.PHONY: ameba
ameba:
	ameba src/ || true
