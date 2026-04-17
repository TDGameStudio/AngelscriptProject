$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$prompt = 'hello ' + [char]0x4F60 + [char]0x597D
Write-Output "SCRIPT_PROMPT=$prompt"
Write-Output "ARG_MODE=$PSNativeCommandArgumentPassing"
codex exec $prompt --skip-git-repo-check *> "$PSScriptRoot\tests\.tmp\pwsh-file-output.txt"
Write-Output "EXIT=$LASTEXITCODE"
