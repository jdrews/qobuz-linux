#!/bin/bash
# build.sh - Automate source generation, npm dependency installation, and Flatpak compilation.
# This script executes a clean build pipeline to guarantee absolute reproducibility.

set -euo pipefail

# Visual styling
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# ----------------------------------------------------
# Dependency Verification
# ----------------------------------------------------
check_command() {
    local cmd="$1"
    local install_msg="$2"
    if ! command -v "$cmd" &> /dev/null; then
        echo -e "${RED}Error: Required tool '$cmd' is missing from your system path.${NC}"
        echo -e "${YELLOW}Recommendation: $install_msg${NC}"
        exit 1
    fi
}

echo -e "${BLUE}=== Qobuz Linux Build Pipeline ===${NC}"

check_command "flatpak-node-generator" "Install via pipx: pipx install flatpak-node-generator"
check_command "npm" "Install Node.js (with npm) on your workstation."
check_command "flatpak-builder" "Install flatpak-builder via your Linux distribution's package manager."

# ----------------------------------------------------
# Pipeline Execution
# ----------------------------------------------------

# Step 1: Regenerate Flatpak Sources
echo -e "\n${YELLOW}[1/3] Regenerating Flatpak sources (npm lockfile integration)...${NC}"
echo -e "  Running flatpak-node-generator..."
flatpak-node-generator --no-requests-cache npm package-lock.json --output flatpak/generated-sources.json

# Step 2: Install Local Development Dependencies
echo -e "\n${YELLOW}[2/3] Installing local development dependencies...${NC}"
echo -e "  Running npm ci..."
npm ci

# Step 3: Run Flatpak Compilation Sandbox
echo -e "\n${YELLOW}[3/3] Building Flatpak application package (offline sandbox)...${NC}"
echo -e "  Running flatpak-builder..."
flatpak-builder --arch=x86_64 --jobs=1 --user --disable-rofiles-fuse --install-deps-from=flathub --force-clean --repo=repo _build flatpak/dev.mukkematti.qobuz-linux.yml

# ----------------------------------------------------
# Completion Instructions
# ----------------------------------------------------
echo -e "\n${GREEN}=== Build Pipeline Succeeded! ===${NC}"
echo -e "${GREEN}To install your newly compiled Flatpak application, run:${NC}"
echo -e "  ${BLUE}flatpak --user install repo dev.mukkematti.qobuz-linux${NC}"
echo -e "${GREEN}To run the installed Flatpak application, run:${NC}"
echo -e "  ${BLUE}flatpak run dev.mukkematti.qobuz-linux${NC}"
