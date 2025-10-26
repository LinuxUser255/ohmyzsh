#!/usr/bin/env zsh

# Test script for custom oh-my-zsh with built-in zsh-syntax-highlighting and zsh-autosuggestions
# This script will test if both plugins are automatically loaded

echo "Testing custom oh-my-zsh integration..."
echo ""

# Set up environment
export ZSH="$HOME/Projects/ZSH-Stuff/ohmyzsh"
export ZSH_CUSTOM="$ZSH/custom"

# Source oh-my-zsh
source "$ZSH/oh-my-zsh.sh"

echo "✓ oh-my-zsh loaded successfully"
echo ""

# Check if zsh-autosuggestions is loaded
if (( ${+ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE} )); then
  echo "✓ zsh-autosuggestions is loaded (ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE is set)"
else
  echo "✗ zsh-autosuggestions is NOT loaded"
fi

# Check if zsh-syntax-highlighting is loaded
if (( ${+ZSH_HIGHLIGHT_HIGHLIGHTERS} )); then
  echo "✓ zsh-syntax-highlighting is loaded (ZSH_HIGHLIGHT_HIGHLIGHTERS is set)"
else
  echo "✗ zsh-syntax-highlighting is NOT loaded"
fi

echo ""
echo "Integration test complete!"
echo ""
echo "To use this custom oh-my-zsh in your shell, add this to your ~/.zshrc:"
echo "  export ZSH=\"\$HOME/Projects/ZSH-Stuff/ohmyzsh\""
echo "  source \"\$ZSH/oh-my-zsh.sh\""
