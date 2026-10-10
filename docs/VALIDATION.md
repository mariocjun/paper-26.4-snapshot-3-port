# Reproducing validation

The normal build runs `:paper-server:test` and `:paper-api:test`. The JSON files in `validation/` summarize the original test XML and the publication replay. Skipped cases are reported separately from passes. These are results for the pinned port; they are not an upstream certification.

## Optional two-start runtime probe

The probe writes blocks, persistent data and a small custom-generator world in a disposable server directory. Accept the Minecraft EULA before using the harness: it writes `eula=true` for the supplied directory. Never point this harness at a live server directory or an irreplaceable world.

From the patched Paper directory, after building the server:

```bash
printf 'include(":test-plugin")\n' > test-plugin.settings.gradle.kts
bash ./gradlew --no-daemon --console=plain -I scripts/local-port/mache.init.gradle :test-plugin:jar
mkdir -p build/probe-server/plugins
python3 scripts/local-port/package-probe.py \
  --input test-plugin/build/libs/test-plugin-1.0.0-SNAPSHOT.jar \
  --output build/probe-server/plugins/LocalPortProbe.jar
```

Check `test-plugin/build/libs/` for the actual input filename if Gradle's project version differs. Packaging copies only the probe classes into a separate JAR and leaves the input unchanged.

Set the Java and server paths, then run the **same directory twice**:

```bash
probe_java="${JAVA_HOME:+$JAVA_HOME/bin/}java"
probe_java=$(command -v "$probe_java")
probe_jar="$PWD/paper-server/build/libs/paper-bundler-26.4-snapshot-3.local-SNAPSHOT.jar"
python3 scripts/local-port/run-private-server.py \
  --java "$probe_java" --jar "$probe_jar" --directory "$PWD/build/probe-server" \
  --port 25577 --marker 'PORT_PROBE_PASS phase=1' --timeout 600
python3 scripts/local-port/run-private-server.py \
  --java "$probe_java" --jar "$probe_jar" --directory "$PWD/build/probe-server" \
  --port 25577 --marker 'PORT_PROBE_PASS phase=2' --timeout 600
```

Each run binds to `127.0.0.1`, waits for the acceptance marker, queries server status, saves and stops gracefully. A zero exit requires a matching marker, successful status response and clean server exit. Logs and JSON receipts remain in `build/probe-server`; detailed probe receipts are under its `plugins/LocalPortProbe` directory.

The probe covers adjacent-block biome precision in the world and snapshots, chunk/structure persistent data, IceCrystal/Icicle block states and sounds, Frostbite/IceBall API wrappers and staged Bukkit generation callback order. The second run checks persisted results.

## World conversion evidence

The original experiment also opened a disposable 26.3 flat-world copy in two starts and inspected chunk data versions and persistent data. The input world is not distributed. Reproducing that scenario requires your own **copy** and additional checks appropriate to it. This publication's fresh-world probe does not certify conversion of your existing world.

## Retrogen terrain-preservation correction

Loading old full chunks on 26.4 reruns the biome conversion. Vanilla advances the persisted status back to `FULL` after that step; Moonrise previously overwrote it with `BIOMES`, which caused later terrain-generation stages to run again. The added feature patch preserves the advanced status and applies vanilla's retrogen transition to empty generation steps as well.

The initial publication did not catch this regression. A later disposable normal-world migration exposed overwritten blocks and lost container contents. The corrected build was tested against untouched older chunk records with a changed world seed. Block-state and container comparisons, restart results, test totals and clean-patch replay are recorded in [retrogen-preservation.json](../validation/retrogen-preservation.json). The private input world, player data and plugin data are excluded from this repository. Fresh-world probe results alone cannot establish terrain fidelity during conversion.
