#!/usr/bin/env bash

set -eu

docker run -it \
	-u "$(id -u):$(id -g)" \
	-v "$PWD:/app" \
	-w "/app" \
	village-crystal crystal "$@"