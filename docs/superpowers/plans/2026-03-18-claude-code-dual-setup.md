# Claude Code Dual Setup (cai / cai-sub / cai-openrouter) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a 3-way Claude Code launch system — `cai` (passthrough), `cai-sub` (force Pro subscription), `cai-openrouter` (force OpenRouter with SOPS key) — keeping the shared module generic and putting host-specific wrappers in a new auto-discovered delib.module under the host directory.

**Architecture:** The shared `modules/programs/claude-code.nix` is stripped of all wrapper/alias logic and only installs `pkgs.claude-code` + the overlay + MCP secrets patching. A new `hosts/Krits-MacBook-Pro/claude-code-wrappers.nix` file using `delib.module` with its own enable option adds the 3 wrapper scripts via `environment.systemPackages`. The SOPS secret `openrouter_api_claude_code` is already declared in `system.nix` — no changes needed there.

**Tech Stack:** Nix (nix-darwin, denix/delib, sops-nix, writeShellScriptBin)

---

## File Map

| File | Action | Responsibility |
|------|--------|----------------|
| `modules/programs/claude-code.nix` | Modify (lines 22-31) | Remove `cai` wrapper, keep only `pkgs.claude-code` in systemPackages |
| `hosts/Krits-MacBook-Pro/claude-code-wrappers.nix` | Create | New `delib.module` with `cai`, `cai-sub`, `cai-openrouter` wrappers |
| `hosts/Krits-MacBook-Pro/default.nix` | Modify (add 1 line) | Enable the new module: `krit.services.Krits-MacBook-Pro.claude-code-wrappers.enable = true` |

**Files NOT modified:**
- `hosts/Krits-MacBook-Pro/system.nix` — SOPS secret `openrouter_api_claude_code` already declared (line 76-79)
- `~/.claude.json` — env vars from wrappers override at runtime, no config changes needed
- `hosts/Krits-MacBook-Pro/local-packages.nix` — not touched per user preference

---

### Task 1: Strip the `cai` wrapper from the shared module

**Files:**
- Modify: `modules/programs/claude-code.nix:19-32`

- [ ] **Step 1: Remove the `cai` writeShellScriptBin from darwin.ifEnabled**

Replace lines 19-32 (the entire `darwin.ifEnabled` block) with a version that only installs `pkgs.claude-code`:

```nix
  darwin.ifEnabled =
    { myconfig, ... }:
    {
      environment.systemPackages = [
        pkgs.claude-code
      ];
    };
```

This removes the `cai` wrapper script entirely. The shared module now only provides the plain `claude` binary — safe for any user without SOPS.

- [ ] **Step 2: Verify syntax**

Run: `cd /Users/krit/nix-darwin-macOS && nix flake check --no-build 2>&1 | head -20`
Expected: No syntax/evaluation errors

- [ ] **Step 3: Commit**

```bash
git add modules/programs/claude-code.nix
git commit -m "refactor: remove host-specific cai wrapper from shared claude-code module

The shared module now only installs pkgs.claude-code. Host-specific
wrappers will be added in a separate host-level module."
```

---

### Task 2: Create the host-specific claude-code-wrappers module

**Files:**
- Create: `hosts/Krits-MacBook-Pro/claude-code-wrappers.nix`

- [ ] **Step 1: Create the new delib.module file**

Create `hosts/Krits-MacBook-Pro/claude-code-wrappers.nix` with:

```nix
{
  delib,
  pkgs,
  ...
}:
delib.module {
  name = "krit.services.Krits-MacBook-Pro.claude-code-wrappers";

  options.krit.services.Krits-MacBook-Pro.claude-code-wrappers = with delib; {
    enable = boolOption false;
  };

  darwin.ifEnabled =
    { myconfig, ... }:
    {
      environment.systemPackages = [
        # cai — passthrough, launches claude with whatever env is present
        (pkgs.writeShellScriptBin "cai" ''
          exec ${pkgs.claude-code}/bin/claude "$@"
        '')

        # cai-sub — forces Pro subscription by stripping all OpenRouter env vars
        (pkgs.writeShellScriptBin "cai-sub" ''
          exec env \
            -u ANTHROPIC_BASE_URL \
            -u ANTHROPIC_AUTH_TOKEN \
            -u ANTHROPIC_MODEL \
            -u ANTHROPIC_API_KEY \
            -u OPENROUTER_API_KEY \
            ${pkgs.claude-code}/bin/claude "$@"
        '')

        # cai-openrouter — routes through OpenRouter using SOPS-managed API key
        # Does NOT set ANTHROPIC_MODEL so user can /model switch freely in-session
        (pkgs.writeShellScriptBin "cai-openrouter" ''
          if [ ! -f /run/secrets/openrouter_api_claude_code ]; then
            echo "Error: /run/secrets/openrouter_api_claude_code not found." >&2
            echo "Run 'darwin-rebuild switch' or check your SOPS config." >&2
            exit 1
          fi
          exec env \
            ANTHROPIC_BASE_URL="https://openrouter.ai/api" \
            ANTHROPIC_AUTH_TOKEN="$(cat /run/secrets/openrouter_api_claude_code)" \
            ANTHROPIC_API_KEY="" \
            ${pkgs.claude-code}/bin/claude "$@"
        '')
      ];
    };
}
```

