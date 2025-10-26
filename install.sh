#!/usr/bin/env bash
# Optimized Oh-My-Zsh Installation Script
# Fork: https://github.com/LinuxUser255/ohmyzsh
# This installs a performance-optimized version of oh-my-zsh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Repository configuration
REPO_URL="https://github.com/LinuxUser255/ohmyzsh.git"
REPO_BRANCH="master"
ZSH_DIR="$HOME/.oh-my-zsh"

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  LinuxUser255's Optimized Oh-My-Zsh${NC}"
echo -e "${CYAN}  https://github.com/LinuxUser255/ohmyzsh${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if running in zsh
if [ -n "$ZSH_VERSION" ]; then
    echo -e "${YELLOW}⚠ Warning: This script should be run in bash, not zsh${NC}"
    echo "  Please run: bash install.sh"
    exit 1
fi

# Check if zsh is installed
if ! command -v zsh &> /dev/null; then
    echo -e "${RED}✗ Error: zsh is not installed${NC}"
    echo ""
    echo "Install zsh with:"
    echo -e "  ${BLUE}sudo apt update && sudo apt install zsh${NC}"
    exit 1
fi

echo -e "${GREEN}✓${NC} Zsh found: $(zsh --version)"
echo ""

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo -e "${RED}✗ Error: git is not installed${NC}"
    echo ""
    echo "Install git with:"
    echo -e "  ${BLUE}sudo apt update && sudo apt install git${NC}"
    exit 1
fi

echo -e "${GREEN}✓${NC} Git found: $(git --version)"
echo ""

# Check if oh-my-zsh already exists
if [[ -d "$ZSH_DIR" ]]; then
    echo -e "${YELLOW}⚠ Oh-My-Zsh is already installed at $ZSH_DIR${NC}"
    echo ""
    read -p "Would you like to backup and reinstall? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        BACKUP_DIR="${ZSH_DIR}.backup-$(date +%Y%m%d-%H%M%S)"
        echo -e "${BLUE}Moving existing installation to $BACKUP_DIR${NC}"
        mv "$ZSH_DIR" "$BACKUP_DIR"
        echo -e "${GREEN}✓ Backup created${NC}"
    else
        echo -e "${RED}Installation cancelled${NC}"
        exit 0
    fi
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Step 1: Clone Optimized Oh-My-Zsh${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Clone the repository
echo "Cloning from $REPO_URL..."
git clone --depth=1 --branch "$REPO_BRANCH" "$REPO_URL" "$ZSH_DIR"

if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}✓ Successfully cloned optimized oh-my-zsh${NC}"
else
    echo -e "${RED}✗ Failed to clone repository${NC}"
    exit 1
fi

