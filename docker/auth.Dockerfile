# syntax=docker/dockerfile:1
# check=error=true;experimental=all;skip=JSONArgsRecommended

#builder-base Build deps
FROM rust:latest AS builder-base
ENV RUSTFLAGS="-C linker=clang -C link-arg=-fuse-ld=mold"
RUN apt-get update && apt-get install -y --no-install-recommends \
	ca-certificates \
	git \
	clang \
	llvm-dev \
	libclang-dev \
	curl \
	mold

RUN curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash
RUN cargo binstall -y cargo-chef
COPY --from=base /app/recipe-auth.json recipe-auth.json
COPY --from=base /app/recipe-server.json recipe-global.json
COPY --from=base /app/recipe-server.json recipe-server.json
COPY . .
# Build dependencies - this is the caching Docker layer!
RUN cargo chef cook --release --recipe-path recipe-auth.json

#builder Build the auth server
FROM builder-base AS builder
# RUN ls &&  sleep 5
# COPY --from=builder-base /target/ /target
RUN cargo build --locked --target-dir=/target --release

#runtime Final
FROM ubuntu:latest AS runtime
WORKDIR /opt/app
COPY --from=builder /target/release/auth-server /opt/app/auth-server
EXPOSE 19253
RUN ls && sleep 4
ENTRYPOINT [ "./auth-server" ]
