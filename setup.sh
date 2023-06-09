#!/bin/bash

# Set Mac hostname
echo "Insert Mac name:"
read hostname
sudo scutil --set HostName "$hostname"
sudo scutil --set LocalHostName "$hostname"
sudo scutil --set ComputerName "$hostname"

# Get sudo permissions
sudo -v

# Create Desktop directory if it doesn't exist
mkdir -p ~/Desktop

# Install Homebrew Silently
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Clone the repository into Desktop
cd ~/Desktop
git clone https://github.com/itprimalab/new-mac

# Change directory to the cloned repository
cd ~/Desktop/new-mac

# Update Homebrew
brew update

# Install Homebrew cask
brew install cask

# Install dockutil
brew install dockutil

# Install packages from Brewfile
brew bundle

# Add apps to the dock
for app in $(brew --prefix)/Caskroom/*/*.app; do
    /usr/local/bin/dockutil --add "$app" --no-restart
done

# Restart the dock to apply changes
killall Dock

# Enable remote login
sudo systemsetup -setremotelogin on

# Enable screen sharing
sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.screensharing.plist
