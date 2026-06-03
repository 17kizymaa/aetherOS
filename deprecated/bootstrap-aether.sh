#!/bin/bash
# aetherOS v0.1 Bootstrap Script
# Run on a fresh Debian Stable + XFCE install
# Idempotent — safe to run again

set -euo pipefail

echo "=== aetherOS Bootstrap Starting ==="

# Update system
sudo apt update && sudo apt upgrade -y

# Base packages (from critique)
sudo apt install -y \
    xfce4 xfce4-goodies lightdm \
    network-manager firefox-esr thunar mousepad \
    curl wget git jq ripgrep fzf \
    python3 python3-venv \
    rsync borgbackup restic timeshift syncthing \
    zenity yad  # for simple UI

# Productivity packages
sudo apt install -y \
    libreoffice gimp inkscape audacity vlc

echo "Packages installed."

# Create runtime structure
mkdir -p ~/aetherOS/{Inbox,Working,Assets,Exports,Archive,Backups}
mkdir -p ~/aetherOS/project-templates/{artist,small-business,writing}

# Simple templates
cat > ~/aetherOS/project-templates/README-TODAY.md << 'EOF'
# README-TODAY.md
Date: $(date +%Y-%m-%d)
Project: 
Current state: 
Next action: 
EOF

# Create Aether Workbench launcher
cat > ~/.local/share/applications/aether-workbench.desktop << 'EOF'
[Desktop Entry]
Name=Aether Workbench
Comment=Calm production workspace
Exec=zenity --list --title="Aether Workbench" --column="Action" \
"Start New Project" \
"Open Projects Folder" \
"Backup Now" \
"System Health" \
"Ask Aether Assistant" \
--height=300 --width=400
Type=Application
Terminal=false
Categories=Utility;
Icon=system-run
EOF

chmod +x ~/.local/share/applications/aether-workbench.desktop

# Copy launcher to desktop
cp ~/.local/share/applications/aether-workbench.desktop ~/Desktop/
chmod +x ~/Desktop/aether-workbench.desktop

echo "=== aetherOS Bootstrap Complete ==="
echo "✅ Aether Workbench is now on your desktop."
echo "Next: Run the workbench and test 'Start New Project'"
