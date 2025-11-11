# Oh My Zsh Performance Optimization Migration Guide

## Introduction

This guide helps you migrate your existing Oh My Zsh setup to use the new performance optimizations. The migration is designed to be smooth and reversible.

## Pre-Migration Checklist

Before starting:

- [ ] Back up your current `.zshrc` file
- [ ] Note your current shell startup time for comparison
- [ ] List your active plugins
- [ ] Identify any custom modifications

```zsh
# Backup your configuration
cp ~/.zshrc ~/.zshrc.backup-$(date +%Y%m%d)

# Measure current startup time
time zsh -i -c exit

# List current plugins
echo "Current plugins: $plugins"
```

## Migration Steps

### Step 1: Update Oh My Zsh

First, ensure you have the latest version with optimization support:

```zsh
# Update Oh My Zsh
cd $ZSH
git pull origin master

# Or use the built-in updater
omz update
```

### Step 2: Enable Basic Optimizations

Add these lines to your `.zshrc` **before** the `source $ZSH/oh-my-zsh.sh` line:

```zsh
# ~/.zshrc

# Enable performance optimizations
export GIT_CACHE_ENABLED=1
export ZSH_LAZY_LOAD_ENABLED=1

# Your existing configuration
ZSH_THEME="your-theme"
plugins=(your plugins here)

source $ZSH/oh-my-zsh.sh
```

### Step 3: Test Your Setup

After adding the optimizations:

```zsh
# Reload your shell
exec zsh

# Test basic functionality
git status  # Should work with caching
node --version  # Should trigger lazy loading if nvm is installed

# Measure new startup time
time zsh -i -c exit
```

### Step 4: Fine-tune Settings (Optional)

Based on your usage patterns, adjust the settings:

```zsh
# For large git repositories
export GIT_CACHE_TIMEOUT=5  # Increase cache duration

# For specific lazy-loaded plugins
export ZSH_LAZY_PLUGINS=(nvm rbenv pyenv custom-plugin)

# If you have issues with a plugin, exclude it from lazy loading
export ZSH_LAZY_PLUGINS=(${ZSH_LAZY_PLUGINS:#problematic-plugin})
```

## Migration Scenarios

### Scenario 1: Basic User

If you're using Oh My Zsh with standard plugins:

```zsh
# Add to .zshrc before sourcing oh-my-zsh.sh
export GIT_CACHE_ENABLED=1
export ZSH_LAZY_LOAD_ENABLED=1

# That's it! Your setup should work as before, but faster
```

### Scenario 2: Heavy Plugin User

If you use many plugins, especially version managers:

```zsh
# Enable all optimizations
export GIT_CACHE_ENABLED=1
export ZSH_LAZY_LOAD_ENABLED=1
export GIT_CACHE_TIMEOUT=3

# Specify which heavy plugins to lazy load
export ZSH_LAZY_PLUGINS=(
  nvm      # Node Version Manager
  rbenv    # Ruby Environment
  pyenv    # Python Environment
  jenv     # Java Environment
  goenv    # Go Environment
)

# Keep frequently-used plugins eager-loaded
plugins=(
  git
  docker
  kubectl
  # ... other essential plugins
)
```

### Scenario 3: Custom Theme User

If you have a custom theme with git information:

```zsh
# In your custom theme file, replace:
git_prompt_info
# With:
git_prompt_info_cached

# Or create an alias for compatibility
alias git_prompt_info='git_prompt_info_cached'
```

### Scenario 4: Development Environment

For developers who need specific timing:

```zsh
# Development-optimized settings
export GIT_CACHE_ENABLED=1
export GIT_CACHE_TIMEOUT=1  # Lower cache for active development
export ZSH_LAZY_LOAD_ENABLED=1

# Load language tools on-demand
export ZSH_LAZY_PLUGINS=(nvm rbenv pyenv)

# Keep build tools eager-loaded
plugins=(git docker docker-compose kubectl npm)
```

## Rollback Instructions

If you encounter issues, you can easily rollback:

### Complete Rollback

```zsh
# Restore your backup
cp ~/.zshrc.backup-$(date +%Y%m%d) ~/.zshrc
exec zsh
```

### Partial Rollback

Disable specific optimizations:

```zsh
# Disable all optimizations
export GIT_CACHE_ENABLED=0
export ZSH_LAZY_LOAD_ENABLED=0

# Or disable just one
export ZSH_LAZY_LOAD_ENABLED=0  # Disable only lazy loading
```

## Troubleshooting Common Issues

### Issue: Git information not updating

**Symptom**: Git branch/status appears stuck

**Solution**:
```zsh
# Option 1: Reduce cache timeout
export GIT_CACHE_TIMEOUT=1

# Option 2: Disable caching for current session
export GIT_CACHE_ENABLED=0
```

