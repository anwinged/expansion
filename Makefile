.PHONY: format
format:
	./cr tool format ./src ./spec

.PHONY: spec
spec:
	./cr spec --warnings all --error-on-warnings
