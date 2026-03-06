#!/usr/bin/env bash
# xbox-cloud-kiosk — Build Script
#
# Automatically detects your Linux distro and builds the appropriate package.
# You can also pass a target manually:
#
#   bash build.sh deb        → .deb  (Debian, Ubuntu, Mint, Pop!_OS)
#   bash build.sh rpm        → .rpm  (Fedora, RHEL, openSUSE)
#   bash build.sh arch       → .pkg.tar.zst  (Arch, Bazzite, Manjaro, EndeavourOS)
#   bash build.sh appimage   → .AppImage  (universal — runs on any distro)
#   bash build.sh all        → all four formats

set -e

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${CYAN}Xbox Cloud Gaming Kiosk — Build${NC}"
echo "---------------------------------"

# ── Dependency check ──────────────────────────────────────────────────────────
if ! command -v node &>/dev/null; then
  echo -e "${RED}Error: Node.js is not installed.${NC}"
  echo ""
  echo "Install it for your distro:"
  echo "  Arch / Bazzite:     sudo pacman -S nodejs npm"
  echo "  Fedora:             sudo dnf install nodejs npm"
  echo "  Debian / Ubuntu:    sudo apt install nodejs npm"
  exit 1
fi

# RPM builds also need rpmbuild on the system
if [[ "$1" == "rpm" || "$1" == "all" ]]; then
  if ! command -v rpmbuild &>/dev/null; then
    echo -e "${YELLOW}Warning: rpmbuild not found. Installing...${NC}"
    if command -v dnf &>/dev/null;    then sudo dnf install -y rpm-build
    elif command -v apt &>/dev/null;  then sudo apt install -y rpm
    elif command -v pacman &>/dev/null; then sudo pacman -S --noconfirm rpm-tools
    fi
  fi
fi

# ── Install npm dependencies ───────────────────────────────────────────────────
if [ ! -d "node_modules" ]; then
  echo -e "\n${CYAN}Installing dependencies...${NC}"
  npm install
fi

# ── Determine build target ────────────────────────────────────────────────────
TARGET="${1:-auto}"

if [[ "$TARGET" == "auto" ]]; then
  if [ -f /etc/os-release ]; then
    source /etc/os-release
    ID_LOWER=$(echo "$ID $ID_LIKE" | tr '[:upper:]' '[:lower:]')
    if echo "$ID_LOWER" | grep -qE "arch|bazzite|manjaro|endeavour"; then
      TARGET="arch"
    elif echo "$ID_LOWER" | grep -qE "fedora|rhel|centos|opensuse|suse"; then
      TARGET="rpm"
    elif echo "$ID_LOWER" | grep -qE "debian|ubuntu|mint|pop"; then
      TARGET="deb"
    else
      echo -e "${YELLOW}Distro not recognised — falling back to AppImage (works on everything).${NC}"
      TARGET="appimage"
    fi
    echo -e "${CYAN}Detected distro: ${NAME} → building ${TARGET}${NC}"
  else
    echo -e "${YELLOW}Could not detect distro — building AppImage.${NC}"
    TARGET="appimage"
  fi
fi

# ── Clean previous output ─────────────────────────────────────────────────────
echo -e "\n${CYAN}Cleaning previous builds...${NC}"
rm -rf dist/
echo -e "${GREEN}✓ Cleaned${NC}"

# ── Build ─────────────────────────────────────────────────────────────────────
echo -e "\n${CYAN}Building target: ${TARGET}${NC}"

case "$TARGET" in
  deb)      npx electron-builder --linux deb ;;
  rpm)      npx electron-builder --linux rpm ;;
  arch)     npx electron-builder --linux pacman ;;
  appimage) npx electron-builder --linux AppImage ;;
  all)      npx electron-builder --linux AppImage deb rpm pacman ;;
  *)
    echo -e "${RED}Unknown target: $TARGET${NC}"
    echo "Valid targets: deb | rpm | arch | appimage | all"
    exit 1
    ;;
esac

# ── Output summary ────────────────────────────────────────────────────────────
echo -e "\n${GREEN}Build complete! Files in dist/:${NC}"
ls dist/*.deb dist/*.rpm dist/*.pkg.tar.zst dist/*.AppImage 2>/dev/null || true

echo ""
echo "Install instructions:"
echo "  .deb  (Debian/Ubuntu):  sudo dpkg -i dist/xbox-cloud-kiosk_*.deb"
echo "  .rpm  (Fedora):         sudo dnf install dist/xbox-cloud-kiosk-*.rpm"
echo "  .pkg  (Arch/Bazzite):   sudo pacman -U dist/xbox-cloud-kiosk-*.pkg.tar.zst"
echo "  .AppImage (any distro): chmod +x dist/*.AppImage && ./dist/*.AppImage"
echo ""
echo "Then run:  bash install.sh"
