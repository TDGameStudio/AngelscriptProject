[CmdletBinding()]
param(
    [string]$ProjectRoot = '',

    [string]$DateSuffix = '',

    [string[]]$Repos,

    [string[]]$Dimensions,

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

function Format-CmdArgument {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Value
    )

    if ($Value -match '[\s"]') {
        return '"' + ($Value -replace '"', '""') + '"'
    }

    return $Value
}

# ── Resolve project root ────────────────────────────────────────────────────
if ([string]::IsNullOrWhiteSpace($ProjectRoot)) {
    $ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
}
else {
    $ProjectRoot = (Resolve-Path $ProjectRoot).Path
}

# ── Read CODEX_HOME from AgentConfig.ini [Codex] CodexHome if not already set
if (-not $env:CODEX_HOME) {
    $agentConfigPath = Join-Path $ProjectRoot 'AgentConfig.ini'
    if (Test-Path -LiteralPath $agentConfigPath -PathType Leaf) {
        $section = ''
        foreach ($line in (Get-Content -LiteralPath $agentConfigPath -Encoding UTF8)) {
            $trimmed = $line.Trim()
            if ($trimmed -match '^\[(.+)\]$') { $section = $Matches[1]; continue }
            if ($section -eq 'Codex' -and $trimmed -match '^CodexHome\s*=\s*(.+)$') {
                $val = $Matches[1].Trim()
                if ($val -ne '' -and $val -notmatch '^\s*;') {
                    $env:CODEX_HOME = $val
                    Write-Host ("  CODEX_HOME = {0}" -f $val) -ForegroundColor DarkCyan
                }
                break
            }
        }
    }
}

if ([string]::IsNullOrWhiteSpace($DateSuffix)) {
    $DateSuffix = Get-Date -Format 'yyyy-MM-dd'
}

# ── Paths ────────────────────────────────────────────────────────────────────
$ruleRelativePath    = 'Documents/Rules/ReferenceComparisonRule_ZH.md'
$outputDir           = Join-Path $ProjectRoot ('Documents/Comparisons/{0}' -f $DateSuffix)
$logRelativePath     = 'Documents/Comparisons/{0}/run_codex.log' -f $DateSuffix
$lastMsgRelativePath = 'Documents/Comparisons/{0}/run_codex_lastmsg.md' -f $DateSuffix

$rulePath    = Join-Path $ProjectRoot $ruleRelativePath
$logPath     = Join-Path $ProjectRoot $logRelativePath
$lastMsgPath = Join-Path $ProjectRoot $lastMsgRelativePath

if (-not (Test-Path -LiteralPath $rulePath -PathType Leaf)) {
    throw ("Required rule document was not found: {0}" -f $rulePath)
}

# ── Build prompt ─────────────────────────────────────────────────────────────
$repoDisplay = if ($null -ne $Repos -and $Repos.Count -gt 0) { $Repos -join ', ' } else { 'all (hazelight, unrealcsharp, unlua, puerts, sluaunreal)' }
$dimDisplay  = if ($null -ne $Dimensions -and $Dimensions.Count -gt 0) { $Dimensions -join ', ' } else { 'all (D1-D11)' }

$promptLines = [System.Collections.Generic.List[string]]::new()