Key design decisions:
- Uses `delib.module` (not `delib.host`) — same pattern as `local-packages.nix`
- Namespaced under `krit.services.Krits-MacBook-Pro.claude-code-wrappers` — same convention as other host modules
- `enable = boolOption false` — opt-in, won't affect other hosts
- Auto-discovered by denix — no imports needed in `flake.nix`
- `cai-openrouter` fails fast with a clear error if the SOPS secret isn't available
- `cai-openrouter` blanks `ANTHROPIC_API_KEY` to prevent Claude from using any existing key
- No `ANTHROPIC_MODEL` set — user picks model freely via `/model` inside session
- All wrappers use `exec` to replace the shell process (clean PID, proper signal handling)

- [ ] **Step 2: Verify syntax**

Run: `cd /Users/krit/nix-darwin-macOS && nix flake check --no-build 2>&1 | head -20`
Expected: No syntax/evaluation errors (module auto-discovered, but not enabled yet)

- [ ] **Step 3: Commit**

```bash
git add hosts/Krits-MacBook-Pro/claude-code-wrappers.nix
git commit -m "feat: add host-specific claude-code wrapper scripts (cai, cai-sub, cai-openrouter)

New delib.module at hosts/Krits-MacBook-Pro/ providing three launch modes:
- cai: passthrough (uses whatever env is present)
- cai-sub: forces Pro subscription (strips ANTHROPIC_* vars)
- cai-openrouter: routes via OpenRouter with SOPS-managed API key"
```

---

### Task 3: Enable the new module in the host's default.nix

**Files:**
- Modify: `hosts/Krits-MacBook-Pro/default.nix:91` (after last krit.services line)

- [ ] **Step 1: Add the enable line**

Add `krit.services.Krits-MacBook-Pro.claude-code-wrappers.enable = true;` in the `KRIT SERVICES` section of `default.nix`, after line 91 (`krit.services.Krits-MacBook-Pro.local-packages.enable = true;`):

```nix
      krit.services.Krits-MacBook-Pro.claude-code-wrappers.enable = true;
```

- [ ] **Step 2: Verify full evaluation**

Run: `cd /Users/krit/nix-darwin-macOS && nix flake check --no-build 2>&1 | head -20`
Expected: No errors — module is now enabled and fully evaluated

- [ ] **Step 3: Dry build to verify packages resolve**

Run: `cd /Users/krit/nix-darwin-macOS && darwin-rebuild build --flake .#Krits-MacBook-Pro 2>&1 | tail -10`
Expected: Build succeeds, output path printed

- [ ] **Step 4: Commit**

```bash
git add hosts/Krits-MacBook-Pro/default.nix
git commit -m "feat: enable claude-code-wrappers module for Krits-MacBook-Pro"
```

---

## Post-Implementation: Manual Steps for User

After `darwin-rebuild switch`:

1. **Test `cai`** — should launch Claude Code normally with existing settings
2. **Test `cai-sub`** — run `/status` inside session, should show Pro subscription, no OpenRouter vars
3. **Test `cai-openrouter`** — run `/status` inside session, should show OpenRouter base URL; use `/model` to switch between models (gemini, gpt, claude, etc.)

## What Was NOT Changed (and why)

- **`system.nix`** — SOPS secret `openrouter_api_claude_code` already declared at line 76-79
- **`~/.claude.json`** — env vars from wrappers take precedence at runtime
- **SOPS encrypted file** — the `openrouter_api_claude_code` key already exists
- **`local-packages.nix`** — per user preference, wrappers live in their own module
- **Shell configs (fish.nix, bash.nix, zsh.nix)** — no claude aliases found, nothing to remove
