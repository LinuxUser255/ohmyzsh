#!/usr/bin/env zsh
# Compile oh-my-zsh files to .zwc for faster loading
# This script compiles all .zsh files to zsh bytecode

echo "🚀 Compiling oh-my-zsh files to .zwc format..."
echo ""

# Compile the main oh-my-zsh.sh file
if [[ -f "$ZSH/oh-my-zsh.sh" ]]; then
    echo "Compiling oh-my-zsh.sh..."
    zcompile "$ZSH/oh-my-zsh.sh"
fi

# Compile all lib files
echo "Compiling lib files..."
for file in "$ZSH"/lib/*.zsh; do
    [[ -f "$file" ]] && zcompile "$file"
done

# Compile all theme files
echo "Compiling theme files..."
for file in "$ZSH"/themes/*.zsh-theme; do
    [[ -f "$file" ]] && zcompile "$file"
done

# Compile plugin files for enabled plugins only
# Read plugins from .zshrc
if [[ -f ~/.zshrc ]]; then
    # Extract plugins array from .zshrc
    ENABLED_PLUGINS=($(grep -oP 'plugins=\(\K[^)]+' ~/.zshrc | tr ' ' '\n' | sort -u))
    
    echo "Compiling enabled plugin files: ${ENABLED_PLUGINS[@]}..."
    for plugin in "${ENABLED_PLUGINS[@]}"; do
        # Compile main plugin file
        if [[ -f "$ZSH/plugins/$plugin/$plugin.plugin.zsh" ]]; then
            zcompile "$ZSH/plugins/$plugin/$plugin.plugin.zsh"
        fi
        
        # Compile any other .zsh files in the plugin directory
        for file in "$ZSH/plugins/$plugin"/*.zsh(N); do
            [[ -f "$file" ]] && zcompile "$file"
        done
    done
fi

# Compile custom files
if [[ -d "$ZSH_CUSTOM" ]]; then
    echo "Compiling custom files..."
    for file in "$ZSH_CUSTOM"/**/*.zsh(N); do
        [[ -f "$file" ]] && zcompile "$file"
    done
fi

# Compile .zshrc
if [[ -f ~/.zshrc ]]; then
    echo "Compiling ~/.zshrc..."
    zcompile ~/.zshrc
fi

echo ""
echo "✅ Compilation complete!"
echo ""
echo "Compiled files count:"
find "$ZSH" -name "*.zwc" -newer "$ZSH/oh-my-zsh.sh" 2>/dev/null | wc -l
echo ""
echo "To see the performance improvement, restart your shell or run: exec zsh"
