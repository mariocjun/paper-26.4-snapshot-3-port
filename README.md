# Experimental Paper port for Minecraft 26.4 Snapshot 3

Reproduce the local Paper port used to build and play-test **Minecraft 26.4 Snapshot 3**. This repository contains a patch against a pinned Paper commit, build scripts, tests and a two-start runtime probe.

**Unofficial community experiment.** It is not a PaperMC release and is not affiliated with PaperMC or Mojang. It runs the snapshot server itself; the patch changes Paper's integrations, API and world generation support.

**Existing-world correction, 2026-10-10:** the initial publication (`b63a9ad`) could regenerate terrain when loading older chunks. The current patch fixes Moonrise overwriting the completed retrogen status. Rebuild with the updated patch in a fresh build directory before testing an existing-world copy. See [the regression evidence](validation/retrogen-preservation.json); this correction does not certify every world or plugin migration.

| Component | Pinned value |
| --- | --- |
| Paper base | `cc7b98af634be07c9b3581306c7b6af33caa3ff2` |
| Minecraft | `26.4-snapshot-3` |
| Mache | `io.papermc:mache:26.4-snapshot-3+build.1` |
| Build/runtime JDK | Java 25 |
| Patch provenance | [provenance.json](provenance.json) |

## Build from scratch

Use Linux or WSL, with Bash, Git, Python 3, `sha256sum`, and **JDK 25** installed. Internet access is needed to fetch Paper, Gradle and Minecraft/build dependencies. Allow several GB of disk space and enough memory for compilation. In WSL, build under the Linux home directory for better filesystem performance.

```bash
git clone https://github.com/mariocjun/paper-26.4-snapshot-3-port.git
cd paper-26.4-snapshot-3-port

# If JDK 25 is not already the selected Java:
# export JAVA_HOME=/path/to/jdk-25
# export PATH="$JAVA_HOME/bin:$PATH"
java -version

bash scripts/apply-port.sh
bash scripts/build.sh
```

The patch script verifies its SHA-256, downloads the exact upstream commit into a **new** `build/Paper` directory, checks that the patch applies, and commits the patched source locally. It refuses an existing destination. An alternative new destination can be supplied to both scripts:

```bash
bash scripts/apply-port.sh "$HOME/paper-snapshot-test"
bash scripts/build.sh "$HOME/paper-snapshot-test"
```

The runnable server is:

```text
build/Paper/paper-server/build/libs/paper-bundler-26.4-snapshot-3.local-SNAPSHOT.jar
```

The build script first applies Paper's source/feature patches through paperweight, then runs both unit-test suites and creates the bundler JAR. See [the build and patch details](docs/BUILD.md) for the direct Gradle commands and the Mache coordinate adjustment.

## Run a disposable test server

Read and accept the [Minecraft EULA](https://www.minecraft.net/eula) before setting `eula=true`. Use a **new world** or a backup copy for experiments. JDK 25 is also required at runtime.

```bash
mkdir -p runtime/manual
cd runtime/manual
printf 'eula=true\n' > eula.txt
printf 'server-ip=127.0.0.1\nserver-port=25565\n' > server.properties
java -Xms512M -Xmx2G -jar ../../build/Paper/paper-server/build/libs/paper-bundler-26.4-snapshot-3.local-SNAPSHOT.jar --nogui
```

Join with the **26.4 Snapshot 3 Java client** at `localhost:25565`, then use `stop` in the server console to save and exit. A different snapshot or a released client may use a different protocol. For Windows, run these commands in a WSL terminal; Linux paths and Bash line continuations cannot be pasted directly into PowerShell.

## Validation and boundaries

- The original local validation recorded **10,494 passing tests, 91 skipped tests, and zero failures/errors**, replayed 935 source patches and 38 feature patches, and booted the built server. Per-module counts are in [validation](validation/).
- The publication replay recorded **10,497 passing tests, 88 skipped tests, and zero failures/errors**, reproduced the same generated Java source tree, and passed both runtime-probe starts. Three Mojang-service-dependent profile tests ran in this replay instead of being skipped. See [publication-replay.json](validation/publication-replay.json).
- A separate probe verifies adjacent-block biome precision, chunk/structure persistent data across a restart, the new entities and block states, and staged Bukkit generation callbacks. [Reproduce the runtime probe](docs/VALIDATION.md).
- The original upgrade rehearsal used a disposable 26.3 flat-world copy. It does not establish safe migration of every existing world, plugin compatibility, terrain fidelity, or performance under load.
- Condition-only custom material rules fall back to stone in the staged Bukkit generator route. Vanilla's fused generation route retains its snapshot material rules.
- Plugin compatibility must be checked separately. Our plugin rehearsal exposed a Geyser version mismatch and an Essentials unsupported-version warning. A successful Paper build does not prove that these plugins support this snapshot.
- World upgrades may be irreversible. Keep untouched backups; do not downgrade a world after opening it on a newer version. `forceUpgrade` was not validated as a migration procedure here.

The port was developed with substantial assistance from OpenAI Codex, then checked through source review, builds, automated tests, runtime probes and a human gameplay session. This repository publishes the experiment and its reproducible procedure, with the limits above.

## Português

Este é o patch experimental do Paper para **Minecraft 26.4 Snapshot 3** que usamos no teste local. O passo a passo em português está em [docs/LEIA-ME-PT-BR.md](docs/LEIA-ME-PT-BR.md). O servidor é compilado a partir do commit fixado acima; Java 25, Git, Python 3 e Linux/WSL são necessários.

## License and attribution

The patch derives from [PaperMC/Paper](https://github.com/PaperMC/Paper). GPL-3.0 applies, with upstream portions retaining their original permissive terms. See [LICENSE](LICENSE), [Paper's licensing notice](UPSTREAM-LICENSE.md), and [MIT license text](licenses/MIT.md). Keep upstream attribution and license notices when redistributing modifications. Minecraft and downloaded dependency artifacts remain subject to their respective terms. This repository distributes source patches and build instructions; the build downloads its required inputs locally.
