# setup

One repo, one command, any machine (Linux or macOS): the full dev setup —
Zed, vim/competitive-programming, git identity — instead of it being
scattered across per-tool folders in other repos and going stale because
nothing forces a re-sync. Cloned locally as `machine-setup/` (the local
folder name doesn't need to match the repo name).

## Use — one command

```bash
curl -fsSL https://raw.githubusercontent.com/mdnihal5/setup/main/bootstrap.sh | bash
```

Or, if this repo is already cloned somewhere:

```bash
bash bootstrap.sh
```

Safe to re-run any time — every install script only backs up real files and
skips anything already symlinked to this repo.

## Why symlinks, not `cp`

The Zed config lived in the `scratch` repo before this (`scratch/zed-setup`,
private, "mostly throwaway" by its own description) and used `cp`. It went
stale the same day it was written — a settings.json edit happened on the
live `~/.config/zed/` copy, and nothing re-ran the capture step, so the repo
silently diverged from what was actually running. Symlinking `~/.config/zed`
straight at this repo's files means there's no separate "capture" step:
editing the live config *is* editing the repo, `git status` shows drift the
moment it happens, and forgetting to sync stops being possible.

## Structure

- **`zed/`** — `settings.json`, `keymap.json`, `themes/ayu-mirage-flat.json`.
  `install.sh` installs Zed itself if missing (official installer on Linux,
  Homebrew cask on macOS) and symlinks all three into `~/.config/zed`
  (same path on both OSes — Zed deliberately skips
  `~/Library/Application Support`).
- **`vim/`** — no vim files here on purpose. The real source of truth is
  `competitive-programming/vimrc/` (`.vimrc`, `UltiSnips/cpp.snippets`,
  `bash_aliases`) — its UltiSnips template resolves an include via an
  *absolute-path* python interpolation to
  `~/Personal/competitive-programming/Templete/debug.hpp`, so duplicating
  those files anywhere else would silently break that include.
  `install.sh` clones/pulls that repo to the exact path the interpolation
  expects, then symlinks `~/.vimrc`, `~/.vim/UltiSnips`, and
  `~/.bash_aliases` to it.
- **`git/`** — the work/personal identity split (`includeIf` on `~/Projects/`
  vs `~/Personal/`, portable — the live machine had these hardcoded to
  `/home/sys2026/...`, rewritten here to `~/` so a different username on a
  different machine doesn't break it) plus `ssh-config.example` for the
  `github-work`/`github-personal` host aliases. **No private keys are ever
  in this repo** — generate a fresh keypair per machine or copy one over a
  channel you trust, never via git.

## Not included (yet)

General shell config (`.bashrc` beyond the CP-specific `bash_aliases`,
prompt, exports) — nothing beyond the competitive-programming aliases was
found worth capturing when this repo was built. Add a `shell/` folder the
same way (files + `install.sh`, wired into `bootstrap.sh`'s tool list) when
there's real content for it.

## Adding a new tool later

1. New folder, e.g. `tmux/`.
2. Put the real config file(s) in it.
3. Write `tmux/install.sh` following the same shape as `zed/install.sh` —
   back up anything real, symlink from this repo, print what's manual.
4. Add `tmux` to the `for tool in ...` list in `bootstrap.sh`.
