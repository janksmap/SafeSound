#!/bin/bash

sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

echo "Starting uninstall process..."

# 1. Remove SafeSound folder
if [ -d ~/Downloads/SafeSound ]; then
    rm -rf ~/Downloads/SafeSound
    echo "Deleted ~/Downloads/SafeSound"
fi

# 2. List and remove Python 3.10 versions from pyenv (ask first)
if command -v pyenv &> /dev/null; then
    py310_versions=$(pyenv versions --bare | grep "^3\.10\.")
    if [ -n "$py310_versions" ]; then
        echo "Python 3.10 versions installed via pyenv:"
        echo "$py310_versions"
        read -p "Remove all these Python 3.10 versions? (y/N): " confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            for v in $py310_versions; do
                pyenv uninstall -f "$v"
                echo "Uninstalled Python $v"
            done
        else
            echo "Skipped uninstalling Python 3.10 versions"
        fi
    fi
fi

# 3. Uninstall pyenv (ask first)
if brew list --formula | grep -q "^pyenv$"; then
    read -p "Uninstall pyenv? (y/N): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        brew uninstall pyenv
        echo "Uninstalled pyenv"
    else
        echo "Skipped uninstalling pyenv"
    fi
fi

# 4. Uninstall ffmpeg (ask first)
if brew list --formula | grep -q "^ffmpeg$"; then
    read -p "Uninstall ffmpeg? (y/N): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        brew uninstall ffmpeg
        echo "Uninstalled ffmpeg"
    else
        echo "Skipped uninstalling ffmpeg"
    fi
fi

# 5. Uninstall Docker Desktop (ask first)
if brew list --cask | grep -q "^docker$"; then
    read -p "Uninstall Docker Desktop? (y/N): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        brew uninstall --cask docker
        echo "Uninstalled Docker Desktop"
    else
        echo "Skipped uninstalling Docker Desktop"
    fi
fi

# 6. Uninstall Homebrew (ask first)
if [ -d /opt/homebrew ]; then
    read -p "Uninstall Homebrew? (y/N): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
    else
        echo "Skipped uninstalling Homebrew"
    fi
fi

# 7. Remove Xcode Command Line Tools (ask first)
if xcode-select -p &> /dev/null; then
    read -p "Remove Xcode Command Line Tools? (y/N): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        sudo rm -rf /Library/Developer/CommandLineTools
        echo "Removed Xcode Command Line Tools"
    else
        echo "Skipped removing Xcode Command Line Tools"
    fi
fi

echo "Uninstall complete!"
