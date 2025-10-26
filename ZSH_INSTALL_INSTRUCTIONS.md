# ZSH Installation & Testing Guide

## Overview
This guide covers building and testing a customized zsh installation from the forked repository at https://github.com/LinuxUser255/zsh

## Files Included
- `build_zsh_improved.sh` - Main installation script with automatic module permission fixes
- `test_zsh_install.sh` - Comprehensive test suite to verify installation

## Installation Instructions

### On Your VM:

1. **Clone the ohmyzsh repository with submodules:**
   ```bash
   git clone --recurse-submodules https://github.com/LinuxUser255/ohmyzsh.git
   cd ohmyzsh
   ```

2. **Run the zsh build script:**
   ```bash
   sudo bash build_zsh_improved.sh
   ```

   The script will:
   - Install all required build dependencies
   - Clone the forked zsh repository
   - Build zsh with proper module support
   - Fix all permission issues automatically
   - Configure zsh as your default shell

3. **Log out and log back in** to activate zsh as your default shell

## Testing Instructions

### After installation, verify everything works:

1. **Run the test suite:**
   ```bash
   bash test_zsh_install.sh
   ```

2. **What the tests check:**
   - Zsh binary exists and is executable
   - All critical modules load properly (zle, complist, complete, etc.)
   - Module permissions are correct
   - Oh-My-Zsh compatibility
   - Dynamic libraries are properly linked

3. **Expected output:**
   - All tests should show `PASSED` in green
   - Final summary should show "✓ All tests passed!"

## Troubleshooting

### If you see module loading errors:

1. **Quick fix (run on VM):**
   ```bash
   sudo chmod -R 755 /usr/lib/zsh/
   sudo ldconfig
   ```

2. **Re-run the test suite:**
   ```bash
   bash test_zsh_install.sh
   ```

### If tests still fail:

1. **Complete reinstall:**
   ```bash
   sudo bash build_zsh_improved.sh
   ```
   
   The script will prompt if you want to reinstall over an existing installation.

## What Makes This Build Special

- Uses your forked zsh repository
- Automatically fixes the common "Permission denied" error for `.so` modules
- Includes comprehensive module loading verification
- Integrates perfectly with your customized oh-my-zsh configuration
- Includes zsh-autosuggestions and zsh-syntax-highlighting as proper submodules

## Quick Test Commands

After installation, test these manually:

```bash
# Test module loading
zsh -c 'zmodload zsh/zle && echo "✓ Modules work!"'

# Test oh-my-zsh loading
zsh -c 'source ~/ohmyzsh/oh-my-zsh.sh && echo "✓ Oh-My-Zsh works!"'

# Check version
zsh --version
```

## Notes

- The build script creates temporary build directories that are automatically cleaned up
- All tests can be run without sudo (except the build script itself)
- The test suite provides diagnostic information if anything fails
- Both scripts use your forked repository at https://github.com/LinuxUser255/zsh