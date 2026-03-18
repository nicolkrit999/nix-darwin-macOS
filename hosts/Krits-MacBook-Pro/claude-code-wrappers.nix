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

        # cai-openrouter — routes through OpenRouter using SOPS-managed API key.
        # Fails hard if the secret is missing — no fallback to Pro/OAuth ever.
        # Uses ANTHROPIC_AUTH_TOKEN (→ Authorization: Bearer) which OpenRouter requires.
        # Strips ANTHROPIC_API_KEY so the SDK cannot fall back to x-api-key auth.
        (pkgs.writeShellScriptBin "cai-openrouter" ''
          if [ ! -f /run/secrets/openrouter_api_claude_code ]; then
            echo "Error: /run/secrets/openrouter_api_claude_code not found." >&2
            echo "Run 'darwin-rebuild switch' or check your SOPS config." >&2
            exit 1
          fi
          exec env \
            -u ANTHROPIC_API_KEY \
            ANTHROPIC_BASE_URL="https://openrouter.ai/api" \
            ANTHROPIC_AUTH_TOKEN="$(cat /run/secrets/openrouter_api_claude_code)" \
            ${pkgs.claude-code}/bin/claude "$@"
        '')
      ];
    };
}
