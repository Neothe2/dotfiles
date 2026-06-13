#!/bin/bash

# Exit immediately if any command fails
set -e

# --- CONFIGURATION ---
GITHUB_USERNAME="NeoThe2" # <-- CHANGE THIS
REPO_URL="https://github.com/$GITHUB_USERNAME/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"

# --- FABULOUS FORMATTING ---
# ANSI Color Codes for terminal output
BLUE='\033[1;34m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
MAGENTA='\033[1;35m'
NC='\033[0m' # No Color

# Helper functions for stylized output
info() { echo -e "${BLUE}[ ℹ ]${NC} $1"; }
success() { echo -e "${GREEN}[ ✔ ]${NC} $1"; }
warn() { echo -e "${YELLOW}[ ⚠ ]${NC} $1"; }
error() {
  echo -e "${RED}[ ❌ ]${NC} $1"
  exit 1
}

echo -e "${MAGENTA}"
cat <<"EOF"
 🚀 BOOTSTRAPPING SYSTEM ENVIRONMENT 🚀
EOF
echo -e "${NC}"

# --- 1. CORE SYSTEM PACKAGES & TOOLS ---
info "Checking and installing core packages (Git, Stow, Zsh, Wget, Curl, Build-Essential, pipx)..."
# We ask for sudo upfront so it doesn't interrupt the flow later
sudo -v

# Keep alive: update existing `sudo` time stamp until the script has finished
while true; do
  sudo -n true
  sleep 60
  kill -0 "$$" || exit
done 2>/dev/null &

sudo apt update -y
# Added pipx and python3-venv here
sudo apt install -y git stow zsh curl tar wget build-essential tmux pipx python3-venv

info "Installing GitHub CLI (gh)..."
(type -p wget >/dev/null || (sudo apt update && sudo apt install wget -y)) &&
  sudo mkdir -p -m 755 /etc/apt/keyrings &&
  out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg &&
  cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null &&
  sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg &&
  sudo mkdir -p -m 755 /etc/apt/sources.list.d &&
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null &&
  sudo apt update &&
  sudo apt install gh -y
success "GitHub CLI installed successfully."

# --- 2. INSTALL NEOVIM (LATEST) ---
info "Fetching the latest Neovim release..."
cd /tmp
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
info "Extracting Neovim to /opt..."
sudo rm -rf /opt/nvim-linux-x86_64
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
sudo rm nvim-linux-x86_64.tar.gz

# Create a symlink so 'nvim' is available globally in your PATH
info "Symlinking Neovim binary to /usr/local/bin..."
sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
success "Neovim installed successfully."

# --- 3. CLONE REPOSITORY ---
if [ -d "$DOTFILES_DIR" ]; then
  warn "$DOTFILES_DIR already exists. Pulling latest changes..."
  cd "$DOTFILES_DIR" && git pull
else
  info "Cloning dotfiles repository..."
  git clone "$REPO_URL" "$DOTFILES_DIR"
fi
success "Dotfiles repository ready."

# --- 4. ZSH ECOSYSTEM SETUP ---
info "Setting up Zsh environment..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  # Unattended install prevents the script from stopping and jumping into zsh immediately
  CHSH=no RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  success "Oh My Zsh installed."
else
  info "Oh My Zsh is already installed."
fi

# Powerlevel10k
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
  info "Installing Powerlevel10k theme..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
else
  info "Powerlevel10k is already installed."
fi

# Zsh Autosuggestions
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
  info "Installing Zsh Autosuggestions plugin..."
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
else
  info "Zsh Autosuggestions is already installed."
fi

# --- 5. PREPARE HOME DIRECTORY ---
if [ -f "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ]; then
  warn "Backing up default .zshrc to .zshrc.bak..."
  mv "$HOME/.zshrc" "$HOME/.zshrc.bak"
fi

# --- 6. STOW CONFIGS ---
info "Stowing configurations..."
cd "$DOTFILES_DIR"

# Using a loop makes it easy to add more apps to stow later
for app in nvim zsh tmux git; do
  stow "$app"
  success "Stowed: $app"
done

# --- 7. PYTHON CLI TOOLS (pipx) ---
info "Setting up pipx and installing custom Python CLI tools..."
# ensurepath adds ~/.local/bin to your bashrc/zshrc
pipx ensurepath
info "Installing N.U.T.S from GitHub..."
pipx install "git+https://github.com/$GITHUB_USERNAME/nuts.git"
success "N.U.T.S installed successfully!"

# --- 8. CUSTOM SCRIPTS ---
info "Setting up custom scripts (tm-dev)..."

# Ensure the local bin directory exists
mkdir -p "$HOME/.local/bin"

# Make the tmux script executable
if [ -f "$DOTFILES_DIR/tm-dev.sh" ]; then
  chmod +x "$DOTFILES_DIR/tm-dev.sh"

  # Force create a symlink to ~/.local/bin so it can be run from anywhere
  ln -sf "$DOTFILES_DIR/tm-dev.sh" "$HOME/.local/bin/tm-dev"
  success "tm-dev script linked successfully!"
else
  warn "tm-dev.sh not found in $DOTFILES_DIR. Skipping."
fi

# --- 9. FINALIZE & SWITCH SHELL ---
# Check if current default shell is already zsh
if [ "$SHELL" != "$(which zsh)" ]; then
  info "Changing default shell to Zsh..."
  chsh -s $(which zsh)
  success "Default shell changed to Zsh."
else
  info "Zsh is already the default shell."
fi

echo ""
echo -e "${GREEN}=====================================================${NC}"
echo -e "${GREEN} ✨ BOOTSTRAP COMPLETE! Welcome to your new system. ✨${NC}"
echo -e "${GREEN}=====================================================${NC}"
echo -e "${BLUE}=>${NC} Run ${YELLOW}gh auth login${NC} to authenticate with GitHub."
echo -e "${BLUE}=>${NC} Open Neovim (${YELLOW}nvim${NC}) to let Tree-sitter and your package manager install everything."
echo -e "${BLUE}=>${NC} Run ${YELLOW}exec zsh${NC} or restart your terminal to apply the new shell environment."
