{
  delib,
  pkgs,
  inputs,
  ...
}:
delib.module {
  name = "programs.claude-code";
  options = delib.singleEnableOption false;

  darwin.always =
    { ... }:
    {
      nixpkgs.overlays = [
        inputs.claude-code.overlays.default
      ];
    };

  darwin.ifEnabled =
    { myconfig, ... }:
    {
      environment.systemPackages = [
        pkgs.claude-code

        (pkgs.writeShellScriptBin "cai" ''
          if [ -f /run/secrets/openrouter_api_claude_code ]; then
            export OPENROUTER_API_KEY=$(cat /run/secrets/openrouter_api_claude_code)
          fi
          exec ${pkgs.claude-code}/bin/claude "$@"
        '')
      ];
    };

  home.ifEnabled =
    { myconfig, ... }:
    {
      programs.fish.shellAbbrs = {
        caitempplugins = "npx claude-code-templates@latest --plugins";
        caitemphealt = "npx claude-code-templates@latest --health-check";
        caitempchat = "npx claude-code-templates@latest --chats";
        caitempanalytics = "npx claude-code-templates@latest --analytics";
      };

      programs.zsh.shellAliases = {
        caitempplugins = "npx claude-code-templates@latest --plugins";
        caitemphealt = "npx claude-code-templates@latest --health-check";
        caitempchat = "npx claude-code-templates@latest --chats";
        caitempanalytics = "npx claude-code-templates@latest --analytics";
      };

      home.activation.patchClaudeJsonSecrets =
        inputs.home-manager.lib.hm.dag.entryAfter [ "writeBoundary" ]
          ''
            _read_secret() {
              if [ -f "$1" ]; then
                cat "$1" 2>/dev/null || true
              fi
            }

            CLAUDE_JSON="$HOME/.claude.json"
            if [ -f "$CLAUDE_JSON" ]; then
              ${pkgs.jq}/bin/jq \
                --arg actual_pw "$(_read_secret /run/secrets/claude_mcp_actual_password)" \
                --arg actual_sync "$(_read_secret /run/secrets/claude_mcp_actual_sync_id)" \
                --arg actual_enc "$(_read_secret /run/secrets/claude_mcp_actual_encryption_password)" \
                --arg ctx7 "$(_read_secret /run/secrets/claude_mcp_context7_api_key)" \
                --arg openai "$(_read_secret /run/secrets/claude_mcp_openai_api_key)" \
                --arg milvus "$(_read_secret /run/secrets/claude_mcp_milvus_token)" \
                --arg ghtoken "$(_read_secret /run/secrets/claude_mcp_github_copilot_token)" \
                --arg portainer "$(_read_secret /run/secrets/claude_mcp_portainer_token)" \
                '
                (if ($actual_pw != "") and (.mcpServers["budget-principale"]? != null) then .mcpServers["budget-principale"].env.ACTUAL_PASSWORD = $actual_pw else . end) |
                (if ($actual_sync != "") and (.mcpServers["budget-principale"]? != null) then .mcpServers["budget-principale"].env.ACTUAL_BUDGET_SYNC_ID = $actual_sync else . end) |
                (if ($actual_enc != "") and (.mcpServers["budget-principale"]? != null) then .mcpServers["budget-principale"].env.ACTUAL_BUDGET_ENCRYPTION_PASSWORD = $actual_enc else . end) |
                (if ($ctx7 != "") and (.mcpServers["context7"]? != null) then .mcpServers["context7"].args[-1] = $ctx7 else . end) |
                (if ($openai != "") and (.mcpServers["claude-context"]? != null) then .mcpServers["claude-context"].env.OPENAI_API_KEY = $openai else . end) |
                (if ($milvus != "") and (.mcpServers["claude-context"]? != null) then .mcpServers["claude-context"].env.MILVUS_TOKEN = $milvus else . end) |
                (if ($ghtoken != "") and (.mcpServers["github"]? != null) then .mcpServers["github"].headers.Authorization = ("Bearer " + $ghtoken) else . end) |
                (if ($portainer != "") and (.mcpServers["portainer"]? != null) then .mcpServers["portainer"].args[3] = $portainer else . end)
                ' "$CLAUDE_JSON" > "$CLAUDE_JSON.tmp" && mv "$CLAUDE_JSON.tmp" "$CLAUDE_JSON"
            fi
          '';
    };
}
