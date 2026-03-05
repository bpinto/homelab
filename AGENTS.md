# Homelab - AI Agent Instructions

## Purpose

This file provides instructions for AI agents working on this multi-project homelab repository. It defines repository-wide conventions, where to find project-specific guidance, and how to approach code changes safely.

## Repository Structure

This is a **multi-project repository** with independent subdirectories:

```
homelab/
├── AGENTS.md              # This file - repository-wide agent instructions
├── README.md              # User-facing documentation
├── nixos/                 # NixOS configuration (VM + bare metal)
│   └── AGENTS.md          # ⚠️ READ THIS for NixOS work
├── bootc-ucore/           # Fedora CoreOS configuration
├── home-assistant/        # Home automation YAML configs
├── esphome/               # ESP device firmware
└── .github/workflows/     # CI/CD automation
```

## Critical Rules for Agents

### 1. Project Isolation

- Each subdirectory is an **independent project** with its own tooling
- **Never make changes across multiple projects** unless explicitly requested
- Changes to one project must not break others

### 2. Read Before Acting

**Before making any changes:**

1. Identify which project(s) are affected
2. Check for project-specific `AGENTS.md` (e.g., `nixos/AGENTS.md`)
3. If no AGENTS.md exists, read project's `README.md`
4. Understand existing patterns and conventions
5. Verify changes won't affect other projects

### 3. Conventional Commits (REQUIRED)

**All commits MUST follow [Conventional Commits](https://www.conventionalcommits.org/) specification.**

Format: `<type>[optional scope]: <description>`

**Types:**

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Formatting, missing semicolons, etc.
- `refactor`: Code change that neither fixes a bug nor adds a feature
- `perf`: Performance improvement
- `test`: Adding or updating tests
- `chore`: Maintenance tasks (dependencies, build config)
- `ci`: CI/CD changes

**Scopes** (use project names):

- `nixos`, `bootc-ucore`, `home-assistant`, `esphome`

**Examples:**

```
feat(nixos): add tailscale service module
fix(home-assistant): correct automation trigger syntax
docs(nixos): update VM setup instructions in AGENTS.md
chore: update renovate configuration
refactor(nixos): simplify module imports
```

**Breaking changes:**

```
feat(nixos)!: switch to flakes-based configuration

BREAKING CHANGE: legacy configuration.nix no longer supported
```

### 4. Secrets Management

⚠️ **NEVER EVER commit secrets, API keys, passwords, or auth tokens.**

- Check `.gitignore` before committing
- Each project handles secrets differently (see project docs)
- When in doubt, ask the user about secrets

### 5. Testing Requirements

Before proposing changes:

- Verify syntax/format is correct
- Check that files compile/validate (if possible)
- Suggest testing steps for the user
- For NixOS: recommend testing in VM before bare metal

## Project-Specific Guidance

### NixOS (`nixos/`)

**⚠️ MUST READ: [nixos/AGENTS.md](nixos/AGENTS.md)**

- Tool: Nix flakes with Determinate Systems Nix
- Environments: VMware Fusion VM + bare metal
- Patterns: Modular, reusable configuration with `machines/`, `modules/`, `home/` structure
- Always test in VM first

### bootc-ucore (`bootc-ucore/`)

**READ: [bootc-ucore/README.md](bootc-ucore/README.md)**

- Tool: Containerfile + Fedora CoreOS
- Immutable, container-native OS

### Home Assistant (`home-assistant/`)

**READ: [home-assistant/README.md](home-assistant/README.md)**

- Format: YAML configuration
- Contains: blueprints, custom_components, packages

### ESPHome (`esphome/`)

- Format: YAML device definitions
- Target: ESP32/ESP8266 firmware

## Common Workflows for Agents

### Making a Code Change

1. **Identify project**: Which directory does this affect?
2. **Read docs**: Load project's AGENTS.md or README.md
3. **Understand context**: Read relevant files before editing
4. **Make minimal changes**: Only modify what's necessary
5. **Follow conventions**: Use patterns from existing code
6. **Use conventional commits**: Format commit messages correctly
7. **Explain clearly**: Describe what changed and why
8. **Suggest testing**: Provide commands to verify changes

### Adding New Files

1. Follow project's directory structure
2. Match existing naming conventions
3. Add appropriate documentation
4. Update relevant imports/references
5. Suggest validation steps

### Modifying Configuration

1. Understand the current state first (read files)
2. Make incremental changes
3. Preserve working functionality
4. Document any behavior changes
5. For NixOS: ensure VM and bare metal compatibility

## What to Check Before Committing

- [ ] Read project-specific AGENTS.md (if exists)
- [ ] Changes follow project conventions
- [ ] No secrets committed
- [ ] Commit message follows Conventional Commits format
- [ ] Files are in correct directory structure
- [ ] Changes are minimal and focused
- [ ] Explained changes clearly to user

## When to Ask for Clarification

Ask the user when:

- Requirements are ambiguous
- Changes would affect multiple projects
- Destructive or breaking changes are needed
- Secrets/credentials are required
- You need hardware-specific information
- Testing isn't possible without their environment

## Multi-Project Changes

If a request affects multiple projects:

1. Handle each project separately
2. Create separate commits per project (with appropriate scopes)
3. Explain dependencies between changes
4. Test order matters - suggest sequence

## Quick Reference

| Project         | Tool/Format   | Agent Instructions                 | Key Points                       |
| --------------- | ------------- | ---------------------------------- | -------------------------------- |
| nixos/          | Nix flakes    | [nixos/AGENTS.md](nixos/AGENTS.md) | Read this first! VM + bare metal |
| bootc-ucore/    | Containerfile | [README](bootc-ucore/README.md)    | Container-native OS              |
| home-assistant/ | YAML          | [README](home-assistant/README.md) | Home automation configs          |
| esphome/        | YAML          | N/A                                | IoT device firmware              |

## Repository-Wide Files

- `.gitignore` - Check before committing files
- `renovate.json` - Dependency automation config
- `.github/workflows/` - CI/CD pipelines
- `README.md` - User-facing documentation (update when adding features)

## Example Agent Workflow

```
User: "Add a new module for Docker to NixOS config"

Agent should:
1. Read nixos/AGENTS.md completely
3. Understand the modular structure
4. Check existing modules for patterns
5. Create module in appropriate location (e.g., modules/services/docker.nix)
6. Follow Nix module conventions
7. Make changes
8. Commit with: "feat(nixos): add docker service module"
9. Explain changes and suggest: "nix flake check" and "test in VM first"
```

---

**Remember**: This is infrastructure code. Changes can break production systems. Always err on the side of caution and clear communication.
