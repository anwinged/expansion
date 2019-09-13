.PHONY: build-docker
build-docker:
	docker pull alpine:edge
	docker build -t village-crystal .

.PHONY: format
format:
	./cr tool format ./src ./spec

.PHONY: spec
spec:
	./cr spec --warnings all --error-on-warnings

.PHONY: release
release:
	mkdir -p build
	./cr build ./src/village.cr --release --no-debug --static -o build/village