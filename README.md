# Pop OS Setup Script 🚀

Dieses Repository enthält mein persönliches Setup-Skript für Pop OS, mit dem ich schnell eine frische Installation einrichten kann.

## Funktionen

- Installation von Basispaketen (`neovim`, `tmux`, `nala`, `fzf`, usw.)
- Optionale Apps: Brave Browser, Obsidian, Tailscale
- Docker-Installation
- DevPod (nur x86_64)
- Automatische Dotfile-Verwaltung mit [`yadm`](https://yadm.io)
- LazyVim-Kompatibilität (`~/.config/nvim`)
- Sicherer Umgang mit bestehender Konfiguration (z. B. kein doppeltes Klonen)

## Verwendung

```bash
bash <(curl -s https://raw.githubusercontent.com/TamaTay/popOS/main/setup.sh)

