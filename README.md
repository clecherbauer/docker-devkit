# docker-devkit
A collection of helper scripts that turn plain Docker installations into a more comfortable development environment on Linux, Windows (WSL2), and macOS.

## Highlights
- **docker-hosts** – keeps `/etc/hosts` in sync with container network aliases so you can skip manual port bindings
- **docker-alias** – bundles a toolbox of Docker-centric commands in one binary with auto-started helpers
- **lazydocker** – brings an approachable TUI for inspecting containers, volumes, and logs
- **Traefik proxy** – optional reverse proxy for easy access to services that expose HTTP endpoints
- **direnv integration** – automatically loads project-specific environment variables when you `cd` into a directory

## Supported Environments
- Ubuntu 20.04 / 22.04 LTS (native or in WSL2)
- Windows 10 / 11 with WSL2 and Docker Desktop
- macOS (experimental; see notes below)

## Linux / WSL Ubuntu
**Requirements**
- Docker Engine with your user added to the `docker` group
- Docker Compose (`docker compose` plugin or standalone `docker-compose` binary)
- `curl`, `unzip`, and either `bash` or `zsh`

**Installation**
```bash
wget -q -O - "https://raw.githubusercontent.com/clecherbauer/tools/docker-devkit/master/linux/setup.sh" | bash
```
The script installs the toolchain, ensures daemons are started, and downloads configuration such as `/opt/traefik.toml`. You may be prompted for `sudo` when system-level files need to be written.

**Updating**
Re-run the installation command whenever you want to pull the latest versions of the bundled tools. Existing configurations (for example, shell rc files) are only appended to when new entries are required.

## Windows (WSL2)
**Requirements**
- Virtualization enabled in BIOS / UEFI
- Windows 10 Pro/Enterprise or Windows 11 with the WSL feature available
- Administrative PowerShell session for the host setup

**Prepare the Windows host**
1. Make sure Windows Update has completed and reboot if required.
2. Run an elevated PowerShell session and execute:
   ```powershell
   Set-ExecutionPolicy Bypass -Scope Process -Force; \
   [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; \
   iex ((New-Object System.Net.WebClient).DownloadString('https://gitlab.com/clecherbauer/tools/docker-devkit/-/raw/master/windows/setup_dependencies.ps1'))
   ```
   This installs WSL2, Docker Desktop, Chocolatey, and the Windows-side `docker-hosts` integration.
3. Reboot once the script finishes to ensure WSL and Docker Desktop complete their setup.
4. Install Ubuntu 20.04 (or later) from the Microsoft Store and make it the default distribution: `wsl --setdefault ubuntu`.
5. In Docker Desktop → Settings → Resources → WSL Integration, enable integration for your Ubuntu distribution.

**Install inside WSL Ubuntu**
1. Enable metadata support for your mounted Windows drives (avoids permission issues):
   ```bash
   cat <<'EOT' | sudo tee /etc/wsl.conf >/dev/null
   [automount]
   options = "metadata"
   EOT
   ```
   Exit the WSL session and run `wsl --shutdown` from Windows PowerShell or Command Prompt, then reopen Ubuntu.
2. Inside Ubuntu, run the Linux installer:
   ```bash
   wget -q -O - "https://raw.githubusercontent.com/clecherbauer/tools/docker-devkit/master/linux/setup.sh" | bash
   ```

## macOS (experimental)
Basic scripts live under `macos/`, but automation is still a work in progress. For now:
- Install Docker Desktop for Mac.
- Ensure `curl`, `wget`, and `direnv` are available (`brew install curl wget direnv`).
- Review and adapt the Linux script or contribute improvements to `macos/setup.sh` to match your workflow.

## Verification
After installation, confirm the tooling works:
- `docker ps` and `docker compose version` should succeed without `sudo`.
- `docker ps --format '{{.Names}}'` should list a running `docker-hosts` container.
- `which docker-alias` should resolve to `~/.local/bin/docker-alias`.
- `lazydocker` should start the TUI within the terminal.

## Troubleshooting
- If Docker commands fail with permission errors, log out and back in (or restart WSL) so the updated group membership takes effect.
- Traefik listens on port 80. Stop the `traefik-proxy` container (`docker stop traefik-proxy`) if you need that port for something else.
- Re-run the setup script with `bash -x` for verbose output if you need to diagnose installation issues.

## Contributing
Issues and pull requests that improve the setup scripts, especially macOS support, are very welcome. Check the `linux/`, `windows/`, and `macos/` directories for platform-specific logic before submitting changes.
