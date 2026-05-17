#!/bin/bash
# clean.sh - Clean up build caches, node_modules, and flatpak artifacts.
# This script ensures a pristine workspace to prevent flatpak-node-generator
# and flatpak-builder caching/local dependency resolution bugs.

set -euo pipefail

# Visual styling
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# ----------------------------------------------------
# Configuration: Define paths to clean
# ----------------------------------------------------
NODE_BUILD_PATHS=(
    "node_modules"
    "dist"
    "flatpak/generated-sources.json"
)

FLATPAK_PATHS=(
    "_build"
    ".flatpak-builder"
    "flatpak-node"
    "repo"
)

# Helper function to remove a path if it exists (handles files, directories, and symlinks)
clean_path() {
    local target="$1"
    if [ -e "$target" ] || [ -L "$target" ]; then
        echo -e "  Removing $target..."
        rm -rf "$target"
    fi
}

# ----------------------------------------------------
# Execution
# ----------------------------------------------------
echo -e "${BLUE}=== Qobuz Linux Clean & Preparation Script ===${NC}"

# 1. Clean Local Workstation npm & Electron Caches
echo -e "\n${YELLOW}[1/3] Cleaning Node & Build Caches...${NC}"
for target in "${NODE_BUILD_PATHS[@]}"; do
    clean_path "$target"
done

# 2. Clean Flatpak Caches
echo -e "\n${YELLOW}[2/3] Cleaning Flatpak Build Artifacts...${NC}"
for target in "${FLATPAK_PATHS[@]}"; do
    clean_path "$target"
done

# 3. Success message
echo -e "\n${GREEN}=== Workspace Cleaned Successfully! ===${NC}"
echo -e "${GREEN}You can now run a clean build pipeline:${NC}"
echo -e "  1. Regenerate sources safely (without local node_modules interfering):"
echo -e "     ${BLUE}flatpak-node-generator --no-requests-cache npm package-lock.json --output flatpak/generated-sources.json${NC}"
echo -e "  2. Install local npm dependencies for development (if needed):"
echo -e "     ${BLUE}npm ci${NC}"
echo -e "  3. Run flatpak-builder:"
echo -e "     ${BLUE}flatpak-builder --arch=x86_64 --jobs=1 --user --disable-rofiles-fuse --install-deps-from=flathub --force-clean --repo=repo _build flatpak/dev.mukkematti.qobuz-linux.yml${NC}"
