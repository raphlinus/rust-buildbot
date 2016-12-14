FROM ubuntu:16.04

RUN apt-get update && apt-get install -y --force-yes --no-install-recommends \
	build-essential \
	ca-certificates \
	curl \
	git \
	golang \
	unzip

RUN curl -s https://raw.githubusercontent.com/fuchsia-mirror/jiri/master/scripts/bootstrap_jiri | bash -s fuchsia
WORKDIR /fuchsia
ENV PATH="/fuchsia/.jiri_root/bin:${PATH}"

RUN jiri import sysroot https://fuchsia.googlesource.com/manifest

# Patch the manifest to add scripts and llvm (for Fuchsia.cmake), and
# also to bring in tools from magenta-rs. Hopefully the need for this
# will go away soon.
COPY fuchsia/manifest-patch /fuchsia/
RUN patch .jiri_manifest < manifest-patch

# Note: we have to fix the file ownership here or else it will cause
# permissions problems when we change USER to rustbuild
RUN jiri update && chmod -R u+rwX,go+rX /fuchsia/buildtools/toolchain

RUN ./scripts/build-sysroot.sh -t x86_64
RUN ./scripts/build-sysroot.sh -t aarch64

# Build the clang wrapper
WORKDIR /fuchsia/rust/magenta-rs/tools
RUN g++ -O --std=c++11 clang_wrapper.cc -o clang_wrapper
RUN ln -s clang_wrapper x86-64-unknown-fuchsia-ar && \
    ln -s clang_wrapper x86-64-unknown-fuchsia-cc && \
    ln -s clang_wrapper x86-64-unknown-fuchsia-clang++ && \
    ln -s clang_wrapper aarch64-unknown-fuchsia-ar && \
    ln -s clang_wrapper aarch64-unknown-fuchsia-cc && \
    ln -s clang_wrapper aarch64-unknown-fuchsia-clang++

ENV RUST_TOOLS=/fuchsia/rust/magenta-rs/tools

ENV AR_x86_64_unknown_fuchsia=${RUST_TOOLS}/x86-64-unknown-fuchsia-ar \
    CC_x86_64_unknown_fuchsia=${RUST_TOOLS}/x86-64-unknown-fuchsia-cc \
    CXX_x86_64_unknown_fuchsia=${RUST_TOOLS}/x86-64-unknown-fuchsia-clang++ \
    AR_aarch64_unknown_fuchsia=${RUST_TOOLS}/aarch64-unknown-fuchsia-ar \
    CC_aarch64_unknown_fuchsia=${RUST_TOOLS}/aarch64-unknown-fuchsia-cc \
    CXX_aarch64_unknown_fuchsia=${RUST_TOOLS}/aarch64-unknown-fuchsia-clang++

# A script which can be used to build Rust from git HEAD
COPY fuchsia/build-head-rust.sh /
COPY fuchsia/config.toml /

# The rest of this is adapted from the linux Dockerfile.

RUN apt-get install -y \
        curl make xz-utils git \
        python-dev python-pip stunnel \
        g++-multilib libssl-dev gdb \
        valgrind \
        cmake pkg-config

# Install buildbot and prep it to run
RUN pip install buildbot-slave
RUN groupadd -r rustbuild && useradd -r -g rustbuild rustbuild
RUN mkdir /buildslave && chown rustbuild:rustbuild /buildslave

# When running this container, startup buildbot
WORKDIR /buildslave
RUN rm -rf /build

# TODO: clean up more stuff not needed for Rust build

USER rustbuild
COPY start-docker-slave.sh start-docker-slave.sh
ENTRYPOINT ["sh", "start-docker-slave.sh"]

