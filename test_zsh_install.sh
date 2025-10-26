#!/usr/bin/env bash

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Test function
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    echo -n "Testing: $test_name ... "
    
    if eval "$test_command" &>/dev/null; then
        echo -e "${GREEN}PASSED${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}FAILED${NC}"
        echo "  Command: $test_command"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Verbose test function (shows output)
run_verbose_test() {
    local test_name="$1"
    local test_command="$2"
    
    echo "Testing: $test_name"
    echo "  Command: $test_command"
    
    if eval "$test_command"; then
        echo -e "  ${GREEN}PASSED${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "  ${RED}FAILED${NC}"
        ((TESTS_FAILED++))
        return 1
    fi
}

echo "========================================="
echo "ZSH Installation Test Suite"
echo "========================================="
echo

# 1. Check if zsh binary exists
run_test "Zsh binary exists" "command -v zsh"

# 2. Check zsh version
run_test "Zsh version check" "zsh --version"

# 3. Check if zsh is in /etc/shells
run_test "Zsh in /etc/shells" "grep -q '^/bin/zsh$' /etc/shells"

# 4. Check module directory exists
echo
echo "Module Directory Tests:"
ZSH_VERSION=$(zsh --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+[^[:space:]]*' | head -1)
if [[ -n "$ZSH_VERSION" ]]; then
    run_test "Module directory exists" "test -d /usr/lib/zsh/${ZSH_VERSION}"
    
    # Get actual module path
    MODULE_PATH=$(zsh -c 'echo $MODULE_PATH' 2>/dev/null)
    if [[ -n "$MODULE_PATH" ]]; then
        run_test "Module path accessible" "test -r $MODULE_PATH"
    fi
fi

# 5. Check critical modules
echo
echo "Module Loading Tests:"
CRITICAL_MODULES=(
    "zsh/zle"
    "zsh/complist"
    "zsh/complete"
    "zsh/main"
    "zsh/parameter"
    "zsh/terminfo"
    "zsh/zutil"
)

for module in "${CRITICAL_MODULES[@]}"; do
    run_test "Load module $module" "zsh -c 'zmodload $module'"
done

# 6. Check shared libraries
echo
echo "Shared Library Tests:"
run_test "Check for .so files" "find /usr/lib -path '*/zsh/*' -name '*.so' -print -quit 2>/dev/null | grep -q '.so'"

# 7. Permission tests
echo
echo "Permission Tests:"
if [[ -n "$MODULE_PATH" ]]; then
    run_test "Module directory readable" "test -r $MODULE_PATH"
    run_test "Module directory executable" "test -x $MODULE_PATH"
    
    # Check .so file permissions
    if [[ -d "$MODULE_PATH/zsh" ]]; then
        for so_file in "$MODULE_PATH/zsh"/*.so 2>/dev/null; do
            if [[ -f "$so_file" ]]; then
                base_name=$(basename "$so_file")
                run_test "Permissions for $base_name" "test -r '$so_file' && test -x '$so_file'"
            fi
        done
    fi
fi

# 8. Functionality tests
echo
echo "Functionality Tests:"
run_test "Basic zsh execution" "zsh -c 'echo test' | grep -q test"
run_test "Interactive mode check" "echo 'echo works' | zsh -i 2>&1 | grep -q works"
run_test "Completion system" "zsh -c 'autoload -U compinit && compinit -u && echo success' | grep -q success"

# 9. Oh-My-Zsh compatibility
echo
echo "Oh-My-Zsh Compatibility Tests:"
if [[ -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]] || [[ -f "./oh-my-zsh.sh" ]]; then
    run_test "Oh-My-Zsh sourcing" "zsh -c 'source ${ZSH:-$HOME/.oh-my-zsh}/oh-my-zsh.sh 2>/dev/null && echo success' | grep -q success"
fi

# 10. Extended tests (verbose)
echo
echo "Extended Diagnostics:"
echo "----------------------------------------"

# Show actual zsh version
echo "Installed Zsh version:"
zsh --version || echo "  Failed to get version"

# Show module path
echo
echo "Module path:"
zsh -c 'echo "  $MODULE_PATH"' || echo "  Failed to get module path"

# List available modules
echo
echo "Available modules in $MODULE_PATH/zsh:"
if [[ -d "$MODULE_PATH/zsh" ]]; then
    ls -1 "$MODULE_PATH/zsh"/*.so 2>/dev/null | head -5 | sed 's/^/  /'
    module_count=$(ls -1 "$MODULE_PATH/zsh"/*.so 2>/dev/null | wc -l)
    echo "  ... (Total: $module_count modules)"
else
    echo "  Module directory not found"
fi

# Check for common issues
echo
echo "Common Issue Checks:"
echo "----------------------------------------"

# Check if running as correct user
if [[ "$EUID" -eq 0 ]]; then
    echo -e "${YELLOW}⚠ Running as root - some user-specific tests may not work${NC}"
fi

# Check if /bin/zsh exists
if [[ ! -f /bin/zsh ]]; then
    echo -e "${RED}✗ /bin/zsh not found${NC}"
elif [[ ! -x /bin/zsh ]]; then
    echo -e "${RED}✗ /bin/zsh exists but is not executable${NC}"
else
    echo -e "${GREEN}✓ /bin/zsh exists and is executable${NC}"
fi

# Check ldconfig
if command -v ldconfig &>/dev/null; then
    echo -e "${GREEN}✓ ldconfig available${NC}"
    if ldconfig -p | grep -q libzsh; then
        echo -e "${GREEN}✓ zsh libraries in ldconfig cache${NC}"
    else
        echo -e "${YELLOW}⚠ zsh libraries not found in ldconfig cache${NC}"
    fi
else
    echo -e "${YELLOW}⚠ ldconfig not found${NC}"
fi

# Final summary
echo
echo "========================================="
echo "Test Summary"
echo "========================================="
echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "\n${GREEN}✓ All tests passed! Zsh is properly installed.${NC}"
    exit 0
else
    echo -e "\n${RED}✗ Some tests failed. Please review the output above.${NC}"
    
    # Provide fix suggestions
    echo
    echo "Suggested fixes:"
    echo "1. Run: sudo chmod -R 755 /usr/lib/zsh/"
    echo "2. Run: sudo ldconfig"
    echo "3. Reinstall with: sudo bash build_zsh_improved.sh"
    
    exit 1
fi