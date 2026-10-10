#!/usr/bin/env bash
set -euo pipefail
kit=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
source_dir=${1:-"$kit/build/Paper"}
cd -- "$source_dir"
command -v python3 >/dev/null
java_cmd=java
if [[ -n ${JAVA_HOME:-} ]]; then java_cmd="$JAVA_HOME/bin/java"; fi
"$java_cmd" -version
if ! "$java_cmd" -version 2>&1 | head -1 | grep -Eq 'version "25([.\"-])'; then
    printf 'Select JDK 25 using JAVA_HOME and PATH before building.\n' >&2
    exit 1
fi
[[ -f scripts/local-port/mache.init.gradle ]]
# paperweight creates commits in its separate generated-source repositories.
# Supply a local fallback without changing the builder's global Git settings.
export GIT_AUTHOR_NAME="${GIT_AUTHOR_NAME:-Local port builder}"
export GIT_AUTHOR_EMAIL="${GIT_AUTHOR_EMAIL:-local-port@localhost}"
export GIT_COMMITTER_NAME="${GIT_COMMITTER_NAME:-$GIT_AUTHOR_NAME}"
export GIT_COMMITTER_EMAIL="${GIT_COMMITTER_EMAIL:-$GIT_AUTHOR_EMAIL}"
bash ./gradlew --no-daemon --console=plain -I scripts/local-port/mache.init.gradle applyPatches
bash ./gradlew --no-daemon --console=plain -I scripts/local-port/mache.init.gradle \
    :paper-server:test :paper-api:test :paper-server:createBundlerJar
printf '\nServer: %s/paper-server/build/libs/paper-bundler-26.4-snapshot-3.local-SNAPSHOT.jar\n' "$PWD"
