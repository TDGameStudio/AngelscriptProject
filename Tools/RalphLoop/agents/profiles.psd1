@{
    DefaultAgent = 'codex'
    Agents = @{
        codex = @{
            Id               = 'codex'
            CommandTemplate  = 'codex exec --skip-git-repo-check --dangerously-bypass-approvals-and-sandbox --cd "{WORKSPACE}" -o "{LAST_MESSAGE_FILE}" -'
            ConsolePrefix    = '[codex] '
            HomeEnvVar       = 'CODEX_HOME'
            DefaultHomePath  = '.codex'
            PromptTransport  = 'stdin'
        }
        opencode = @{
            Id               = 'opencode'
            CommandTemplate  = 'pwsh -NoProfile -ExecutionPolicy Bypass -Command "$prompt = Get-Content -Raw -Path ''{PROMPT_FILE}''; opencode run $prompt"'
            ConsolePrefix    = '[opencode] '
            HomeEnvVar       = 'OPENCODE_CONFIG_DIR'
            DefaultHomePath  = '.local\share\opencode'
            PromptTransport  = 'inline-from-file'
        }
    }
}
