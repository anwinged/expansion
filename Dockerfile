FROM alpine:edge as builder

RUN apk add -u make crystal shards tzdata libc-dev yaml-dev
