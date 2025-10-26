#!/usr/bin/env bash

build_zsh_from_source() {
    # Check if zsh is already installed
    if command -v zsh &>/dev/null; then
        echo "[INFO] Zsh already installed at $(command -v zsh)"
        zsh --version
        read -p "Reinstall anyway? (y/N): " -n 1 -r
        echo
        [[ ! $REPLY =~ ^[Yy]$ ]] && return 0
    fi

    echo "[INFO] Building Zsh from source..."

    # Install build dependencies
    echo "[INFO] Installing build dependencies..."
    if ! apt-get update && apt-get install -y \
        build-essential \
        git \
        autoconf \
        automake \
        ncurses-dev \
        libncursesw5-dev \
        yodl \
        libpcre3-dev \
        libgdbm-dev; then
        echo "[ERROR] Failed to install build dependencies"
        return 1
    fi

    # Create temporary build directory
    local build_dir
    build_dir=$(mktemp -d) || {
        echo "[ERROR] Failed to create temporary directory"
        return 1
    }
    echo "[INFO] Building in $build_dir"

    # Ensure cleanup on exit
    trap 'rm -rf "$build_dir"' EXIT INT TERM

    # Clone the repository
    echo "[INFO] Cloning zsh from https://github.com/LinuxUser255/zsh..."
    if ! git clone --depth 1 https://github.com/LinuxUser255/zsh.git "$build_dir/zsh"; then
        echo "[ERROR] Failed to clone repository"
        return 1
    fi

    cd "$build_dir/zsh" || {
        echo "[ERROR] Failed to enter zsh directory"
        return 1
    }

    # Run preconfig
    echo "[INFO] Running preconfig..."
    if ! ./Util/preconfig; then
        echo "[ERROR] preconfig failed"
        return 1
    fi

    # Configure with proper options
    echo "[INFO] Configuring zsh..."
    if ! ./configure \
        --prefix=/usr \
        --bindir=/bin \
        --sysconfdir=/etc/zsh \
        --enable-etcdir=/etc/zsh \
        --enable-fndir=/usr/share/zsh/functions \
        --enable-site-fndir=/usr/local/share/zsh/site-functions \
        --enable-function-subdirs \
        --enable-cap \
        --enable-pcre \
        --enable-multibyte \
        --enable-zsh-secure-free \
        --with-tcsetpgrp \
        --enable-shared; then
        echo "[ERROR] configure failed"
        return 1
    fi

    # Build
    echo "[INFO] Building zsh (this may take a while)..."
    if ! make -j "$(nproc)"; then
        echo "[ERROR] make failed"
        return 1
    fi

    # Run tests (optional, continue even if some tests fail)
    echo "[INFO] Running tests..."
    if ! make check; then
        echo "[WARNING] Some tests failed, but continuing installation"
    fi

    # Install
    echo "[INFO] Installing zsh..."
    if ! make install; then
        echo "[ERROR] Installation failed"
        return 1
    fi

    # Verify installation
    if ! command -v zsh &>/dev/null; then
        echo "[ERROR] Zsh binary not found after installation"
        return 1
    fi

    # Add to /etc/shells if not present
    if ! grep -Fxq "/bin/zsh" /etc/shells; then
        echo "[INFO] Adding /bin/zsh to /etc/shells"
        echo "/bin/zsh" | tee -a /etc/shells >/dev/null || {
            echo "[WARNING] Failed to add /bin/zsh to /etc/shells"
        }
    fi

    # Change default shell
    local target_user="${SUDO_USER:-$USER}"
    echo "[INFO] Changing default shell to zsh for $target_user..."
    if [[ -n "$SUDO_USER" ]]; then
        if ! chsh -s /bin/zsh "$SUDO_USER"; then
            echo "[WARNING] Failed to change shell for $SUDO_USER"
            echo "Run manually: chsh -s /bin/zsh"
        fi
    else
        if ! chsh -s /bin/zsh; then
            echo "[WARNING] Failed to change default shell"
            echo "Run manually: chsh -s /bin/zsh"
        fi
    fi

    echo "[SUCCESS] Zsh built and installed successfully"
    zsh --version
    echo "[INFO] Log out and back in to use zsh as default shell"
    
    return 0
}

# Run the function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [[ $EUID -ne 0 ]]; then
        echo "[ERROR] This script must be run as root or with sudo"
        exit 1
    fi
    build_zsh_from_source
fi
