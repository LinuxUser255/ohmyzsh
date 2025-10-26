#!/usr/bin/env bash
# Optimized Oh-My-Zsh Installation Script
# Fork: https://github.com/LinuxUser255/ohmyzsh
# Refactored following shell scripting style guide

set -euo pipefail
IFS=$'\n\t'

# ═══════════════════════════════════════════════════════════
#  Constants
# ═══════════════════════════════════════════════════════════

readonly REPO_URL="https://github.com/LinuxUser255/ohmyzsh.git"
readonly REPO_BRANCH="master"
readonly ZSH_DIR="$HOME/.oh-my-zsh"
readonly MAX_JOBS=$(nproc)

# Colors - using printf for better portability
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

# ═══════════════════════════════════════════════════════════
#  Utility Functions (8 spaces indentation)
# ═══════════════════════════════════════════════════════════

log() {
        printf "[%s] %s\n" "$(date +%H:%M:%S)" "$*"
}

success() {
        printf "${GREEN}✓${NC} %s\n" "$*"
}

error() {
        printf "${RED}✗${NC} %s\n" "$*" >&2
}

warning() {
        printf "${YELLOW}⚠${NC} %s\n" "$*"
}

info() {
        printf "${BLUE}ℹ${NC} %s\n" "$*"
}

header() {
        printf "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
        printf "${CYAN}  %s${NC}\n" "$*"
        printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n\n"
}

# Shorter function syntax using tests
cmd_exists()(command -v "$1" &>/dev/null)

# ═══════════════════════════════════════════════════════════
#  Validation Functions
# ═══════════════════════════════════════════════════════════

check_requirements() {
        local missing=0

        # Check zsh
        cmd_exists zsh || {
                error "zsh is not installed"
                info "Install with: sudo apt install zsh"
                ((missing++))
        }

        # Check git
        cmd_exists git || {
                error "git is not installed"
                info "Install with: sudo apt install git"
                ((missing++))
        }

        [[ $missing -gt 0 ]] && exit 1

        success "All requirements met"
        info "Zsh: $(zsh --version 2>&1 | head -1)"
        info "Git: $(git --version)"
}

check_zsh_running() {
        [[ -n "${ZSH_VERSION:-}" ]] && {
                warning "This script should be run in bash, not zsh"
                info "Please run: bash install.sh"
                exit 1
        }
}

# ═══════════════════════════════════════════════════════════
#  Installation Functions
# ═══════════════════════════════════════════════════════════

backup_existing() {
        local backup_dir="$HOME/.zsh-backup-$(date +%Y%m%d-%H%M%S)"

        # Create backup dir if needed files exist
        local need_backup=false

        [[ -f "$HOME/.zshrc" ]] && need_backup=true
        [[ -f "$HOME/.zshrc.zwc" ]] && need_backup=true
        ls "$HOME/.zcompdump"* &>/dev/null && need_backup=true

        [[ "$need_backup" == false ]] && return 0

        mkdir -p "$backup_dir"

        # Backup files in parallel for speed
        {
                [[ -f "$HOME/.zshrc" ]] && cp "$HOME/.zshrc" "$backup_dir/" &
                [[ -f "$HOME/.zshrc.zwc" ]] && cp "$HOME/.zshrc.zwc" "$backup_dir/" &
                ls "$HOME/.zcompdump"* &>/dev/null && cp "$HOME/.zcompdump"* "$backup_dir/" 2>/dev/null &
        }
        wait

        success "Backup saved to: $backup_dir"
        printf "%s\n" "$backup_dir" > "$HOME/.last_zsh_backup"
}

handle_existing_omz() {
        [[ ! -d "$ZSH_DIR" ]] && return 0

        warning "Oh-My-Zsh already installed at $ZSH_DIR"
        read -rp "Backup and reinstall? (y/n) " -n 1
        echo

        [[ ! "$REPLY" =~ ^[Yy]$ ]] && {
                info "Installation cancelled"
                exit 0
        }

        local backup="${ZSH_DIR}.backup-$(date +%Y%m%d-%H%M%S)"
        mv "$ZSH_DIR" "$backup"
        success "Existing installation backed up to $backup"
}

clone_repository() {
        info "Cloning optimized oh-my-zsh..."
        git clone --depth=1 --branch "$REPO_BRANCH" "$REPO_URL" "$ZSH_DIR" || {
                error "Failed to clone repository"
                exit 1
        }
        success "Repository cloned"
}

install_plugins() {
        local custom_dir="$ZSH_DIR/custom"
        mkdir -p "$custom_dir/plugins"

        # Check if syntax highlighting exists
        local syntax_path="$custom_dir/plugins/zsh-syntax-highlighting"
        [[ -d "$ZSH_DIR/plugins/zsh-syntax-highlighting" ]] || [[ -d "$syntax_path" ]] && {
                success "zsh-syntax-highlighting already included"
                return 0
        }

        info "Installing zsh-syntax-highlighting..."
        git clone --depth=1 \
                https://github.com/zsh-users/zsh-syntax-highlighting.git \
                "$syntax_path" || {
                warning "Failed to install zsh-syntax-highlighting"
        }
}

