#!/usr/bin/env bash
# One file, no clone: fetches the three config files straight from GitHub raw
# and installs Zed. Use this when you just want Zed set up somewhere and
# don't want the whole machine-setup repo on that machine.
#
#   curl -fsSL https://raw.githubusercontent.com/mdnihal5/setup/main/zed/bootstrap.sh | bash
#
# Trade-off, on purpose: this COPIES the files (there's no local clone to
# symlink to), so unlike zed/install.sh this config can go stale if the repo
# changes later. If you want the repo checked out and kept in sync instead,
# clone https://github.com/mdnihal5/setup and run zed/install.sh from it.
set -euo pipefail

RAW_BASE="https://raw.githubusercontent.com/mdnihal5/setup/main/zed"
ZED_CONFIG="$HOME/.config/zed"
OS="$(uname -s)"

echo "==> Zed itself"
case "$OS" in
  Linux)
    command -v zed >/dev/null 2>&1 || curl -f https://zed.dev/install.sh | sh
    ;;
  Darwin)
    if ! command -v brew >/dev/null 2>&1; then
      echo "Homebrew not found — install it first: https://brew.sh" >&2
      exit 1
    fi
    brew list --cask zed >/dev/null 2>&1 || brew install --cask zed
    brew list --cask font-jetbrains-mono >/dev/null 2>&1 || brew install --cask font-jetbrains-mono
    brew list --cask font-dejavu >/dev/null 2>&1 || brew install --cask font-dejavu
    ;;
  *)
    echo "Unrecognized OS '$OS' — install Zed manually, then re-run this script." >&2
    ;;
esac

echo "==> Backing up any existing ~/.config/zed"
if [ -e "$ZED_CONFIG" ] && [ ! -e "$ZED_CONFIG/.from-mdnihal5-setup" ]; then
  mv "$ZED_CONFIG" "${ZED_CONFIG}.bak-$(date +%Y%m%d-%H%M%S)"
fi

echo "==> Fetching config"
mkdir -p "$ZED_CONFIG/themes"
curl -fsSL "$RAW_BASE/settings.json" -o "$ZED_CONFIG/settings.json"
curl -fsSL "$RAW_BASE/keymap.json" -o "$ZED_CONFIG/keymap.json"
curl -fsSL "$RAW_BASE/themes/ayu-mirage-flat.json" -o "$ZED_CONFIG/themes/ayu-mirage-flat.json"
touch "$ZED_CONFIG/.from-mdnihal5-setup"   # marks these as ours, so a re-run doesn't back itself up

cat <<'EOF'

Done. Open Zed once — auto_install_extensions in settings.json makes it pull
every extension itself (astro, dockerfile, sql, golangci-lint, mermaid,
postgres-language-server, ...). Nothing else to install manually there.

Linux font install (no reliable single apt package across distros):
  mkdir -p ~/.local/share/fonts && cd ~/.local/share/fonts && \
    curl -fLo JetBrainsMono.zip https://github.com/JetBrains/JetBrainsMono/releases/latest/download/JetBrainsMono.zip && \
    unzip -o JetBrainsMono.zip -d JetBrainsMono && fc-cache -f

Verify fonts actually resolve in Zed's renderer (the OS listing a font is
not proof Zed's GPU renderer resolved it) — open a file, check ligatures
(calt) render and the buffer font isn't silently falling back.

macOS only: keymap.json's ctrl-alt-down/up (Add Cursor Below/Above) collides
with macOS's default Mission Control/Spaces shortcut on the same keys — see
the comment above that block in ~/.config/zed/keymap.json for the fix.

This copy will go stale if the source repo changes later — re-run this
script to refresh it, or switch to a real clone (see the comment at the top
of this file) if you want it to stay in sync automatically.
EOF
