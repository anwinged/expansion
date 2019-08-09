#!/usr/bin/env bash

set -eu

docker run -it \
	-u "$(id -u):$(id -g)" \
	-v "$PWD:/app" \
	-w "/app" \
	crystallang/crystal:0.30.0 crystal "$@"