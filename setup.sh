#!/usr/bin/env bash
set -euo pipefail

# Konfiguration
DOTFILES_REPO="https://github.com/TamaTay/dotfiles.git"
YADM_DIR="$HOME/.local/share/yadm/repo.git"

# Farben
if [[ -t 1 ]]; then
  COLOR_RESET="\e[0m"
  COLOR_GREEN="\e[0;32m"
  COLOR_YELLOW="\e[0;33m"
  COLOR_RED="\e[0;31m"
  COLOR_BLUE="\e[0;34m"
else
  COLOR_RESET=""
  COLOR_GREEN=""
  COLOR_YELLOW=""
  COLOR_RED=""
  COLOR_BLUE=""
fi

msg()     { echo -e "${COLOR_BLUE}[INFO]${COLOR_RESET} $1"; }
msg_ok()  { echo -e "${COLOR_GREEN}[OK]${COLOR_RESET}  $1"; }
msg_warn(){ echo -e "${COLOR_YELLOW}[WARN]${COLOR_RESET} $1"; }
msg_err() { echo -e "${COLOR_RED}[ERR]${COLOR_RESET} $1" >&2; }

# Basispakete installieren
install_base_packages() {
  msg "Installiere Basispakete..."
  sudo apt update
  sudo apt install -y git fzf curl tmux neovim ca-certificates nala yadm tree
  msg_ok "Pakete installiert."
}

# Optionales: Brave, Obsidian, Tailscale
install_optional_apps() {
  read -p "[?] Brave installieren? (y/N): " choice
  [[ "$choice" =~ ^[Yy]$ ]] && curl -fsS https://dl.brave.com/install.sh | sudo bash && msg_ok "Brave installiert."

  read -p "[?] Obsidian installieren? (y/N): " choice
  [[ "$choice" =~ ^[Yy]$ ]] && sudo flatpak install flathub md.obsidian.Obsidian -y && msg_ok "Obsidian installiert."

  read -p "[?] Tailscale installieren? (y/N): " choice
  [[ "$choice" =~ ^[Yy]$ ]] && curl -fsSL https://tailscale.com/install.sh | sudo sh && msg_ok "Tailscale installiert."
}

# Docker
install_docker() {
  read -p "[?] Docker installieren? (y/N): " choice
  if [[ "$choice" =~ ^[Yy]$ ]]; then
    sudo apt remove -y docker.io docker-doc docker-compose podman-docker containerd runc || true
    sudo apt update
    sudo apt install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    msg_warn "Führe 'newgrp docker' oder logge dich neu ein, um Docker ohne sudo zu nutzen."
    msg_ok "Docker installiert."
  fi
}

# DevPod (nur x86_64)
install_devpod() {
  local arch
  arch=$(uname -m)
  read -p "[?] DevPod installieren? (nur für x86_64) (y/N): " choice
  if [[ "$choice" =~ ^[Yy]$ && "$arch" == "x86_64" ]]; then
    curl -Lo /tmp/devpod "https://github.com/loft-sh/devpod/releases/latest/download/devpod-linux-amd64"
    sudo install -m 0755 /tmp/devpod /usr/local/bin/devpod
    rm /tmp/devpod
    msg_ok "DevPod installiert."
  elif [[ "$arch" != "x86_64" ]]; then
    msg_warn "DevPod wird auf dieser Architektur nicht unterstützt."
  fi
}

# Yadm initialisieren, falls nicht vorhanden
setup_yadm() {
  if ! command -v yadm &> /dev/null; then
    msg "Installiere yadm..."
    sudo apt install -y yadm
  fi

  if [[ ! -d "$YADM_DIR" ]]; then
    msg "Cloning Dotfiles mit yadm..."
    yadm clone "$DOTFILES_REPO"
  else
    msg_ok "yadm Repo existiert bereits – überspringe Klonen."
  fi
}

# Lazy.nvim Plugin Sync
lazyvim_sync() {
  local nvim_dir="$HOME/.config/nvim"
  if [[ -d "$nvim_dir" && -f "$nvim_dir/lua/config/lazy.lua" ]]; then
    msg "Neovim-Konfiguration gefunden. Lazy.nvim Plugin Sync läuft..."
    if command -v nvim &> /dev/null; then
      nvim --headless "+Lazy! sync" +qa && msg_ok "Lazy.nvim Plugins synchronisiert."
    else
      msg_warn "nvim nicht gefunden – überspringe Lazy.nvim-Sync."
    fi
  else
    msg_warn "Keine gültige Lazy.nvim-Konfiguration in $nvim_dir gefunden – überspringe Plugin-Sync."
  fi
}

# Hauptfunktion
main() {
  msg "Starte PopOS Setup"

  install_base_packages
  install_optional_apps
  install_docker
  install_devpod
  setup_yadm
  lazyvim_sync

  msg_ok "Setup abgeschlossen!"
  msg_warn "Starte ggf. eine neue Shell oder logge dich neu ein."
}

main

