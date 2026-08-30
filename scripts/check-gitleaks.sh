#!/usr/bin/env bash
set -Eeuo pipefail

version="8.29.1"
platform="$(uname -s | tr '[:upper:]' '[:lower:]')"
machine="$(uname -m)"
case "${platform}/${machine}" in
  linux/x86_64) archive="gitleaks_${version}_linux_x64.tar.gz"; expected="e4eb209d04e20339d77122a3bdf9cd41351255cfb27ebcb75e85325e04f88924" ;;
  linux/aarch64|linux/arm64) archive="gitleaks_${version}_linux_arm64.tar.gz"; expected="691f826ce7c1c564c9c02d0f9025e8e70803e3816707a4be6224408a06a81eaa" ;;
  darwin/arm64) archive="gitleaks_${version}_darwin_arm64.tar.gz"; expected="69836c841d7e648fb30ff4846f8c3587855c5754ed02b8510caaf6008f65d177" ;;
  darwin/x86_64) archive="gitleaks_${version}_darwin_x64.tar.gz"; expected="2cd739c684bf3f543f4f37774075c276e40a72bb16c4c5bb9dfd27bf4a4465a7" ;;
  *) echo "unsupported gitleaks platform: ${platform}/${machine}" >&2; exit 2 ;;
esac

scan_dir="$(mktemp -d)"
trap 'rm -rf "$scan_dir"' EXIT
download="${scan_dir}/${archive}"
curl --fail --location --silent --show-error \
  "https://github.com/gitleaks/gitleaks/releases/download/v${version}/${archive}" \
  --output "$download"

if command -v sha256sum >/dev/null 2>&1; then
  actual="$(sha256sum "$download" | awk '{print $1}')"
else
  actual="$(shasum -a 256 "$download" | awk '{print $1}')"
fi
if [[ "$actual" != "$expected" ]]; then
  echo "gitleaks archive checksum mismatch" >&2
  exit 1
fi

tar -xzf "$download" -C "$scan_dir" gitleaks
"${scan_dir}/gitleaks" git \
  --exit-code 1 \
  --log-opts="--all" \
  --no-banner \
  --redact \
  --verbose \
  .
