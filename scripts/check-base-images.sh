#!/usr/bin/env bash
set -Eeuo pipefail

dockerfile="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)/Dockerfile"
[[ -r "$dockerfile" ]] || { printf 'missing Dockerfile: %s\n' "$dockerfile" >&2; exit 1; }

from_lines=()
while IFS= read -r image; do
  from_lines+=("$image")
done < <(awk 'toupper($1) == "FROM" { print $2 }' "$dockerfile")
(( ${#from_lines[@]} > 0 )) || { printf 'Dockerfile has no FROM instructions\n' >&2; exit 1; }
for image in "${from_lines[@]}"; do
  [[ "$image" =~ @sha256:[0-9a-fA-F]{64}$ ]] || {
    printf 'base image must use an immutable digest: %s\n' "$image" >&2
    exit 1
  }
done
printf 'PASS: %d Dockerfile base images are digest-pinned\n' "${#from_lines[@]}"
