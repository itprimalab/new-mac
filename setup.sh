#!/bin/bash

# Install Xcode Command Line Tools (skip if already installed)
if ! command -v xcode-select &> /dev/null; then
    echo "Installing Xcode Command Line Tools"
    xcode-select --install
else
    echo "Xcode Command Line Tools already installed"
fi

# Set Mac hostname, press enter to skip
echo "Enter the hostname for this Mac, or press enter to skip"
read hostname

if [ -z "$hostname" ]
then
    echo "Skipping hostname change"
else
    sudo scutil --set ComputerName "$hostname"
    sudo scutil --set HostName "$hostname"
    sudo scutil --set LocalHostName "$hostname"
    sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "$hostname"
fi

# Get sudo permissions
sudo -v

# Keep-alive: update existing `sudo` time stamp until `setup.sh` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Create Desktop directory if it doesn't exist
mkdir -p ~/Desktop

# Install Homebrew Silently
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add Homebrew to PATH
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/$(whoami)/.zprofile

# Refresh the terminal so that Homebrew is added to PATH
source ~/.zprofile

# Clone the repository into Desktop
cd ~/Desktop
git clone https://github.com/itprimalab/new-mac

# Change directory to the cloned repository
cd ~/Desktop/new-mac

# Update Homebrew
brew update

# Install Homebrew cask
brew install cask

# Install python
brew install python

# Install dockutil from the Github repository
curl -LO https://github.com/kcrawford/dockutil/releases/download/3.0.2/dockutil-3.0.2.pkg
sudo installer -pkg dockutil-3.0.2.pkg -target /

# Install packages from Brewfile
brew bundle

# Download the Dymo Label Software 8.7.5. It is a dmg file, so we need to mount it and install the pkg inside.
if [ -d "/Applications/Dymo Label.app" ]
then
    echo "Dymo Label already installed"
else
    curl -LO https://download.dymo.com/dymo/Software/Mac/DLS8Setup.8.7.5.dmg
    hdiutil attach DLS8Setup.8.7.5.dmg
    sudo installer -pkg /Volumes/DYMO\ Label\ v.8.pkg/DYMO\ Label\ v.8.pkg -target /
    hdiutil detach /Volumes/DYMO\ Label\ v.8.pkg
fi

# Delete all the apps from the dock
dockutil --remove all
killall Dock

# Read the application folder for apps that are not the default ones, and add them to the dock. Ignore OneDrive, 
find /Applications -maxdepth 1 -type d -name "*.app" -exec basename {} \; | sort | while read app; do
    if [[ ! -f "/System/Library/CoreServices/$app" ]]; then
        dockutil --add "/Applications/$app" --no-restart
    fi
done

# Restart the dock to apply changes
killall Dock

# If it doesn't exist, create the Admin user
if id "admin" &>/dev/null; then
    echo "Admin user already exists"
else
    sudo dscl . -create /Users/admin
    sudo dscl . -create /Users/admin UserShell /bin/bash
    sudo dscl . -create /Users/admin RealName "Admin"
    sudo dscl . -create /Users/admin UniqueID "1001"
    sudo dscl . -create /Users/admin PrimaryGroupID 80
    sudo dscl . -create /Users/admin NFSHomeDirectory /Users/admin
    # Prompt for password
    sudo dscl . -passwd /Users/admin
    sudo dscl . -append /Groups/admin GroupMembership admin
    sudo createhomedir -c -u admin > /dev/null
fi

# Enable remote management for Admin user
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate -configure -access -on -users admin -privs -all -restart -agent -menu

# Enable screen sharing
sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.screensharing.plist
