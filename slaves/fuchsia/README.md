# Buildslave for Fuchsia

Go to the parent directory and run:

```
docker build -f fuchsia/Dockerfile .
```

This fetches relevant packages from the
[Fuchsia](https://fuchsia.googlesource.com/fuchsia) repositories using
[jiri](https://fuchsia.googlesource.com/jiri). The hooks for the
magenta repo in turn fetch toolchain binaries from Google Cloud
Storage.

The Docker script builds a sysroot, and also builds the "clang
wrapper". See the
[magenta-rs](https://fuchsia.googlesource.com/magenta-rs/+/HEAD/GETTING_STARTED.md)
documentation for more information on that.

The resulting docker image can also be used to build a working Rust compiler:

```
docker run -it --entrypoint=/bin/bash ${IMAGE}
/build-head-rust.sh
```

