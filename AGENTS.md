# homelab — Agent instructions (concise)

Purpose
- Minimal guidance for AI agents working on this repository.

Core rules (summary)
- Work only inside this repo and the specific subdirectory you need to change. Do not touch unrelated projects.
- Read relevant files (this AGENTS.md and README.md, plus any project README) before making edits.
- Do not read, decrypt, or commit secrets. Ask the user if secrets are required. Do not use sops (or any automated decryption tool) to parse or extract secrets.
- All commits must follow Conventional Commits: <type>(scope): short description
  - Examples: feat(nixos): add tailscale module, fix(home-assistant): correct trigger
- Keep changes minimal and reversible. Prefer small, single-purpose commits.
- Do not push or open PRs without explicit user approval; provide a one-line git push command instead.

Validation & testing
- Suggest local validation commands the user can run (examples below).
  - nix flake check
  - nix build .#nixosConfigurations.<host>.config.system.build.toplevel
  - make vm/switch (when applicable)

When to ask the user
- Ambiguous requirements
- Cross-project changes
- Anything that requires secrets or credentials
- Breaking or destructive changes

Deliverables from the agent
- A short summary of proposed edits
- Exact git commands for the user to run to apply/push changes
- A Conventional Commit message suggestion

That's it — prefer clarity and small changes.