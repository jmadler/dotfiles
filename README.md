run install.sh

## Claude Code permissions

`claude/settings.json` is the only permission allowlist. `install.sh` symlinks it to
`~/.claude/settings.json`, so an edit here takes effect at the next session start. Keep
project-level `.claude/settings.json` files empty of anything this file already covers —
two copies drift.

Add a pattern only when it is read-only. Never allowlist a wildcard that grants arbitrary
execution:

- interpreters and shells — `python`, `node`, `bash`, `ssh`
- package runners — `npx`, `bunx`, `uvx`, `uv run`
- task-runner wildcards — `npm run *`, `make *`, `cargo run *`; an exact `npm run build` is fine
- `docker run`, `docker exec`, `kubectl exec`, `sudo`

Claude Code already auto-allows most read-only commands, so they need no entry: `cat`, `ls`,
`head`, `grep`, `find`, every read-only `git` and `gh` subcommand, and `docker ps`. Check
before adding — an entry that never fires is noise.

To find what is worth adding, run `/fewer-permission-prompts`. It counts the Bash and MCP
calls in recent transcripts and proposes patterns.
