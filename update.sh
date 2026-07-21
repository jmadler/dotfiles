#!/usr/bin/env bash
# Capture this machine's current state back into the repo — the parts that do NOT
# auto-sync. (dot/*, claude/settings.json, skills, and the repo list are symlinked
# or generated live, so they need no capture step.)
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# 1. Brewfile: snapshot everything currently installed (includes casks + taps).
if command -v brew >/dev/null; then
	brew bundle dump --force --file="$DOTFILES_DIR/Brewfile"
	echo "Brewfile refreshed from installed packages."
fi

# 2. Report home dotfiles that are not tracked yet, so you can add the ones you want.
#    Files only (not ~/.ssh, ~/.aws dirs), and never suggests known secret files.
echo "Untracked home dotfiles (add to dot/ manually if wanted):"
for f in "$HOME"/.*; do
	[ -f "$f" ] || continue
	base="$(basename "$f")"
	case "$base" in
		.DS_Store|.*_history|.viminfo|.lesshst|.netrc|.pgpass) continue ;;
	esac
	[ -e "$DOTFILES_DIR/dot/${base#.}" ] || echo "  $f"
done

echo
echo "Review with: git -C \"$DOTFILES_DIR\" diff  — then commit."
