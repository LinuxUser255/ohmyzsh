#!/usr/bin/env bash
# Fix missing zsh-syntax-highlighting plugin

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Fixing zsh-syntax-highlighting Plugin${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Set paths
ZSH="${ZSH:-$HOME/.oh-my-zsh}"
ZSH_CUSTOM="${ZSH_CUSTOM:-$ZSH/custom}"

# Check if plugin already exists
if [[ -f "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh" ]]; then
    echo -e "${GREEN}✓ Plugin already installed${NC}"
    echo ""
    echo "Compiling plugin files..."
    zsh -c "zcompile $ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh" 2>/dev/null
    zsh -c "for file in $ZSH_CUSTOM/plugins/zsh-syntax-highlighting/*.zsh; do [[ -f \"\$file\" ]] && zcompile \"\$file\" 2>/dev/null; done"
    echo -e "${GREEN}✓ Plugin compiled${NC}"
elif [[ -f "$ZSH/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh" ]]; then
    echo -e "${GREEN}✓ Plugin found in standard directory${NC}"
    echo ""
    echo "Compiling plugin files..."
    zsh -c "zcompile $ZSH/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh" 2>/dev/null
    zsh -c "for file in $ZSH/plugins/zsh-syntax-highlighting/*.zsh; do [[ -f \"\$file\" ]] && zcompile \"\$file\" 2>/dev/null; done"
    echo -e "${GREEN}✓ Plugin compiled${NC}"
else
    echo -e "${YELLOW}⚠ Plugin not found, installing...${NC}"
    echo ""
    
    # Create custom plugins directory if it doesn't exist
    mkdir -p "$ZSH_CUSTOM/plugins"
    
    # Clone the plugin
    echo "Cloning from GitHub..."
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git \
        "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    
    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}✓ Plugin installed successfully${NC}"
        echo ""
        echo "Compiling plugin files..."
        zsh -c "zcompile $ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh" 2>/dev/null
        zsh -c "for file in $ZSH_CUSTOM/plugins/zsh-syntax-highlighting/*.zsh; do [[ -f \"\$file\" ]] && zcompile \"\$file\" 2>/dev/null; done"
        echo -e "${GREEN}✓ Plugin compiled${NC}"
    else
        echo -e "${RED}✗ Failed to install plugin${NC}"
        exit 1
    fi
fi

echo ""

# Verify installation
echo "Verifying installation..."
if zsh -i -c "exit" 2>&1 | grep -q "plugin 'zsh-syntax-highlighting' not found"; then
    echo -e "${RED}✗ Plugin still not loading properly${NC}"
    echo ""
    echo "Please check your .zshrc file and ensure it contains:"
    echo -e "${BLUE}plugins=(git alias-finder zsh-syntax-highlighting)${NC}"
    exit 1
else
    echo -e "${GREEN}✓ Plugin loads successfully${NC}"
fi

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  Fixed! zsh-syntax-highlighting is ready${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Restart your shell to see the changes:"
echo -e "  ${BLUE}exec zsh${NC}"
echo ""