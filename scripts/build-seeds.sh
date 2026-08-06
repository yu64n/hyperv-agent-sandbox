#!/usr/bin/env bash
set -euo pipefail
command -v xorriso >/dev/null
mkdir -p build/seeds
for guest in router sandbox; do
  src="cloud-init/$guest"
  xorriso -as mkisofs -quiet -volid cidata -joliet -rock \
    -output "build/seeds/$guest.iso" "$src/user-data" "$src/meta-data" "$src/network-config"
done

