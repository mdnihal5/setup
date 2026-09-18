#!/usr/bin/env bash
# One command, any machine:
#   curl -fsSL <raw-url-to-this-file> | bash
#
# Clones this repo (if not already present) to a fixed path — same
# "fixed path" convention competitive-programming's UltiSnips already
# depends on — then runs every tool's own install.sh. Safe to re-run:
# every install.sh only backs up real files, and skips work that's already
# symlinked to this repo.
set -euo pipefail

REPO_DIR="$HOME/Personal/machine-setup"
REMOTE="git@github-personal:mdnihal5/machine-setup.git"

if [ ! -d "$REPO_DIR/.git" ]; then
  echo "==> Cloning machine-setup to $REPO_DIR"
  mkdir -p "$(dirname "$REPO_DIR")"
  git clone "$REMOTE" "$REPO_DIR" || {
    echo "SSH clone failed (no github-personal key on this machine yet?)." >&2
    echo "Falling back to HTTPS — you'll only be able to pull, not push, until the SSH alias is set up (see git/ssh-config.example)." >&2
    git clone "https://github.com/mdnihal5/machine-setup.git" "$REPO_DIR"
  }
else
  echo "==> Pulling latest"
  git -C "$REPO_DIR" pull --ff-only || echo "(couldn't fast-forward — using what's on disk)"
fi

for tool in git zed vim; do
  echo
  echo "########## $tool ##########"
  bash "$REPO_DIR/$tool/install.sh"
done

cat <<'EOF'

Done. Restart your terminal (for the shell alias) and Zed (to pick up the
config) to see everything take effect.
EOF