$promptLines.Add('Strictly follow Documents/Rules/ReferenceComparisonRule_ZH.md and perform a comprehensive reference comparison analysis.') | Out-Null
$promptLines.Add('') | Out-Null
$promptLines.Add('## Scope') | Out-Null
$promptLines.Add(('Reference repos to analyze: {0}' -f $repoDisplay)) | Out-Null
$promptLines.Add(('Dimensions: {0}' -f $dimDisplay)) | Out-Null
$promptLines.Add(('Output directory: {0}' -f ('Documents/Comparisons/{0}' -f $DateSuffix))) | Out-Null
$promptLines.Add('') | Out-Null
$promptLines.Add('## Three-Phase Workflow') | Out-Null
$promptLines.Add('') | Out-Null
$promptLines.Add('### Phase 1: Per-Repo Analysis') | Out-Null
$promptLines.Add('For each reference repo, write a per-repo analysis document covering all requested dimensions.') | Out-Null
$promptLines.Add('Output filenames: 00_<RepoName>_Analysis.md, 01_<RepoName>_Analysis.md, etc.') | Out-Null
$promptLines.Add('Hazelight source path is in AgentConfig.ini (References.HazelightAngelscriptEngineRoot); other repos are under Reference/.') | Out-Null
$promptLines.Add('') | Out-Null
$promptLines.Add('### Phase 2: Cross-Repo Comparison') | Out-Null
$promptLines.Add('For each dimension, write a cross-comparison document comparing all repos + our Angelscript plugin.') | Out-Null
$promptLines.Add('Output filenames: 05_CrossComparison_<DimensionNameEn>.md, etc.') | Out-Null
$promptLines.Add('') | Out-Null
$promptLines.Add('### Phase 3: Gap Analysis') | Out-Null
$promptLines.Add('Synthesize all previous documents into a final Summary_GapAnalysis.md.') | Out-Null
$promptLines.Add('') | Out-Null
$promptLines.Add('## Work Mode') | Out-Null
$promptLines.Add('') | Out-Null
$promptLines.Add('Write incrementally - create each file and fill sections as you go.') | Out-Null
$promptLines.Add('If output files already exist from a previous run, READ them first, then EDIT IN PLACE to deepen and strengthen content.') | Out-Null
$promptLines.Add('Do NOT rewrite from scratch; preserve existing content and expand.') | Out-Null
$promptLines.Add('') | Out-Null
$promptLines.Add('## Critical Requirements') | Out-Null
$promptLines.Add('') | Out-Null
$promptLines.Add('1. Every dimension MUST include at least one ASCII architecture/call-chain diagram.') | Out-Null
$promptLines.Add('2. Every dimension MUST reference specific source files with paths and annotated code snippets.') | Out-Null
$promptLines.Add('3. Per-repo docs MUST end with a comparison table (差异速查 or 移植状态速查).') | Out-Null
$promptLines.Add('4. Do NOT generate any TodoList section. Only analysis and evidence.') | Out-Null
$promptLines.Add('5. All prose and code comments in Chinese; code and technical terms in English.') | Out-Null
$promptLines.Add('6. Comparison baseline is always Plugins/Angelscript/.') | Out-Null

if ($null -ne $AdditionalRequirements -and $AdditionalRequirements.Count -gt 0) {
    $extraText = ($AdditionalRequirements -join ' ').Trim()
    if (-not [string]::IsNullOrWhiteSpace($extraText)) {
        $promptLines.Add(('Additional requirement: {0}' -f $extraText)) | Out-Null
    }
}

$prompt = ($promptLines -join [Environment]::NewLine)

# ── Build codex arguments ────────────────────────────────────────────────────
$argumentList = [System.Collections.Generic.List[string]]::new()
$argumentList.Add('exec') | Out-Null
$argumentList.Add('--cd') | Out-Null
$argumentList.Add($ProjectRoot) | Out-Null
$argumentList.Add('--full-auto') | Out-Null
$argumentList.Add('--color') | Out-Null
$argumentList.Add('never') | Out-Null
$argumentList.Add('--output-last-message') | Out-Null
$argumentList.Add($lastMsgPath) | Out-Null
$argumentList.Add('-') | Out-Null
$argumentList = $argumentList.ToArray()

if ($Preview) {
    $displayCommand = 'codex ' + (($argumentList | ForEach-Object { Format-DisplayArgument -Value ([string]$_) }) -join ' ')
    Write-Output 'Status=Preview'
    Write-Output ('ProjectRoot={0}'         -f $ProjectRoot)
    Write-Output ('RulePath={0}'            -f $rulePath)
    Write-Output ('OutputDir={0}'           -f $outputDir)
    Write-Output ('Repos={0}'              -f $repoDisplay)
    Write-Output ('Dimensions={0}'         -f $dimDisplay)
    Write-Output ('LogRelativePath={0}'     -f ($logRelativePath     -replace '\\', '/'))
    Write-Output ('LastMsgRelativePath={0}' -f ($lastMsgRelativePath -replace '\\', '/'))
    Write-Output ('Command={0}'             -f $displayCommand)
    Write-Output ('Prompt={0}'              -f ($prompt -replace "\r?\n", ' \n '))
    exit 0
}

if (-not (Get-Command codex -ErrorAction SilentlyContinue)) {
    throw 'The codex command was not found in PATH. Install with: npm install -g @openai/codex'
}

New-Item -ItemType Directory -Path $outputDir -Force | Out-Null

$previousErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = 'Continue'

