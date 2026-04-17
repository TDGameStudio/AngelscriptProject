[CmdletBinding()]
param(
    [string]$ProjectRoot = '',

    [string]$DateSuffix = '',

    # 默认不显式传递，由 ~/.codex/config.toml 决定
    [string]$Model = '',

    [string]$ReasoningEffort = '',

    [switch]$Preview,

    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$AdditionalRequirements
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

function Format-DisplayArgument {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Value
    )

    if ($Value -match '[\s"]') {
        return '"' + ($Value -replace '"', '\"') + '"'
    }

    return $Value
}

if ([string]::IsNullOrWhiteSpace($ProjectRoot)) {
    $ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
}
else {
    $ProjectRoot = (Resolve-Path $ProjectRoot).Path
}

if ([string]::IsNullOrWhiteSpace($DateSuffix)) {
    $DateSuffix = Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'
}

$ruleRelativePath   = 'Documents/Rules/ReviewRule_ZH.md'
$outputRelativePath = 'Documents/Reviews/Review_{0}.md' -f $DateSuffix
$logRelativePath    = 'Documents/Reviews/run_codex.log'
$lastMsgRelativePath = 'Documents/Reviews/run_codex_lastmsg.md'

$rulePath        = Join-Path $ProjectRoot $ruleRelativePath
$outputPath      = Join-Path $ProjectRoot $outputRelativePath
$logPath         = Join-Path $ProjectRoot $logRelativePath
$lastMsgPath     = Join-Path $ProjectRoot $lastMsgRelativePath
$outputDirectory = Split-Path -Parent $outputPath

if (-not (Test-Path -LiteralPath $rulePath -PathType Leaf)) {
    throw ("Required review rule document was not found: {0}" -f $rulePath)
}

# ── 从独立提示词文件读取，替换占位符 ─────────────────────────────────────────
$promptTemplatePath = Join-Path $PSScriptRoot '..\ReviewPrompt.md'
if (-not (Test-Path -LiteralPath $promptTemplatePath -PathType Leaf)) {
    throw ("Review prompt template was not found: {0}" -f $promptTemplatePath)
}

$prompt = (Get-Content -LiteralPath $promptTemplatePath -Raw -Encoding UTF8).TrimEnd()
$prompt = $prompt -replace '\{OUTPUT_PATH\}', ($outputRelativePath -replace '\\', '/')

if ($null -ne $AdditionalRequirements -and $AdditionalRequirements.Count -gt 0) {
    $extraText = ($AdditionalRequirements -join ' ').Trim()
    if (-not [string]::IsNullOrWhiteSpace($extraText)) {
        $prompt = $prompt + [Environment]::NewLine + [Environment]::NewLine + ('Additional requirement: {0}' -f $extraText)
    }
}

# ── 组装 codex exec 参数 ──────────────────────────────────────────────────────
#
#   codex exec [GLOBAL_FLAGS] [-]
#   Use "-" and pipe the prompt on stdin so Windows shells do not drop the instruction text
#   (otherwise codex prints "Reading additional input from stdin..." and waits forever).
#
#   --cd          : 设置 agent 工作目录（等价于 opencode --dir）
#   --full-auto   : workspace-write 沙箱 + on-request 审批，适合本地自动化
#   --model       : 覆盖配置文件中的模型
#   --color never : 禁用 ANSI 颜色码，避免日志和 Tee-Object 时乱码
#   --output-last-message : 把 agent 最终回复额外写入指定文件，便于后续解析
#
$argumentList = [System.Collections.Generic.List[string]]::new()
$argumentList.Add('exec') | Out-Null
$argumentList.Add('--cd') | Out-Null
$argumentList.Add($ProjectRoot) | Out-Null
$argumentList.Add('--full-auto') | Out-Null
if (-not [string]::IsNullOrWhiteSpace($ReasoningEffort) -and ($ReasoningEffort -ne 'none')) {
    $argumentList.Add('-c') | Out-Null
    $argumentList.Add(('model_reasoning_effort="{0}"' -f $ReasoningEffort)) | Out-Null
}
if (-not [string]::IsNullOrWhiteSpace($Model)) {
    $argumentList.Add('--model') | Out-Null
    $argumentList.Add($Model) | Out-Null
}
$argumentList.Add('--color') | Out-Null
$argumentList.Add('never') | Out-Null
$argumentList.Add('--output-last-message') | Out-Null
$argumentList.Add($lastMsgPath) | Out-Null
$argumentList.Add('-') | Out-Null
$argumentList = $argumentList.ToArray()

if ($Preview) {
    $displayCommand = 'codex ' + (($argumentList | ForEach-Object { Format-DisplayArgument -Value ([string]$_) }) -join ' ')
    Write-Output 'Status=Preview'
    Write-Output ('ProjectRoot={0}'           -f $ProjectRoot)
    Write-Output ('Model={0}'                 -f $(if ([string]::IsNullOrWhiteSpace($Model)) { '(codex config.toml default)' } else { $Model }))
    Write-Output ('ReasoningEffort={0}'       -f $(if ([string]::IsNullOrWhiteSpace($ReasoningEffort)) { '(codex config.toml default)' } else { $ReasoningEffort }))
    Write-Output ('RulePath={0}'              -f $rulePath)
    Write-Output ('OutputRelativePath={0}'    -f ($outputRelativePath  -replace '\\', '/'))
    Write-Output ('LogRelativePath={0}'       -f ($logRelativePath     -replace '\\', '/'))
    Write-Output ('LastMsgRelativePath={0}'   -f ($lastMsgRelativePath -replace '\\', '/'))
    Write-Output ('Command={0}'               -f $displayCommand)
    Write-Output ('Prompt={0}'                -f ($prompt -replace "\r?\n", ' \n '))
    exit 0
}

if (-not (Get-Command codex -ErrorAction SilentlyContinue)) {
    throw 'The codex command was not found in PATH. Install with: npm install -g @openai/codex'
}

New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null

$previousErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = 'Continue'

$logWriter = $null
try {
    $logWriter = [System.IO.StreamWriter]::new($logPath, $false, [System.Text.Encoding]::UTF8)
    $prompt | & codex @argumentList 2>&1 |
        ForEach-Object {
            $line = if ($_ -is [System.Management.Automation.ErrorRecord]) { $_.ToString() } else { [string]$_ }
            $logWriter.WriteLine($line)
            $line
        }
}
finally {
    if ($null -ne $logWriter) { $logWriter.Dispose() }
    $ErrorActionPreference = $previousErrorActionPreference
}

$exitCode = $LASTEXITCODE
exit $exitCode
