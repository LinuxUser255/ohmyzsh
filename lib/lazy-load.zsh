# Lazy Loading System for Oh My Zsh
# Defers loading of heavy plugins until first use
#
# Configuration variables:
#   ZSH_LAZY_PLUGINS - Array of plugins to lazy load (default: nvm rbenv pyenv)
#   ZSH_LAZY_LOAD_ENABLED - Enable/disable lazy loading (default: 1)

# Enable lazy loading by default
typeset -gi ZSH_LAZY_LOAD_ENABLED=${ZSH_LAZY_LOAD_ENABLED:-1}

# Default list of heavy plugins to lazy load
typeset -ga ZSH_LAZY_PLUGINS
if (( ! ${#ZSH_LAZY_PLUGINS[@]} )); then
  ZSH_LAZY_PLUGINS=(nvm rbenv pyenv jenv nodenv goenv virtualenvwrapper conda)
fi

# Track loaded plugins
typeset -gA __lazy_loaded_plugins

# Create lazy loading wrapper for a plugin
function __create_lazy_loader() {
  local plugin="$1"
  local plugin_path="$2"
  
  # Create stub functions for common commands
  case "$plugin" in
    nvm)
      eval "
        function nvm() {
          __lazy_load_plugin '$plugin' '$plugin_path'
          nvm \"\$@\"
        }
        function node() {
          __lazy_load_plugin '$plugin' '$plugin_path'
          node \"\$@\"
        }
        function npm() {
          __lazy_load_plugin '$plugin' '$plugin_path'
          npm \"\$@\"
        }
      "
      ;;
    rbenv)
      eval "
        function rbenv() {
          __lazy_load_plugin '$plugin' '$plugin_path'
          rbenv \"\$@\"
        }
        function ruby() {
          __lazy_load_plugin '$plugin' '$plugin_path'
          ruby \"\$@\"
        }
        function gem() {
          __lazy_load_plugin '$plugin' '$plugin_path'
          gem \"\$@\"
        }
        function bundle() {
          __lazy_load_plugin '$plugin' '$plugin_path'
          bundle \"\$@\"
        }
      "
      ;;
    pyenv)
      eval "
        function pyenv() {
          __lazy_load_plugin '$plugin' '$plugin_path'
          pyenv \"\$@\"
        }
        function python() {
          __lazy_load_plugin '$plugin' '$plugin_path'
          python \"\$@\"
        }
        function python3() {
          __lazy_load_plugin '$plugin' '$plugin_path'
          python3 \"\$@\"
        }
        function pip() {
          __lazy_load_plugin '$plugin' '$plugin_path'
          pip \"\$@\"
        }
        function pip3() {
          __lazy_load_plugin '$plugin' '$plugin_path'
          pip3 \"\$@\"
        }
      "
      ;;
    jenv)
      eval "
        function jenv() {
          __lazy_load_plugin '$plugin' '$plugin_path'
          jenv \"\$@\"
        }
        function java() {
          __lazy_load_plugin '$plugin' '$plugin_path'
          java \"\$@\"
        }
        function javac() {
          __lazy_load_plugin '$plugin' '$plugin_path'
          javac \"\$@\"
        }
      "
      ;;
    nodenv)
      eval "
        function nodenv() {
          __lazy_load_plugin '$plugin' '$plugin_path'
          nodenv \"\$@\"
        }
        function node() {
          __lazy_load_plugin '$plugin' '$plugin_path'
          node \"\$@\"
        }
        function npm() {
          __lazy_load_plugin '$plugin' '$plugin_path'
          npm \"\$@\"
        }
      "
      ;;
    goenv)
      eval "
        function goenv() {
          __lazy_load_plugin '$plugin' '$plugin_path'
          goenv \"\$@\"
        }
        function go() {
          __lazy_load_plugin '$plugin' '$plugin_path'
          go \"\$@\"
        }
      "
      ;;
    virtualenvwrapper)
      eval "
        function mkvirtualenv() {
          __lazy_load_plugin '$plugin' '$plugin_path'
          mkvirtualenv \"\$@\"
        }
        function workon() {
          __lazy_load_plugin '$plugin' '$plugin_path'
          workon \"\$@\"
        }
        function deactivate() {
          __lazy_load_plugin '$plugin' '$plugin_path'
          deactivate \"\$@\"
        }
        function virtualenv() {
          __lazy_load_plugin '$plugin' '$plugin_path'
          virtualenv \"\$@\"
        }
      "
      ;;
    conda)
      eval "
        function conda() {
          __lazy_load_plugin '$plugin' '$plugin_path'
          conda \"\$@\"
        }
        function activate() {
          __lazy_load_plugin '$plugin' '$plugin_path'
          activate \"\$@\"
        }
      "
      ;;
    *)
      # Generic lazy loader for unknown plugins
      eval "
        function __lazy_load_${plugin}() {
          __lazy_load_plugin '$plugin' '$plugin_path'
        }
      "
      # Add to precmd to load on first prompt
      precmd_functions+=(__lazy_load_${plugin})
      ;;
  esac
}

# Load a plugin and remove stub functions
function __lazy_load_plugin() {
  local plugin="$1"
  local plugin_path="$2"
  
  # Check if already loaded
  if (( __lazy_loaded_plugins[$plugin] )); then
    return 0
  fi
  
  # Remove stub functions
  case "$plugin" in
    nvm)
      unfunction nvm node npm 2>/dev/null
      ;;
    rbenv)
      unfunction rbenv ruby gem bundle 2>/dev/null
      ;;
    pyenv)
      unfunction pyenv python python3 pip pip3 2>/dev/null
      ;;
    jenv)
      unfunction jenv java javac 2>/dev/null
      ;;
    nodenv)
      unfunction nodenv node npm 2>/dev/null
      ;;
    goenv)
      unfunction goenv go 2>/dev/null
      ;;
    virtualenvwrapper)
      unfunction mkvirtualenv workon deactivate virtualenv 2>/dev/null
      ;;
    conda)
      unfunction conda activate 2>/dev/null
      ;;
    *)
      unfunction __lazy_load_${plugin} 2>/dev/null
      # Remove from precmd
      precmd_functions=(${precmd_functions:#__lazy_load_${plugin}})
      ;;
  esac
  
  # Source the plugin
  if [[ -f "$plugin_path" ]]; then
    source "$plugin_path"
    __lazy_loaded_plugins[$plugin]=1
    
    # Run any post-load hooks
    local post_hook="__${plugin}_post_lazy_load"
    (( ${+functions[$post_hook]} )) && $post_hook
  else
    echo "[oh-my-zsh] Warning: Cannot lazy load $plugin - file not found: $plugin_path" >&2
    return 1
  fi
}

# Check if a plugin should be lazy loaded
function should_lazy_load() {
  local plugin="$1"
  
  # Check if lazy loading is enabled
  (( ZSH_LAZY_LOAD_ENABLED )) || return 1
  
  # Check if plugin is in lazy load list
  (( ${ZSH_LAZY_PLUGINS[(Ie)$plugin]} ))
}

# Initialize lazy loading for a plugin
function init_lazy_plugin() {
  local plugin="$1"
  local plugin_path="$2"
  
  if should_lazy_load "$plugin"; then
    __create_lazy_loader "$plugin" "$plugin_path"
    return 0
  fi
  
  return 1
}

# Export functions
typeset -gf should_lazy_load init_lazy_plugin __lazy_load_plugin __create_lazy_loader