#!/bin/bash
# build.sh - Automate source generation, npm dependency installation, and Flatpak compilation.
set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=== Qobuz Linux Build Pipeline ===${NC}"

# Step 1: Regenerate Flatpak Sources (auto-regenerate if missing)
echo -e "\n${YELLOW}[1/4] Regenerating Flatpak sources..."
if [ ! -f "flatpak/generated-sources.json" ]; then
    echo -e "${BLUE}  Regenerating flatpak-node-generator sources...${NC}"
fi
flatpak-node-generator --no-requests-cache npm package-lock.json --output flatpak/generated-sources.json

# Step 2: Install Local Development Dependencies
echo -e "\n${YELLOW}[2/4] Installing local development dependencies..."
npm ci

# Step 3: Run Flatpak Compilation Sandbox
echo -e "\n${YELLOW}[3/4] Building Flatpak application package (offline sandbox)..."
flatpak-builder --arch=x86_64 --jobs=1 --user --disable-rofiles-fuse --install-deps-from=flathub --force-clean --repo=repo _build flatpak/dev.mukkematti.qobuz-linux.yml

# Step 4: Bundle into a Flatpak bundle
echo -e "\n${YELLOW}[4/4] Bundling Flatpak application..."
flatpak build-bundle --arch=x86_64 repo qobuz-linux.flatpak dev.mukkematti.qobuz-linux

echo -e "\n${GREEN}=== Build Pipeline Succeeded! ===${NC}"
echo -e "${GREEN}To install your newly compiled Flatpak application, run:${NC}"
echo -e "  ${BLUE}flatpak --user install repo dev.mukkematti.qobuz-linux${NC}"
