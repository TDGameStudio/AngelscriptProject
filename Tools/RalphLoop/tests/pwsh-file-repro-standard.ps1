$PSNativeCommandArgumentPassing = 'Standard'
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$prompt = 'hello ' + [char]0x4F60 + [char]0x597D
$target = Join-Path (Resolve-Path (Join-Path $PSScriptRoot '..')).Path 'tests\.tmp\pwsh-file-output-standard.txt'
New-Item -ItemType Directory -Path (Split-Path -Parent $target) -Force | Out-Null
Write-Output "SCRIPT_PROMPT=$prompt"
Write-Output "ARG_MODE=$PSNativeCommandArgumentPassing"
codex exec $prompt --skip-git-repo-check *> $target
Write-Output "EXIT=$LASTEXITCODE"