echo ""

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Step 2: Install Required Plugins${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Create custom plugins directory
ZSH_CUSTOM="$ZSH_DIR/custom"
mkdir -p "$ZSH_CUSTOM/plugins"

# Install zsh-syntax-highlighting if not already included
if [[ ! -d "$ZSH_DIR/plugins/zsh-syntax-highlighting" ]] && \
   [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
    echo "Installing zsh-syntax-highlighting..."
    git clone --depth=1 \
        https://github.com/zsh-users/zsh-syntax-highlighting.git \
        "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    echo -e "${GREEN}✓ Installed zsh-syntax-highlighting${NC}"
else
    echo -e "${GREEN}✓ zsh-syntax-highlighting already included${NC}"
fi

echo ""

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Step 3: Backup Existing Configuration${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Create backup directory
BACKUP_DIR="$HOME/.zsh-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Backup existing .zshrc
if [[ -f "$HOME/.zshrc" ]]; then
    cp "$HOME/.zshrc" "$BACKUP_DIR/.zshrc"
    echo -e "${GREEN}✓ Backed up existing .zshrc${NC}"
fi

# Backup .zshrc.zwc if exists
if [[ -f "$HOME/.zshrc.zwc" ]]; then
    cp "$HOME/.zshrc.zwc" "$BACKUP_DIR/.zshrc.zwc"
    echo -e "${GREEN}✓ Backed up .zshrc.zwc${NC}"
fi

# Backup completion dumps
if ls "$HOME/.zcompdump"* 1> /dev/null 2>&1; then
    cp "$HOME/.zcompdump"* "$BACKUP_DIR/" 2>/dev/null || true
    echo -e "${GREEN}✓ Backed up completion dumps${NC}"
fi

echo -e "${GREEN}✓ Backup saved to: $BACKUP_DIR${NC}"
echo ""

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Step 4: Create Optimized .zshrc${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Create optimized .zshrc
cat > "$HOME/.zshrc" << 'ZSHRC_EOF'
# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Skip the check for insecure directories (speeds up compinit)
ZSH_DISABLE_COMPFIX="true"

# Set theme
ZSH_THEME="robbyrussell"

# Update configuration (disabled for faster startup)
zstyle ':omz:update' mode disabled

# Enable async git prompt for better performance
zstyle ':omz:alpha:lib:git' async-prompt yes

# Update frequency (in days) - only matters if updates are enabled
zstyle ':omz:update' frequency 10

# Enable command auto-correction
ENABLE_CORRECTION="true"

# Completion waiting dots
COMPLETION_WAITING_DOTS="true"

# Plugins to load
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
plugins=(git alias-finder zsh-syntax-highlighting)

# Load Oh-My-Zsh
source $ZSH/oh-my-zsh.sh

# ═══════════════════════════════════════════════════════════
#  User Configuration
# ═══════════════════════════════════════════════════════════

# Language environment
export LANG=en_US.UTF-8

# Preferred editor
if [[ -n $SSH_CONNECTION ]]; then
    export EDITOR='vim'
else
    export EDITOR='nvim'
fi

# ═══════════════════════════════════════════════════════════
#  Completion Settings (configured after oh-my-zsh loads)
# ═══════════════════════════════════════════════════════════

zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' rehash true
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# ═══════════════════════════════════════════════════════════
#  Auto-recompile .zshrc if modified (keeps performance optimal)
# ═══════════════════════════════════════════════════════════

if [[ ~/.zshrc -nt ~/.zshrc.zwc ]] || [[ ! -f ~/.zshrc.zwc ]]; then
    zcompile ~/.zshrc
fi

# ═══════════════════════════════════════════════════════════
#  Add your custom aliases, functions, and paths below
# ═══════════════════════════════════════════════════════════

ZSHRC_EOF

echo -e "${GREEN}✓ Created optimized .zshrc${NC}"
echo ""

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Step 5: Compile Files for Maximum Speed${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Compile oh-my-zsh files
echo "Compiling oh-my-zsh files to .zwc bytecode..."

# Compile main file
[[ -f "$ZSH_DIR/oh-my-zsh.sh" ]] && zsh -c "zcompile $ZSH_DIR/oh-my-zsh.sh" 2>/dev/null && \
    echo -e "${GREEN}✓${NC} Compiled oh-my-zsh.sh"

# Compile lib files
for file in "$ZSH_DIR"/lib/*.zsh; do
    [[ -f "$file" ]] && zsh -c "zcompile $file" 2>/dev/null
done
echo -e "${GREEN}✓${NC} Compiled lib files"

# Compile theme
[[ -f "$ZSH_DIR/themes/robbyrussell.zsh-theme" ]] && \
    zsh -c "zcompile $ZSH_DIR/themes/robbyrussell.zsh-theme" 2>/dev/null && \
    echo -e "${GREEN}✓${NC} Compiled theme"

# Compile plugins
for plugin in git alias-finder zsh-syntax-highlighting; do
    if [[ -f "$ZSH_DIR/plugins/$plugin/$plugin.plugin.zsh" ]]; then
        zsh -c "zcompile $ZSH_DIR/plugins/$plugin/$plugin.plugin.zsh" 2>/dev/null
    elif [[ -f "$ZSH_CUSTOM/plugins/$plugin/$plugin.plugin.zsh" ]]; then
        zsh -c "zcompile $ZSH_CUSTOM/plugins/$plugin/$plugin.plugin.zsh" 2>/dev/null
    fi
done
echo -e "${GREEN}✓${NC} Compiled plugins"

# Compile .zshrc
[[ -f "$HOME/.zshrc" ]] && zsh -c "zcompile $HOME/.zshrc" 2>/dev/null && \
    echo -e "${GREEN}✓${NC} Compiled .zshrc"

echo ""

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Step 6: Set Zsh as Default Shell${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check current shell
CURRENT_SHELL=$(basename "$SHELL")

if [[ "$CURRENT_SHELL" != "zsh" ]]; then
    echo -e "${YELLOW}Current shell: $CURRENT_SHELL${NC}"
    read -p "Would you like to set zsh as your default shell? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if command -v chsh &> /dev/null; then
            chsh -s $(which zsh)
            echo -e "${GREEN}✓ Default shell changed to zsh${NC}"
            echo -e "${YELLOW}  Note: You may need to log out and back in for this to take effect${NC}"
        else
            echo -e "${YELLOW}⚠ chsh command not found${NC}"
            echo "  Manually set your default shell with:"
            echo -e "  ${BLUE}chsh -s \$(which zsh)${NC}"
        fi
    fi
else
    echo -e "${GREEN}✓ Zsh is already your default shell${NC}"
fi

echo ""

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  Installation Complete! 🎉${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${GREEN}✓ Optimized Oh-My-Zsh installed successfully${NC}"
echo ""
echo -e "${YELLOW}Performance Optimizations Applied:${NC}"
echo "  • Async git prompt (instant shell response)"
echo "  • Disabled startup update checks"
echo "  • Compiled .zsh files to bytecode"
echo "  • Removed duplicate compinit calls"
echo "  • Enabled ZSH_DISABLE_COMPFIX"
echo "  • Auto-recompilation on .zshrc changes"
echo ""
echo -e "${YELLOW}Expected Performance:${NC}"
echo "  • Startup time: 50-150ms (vs 300-500ms standard)"
echo "  • 60-70% faster than default oh-my-zsh"
echo ""
echo -e "${YELLOW}Configuration Backup:${NC}"
echo "  $BACKUP_DIR"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "  1. Start using your optimized shell:"
echo -e "     ${BLUE}exec zsh${NC}"
echo ""
echo "  2. (Optional) Benchmark your startup time:"
echo -e "     ${BLUE}$ZSH_DIR/benchmark_startup.sh${NC}"
echo ""
echo "  3. (Optional) Read the optimization guide:"
echo -e "     ${BLUE}cat $ZSH_DIR/OPTIMIZATION_GUIDE.md${NC}"
echo ""
echo -e "${YELLOW}To Customize:${NC}"
echo "  • Edit ~/.zshrc to add your aliases and settings"
echo "  • Add custom plugins to $ZSH_CUSTOM/plugins/"
echo "  • Change theme by editing ZSH_THEME in ~/.zshrc"
echo ""
echo -e "${YELLOW}To Restore Previous Config:${NC}"
echo -e "  ${BLUE}cp $BACKUP_DIR/.zshrc ~/.zshrc && exec zsh${NC}"
echo ""
echo -e "${CYAN}Enjoy your blazing fast shell! ⚡${NC}"
echo ""
