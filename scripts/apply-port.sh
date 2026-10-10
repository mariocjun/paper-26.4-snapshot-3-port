#!/usr/bin/env bash
set -euo pipefail
kit=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
base=cc7b98af634be07c9b3581306c7b6af33caa3ff2
destination=${1:-"$kit/build/Paper"}
command -v git >/dev/null
command -v sha256sum >/dev/null
(cd "$kit/patches" && sha256sum --check SHA256SUMS)
if [[ -e "$destination" ]]; then
    printf 'Destination already exists; choose a new directory: %s\n' "$destination" >&2
    exit 1
fi
mkdir -p -- "$destination"
git init -- "$destination"
git -C "$destination" remote add origin https://github.com/PaperMC/Paper.git
git -C "$destination" fetch --depth=1 origin "$base"
git -C "$destination" checkout -b codex/paper-26.4-local FETCH_HEAD
[[ $(git -C "$destination" rev-parse HEAD) == "$base" ]]
git -C "$destination" apply --check "$kit/patches/paper-26.4-snapshot-3.patch"
git -C "$destination" apply --index "$kit/patches/paper-26.4-snapshot-3.patch"
git -C "$destination" -c user.name='Local port builder' -c user.email='local-port@localhost' \
    commit -m 'Apply experimental Paper 26.4 Snapshot 3 port'
printf '\nPort applied in: %s\n' "$destination"
printf 'Next: bash %q %q\n' "$kit/scripts/build.sh" "$destination"
