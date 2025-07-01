# syntax=docker/dockerfile:1
# check=error=true;experimental=all

FROM rust:latest AS planner

RUN apt-get update && apt-get install -y --no-install-recommends \
	ca-certificates \
	curl \
	git

RUN curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash

RUN cargo binstall -y cargo-chef

WORKDIR /app
COPY veloren /app/veloren
COPY auth /app/auth

RUN cd /app/auth \
	&& cargo update \
	&& cargo chef prepare --recipe-path /app/recipe-auth.json \
	&& cd /app

RUN cd /app/veloren/ \
	# cargo update \
	&& cargo chef prepare --recipe-path /app/recipe-global.json \
	&& cd /app

RUN cd /app/veloren/server-cli \
	# cargo update \
	&& cargo chef prepare --recipe-path /app/recipe-server.json \
	&& cd /app
