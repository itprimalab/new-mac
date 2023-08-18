#!/bin/bash

# Install Xcode Command Line Tools
xcode-select --install

# Set Mac hostname
echo "Insert Mac name:"
read hostname
sudo scutil --set HostName "$hostname"
sudo scutil --set LocalHostName "$hostname"
sudo scutil --set ComputerName "$hostname"

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

# Delete all the apps from the dock
dockutil --remove all
killall Dock

# Add all apps installed from Brewfile to the dock, reading the brewfile
dockutil --add $(brew bundle dump --force --describe --file=- | awk '/^mas / {print $2}') --no-restart

# Restart the dock to apply changes
killall Dock

# Enable remote login
sudo systemsetup -setremotelogin on

# Enable screen sharing
sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.screensharing.plist
