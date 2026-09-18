#!/usr/bin/env bash
# Symlinks the git identity split (~/.gitconfig + work/personal halves) into
# place. Does NOT touch ~/.ssh/config automatically — that file can hold
# other unrelated hosts and needs 600 permissions, so it's safer to just
# tell you what to append rather than script edits into it.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"   # .../machine-setup/git

for f in gitconfig gitconfig-work gitconfig-personal; do
  target="$HOME/.$f"
  [ -e "$target" ] && [ ! -L "$target" ] && mv "$target" "${target}.bak-$(date +%Y%m%d-%H%M%S)"
  ln -sf "$HERE/$f" "$target"
done

if ! grep -q "Host github-personal" "$HOME/.ssh/config" 2>/dev/null; then
  cat <<EOF

~/.ssh/config doesn't have the github-work/github-personal host aliases yet.
Append $HERE/ssh-config.example to it, then generate (or copy) the matching
keypairs — see the comment at the top of that file. Without this, any
Personal-dir clone using the github-personal alias, or gitconfig-personal's
git@github.com: -> git@github-personal: rewrite, will fail to authenticate.
EOF
fi

echo "Git identity split linked: ~/Projects -> work email, ~/Personal -> personal email."
