# Open bash terminal and run the following commands:
#!/bin/bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew update
# Install Homebrew Bundle from Brewfile
brew install cask
brew bundle

# Enable Remote Login
sudo systemsetup -setremotelogin on
# Enable Screen Sharing
sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.screensharing.plist