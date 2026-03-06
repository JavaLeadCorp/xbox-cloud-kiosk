# Xbox Cloud Gaming Kiosk

A fullscreen Electron kiosk app for Linux that opens [Xbox Cloud Gaming](https://www.xbox.com/en-US/play) as if it were a native app — no browser chrome, no address bar, no way to navigate away from Xbox.

Works on **any Linux distro**: Arch, Bazzite, Fedora, Ubuntu, Debian, Mint, Pop!_OS, Manjaro, and more.

Also Works on **MacOS** :Simply download, cd into the folder run npm install && start

---

## Features

- Fullscreen frameless window — looks and feels like a native app
- Animated Xbox-style splash screen on launch
- Navigation locked to Xbox & Microsoft domains only (login works, random browsing doesn't)
- User agent spoofed to Windows Chrome (required for Xbox Cloud Gaming to work on Linux)
- Full controller / gamepad passthrough support
- Auto-launches on login (enabled via `install.sh`)
- Sign-in persists between sessions — only log in once

---

## Requirements

- **Node.js 18+** and **npm**

| Distro | Install command |
|---|---|
| Arch / Bazzite / Manjaro | `sudo pacman -S nodejs npm` |
| Fedora | `sudo dnf install nodejs npm` |
| Debian / Ubuntu / Mint | `sudo apt install nodejs npm` |

---

## Quick Start (run from source)

```bash
git clone https://github.com/YOUR_USERNAME/xbox-cloud-kiosk.git
cd xbox-cloud-kiosk
npm install
npm start
```

---

## Building a Package

The `build.sh` script **auto-detects your distro** and builds the right format. Just run:

```bash
bash build.sh
```

Or specify a target manually:

```bash
bash build.sh deb       # Debian / Ubuntu / Mint / Pop!_OS
bash build.sh rpm       # Fedora / RHEL / openSUSE
bash build.sh arch      # Arch / Bazzite / Manjaro / EndeavourOS
bash build.sh appimage  # Universal — works on any distro
bash build.sh all       # Build all four formats at once
```

Compiled packages appear in the `dist/` folder.

---

## Installing a Built Package

| Format | Command |
|---|---|
| `.deb` (Debian/Ubuntu) | `sudo dpkg -i dist/xbox-cloud-kiosk_*.deb` |
| `.rpm` (Fedora) | `sudo dnf install dist/xbox-cloud-kiosk-*.rpm` |
| `.pkg.tar.zst` (Arch/Bazzite) | `sudo pacman -U dist/xbox-cloud-kiosk-*.pkg.tar.zst` |
| `.AppImage` (any distro) | `chmod +x dist/*.AppImage && ./dist/*.AppImage` |

After installing, run the setup script to add the app to your launcher and enable auto-launch:

```bash
bash install.sh
```

To disable auto-launch later:

```bash
rm ~/.config/autostart/xbox-cloud-kiosk-autostart.desktop
```

---

## Project Structure

```
xbox-cloud-kiosk/
├── src/
│   ├── main.js          # Electron main process
│   └── splash.html      # Animated splash screen
├── assets/
│   ├── icon.png                            # App icon — add a 512×512 PNG here
│   ├── xbox-cloud-kiosk.desktop            # App launcher shortcut
│   └── xbox-cloud-kiosk-autostart.desktop  # Autostart entry
├── build.sh             # Build script (auto-detects distro)
├── install.sh           # Post-install: adds launcher + autostart
├── package.json
└── .gitignore
```

> **Note:** You need to add your own `assets/icon.png` (512×512 PNG) before building. Any green square or Xbox logo PNG will work.

---

## Releases — Pre-compiled Downloads

Pre-compiled packages are automatically built and attached to every [GitHub Release](../../releases/latest) via GitHub Actions. If you just want to install and play, go to the **Releases** page and download the right file for your distro — no need to compile anything yourself.

| Distro | File to download |
|---|---|
| Arch / Bazzite / Manjaro / EndeavourOS | `.pkg.tar.zst` |
| Fedora / RHEL / openSUSE | `.rpm` |
| Debian / Ubuntu / Mint / Pop!_OS | `.deb` |
| Any Linux distro | `.AppImage` |

---

## Publishing a New Release

To trigger a new build and publish updated packages, just push a version tag:

```bash
git tag v1.0.0
git push origin v1.0.0
```

GitHub Actions will automatically compile all four formats and attach them to a new Release. No manual building needed.

---

## 🛠️ Developer Notes — Compiling Packages

This project uses [electron-builder](https://www.electron.build/) to produce native Linux packages. Here's exactly how each format is built and what you need on your system.

### General prerequisites

```bash
npm install          # installs electron and electron-builder locally
```

electron-builder downloads its own bundled copy of Electron, so you don't need to install Electron globally.

---

### Debian / Ubuntu — `.deb`

**.deb** is the native package format for Debian and all derivatives (Ubuntu, Linux Mint, Pop!_OS, etc.). It's installed via `dpkg` or `apt`.

**No extra system tools needed** — electron-builder handles `.deb` creation entirely in Node using its own bundled tooling.

```bash
# Build
npm run build:deb

# Install the output
sudo dpkg -i dist/xbox-cloud-kiosk_1.0.0_amd64.deb

# If dpkg complains about missing dependencies, fix with:
sudo apt --fix-broken install
```

The `.deb` will install the binary to `/opt/xbox-cloud-kiosk/` and register the app with the system. Then run `bash install.sh` to add the desktop shortcut and autostart.

---

### Fedora / RHEL — `.rpm`

**.rpm** is the native package format for Red Hat-based distros — Fedora, RHEL, CentOS Stream, and openSUSE. It's installed via `dnf` (Fedora) or `rpm`.

**Extra system tool required:** `rpmbuild` must be installed before building.

```bash
# Install rpmbuild first (Fedora)
sudo dnf install rpm-build

# Build
npm run build:rpm

# Install the output
sudo dnf install dist/xbox-cloud-kiosk-1.0.0.x86_64.rpm
# or with rpm directly:
sudo rpm -i dist/xbox-cloud-kiosk-1.0.0.x86_64.rpm
```

Then run `bash install.sh` to add the desktop shortcut and autostart.

> **Note:** RPM builds must be done on a Linux machine. You cannot cross-compile an `.rpm` from macOS or Windows.

---

### Arch Linux / Bazzite — `.pkg.tar.zst`

**.pkg.tar.zst** is the native package format for Arch Linux and all Arch-based distros (Bazzite, Manjaro, EndeavourOS). It's installed via `pacman`.

**No extra system tools needed** — electron-builder handles this format itself.

```bash
# Build
npm run build:arch

# Install the output
sudo pacman -U dist/xbox-cloud-kiosk-1.0.0.pacman
```

> **Note:** electron-builder names the file with a `.pacman` extension. `pacman -U` accepts it regardless.

Then run `bash install.sh` to add the desktop shortcut and autostart.

---

### Universal — `.AppImage`

**.AppImage** is a self-contained executable that runs on **any** Linux distro without installation. It bundles everything it needs. This is the best format if you want to share one file that works everywhere.

```bash
# Build
npm run build:appimage

# Run directly — no install needed
chmod +x dist/Xbox\ Cloud\ Gaming-1.0.0.AppImage
./dist/Xbox\ Cloud\ Gaming-1.0.0.AppImage
```

For a nicer experience on AppImage, you can integrate it with your launcher using [AppImageLauncher](https://github.com/TheAssassin/AppImageLauncher).

---

### Build all formats at once

```bash
npm run build:all
```

> **Note:** Building the `.rpm` format requires `rpmbuild` to be installed (see the Fedora section above).

---

## Notes

- Fortnite is **free** on Xbox Cloud Gaming — no Game Pass needed (as of December 2025).
- Sign in with any free Microsoft account.
- Press **Alt+F4** to close the app.

---

## License

MIT
