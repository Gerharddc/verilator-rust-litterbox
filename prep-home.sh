#!/bin/sh

set -e

# We need the rust toolchain for development
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# It is easier to get XML formatted test results with cargo-nextest
curl -LsSf https://get.nexte.st/latest/linux | tar zxf - -C ${CARGO_HOME:-~/.cargo}/bin
