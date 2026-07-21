#!/usr/bin/env bash
# Bootstrap a fresh machine: packages, dotfiles, ~/code repos, Claude Code config.
# Safe to re-run: every step is idempotent.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# 1. Packages ---------------------------------------------------------------
if [[ "$(uname)" == "Darwin" ]]; then
	xcode-select --install 2>/dev/null || true
	if ! command -v brew >/dev/null; then
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	fi
	brew bundle --file="$DOTFILES_DIR/Brewfile"
else
	xargs -a "$DOTFILES_DIR/dpkgs" sudo apt-get install -y
fi

# 2. Dotfiles: symlink dot/* -> ~/.* (edits in either place stay in sync) ---
for f in "$DOTFILES_DIR"/dot/*; do
	ln -sfn "$f" "$HOME/.$(basename "$f")"
done

# 3. Clone personal repos into ~/code (skips any that already exist) --------
mkdir -p "$HOME/code"
while IFS=$'\t' read -r dir url; do
	if [ -z "$dir" ]; then continue; fi
	dest="$HOME/code/$dir"
	if [ ! -d "$dest/.git" ]; then
		git clone "$url" "$dest" || echo "skip (clone failed): $dir"
	fi
done < "$DOTFILES_DIR/repos.txt"

# 4. Claude Code config -----------------------------------------------------
mkdir -p "$HOME/.claude"
ln -sfn "$DOTFILES_DIR/claude/settings.json" "$HOME/.claude/settings.json"
# Global instructions live in the AGENTS.md repo (cloned in step 3).
if [ -f "$HOME/code/AGENTS.md/AGENTS.md" ]; then
	ln -sfn "$HOME/code/AGENTS.md/AGENTS.md" "$HOME/.claude/CLAUDE.md"
fi
# Reinstall the enabled plugin from its public marketplace.
if command -v claude >/dev/null; then
	claude plugin marketplace add anthropics/claude-plugins-official || true
	claude plugin install frontend-design@claude-plugins-official || true
fi

# 5. rtk hook into Claude Code (idempotent; rtk owns the generated files) ----
if command -v rtk >/dev/null; then
	rtk init -g --auto-patch
fi

echo "dotfiles bootstrap complete."