create_optimized_zshrc() {
        cat > "$HOME/.zshrc" << 'ZSHRC_EOF'
# Path to Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"

# Performance optimizations
ZSH_DISABLE_COMPFIX="true"
ZSH_THEME="robbyrussell"
zstyle ':omz:update' mode disabled
zstyle ':omz:alpha:lib:git' async-prompt yes

# Settings
ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"

# Plugins
plugins=(git alias-finder zsh-syntax-highlighting)

# Load Oh-My-Zsh
source $ZSH/oh-my-zsh.sh

# User Configuration
export LANG=en_US.UTF-8
[[ -n $SSH_CONNECTION ]] && export EDITOR='vim' || export EDITOR='nvim'

# Completion Settings
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' rehash true
zstyle ':completion:*' verbose true

# Auto-recompile .zshrc if modified
[[ ~/.zshrc -nt ~/.zshrc.zwc ]] || [[ ! -f ~/.zshrc.zwc ]] && zcompile ~/.zshrc

ZSHRC_EOF

        success "Created optimized .zshrc"
}

# Compile files in parallel for speed
compile_zsh_files() {
        info "Compiling zsh files for maximum speed..."

        local files_to_compile=()

        # Collect files to compile
        [[ -f "$ZSH_DIR/oh-my-zsh.sh" ]] && files_to_compile+=("$ZSH_DIR/oh-my-zsh.sh")
        [[ -f "$HOME/.zshrc" ]] && files_to_compile+=("$HOME/.zshrc")

        # Add lib files
        while IFS= read -r -d '' file; do
                files_to_compile+=("$file")
        done < <(find "$ZSH_DIR/lib" -name "*.zsh" -print0 2>/dev/null)

        # Add theme
        [[ -f "$ZSH_DIR/themes/robbyrussell.zsh-theme" ]] && \
                files_to_compile+=("$ZSH_DIR/themes/robbyrussell.zsh-theme")

        # Compile in parallel using process pool pattern
        local joblist=()
        for file in "${files_to_compile[@]}"; do
                zsh -c "zcompile '$file'" 2>/dev/null &
                joblist+=($!)

                # Limit concurrent jobs
                (( ${#joblist[@]} >= MAX_JOBS )) && {
                        wait "${joblist[0]}" 2>/dev/null || true
                        joblist=("${joblist[@]:1}")
                }
        done

        # Wait for remaining jobs
        wait

        success "Compiled ${#files_to_compile[@]} files"
}

set_default_shell() {
        local current_shell
        current_shell=$(basename "$SHELL")

        [[ "$current_shell" == "zsh" ]] && {
                success "Zsh is already your default shell"
                return 0
        }

        info "Current shell: $current_shell"
        read -rp "Set zsh as default shell? (y/n) " -n 1
        echo

        [[ ! "$REPLY" =~ ^[Yy]$ ]] && return 0

        cmd_exists chsh || {
                warning "chsh command not found"
                info "Manually set with: chsh -s \$(which zsh)"
                return 1
        }

        chsh -s "$(command -v zsh)" && success "Default shell changed to zsh"
}

# ═══════════════════════════════════════════════════════════
#  Main Installation Flow
# ═══════════════════════════════════════════════════════════

main() {
        header "LinuxUser255's Optimized Oh-My-Zsh Installer"

        # Validation
        check_zsh_running
        check_requirements

        # Handle existing installations
        handle_existing_omz
        backup_existing

        # Installation steps
        header "Step 1: Clone Repository"
        clone_repository

        header "Step 2: Install Plugins"
        install_plugins

        header "Step 3: Create Configuration"
        create_optimized_zshrc

        header "Step 4: Compile Files"
        compile_zsh_files

        header "Step 5: Set Default Shell"
        set_default_shell

        # Final summary
        header "Installation Complete! "

        success "Optimized Oh-My-Zsh installed successfully"
        echo
        info "Performance optimizations applied:"
        printf "  • Async git prompt\n"
        printf "  • Disabled update checks\n"
        printf "  • Compiled bytecode\n"
        printf "  • Auto-recompilation\n"
        echo
        info "Expected startup time: 50-150ms"
        echo
        info "Next steps:"
        printf "  1. Start using zsh: ${BLUE}exec zsh${NC}\n"
        printf "  2. Customize ~/.zshrc as needed\n"
        echo

        [[ -f "$HOME/.last_zsh_backup" ]] && {
                local backup_path
                backup_path=$(<"$HOME/.last_zsh_backup")
                info "Restore previous config:"
                printf "  ${BLUE}cp %s/.zshrc ~/.zshrc && exec zsh${NC}\n" "$backup_path"
        }
}

# ═══════════════════════════════════════════════════════════
#  Script Entry Point
# ═══════════════════════════════════════════════════════════

# Only run main if executed directly
[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "$@"
