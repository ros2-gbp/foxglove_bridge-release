FROM rust:1.89-bookworm AS builder

ARG MSRV_RUST_VERSION=1.83.0

WORKDIR /app

RUN rustup toolchain install nightly --component rust-src
RUN rustup toolchain install ${MSRV_RUST_VERSION}
RUN rustup component add rustfmt clippy

RUN curl -fsSL https://deb.nodesource.com/setup_23.x -o nodesource_setup.sh
RUN bash nodesource_setup.sh

RUN apt-get update \
    && apt-get install -y \
        clang-19=1:19.1.7-3~deb12u1 \
        clang-format-19=1:19.1.7-3~deb12u1 \
        clang-tidy-19=1:19.1.7-3~deb12u1 \
        cmake=3.25.1-1 \
        doxygen=1.9.4-4 \
        nodejs=23.11.1-1nodesource1 \
        protobuf-compiler=3.21.12-3 \
        python3.11-dev=3.11.2-6+deb12u6 \
    && rm -rf /var/lib/apt/lists/*

RUN corepack enable yarn

ENV PATH=/usr/lib/llvm-19/bin:$PATH \
    POETRY_NO_INTERACTION=1 \
    POETRY_CACHE_DIR='/var/cache/pypoetry' \
    POETRY_HOME='/usr/local' \
    COREPACK_ENABLE_DOWNLOAD_PROMPT=0

RUN curl -sSL https://install.python-poetry.org | python3 -
