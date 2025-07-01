# syntax=docker/dockerfile:1
# check=error=true;experimental=all

#builder-base Build the deps
FROM rust:latest AS builder-base
ENV RUSTFLAGS="-C linker=clang -C link-arg=-fuse-ld=mold"
RUN apt-get update && apt-get install -y --no-install-recommends \
	ca-certificates \
	clang \
	git \
	llvm-dev \
	libclang-dev \
	curl \
	mold

RUN curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash
RUN cargo binstall -y cargo-chef
COPY --from=base /app/recipe-auth.json recipe-auth.json
# COPY --from=base /app/recipe-server.json recipe-global.json
COPY --from=base /app/recipe-server.json recipe-server.json
COPY . .

# Build dependencies - this is the caching Docker layer!
# RUN cargo chef cook --release --recipe-path recipe-global.json
# RUN cargo chef cook --release --recipe-path recipe-server.json

#builder Build the server CLI binary
FROM builder-base AS builder

# librust-backtrace+libbacktrace-dev = backtrace functionality
# iproute2 and net-tools for diagnostic purposes
RUN apt-get update \
	&& export DEBIAN_FRONTEND=noninteractive \
	&& apt-get install -y --assume-yes \
	ca-certificates \
	librust-backtrace+libbacktrace-dev \
	iproute2 \
	net-tools \
	git-all \
	&& rm -rf /var/lib/apt/lists/*;

#GIT_DATETIME Define build argument for git_datetime
ARG GIT_DATETIME
# Set environment variable for runtime access
ENV GIT_DATETIME=$GIT_DATETIME

# COPY --from=builder-base /app/target/ /target
RUN cargo build --locked --target-dir=/target --release --bin=veloren-server-cli



#runtime Final
FROM gcr.io/distroless/cc-debian12 AS runtime
ENV RUST_BACKTRACE=full

#GIT_DATETIME Define build argument for git_datetime
ARG GIT_DATETIME
# Set environment variable for runtime access
ENV GIT_DATETIME=$GIT_DATETIME

# SIGUSR1 causes veloren-server-cli to initiate a graceful shutdown
LABEL com.centurylinklabs.watchtower.stop-signal="SIGUSR1"


COPY ./assets/common /opt/assets/common
COPY ./assets/server /opt/assets/server
COPY ./assets/world /opt/assets/world
COPY --from=builder /target/release/veloren-server-cli /opt/veloren-server-cli
WORKDIR /opt
ENTRYPOINT ["/opt/veloren-server-cli"]
