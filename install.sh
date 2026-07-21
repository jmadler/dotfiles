#!/usr/bin/env bash
# Bootstrap a fresh machine: packages, dotfiles, ~/code repos, Claude Code config + skills.
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

# 3. Clone every personal repo into ~/code -----------------------------------
# The list is pulled live from GitHub, so there is no manifest to keep in sync.
mkdir -p "$HOME/code"
if command -v gh >/dev/null; then
	repos="$(gh repo list jmadler --limit 1000 \
		--json name,sshUrl --jq '.[] | [.name, .sshUrl] | @tsv' 2>/dev/null || true)"
	if [ -n "$repos" ]; then
		while IFS=$'\t' read -r name url; do
			dest="$HOME/code/$name"
			[ -d "$dest/.git" ] || git clone "$url" "$dest" || echo "skip (clone failed): $name"
		done <<< "$repos"
	else
		echo "gh returned no repos (check 'gh auth status'); skipping clone."
	fi
else
	echo "gh not found; skipping repo clone. Install gh, authenticate, and re-run."
fi

# 4. Claude Code: settings, global rules, skills, plugin --------------------
mkdir -p "$HOME/.claude/skills"
ln -sfn "$DOTFILES_DIR/claude/settings.json" "$HOME/.claude/settings.json"

# Global operating rules: use the AGENTS.md repo's own installer.
if [ -d "$HOME/code/AGENTS.md" ]; then
	make -C "$HOME/code/AGENTS.md" install
fi

# Workflow skills: symlink each skill from the pack so repo pulls/edits propagate.
if [ -d "$HOME/code/agent-cycle-skills/skills" ]; then
	for s in "$HOME/code/agent-cycle-skills/skills"/*/; do
		ln -sfn "${s%/}" "$HOME/.claude/skills/$(basename "${s%/}")"
	done
fi

# Enabled plugin from its public marketplace.
if command -v claude >/dev/null; then
	claude plugin marketplace add anthropics/claude-plugins-official || true
	claude plugin install frontend-design@claude-plugins-official || true
fi

# 5. rtk hook into Claude Code (idempotent; rtk owns the generated files) ----
if command -v rtk >/dev/null; then
	rtk init -g --auto-patch
fi

echo "dotfiles bootstrap complete."