### Issue: Command not found after migration

**Symptom**: Commands like `nvm`, `node` not found

**Solution**:
```zsh
# Option 1: Manually trigger loading
nvm  # Just type the command once to load

# Option 2: Remove from lazy load list
export ZSH_LAZY_PLUGINS=(${ZSH_LAZY_PLUGINS:#nvm})
```

### Issue: Plugin not working correctly

**Symptom**: Plugin features missing or broken

**Solution**:
```zsh
# Exclude problematic plugin from lazy loading
export ZSH_LAZY_PLUGINS=(${ZSH_LAZY_PLUGINS:#plugin-name})

# Or disable lazy loading entirely
export ZSH_LAZY_LOAD_ENABLED=0
```

### Issue: Theme looks different

**Symptom**: Git information missing from prompt

**Solution**:
```zsh
# Ensure your theme uses the cached functions
# Edit your theme file to use:
git_prompt_info_cached
git_prompt_status_cached

# Or add aliases
alias git_prompt_info='git_prompt_info_cached'
alias git_prompt_status='git_prompt_status_cached'
```

## Verification Tests

Run these tests to ensure everything works correctly:

```zsh
# Test 1: Git functionality
cd /path/to/git/repo
git status
echo "Git prompt: $(git_prompt_info_cached)"

# Test 2: Lazy loading (if using nvm)
which node  # Should not be found initially
nvm  # Triggers loading
which node  # Should now be found

# Test 3: Performance measurement
for i in {1..5}; do time zsh -i -c exit; done

# Test 4: Cache behavior
cd /different/git/repo
# Prompt should update to new repo

# Test 5: Plugin functionality
# Test each of your critical plugins
```

## Advanced Migration

### Custom Plugin Integration

For custom plugins to support lazy loading:

```zsh
# In your custom plugin file
if should_lazy_load "my-plugin"; then
  # Create stub functions
  function my_command() {
    __lazy_load_plugin "my-plugin" "$0"
    my_command "$@"
  }
  return 0
fi

# Regular plugin code here
```

### Performance Profiling

Compare before and after:

```zsh
# Profile old configuration
zsh -c 'source ~/.zshrc.backup; zprof' > old-profile.txt

# Profile new configuration  
zsh -c 'source ~/.zshrc; zprof' > new-profile.txt

# Compare
diff old-profile.txt new-profile.txt
```

### Gradual Migration

Enable optimizations one at a time:

```zsh
# Week 1: Enable git caching only
export GIT_CACHE_ENABLED=1
# export ZSH_LAZY_LOAD_ENABLED=0

# Week 2: Add lazy loading for one plugin
export ZSH_LAZY_PLUGINS=(nvm)
export ZSH_LAZY_LOAD_ENABLED=1

# Week 3: Expand lazy loading
export ZSH_LAZY_PLUGINS=(nvm rbenv pyenv)
```

## Post-Migration Optimization

After successful migration:

### 1. Clean up unused plugins

```zsh
# Review and remove unused plugins
plugins=(git docker kubectl)  # Keep only what you use
```

### 2. Compile your configuration

```zsh
# Compile .zshrc for faster loading
zcompile ~/.zshrc
```

### 3. Optimize plugin order

```zsh
# Load most-used plugins first
plugins=(
  git          # Used everywhere
  docker       # Frequently used
  kubectl      # Frequently used
  terraform    # Sometimes used
  ansible      # Rarely used
)
```

### 4. Set up monitoring

```zsh
# Add to .zshrc to track startup time
if [[ -n "$ZSH_PROFILE_STARTUP" ]]; then
  zmodload zsh/zprof
fi

# At the end of .zshrc
if [[ -n "$ZSH_PROFILE_STARTUP" ]]; then
  zprof
fi

# Enable profiling when needed
ZSH_PROFILE_STARTUP=1 zsh
```

## Success Metrics

Your migration is successful when:

- ✅ Shell starts 30-50% faster
- ✅ All plugins work as expected
- ✅ Git prompts update within 2-5 seconds
- ✅ No "command not found" errors
- ✅ Theme displays correctly

## Getting Help

If you encounter issues:

1. Check the [Performance Guide](PERFORMANCE.md)
2. Review the [Optimization Report](../OPTIMIZATION_REPORT.md)
3. Search existing issues: https://github.com/ohmyzsh/ohmyzsh/issues
4. Ask in the community forum
5. File a bug report with:
   - Your `.zshrc` configuration
   - Output of `zsh --version`
   - Error messages
   - Performance measurements

## Summary

The migration to optimized Oh My Zsh is:
- **Safe**: All changes are reversible
- **Compatible**: Works with existing setups
- **Flexible**: Enable only what you need
- **Fast**: Significant performance improvements

Start with basic optimizations and gradually enable more features as you become comfortable with the new system.