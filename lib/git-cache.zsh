# Git caching system for Oh My Zsh
# Reduces redundant git calls and improves prompt performance
#
# Configuration variables:
#   GIT_CACHE_TIMEOUT - Cache timeout in seconds (default: 2)
#   GIT_CACHE_ENABLED - Enable/disable caching (default: 1)

# Enable caching by default
typeset -gi GIT_CACHE_ENABLED=${GIT_CACHE_ENABLED:-1}
typeset -gi GIT_CACHE_TIMEOUT=${GIT_CACHE_TIMEOUT:-2}

# Cache storage
typeset -gA __git_cache
typeset -gi __git_cache_time=0
typeset -g __git_cache_dir=""

# Check if caching is enabled
function __git_cache_enabled() {
  (( GIT_CACHE_ENABLED == 1 ))
}

# Validate cache state
function __git_cache_validate() {
  __git_cache_enabled || return 1
  
  local current_dir="$PWD"
  local current_time=$(print -P "%D{%s}")
  
  # Check if directory changed
  if [[ "$__git_cache_dir" != "$current_dir" ]]; then
    __git_cache_dir="$current_dir"
    __git_cache_time=0
    __git_cache=()
    return 1
  fi
  
  # Check if cache expired
  if (( current_time - __git_cache_time > GIT_CACHE_TIMEOUT )); then
    __git_cache_time=$current_time
    return 1
  fi
  
  return 0
}

# Cached git command wrapper
function __git_cached() {
  local cache_key="$1"
  shift
  
  if __git_cache_validate && [[ -n "${__git_cache[$cache_key]}" ]]; then
    echo "${__git_cache[$cache_key]}"
    return 0
  fi
  
  local result
  result=$(GIT_OPTIONAL_LOCKS=0 command git "$@" 2>/dev/null)
  local ret=$?
  
  if [[ $ret -eq 0 ]] && __git_cache_enabled; then
    __git_cache[$cache_key]="$result"
  fi
  
  [[ $ret -eq 0 ]] && echo "$result"
  return $ret
}

# Optimized git prompt info with caching
function git_prompt_info_cached() {
  # Check if we're in a git repository
  __git_cached "is_repo" rev-parse --git-dir >/dev/null || return 0
  
  # Check for hide-info setting
  local hide_info
  hide_info=$(__git_cached "hide_info" config --get oh-my-zsh.hide-info)
  [[ "$hide_info" == "1" ]] && return 0
  
  # Get branch/tag/commit info
  local ref
  ref=$(__git_cached "ref" symbolic-ref --short HEAD 2>/dev/null) \
    || ref=$(__git_cached "describe" describe --tags --exact-match HEAD 2>/dev/null) \
    || ref=$(__git_cached "rev" rev-parse --short HEAD 2>/dev/null) \
    || return 0
  
  # Get upstream if requested
  local upstream=""
  if (( ${+ZSH_THEME_GIT_SHOW_UPSTREAM} )); then
    upstream=$(__git_cached "upstream" rev-parse --abbrev-ref --symbolic-full-name "@{upstream}" 2>/dev/null)
    [[ -n "$upstream" ]] && upstream=" -> $upstream"
  fi
  
  # Get dirty status
  local dirty_status=""
  local status_output
  status_output=$(__git_cached "status_porcelain" status --porcelain 2>/dev/null)
  
  if [[ -n "$status_output" ]]; then
    dirty_status="${ZSH_THEME_GIT_PROMPT_DIRTY}"
  else
    dirty_status="${ZSH_THEME_GIT_PROMPT_CLEAN}"
  fi
  
  echo "${ZSH_THEME_GIT_PROMPT_PREFIX}${ref:gs/%/%%}${upstream:gs/%/%%}${dirty_status}${ZSH_THEME_GIT_PROMPT_SUFFIX}"
}

# Clear cache on directory change
function __git_cache_chpwd() {
  __git_cache_dir=""
  __git_cache_time=0
  __git_cache=()
}

# Hook into directory changes
autoload -Uz add-zsh-hook
add-zsh-hook chpwd __git_cache_chpwd

# Export functions for use
typeset -gf git_prompt_info_cached __git_cached __git_cache_validate