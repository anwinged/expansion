FROM alpine:edge as builder

RUN apk add -u crystal shards libc-dev