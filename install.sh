#!/bin/bash

# Functions to print highlighted messages in a
highlight_msg() {
    echo -e "\e[1;33m####################################################\e[0m" # Yellow color
    echo -e "\e[1;33m# $1\e[0m" # Yellow color
    echo -e "\e[1;33m####################################################\e[0m" # Yellow color
}

highlight_msg_green() {
    echo -e "\e[1;32m#########################\e[0m" # Green color
    echo -e "\e[1;32m# $1\e[0m"                           # Green color
    echo -e "\e[1;32m#########################\e[0m" # Green color
}

highlight_msg "Installing necessary dependencies..."
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
highlight_msg "Importing Tor Browser Developers' signing key..."
gpg --auto-key-locate nodefault,wkd --locate-keys torbrowser@torproject.org

# Set trust level to ultimate
echo -e "trust\n5\ny\nquit" | gpg --command-fd 0 --edit-key EF6E286DDA85EA2A4BA7DE684E2C6E8793298290

# Download files using wget
highlight_msg "Downloading Mullvad Browser and its signature..."
wget "$MULLVAD_URL" -O "$TAR_FILE"
wget "$SIGNATURE_URL" -O "$SIG_FILE"
echo "Download complete."

# Verify the integrity of the downloaded file
highlight_msg "Verifying the integrity of the downloaded file..."
gpg --verify "$SIG_FILE" "$TAR_FILE"
if [ $? -ne 0 ]; then
    echo -e "\e[1;31mGPG verification failed.\e[0m" # Red color for error message
    exit 1
fi
echo "Verification successful."

# Extract to ~/.local/share
highlight_msg "Installing..."
INSTALL_DIR="${HOME}/.local/share"
mkdir -p "$INSTALL_DIR"
tar xf "$TAR_FILE" -C "$INSTALL_DIR"

# Set permissions
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
highlight_msg_green "Installation complete!"