# Write prompt to a temp file so codex can read via stdin redirect
$promptTmpPath = Join-Path $outputDir ('codex_prompt_{0}.tmp' -f $PID)
[System.IO.File]::WriteAllText($promptTmpPath, $prompt, [System.Text.Encoding]::UTF8)

$stdoutTmpPath = Join-Path $outputDir ('codex_stdout_{0}.tmp' -f $PID)
$stderrTmpPath = Join-Path $outputDir ('codex_stderr_{0}.tmp' -f $PID)

try {
    Write-Host ''
    Write-Host '================================================================' -ForegroundColor Cyan
    Write-Host '  Codex ReferenceComparison — starting'                            -ForegroundColor Cyan
    Write-Host ('  Output dir : {0}' -f $outputDir)
    Write-Host ('  Log file   : {0}' -f $logPath)
    Write-Host ('  Repos      : {0}' -f $repoDisplay)
    Write-Host ('  Dimensions : {0}' -f $dimDisplay)
    Write-Host '================================================================' -ForegroundColor Cyan
    Write-Host ''

    $codexArgs = ($argumentList | ForEach-Object { Format-CmdArgument -Value ([string]$_) }) -join ' '
    $cmdLine = ('cmd.exe /d /c "codex {0} < "{1}""' -f $codexArgs, $promptTmpPath)

    $process = Start-Process `
        -FilePath 'cmd.exe' `
        -ArgumentList ('/d', '/c', ('codex {0} < "{1}"' -f $codexArgs, $promptTmpPath)) `
        -WorkingDirectory $ProjectRoot `
        -NoNewWindow `
        -PassThru `
        -RedirectStandardOutput $stdoutTmpPath `
        -RedirectStandardError  $stderrTmpPath

    $spinChars = @('|', '/', '-', '\')
    $spinIdx   = 0
    $sw        = [System.Diagnostics.Stopwatch]::StartNew()

    while (-not $process.HasExited) {
        $elapsed = $sw.Elapsed.ToString('hh\:mm\:ss')
        $spin    = $spinChars[$spinIdx % $spinChars.Length]
        Write-Host ("`r  [{0}] codex running... {1}  " -f $spin, $elapsed) -NoNewline
        $spinIdx++
        Start-Sleep -Milliseconds 500
    }

    $sw.Stop()
    $elapsed = $sw.Elapsed.ToString('hh\:mm\:ss')
    $exitCode = $process.ExitCode
    Write-Host ''

    # Merge stdout + stderr into the log file
    $logWriter = [System.IO.StreamWriter]::new($logPath, $false, [System.Text.Encoding]::UTF8)
    try {
        foreach ($tmpPath in @($stdoutTmpPath, $stderrTmpPath)) {
            if (Test-Path -LiteralPath $tmpPath -PathType Leaf) {
                $raw = [System.IO.File]::ReadAllBytes($tmpPath)
                if ($raw.Length -gt 0) {
                    $logWriter.Write([System.Text.Encoding]::UTF8.GetString($raw))
                }
            }
        }
    }
    finally { $logWriter.Dispose() }

    Write-Host ''
    if ($exitCode -eq 0) {
        Write-Host ('  Done (exit=0, elapsed={0})' -f $elapsed) -ForegroundColor Green
    }
    else {
        Write-Host ('  Finished with exit={0} (elapsed={1})' -f $exitCode, $elapsed) -ForegroundColor Yellow
    }
    Write-Host ('  Log : {0}' -f $logPath)

    if (Test-Path -LiteralPath $logPath -PathType Leaf) {
        $tailLines = Get-Content -LiteralPath $logPath -Tail 6 -Encoding UTF8 -ErrorAction SilentlyContinue
        if ($tailLines) {
            Write-Host ''
            Write-Host '  --- last log lines ---' -ForegroundColor DarkGray
            foreach ($tl in $tailLines) { Write-Host ('  {0}' -f $tl) -ForegroundColor DarkGray }
            Write-Host '  ----------------------' -ForegroundColor DarkGray
        }
    }
    Write-Host ''
}
finally {
    foreach ($tmpPath in @($promptTmpPath, $stdoutTmpPath, $stderrTmpPath)) {
        if (-not [string]::IsNullOrWhiteSpace($tmpPath) -and (Test-Path -LiteralPath $tmpPath -PathType Leaf)) {
            Remove-Item -LiteralPath $tmpPath -Force -ErrorAction SilentlyContinue
        }
    }
    $ErrorActionPreference = $previousErrorActionPreference
}

exit $exitCode
