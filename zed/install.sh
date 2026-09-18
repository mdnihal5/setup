#!/usr/bin/env bash
# Installs Zed itself (if missing) and symlinks this repo's config into
# ~/.config/zed — same path on Linux and macOS (verified against Zed's own
# docs; it deliberately skips ~/Library/Application Support).
#
# Symlinked, not copied: editing ~/.config/zed/settings.json IS editing this
# repo's copy, so `git status` shows drift immediately instead of the config
# silently going stale until someone remembers to re-copy it by hand.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"   # .../machine-setup/zed
ZED_CONFIG="$HOME/.config/zed"
OS="$(uname -s)"

echo "==> Zed itself"
case "$OS" in
  Linux)
    if ! command -v zed >/dev/null 2>&1; then
      curl -f https://zed.dev/install.sh | sh
    fi
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
    echo "Unrecognized OS '$OS' — install Zed manually, then re-run this script to link config." >&2
    ;;
esac

echo "==> Backing up any existing ~/.config/zed that isn't already this repo"
if [ -e "$ZED_CONFIG" ] && [ "$(readlink -f "$ZED_CONFIG/settings.json" 2>/dev/null)" != "$(readlink -f "$HERE/settings.json")" ]; then
  mv "$ZED_CONFIG" "${ZED_CONFIG}.bak-$(date +%Y%m%d-%H%M%S)"
fi

mkdir -p "$ZED_CONFIG"
ln -sf "$HERE/settings.json" "$ZED_CONFIG/settings.json"
ln -sf "$HERE/keymap.json" "$ZED_CONFIG/keymap.json"
ln -sfn "$HERE/themes" "$ZED_CONFIG/themes"

cat <<EOF

Zed config linked. Open Zed once — auto_install_extensions in settings.json
makes it pull every extension itself (astro, dockerfile, sql, golangci-lint,
mermaid, postgres-language-server, ...). Nothing else to install manually
for extensions.

Linux font install (no reliable single apt package across distros — do this
manually if buffer_font_family/JetBrains Mono isn't already on the system):
  mkdir -p ~/.local/share/fonts && cd ~/.local/share/fonts && \\
    curl -fLo JetBrainsMono.zip https://github.com/JetBrains/JetBrainsMono/releases/latest/download/JetBrainsMono.zip && \\
    unzip -o JetBrainsMono.zip -d JetBrainsMono && fc-cache -f

Verify fonts actually resolve in Zed's renderer (the OS listing a font is
not proof Zed's GPU renderer resolved it) — open a file and check ligatures
(calt) render and the buffer font isn't silently falling back to a generic
monospace.

Optional, only for languages you actually build/run on this machine:
  Go:            (apt) sudo apt install golang-go   (brew) brew install go
  golangci-lint: https://golangci-lint.run/welcome/install/
  Rust:          https://rustup.rs
EOF
