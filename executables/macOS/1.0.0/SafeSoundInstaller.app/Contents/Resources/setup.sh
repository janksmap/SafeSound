#!/bin/bash

# Ask for sudo once upfront
sudo -v
# Keep-alive: update existing `sudo` time stamp until script finishes
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# 1. Install Homebrew if missing
if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)" # For Apple Silicon
fi

# 2. Install Xcode Command Line Tools if missing
if ! xcode-select -p &> /dev/null; then
    echo "Installing Xcode Command Line Tools..."
    xcode-select --install
    until xcode-select -p &> /dev/null; do
        sleep 5
    done
fi

# 3. Install ffmpeg if missing
if ! command -v ffmpeg &> /dev/null; then
    echo "Installing ffmpeg..."
    brew install ffmpeg
fi

# 4. Install pyenv if missing
if ! command -v pyenv &> /dev/null; then
    echo "Installing pyenv..."
    brew install pyenv
fi

# 5. Install Docker Desktop if missing (do not start)
if [ ! -d "/Applications/Docker.app" ]; then
    echo "Installing Docker Desktop..."
    brew install --cask docker
else
    echo "Docker Desktop already installed. Skipping."
fi

# 6. Check for existing SafeSound folder and confirm removal
if [ -d ~/Downloads/SafeSound ]; then
    echo "Warning: ~/Downloads/SafeSound already exists."
    read -p "Do you want to delete and re-clone it? (y/N): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        rm -rf ~/Downloads/SafeSound
        echo "Old SafeSound folder deleted."
    else
        echo "Skipping cloning SafeSound."
        skip_clone=true
    fi
fi

# Clone SafeSound if not skipped
if [ "$skip_clone" != true ]; then
    echo "Cloning SafeSound repo to ~/Downloads..."
    git clone https://github.com/janksmap/SafeSound.git ~/Downloads/SafeSound
fi

# 7. Install Python 3.10 via pyenv if missing (any 3.10.x)
if ! pyenv versions --bare | grep -q "^3\.10\."; then
    echo "Installing Python 3.10 via pyenv..."
    pyenv install 3.10.16
else
    echo "Python 3.10 already installed via pyenv. Skipping."
fi

# 8. Set local python version and create venv
cd ~/Downloads/SafeSound || exit
pyenv local 3.10
$(pyenv which python3) -m venv venv
source venv/bin/activate

# 9. Install python requirements
pip install -r requirements.txt

# 10. Create .env from .env.template if missing
if [ ! -f .env ]; then
    cp .env.template .env
    echo ".env created from .env.template"
fi

echo "All installations complete!"

# Activate venv in SafeSound directory...

cd ~/Downloads/SafeSound || exit
pyenv local 3.10
$(pyenv which python3) -m venv venv
source venv/bin/activate

# Now inside the venv in SafeSound folder
