#!/usr/bin/env bash
# The vim setup itself (.vimrc, UltiSnips/cpp.snippets, bash_aliases) is NOT
# duplicated into this repo — it already lives in `competitive-programming`,
# and UltiSnips' `normal` snippet resolves its debug.hpp include via an
# absolute-path python interpolation to
#   ~/Personal/competitive-programming/Templete/debug.hpp
# Copying the vim files elsewhere would silently break that include. So this
# script just makes sure that repo exists at the exact path the interpolation
# expects, then symlinks the live dotfiles to it — same "symlink, don't copy"
# reasoning as zed/install.sh, for the same anti-drift reason.
set -euo pipefail

CP_REPO="$HOME/Personal/competitive-programming"
CP_REMOTE="git@github-personal:mdnihal5/competitive-programming.git"

echo "==> competitive-programming (source of truth for the vim setup)"
if [ ! -d "$CP_REPO/.git" ]; then
  git clone "$CP_REMOTE" "$CP_REPO"
else
  git -C "$CP_REPO" pull --ff-only || echo "(couldn't fast-forward — using what's on disk)"
fi

echo "==> Symlinking ~/.vimrc and ~/.vim/UltiSnips"
mkdir -p "$HOME/.vim"
[ -e "$HOME/.vimrc" ] && [ ! -L "$HOME/.vimrc" ] && mv "$HOME/.vimrc" "$HOME/.vimrc.bak-$(date +%Y%m%d-%H%M%S)"
ln -sf "$CP_REPO/vimrc/vimrc" "$HOME/.vimrc"
[ -e "$HOME/.vim/UltiSnips" ] && [ ! -L "$HOME/.vim/UltiSnips" ] && mv "$HOME/.vim/UltiSnips" "$HOME/.vim/UltiSnips.bak-$(date +%Y%m%d-%H%M%S)"
ln -sfn "$CP_REPO/vimrc/UltiSnips" "$HOME/.vim/UltiSnips"

echo "==> Symlinking ~/.bash_aliases (the cstart launcher)"
[ -e "$HOME/.bash_aliases" ] && [ ! -L "$HOME/.bash_aliases" ] && mv "$HOME/.bash_aliases" "$HOME/.bash_aliases.bak-$(date +%Y%m%d-%H%M%S)"
ln -sf "$CP_REPO/vimrc/bash_aliases" "$HOME/.bash_aliases"
grep -q '\.bash_aliases' "$HOME/.bashrc" 2>/dev/null || cat >> "$HOME/.bashrc" <<'RC'

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi
RC

OS="$(uname -s)"
if [ "$OS" = "Darwin" ]; then
  cat <<'EOF'

macOS: Apple's own `g++` is actually Clang — no <bits/stdc++.h>, no PBDS
(policy-based data structures). Install real GCC before compiling anything
from this template set:
  brew install gcc astyle
EOF
fi

cat <<EOF

Vim setup linked from $CP_REPO.
  - UltiSnips 'list' trigger reads UltiSnips/INDEX.md for every template.
  - Forgot a trigger name? <C-x><C-u> in insert mode (custom completefunc).
  - cstart <contest> <a,b,c> opens a fresh problem file — needs the new
    shell (source ~/.bashrc, or open a new terminal) to pick up the alias.
EOF
