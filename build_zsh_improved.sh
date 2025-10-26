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

    # Update dynamic linker cache
    echo "[INFO] Updating dynamic linker cache..."
    ldconfig

    # Verify installation
    if ! command -v zsh &>/dev/null; then
        echo "[ERROR] Zsh binary not found after installation"
        return 1
    fi

    # Fix module permissions
    echo "[INFO] Fixing module permissions..."
    local zsh_version
    zsh_version=$(zsh --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+[^[:space:]]*' | head -1)
    local module_paths=(
        "/usr/lib/zsh/${zsh_version}"
        "/usr/lib/zsh/${zsh_version}/zsh"
        "/usr/lib64/zsh/${zsh_version}"
        "/usr/lib64/zsh/${zsh_version}/zsh"
        "/usr/share/zsh/${zsh_version}"
    )
    
    for path in "${module_paths[@]}"; do
        if [[ -d "$path" ]]; then
            echo "[INFO] Setting permissions for $path"
            chmod -R 755 "$path" 2>/dev/null
            find "$path" -name "*.so" -exec chmod 755 {} \; 2>/dev/null
        fi
    done

    # Verify zsh can load modules
    echo "[INFO] Verifying zsh module loading..."
    if ! zsh -c 'zmodload zsh/zle' 2>/dev/null; then
        echo "[WARNING] Module loading test failed, attempting comprehensive fix..."
        
        # Get the actual module path from zsh
        local actual_module_path
        actual_module_path=$(zsh -c 'echo $MODULE_PATH' 2>/dev/null)
        
        # Also try to find module directories by searching for .so files
        echo "[INFO] Searching for zsh module directories..."
        local found_modules=false
        for search_path in /usr/lib /usr/lib64 /usr/local/lib; do
            if [[ -d "$search_path" ]]; then
                while IFS= read -r -d '' so_file; do
                    local dir=$(dirname "$so_file")
                    echo "[INFO] Found modules in: $dir"
                    echo "[INFO] Fixing permissions for $dir"
                    chmod -R 755 "$dir"
                    found_modules=true
                done < <(find "$search_path" -path "*/zsh/*" -name "*.so" -print0 2>/dev/null)
            fi
        done
        
        if [[ "$found_modules" == false ]]; then
            echo "[ERROR] No zsh modules found! Build may have failed."
            echo "[INFO] Attempting rebuild with explicit module support..."
            # Force rebuild modules
            cd "$build_dir/zsh" && make install-modules 2>/dev/null
        fi
        
        # Update ld cache again after permission fixes
        ldconfig
        
        # Final test
        if ! zsh -c 'zmodload zsh/zle' 2>/dev/null; then
            echo "[ERROR] Module loading still fails."
            echo "[INFO] Module path reported by zsh: $actual_module_path"
            if [[ -n "$actual_module_path" ]]; then
                echo "[INFO] Contents of module directory:"
                ls -la "$actual_module_path/zsh/" 2>/dev/null || echo "  Directory not found"
            fi
        else
            echo "[SUCCESS] Module loading works!"
        fi
    else
        echo "[SUCCESS] Module loading verified"
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
