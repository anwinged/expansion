FROM alpine:edge as builder

# Install crystal and dev libs
RUN apk add -u \
	crystal \
	shards \
	make  \
	tzdata \
	libc-dev \
	yaml-dev
