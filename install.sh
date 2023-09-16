#!/bin/bash

# Directly install necessary tools
sudo apt update
sudo apt install -y curl gpg libdbus-glib-1-dev

# Working directory
WORK_DIR="/tmp/mullvad_browser"

# Download URLs
MULLVAD_URL="https://mullvad.net/en/download/browser/linux64/latest"
SIGNATURE_URL="https://mullvad.net/en/download/browser/linux64/latest/signature"

# File names
TAR_FILE="mullvad_browser.tar.xz"
SIG_FILE="mullvad_browser.tar.xz.asc"

# Create working directory
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

# Download and import Tor Browser Developers' signing key
gpg --auto-key-locate nodefault,wkd --locate-keys torbrowser@torproject.org

# Set trust level to ultimate
echo -e "trust\n5\ny\nquit" | gpg --command-fd 0 --edit-key EF6E286DDA85EA2A4BA7DE684E2C6E8793298290

# Download files
curl -L "$MULLVAD_URL" -o "$TAR_FILE"
curl -L "$SIGNATURE_URL" -o "$SIG_FILE"

# Verify the integrity of the downloaded file
gpg --verify "$SIG_FILE" "$TAR_FILE"
if [ $? -ne 0 ]; then
    echo "GPG verification failed."
    exit 1
fi

# Extract to ~/.local/share
INSTALL_DIR="${HOME}/.local/share"
mkdir -p "$INSTALL_DIR"
tar xf "$TAR_FILE" -C "$INSTALL_DIR"

# Set permissions for ~/.local/share/mullvad-browser to be readable and executable by the user
chmod -R 755 "$INSTALL_DIR"

# Create a desktop file
DESKTOP_FILE_DIR="${HOME}/.local/share/applications"
DESKTOP_FILE_PATH="${DESKTOP_FILE_DIR}/start-mullvad-browser.desktop"

mkdir -p "$DESKTOP_FILE_DIR"

cat > "$DESKTOP_FILE_PATH" <<EOL
[Desktop Entry]
Type=Application
Name=Mullvad Browser
GenericName=Web Browser
Comment=Mullvad Browser  is +1 for privacy and −1 for mass surveillance
Categories=Network;WebBrowser;Security;
Exec=${HOME}/.local/share/mullvad-browser/Browser/start-mullvad-browser --detach
X-MullvadBrowser-ExecShell=${HOME}/.local/share/mullvad-browser/Browser/start-mullvad-browser --detach
Icon=${HOME}/.local/share/mullvad-browser/Browser/browser/chrome/icons/default/default128.png
StartupWMClass=Mullvad Browser
EOL

# Cleanup
rm -rf "$WORK_DIR"
