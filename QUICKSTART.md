# ⚡ Quick Start - Optimized Oh-My-Zsh

## One-Line Install

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/LinuxUser255/ohmyzsh/master/install.sh)"
```

## What Happens?

1. ✅ Backs up your existing `.zshrc`
2. ✅ Clones the optimized oh-my-zsh fork
3. ✅ Installs `zsh-syntax-highlighting` plugin
4. ✅ Creates an optimized `.zshrc` with:
   - Async git prompt
   - Disabled update checks
   - Auto-recompilation
5. ✅ Compiles all files to `.zwc` bytecode
6. ✅ Ready to use!

## After Installation

```bash
# Start your optimized shell
exec zsh

# Test the performance
~/.oh-my-zsh/benchmark_startup.sh
```

## Expected Results

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Average startup time: 85ms
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🚀 Excellent! Your shell is blazing fast!
```

## Key Features

- **Instant prompt** - No waiting for git status
- **60-70% faster** - Compared to standard oh-my-zsh
- **Auto-recompiles** - Maintains speed automatically
- **Clean config** - Well-organized and commented

## Common Tasks

### Add an Alias

Edit `~/.zshrc` and add to the bottom:
```zsh
alias gs='git status'
```

### Change Theme

Edit `~/.zshrc`:
```zsh
ZSH_THEME="agnoster"
```

### Add a Plugin

Edit `~/.zshrc`:
```zsh
plugins=(git alias-finder zsh-syntax-highlighting docker)
```

Then recompile:
```bash
~/.oh-my-zsh/compile_ohmyzsh.sh
```

### Update Oh-My-Zsh

```bash
omz update
~/.oh-my-zsh/compile_ohmyzsh.sh
exec zsh
```

## Troubleshooting

### Syntax Highlighting Not Working?

```bash
# Check if plugin exists
ls ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

# If missing, reinstall:
git clone --depth=1 \
  https://github.com/zsh-users/zsh-syntax-highlighting.git \
  ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
```

### Shell Still Slow?

```bash
# Profile your startup
echo "zmodload zsh/zprof" >> ~/.zshrc.tmp
cat ~/.zshrc >> ~/.zshrc.tmp
echo "zprof" >> ~/.zshrc.tmp
mv ~/.zshrc.tmp ~/.zshrc
exec zsh
# Look for slow operations, then remove profiling
```

### Want Original Config Back?

Your backup is saved with a timestamp:
```bash
# List backups
ls -la ~/.zsh-backup-*

# Restore
cp ~/.zsh-backup-YYYYMMDD-HHMMSS/.zshrc ~/.zshrc
exec zsh
```

## More Info

- Full documentation: [README-OPTIMIZED.md](./README-OPTIMIZED.md)
- Optimization details: [OPTIMIZATION_GUIDE.md](./OPTIMIZATION_GUIDE.md)
- GitHub: https://github.com/LinuxUser255/ohmyzsh

---

**Questions?** Open an issue on GitHub!
