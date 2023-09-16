#!/bin/bash

echo "Installing necessary dependencies..."
sudo apt update
sudo apt install -y gpg libdbus-glib-1-2
echo "Dependencies installed successfully."

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
echo "Importing Tor Browser Developers' signing key..."
gpg --auto-key-locate nodefault,wkd --locate-keys torbrowser@torproject.org

# Set trust level to ultimate
echo -e "trust\n5\ny\nquit" | gpg --command-fd 0 --edit-key EF6E286DDA85EA2A4BA7DE684E2C6E8793298290

# Download files using wget
echo "Downloading Mullvad Browser and its signature..."
wget "$MULLVAD_URL" -O "$TAR_FILE"
wget "$SIGNATURE_URL" -O "$SIG_FILE"
echo "Download complete."

# Verify the integrity of the downloaded file
echo "Verifying the integrity of the downloaded file..."
gpg --verify "$SIG_FILE" "$TAR_FILE"
if [ $? -ne 0 ]; then
    echo "GPG verification failed."
    exit 1
fi
echo "Verification successful."

# Extract to ~/.local/share
echo "Extracting the downloaded browser..."
INSTALL_DIR="${HOME}/.local/share"
mkdir -p "$INSTALL_DIR"
tar xf "$TAR_FILE" -C "$INSTALL_DIR"
echo "Extraction complete."

# Set permissions
echo "Setting permissions..."
chmod -R 755 "$INSTALL_DIR"
echo "Permissions set."

# Create a desktop file
echo "Creating a menu shortcut..."
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
echo "Cleaning up temporary files..."
rm -rf "$WORK_DIR"
echo "Installation complete!"
