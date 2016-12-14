# This shell script will build a stage1 Rust compiler from git HEAD

set -e

# Cargo tries to create ${HOME}/.cargo, make sure it can.
export HOME=`pwd`

git clone https://github.com/rust-lang/rust.git
cd rust
cp /config.toml .

# apt-get install -y --force-yes --no-install-recommends file python cmake
./configure --enable-rustbuild --target=x86_64-unknown-fuchsia
./x.py build --stage 1

