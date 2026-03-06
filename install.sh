#!/usr/bin/env bash
# xbox-cloud-kiosk — Post-install setup
# Adds a desktop launcher and optionally enables auto-launch on login.
# Works on any Linux desktop that respects ~/.config/autostart (KDE, GNOME, XFCE, etc.)

set -e

CYAN='\033[0;36m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${CYAN}Xbox Cloud Gaming Kiosk — Setup${NC}"
echo "-----------------------------------"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Desktop shortcut
echo -e "\n${CYAN}Installing app launcher shortcut...${NC}"
mkdir -p "$HOME/.local/share/applications"
cp "$SCRIPT_DIR/assets/xbox-cloud-kiosk.desktop" "$HOME/.local/share/applications/"
update-desktop-database "$HOME/.local/share/applications/" 2>/dev/null || true
echo -e "${GREEN}✓ Shortcut added — search for 'Xbox Cloud Gaming' in your launcher${NC}"

# Autostart
echo -e "\n${CYAN}Enabling auto-launch on login...${NC}"
mkdir -p "$HOME/.config/autostart"
cp "$SCRIPT_DIR/assets/xbox-cloud-kiosk-autostart.desktop" "$HOME/.config/autostart/"
echo -e "${GREEN}✓ Autostart enabled — app will launch on next login${NC}"

echo ""
echo -e "${GREEN}All done!${NC}"
echo "To disable auto-launch at any time:"
echo "  rm ~/.config/autostart/xbox-cloud-kiosk-autostart.desktop"
