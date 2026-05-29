#!/bin/bash

# Exit immediately if any command fails
set -e

# --- CONFIGURATION ---
GITHUB_USERNAME="YOUR_GITHUB_USERNAME" # <-- CHANGE THIS
REPO_URL="https://github.com/$GITHUB_USERNAME/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"

echo "=> 🚀 Starting new machine bootstrap..."

# --- 1. PREREQUISITE CHECKS ---
if ! command -v git &>/dev/null; then
  echo "❌ Git is not installed. Please install git (e.g., brew install git or apt install git)."
  exit 1
fi

if ! command -v stow &>/dev/null; then
  echo "❌ GNU Stow is not installed. Please install stow (e.g., brew install stow or apt install stow)."
  exit 1
fi

# --- 2. CLONE REPOSITORY ---
if [ -d "$DOTFILES_DIR" ]; then
  echo "=> ⚠️  $DOTFILES_DIR already exists. Pulling latest changes..."
  cd "$DOTFILES_DIR" && git pull
else
  echo "=> 📥 Cloning dotfiles repository..."
  git clone "$REPO_URL" "$DOTFILES_DIR"
fi

# --- 3. INSTALL DEPENDENCIES ---
echo "=> ⚙️  Installing Oh My Zsh (unattended)..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  # Unattended install prevents the script from stopping and jumping into zsh immediately
  CHSH=no RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "  -> Oh My Zsh is already installed."
fi

echo "=> 🎨 Installing Powerlevel10k..."
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
else
  echo "  -> Powerlevel10k is already installed."
fi

# --- 4. PREPARE HOME DIRECTORY ---
# Sometimes a new machine creates a default .zshrc.
# Stow will fail if a real file already exists where it wants to put a symlink.
if [ -f "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ]; then
  echo "=> 📦 Backing up default .zshrc to .zshrc.bak..."
  mv "$HOME/.zshrc" "$HOME/.zshrc.bak"
fi

# --- 5. STOW CONFIGS ---
echo "=> 🔗 Stowing configurations..."
cd "$DOTFILES_DIR"

stow nvim
stow zsh
stow tmux
stow git

echo "=> ✨ Bootstrap complete!"
echo "=> Open a new terminal session or run 'zsh' to see your environment."
echo "=> Note: Open Neovim to let your package manager automatically install your plugins."
