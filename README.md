# Matter Scripts

Helper scripts to simplify setting up the ESP-IDF and ESP-Matter development environments.

## Scripts

### `env.sh`

Sets up your environment for working with ESP-IDF and ESP-Matter:

- Sources `esp-idf` and `esp-matter` environment scripts.
- Enables `ccache` to speed up compilation.
- Sets the Matter SDK path (`$MATTER_SDK_PATH`) and adds Matter host tools to your `PATH`.
- Provides helpful shortcuts for common IDF commands:
  - `itarget` — Set target
  - `ibuild` — Build project
  - `iflash` — Flash firmware
  - `ierase` — Erase flash
  - `imenu` — Open menuconfig
  - `imonitor` — Monitor serial output
- Provides a helper function `iflashmfg` to easily flash manufacturing binaries.

**Usage:**
```bash
source env.sh
```

### install.sh

Fully automated setup of the ESP-IDF and ESP-Matter SDKs.

| Option                       | Description                                            |
|------------------------------|--------------------------------------------------------|
| `--packages`                 | Install required system packages                       |
| `--idf-version <ver>`        | Specify ESP-IDF version (default: `v5.4.1`)            |
| `--matter-branch <branch>`   | Specify ESP-Matter branch (default: `main`)            |
| `--clean-idf`                | Remove existing `~/esp-idf` before setup               |
| `--clean-matter`             | Remove existing `~/esp-matter` before setup            |
| `--clean`                    | Shortcut for `--clean-idf` and `--clean-matter`        |
| `--help, -h`                 | Show usage instructions                               |

Examples:

Basic (installs esp-idf and esp-matter)
```bash
./install.sh
```

Use a different ESP-IDF version:
```bash
./install.sh --idf-version v5.3
```

