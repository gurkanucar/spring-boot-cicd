#!/usr/bin/env bash
set -euo pipefail

# Standalone Docker installer — extracted from install.sh.
# Installs Docker Engine and the Docker Compose plugin on Linux.

# ── colours ───────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; BOLD='\033[1m'; NC='\033[0m'

ok()      { echo -e "${GREEN}✓${NC}  $1"; }
info()    { echo -e "${BLUE}→${NC}  $1"; }
warn()    { echo -e "${YELLOW}!${NC}  $1"; }
die()     { echo -e "${RED}✗${NC}  $1" >&2; exit 1; }
section() { echo -e "\n${BOLD}── $1 ──────────────────────────────────────────────${NC}"; }

# ── helpers ───────────────────────────────────────────────────────────────────
has() { command -v "$1" &>/dev/null; }

SUDO=""
[[ $EUID -ne 0 ]] && SUDO="sudo"

detect_os() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS_ID="${ID:-unknown}"
        OS_LIKE="${ID_LIKE:-}"
    else
        OS_ID="unknown"
        OS_LIKE=""
    fi
}

is_debian() { [[ "$OS_ID" == "debian" || "$OS_ID" == "ubuntu" || "$OS_LIKE" == *"debian"* ]]; }

# ── Docker ────────────────────────────────────────────────────────────────────
install_docker() {
    section "Docker"
    if has docker; then
        ok "Docker already installed: $(docker --version)"
    else
        info "Installing Docker..."
        curl -fsSL https://get.docker.com | $SUDO sh
        $SUDO systemctl enable --now docker
        $SUDO usermod -aG docker "$USER"
        ok "Docker installed: $(docker --version)"
        warn "Log out and back in (or run: newgrp docker) for group changes to take effect"
    fi

    if docker compose version &>/dev/null; then
        ok "Docker Compose plugin: $(docker compose version)"
    else
        info "Installing Docker Compose plugin..."
        COMPOSE_VER=$(curl -fsSL https://api.github.com/repos/docker/compose/releases/latest \
            | grep '"tag_name"' | cut -d'"' -f4)
        ARCH=$(uname -m); [[ "$ARCH" == "x86_64" ]] && ARCH="x86_64" || ARCH="aarch64"
        $SUDO mkdir -p /usr/local/lib/docker/cli-plugins
        $SUDO curl -fsSL \
            "https://github.com/docker/compose/releases/download/${COMPOSE_VER}/docker-compose-linux-${ARCH}" \
            -o /usr/local/lib/docker/cli-plugins/docker-compose
        $SUDO chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
        ok "Docker Compose installed: $(docker compose version)"
    fi
}

# ── main ──────────────────────────────────────────────────────────────────────
main() {
    echo -e "\n${BOLD}Docker installer${NC}"

    detect_os
    info "Detected OS: ${OS_ID}"

    if is_debian; then
        info "Updating package index..."
        $SUDO apt-get update -q
    fi

    install_docker

    section "Done"
    echo -e "${GREEN}Docker is ready.${NC}"
}

main "$@"
