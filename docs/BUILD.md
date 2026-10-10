# Pinned build procedure

`scripts/apply-port.sh` fetches the Paper source from its official repository at commit `cc7b98af634be07c9b3581306c7b6af33caa3ff2`. The patch includes the complete build changes, API additions, rebuilt source/feature patches, unit tests and five portable validation/build helper files. Historical conflict-resolution scripts and private operational documents are unnecessary for replay and are excluded.

From the resulting Paper directory, with JDK 25 selected:

```bash
export GIT_AUTHOR_NAME="${GIT_AUTHOR_NAME:-Local port builder}"
export GIT_AUTHOR_EMAIL="${GIT_AUTHOR_EMAIL:-local-port@localhost}"
export GIT_COMMITTER_NAME="${GIT_COMMITTER_NAME:-$GIT_AUTHOR_NAME}"
export GIT_COMMITTER_EMAIL="${GIT_COMMITTER_EMAIL:-$GIT_AUTHOR_EMAIL}"
bash ./gradlew --no-daemon --console=plain -I scripts/local-port/mache.init.gradle applyPatches
bash ./gradlew --no-daemon --console=plain -I scripts/local-port/mache.init.gradle \
  :paper-server:test :paper-api:test :paper-server:createBundlerJar
```

These scoped identity values let paperweight commit generated sources even when Git has no global user identity configured. `scripts/build.sh` supplies the same defaults without modifying global Git configuration.

## Mache workaround

The pinned Mache ZIP has six stale patch hunk coordinates for this replay. `mache.init.gradle` invokes `prepare-mache.py` to make a separate adjusted archive. The original must match SHA-256 `e74865ffe64350fdeeccbb176df8e652b84762c075b81ca1e324253fc2b3d21b`. Only six hunk start coordinates change; hunk bodies remain unchanged. Native paperweight retains its context checks. This is a workaround for this exact Mache input, not a general bypass for other snapshots.

Minecraft generated sources live in a separate Git repository under `paper-server/src/minecraft/java`. Running patch extraction/application can replace generated work. Rebuild patches and preserve edits before using those tasks while developing. Task exclusions used to compile dirty generated sources do not demonstrate a clean replay.

## Updating this experiment

This patch is pinned to one snapshot. Later snapshots can change classes, methods, registries, chunk scheduling, biome storage and networking. Applying it blindly to another Paper or Mache version is unsupported. A future port should update its pins, rebuild patches, rerun tests, and repeat restart and world-copy probes.

## Troubleshooting

- **Patch does not apply:** verify the base commit and patch checksum. Start in a new destination; do not reset an existing checkout containing your work.
- **Wrong Java:** set `JAVA_HOME` to a JDK 25 installation and prepend its `bin` to `PATH`. The wrapper uses `JAVA_HOME` when provided.
- **Dependency downloads fail:** check network access and the upstream repositories. The build needs live dependency downloads; this kit is not an offline dependency mirror.
- **PowerShell cannot find `/home/...` or `/mnt/c/...`:** open WSL first. Those are Linux paths. Execute the multi-line Bash commands inside Linux/WSL.
- **Existing build/Paper directory:** reuse it with `scripts/build.sh`, or pass a different new directory to `scripts/apply-port.sh`.
