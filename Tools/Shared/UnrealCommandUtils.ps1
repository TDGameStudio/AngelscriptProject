Set-StrictMode -Version Latest

$script:UnrealCommandUtilsMaxTimeoutMs = 3600000
$script:UnrealBundledDotNetVersion = '8.0.412'
$script:HeldMutexNames = New-Object 'System.Collections.Generic.HashSet[string]'
$script:HeldMutexSyncRoot = New-Object object

function Normalize-PathValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $trimmedPath = $Path.Trim().Trim('"')
    if ([string]::IsNullOrWhiteSpace($trimmedPath)) {
        throw 'Path cannot be empty.'
    }

    $fullPath = [System.IO.Path]::GetFullPath($trimmedPath)
    $normalizedPath = $fullPath.Replace('/', '\')
    if ($normalizedPath.Length -gt 3) {
        $normalizedPath = $normalizedPath.TrimEnd('\')
    }

    return $normalizedPath
}

function Read-IniFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "AgentConfig.ini was not found: $Path"
    }

    $result = @{}
    $section = ''

    foreach ($line in Get-Content -LiteralPath $Path -Encoding UTF8) {
        $trimmedLine = $line.Trim()
        if ([string]::IsNullOrWhiteSpace($trimmedLine) -or $trimmedLine.StartsWith(';') -or $trimmedLine.StartsWith('#')) {
            continue
        }

        if ($trimmedLine.StartsWith('[') -and $trimmedLine.EndsWith(']')) {
            $section = $trimmedLine.Substring(1, $trimmedLine.Length - 2)
            if (-not $result.ContainsKey($section)) {
                $result[$section] = @{}
            }
            continue
        }

        $separatorIndex = $trimmedLine.IndexOf('=')
        if ($separatorIndex -lt 0) {
            continue
        }

        if (-not $result.ContainsKey($section)) {
            $result[$section] = @{}
        }

        $key = $trimmedLine.Substring(0, $separatorIndex).Trim()
        $value = $trimmedLine.Substring($separatorIndex + 1).Trim()
        $result[$section][$key] = $value
    }

    return $result
}

function Write-IniFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [hashtable]$Config
    )

    $directory = Split-Path -Parent $Path
    if (-not [string]::IsNullOrWhiteSpace($directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }

    $utf8Encoding = New-Object System.Text.UTF8Encoding($false)
    $builder = New-Object System.Text.StringBuilder
    $orderedSections = @($Config.Keys | Sort-Object)
    foreach ($section in $orderedSections) {
        [void]$builder.AppendLine(("[{0}]" -f $section))
        $sectionValues = $Config[$section]
        if ($null -ne $sectionValues) {
            $orderedKeys = @($sectionValues.Keys | Sort-Object)
            foreach ($key in $orderedKeys) {
                [void]$builder.AppendLine(("{0}={1}" -f $key, [string]$sectionValues[$key]))
            }
        }
        [void]$builder.AppendLine()
    }

    [System.IO.File]::WriteAllText($Path, $builder.ToString(), $utf8Encoding)
}

function Get-IniValue {
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Config,

        [Parameter(Mandatory = $true)]
        [string]$Section,

        [Parameter(Mandatory = $true)]
        [string]$Key,

        [string]$DefaultValue = '',

        [switch]$Required
    )

    if ($Config.ContainsKey($Section) -and $Config[$Section].ContainsKey($Key)) {
        $value = [string]$Config[$Section][$Key]
        if (-not [string]::IsNullOrWhiteSpace($value)) {
            return $value
        }
    }

    if ($Required) {
        throw "Missing required AgentConfig.ini value [$Section] $Key"
    }

    return $DefaultValue
}

function Resolve-TimeoutMs {
    param(
        [int]$RequestedTimeoutMs,
        [int]$DefaultTimeoutMs,
        [string]$ParameterName = 'TimeoutMs'
    )

    $resolvedTimeoutMs = if ($RequestedTimeoutMs -gt 0) { $RequestedTimeoutMs } else { $DefaultTimeoutMs }
    if ($resolvedTimeoutMs -le 0) {
        throw "$ParameterName must be greater than zero."
    }

    if ($resolvedTimeoutMs -gt $script:UnrealCommandUtilsMaxTimeoutMs) {
        throw "$ParameterName cannot exceed $script:UnrealCommandUtilsMaxTimeoutMs milliseconds."
    }

    return $resolvedTimeoutMs
}

function New-ExecutionDeadline {
    param(
        [Parameter(Mandatory = $true)]
        [int]$TimeoutMs
    )

    $resolvedTimeoutMs = Resolve-TimeoutMs -RequestedTimeoutMs $TimeoutMs -DefaultTimeoutMs $TimeoutMs -ParameterName 'TimeoutMs'
    return [DateTime]::UtcNow.AddMilliseconds($resolvedTimeoutMs)
}

function Get-RemainingTimeoutMs {
    param(
        [Parameter(Mandatory = $true)]
        [DateTime]$DeadlineUtc,

        [string]$PhaseName = 'command'
    )

    $remainingMs = [int][Math]::Floor(($DeadlineUtc - [DateTime]::UtcNow).TotalMilliseconds)
    if ($remainingMs -le 0) {
        throw ("{0} exceeded the allocated timeout budget." -f $PhaseName)
    }

    return $remainingMs
}

function ConvertTo-SafeLabel {
    param(
        [string]$Value,
        [string]$Fallback = 'Run'
    )

    $candidate = [string]$Value
    if ([string]::IsNullOrWhiteSpace($candidate)) {
        $candidate = $Fallback
    }

    $candidate = $candidate -replace '[^A-Za-z0-9._-]', '-'
    $candidate = $candidate.Trim('-')
    if ([string]::IsNullOrWhiteSpace($candidate)) {
        return $Fallback
    }

    return $candidate
}

function Write-Utf8JsonFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [object]$Value,

        [int]$Depth = 8
    )

    $directory = Split-Path -Parent $Path
    if (-not [string]::IsNullOrWhiteSpace($directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }

    $utf8Encoding = New-Object System.Text.UTF8Encoding($false)
    $json = $Value | ConvertTo-Json -Depth $Depth
    [System.IO.File]::WriteAllText($Path, $json, $utf8Encoding)
}

function Get-UhtTimestampConflictSummary {
    param(
        [string[]]$LogPaths = @(),

        [string]$EngineRoot = ''
    )

    $logContents = New-Object System.Collections.Generic.List[string]
    foreach ($logPath in $LogPaths) {
        if ([string]::IsNullOrWhiteSpace($logPath)) {
            continue
        }

        if (-not (Test-Path -LiteralPath $logPath -PathType Leaf)) {
            continue
        }

        $logContents.Add((Get-Content -LiteralPath $logPath -Raw -Encoding UTF8)) | Out-Null
    }

    $allPaths = New-Object System.Collections.Generic.List[string]
    $pattern = [regex]'(?im)(?<Path>[A-Z]:\\[^''"\r\n]*\\UHT\\Timestamp)(?:''|")?[^\r\n]*being used by another process'
    foreach ($logText in $logContents) {
        foreach ($match in $pattern.Matches([string]$logText)) {
            $matchedPath = [string]$match.Groups['Path'].Value
            if ([string]::IsNullOrWhiteSpace($matchedPath)) {
                continue
            }

            $normalizedMatchedPath = Normalize-PathValue -Path $matchedPath
            if (-not $allPaths.Contains($normalizedMatchedPath)) {
                $allPaths.Add($normalizedMatchedPath) | Out-Null
            }
        }
    }

    $sharedEnginePaths = New-Object System.Collections.Generic.List[string]
    $normalizedEngineRoot = if ([string]::IsNullOrWhiteSpace($EngineRoot)) {
        ''
    }
    else {
        Normalize-PathValue -Path $EngineRoot
    }

    if (-not [string]::IsNullOrWhiteSpace($normalizedEngineRoot)) {
        foreach ($matchedPath in $allPaths) {
            if ($matchedPath.StartsWith($normalizedEngineRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
                $sharedEnginePaths.Add($matchedPath) | Out-Null
            }
        }
    }

    return [PSCustomObject]@{
        Detected             = ($allPaths.Count -gt 0)
        SharedEngineDetected = ($sharedEnginePaths.Count -gt 0)
        Paths                = @($allPaths)
        SharedEnginePaths    = @($sharedEnginePaths)
    }
}

function New-CommandOutputLayout {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProjectRoot,

        [Parameter(Mandatory = $true)]
        [string]$Category,

        [string]$Label = '',

        [string]$RequestedOutputRoot = '',

        [string]$LogFileName = 'Command.log',

        [string]$ReportFolderName = 'Report'
    )

    $resolvedProjectRoot = Normalize-PathValue -Path $ProjectRoot
    $safeCategory = ConvertTo-SafeLabel -Value $Category -Fallback 'Command'
    $safeLabel = ConvertTo-SafeLabel -Value $Label -Fallback $safeCategory
    $runId = "{0}_{1}" -f (Get-Date -Format 'yyyyMMdd_HHmmss_fff'), ([Guid]::NewGuid().ToString('N').Substring(0, 8))
    $outputParent = if ([string]::IsNullOrWhiteSpace($RequestedOutputRoot)) {
        Join-Path $resolvedProjectRoot (Join-Path "Saved\$safeCategory\$safeLabel" '')
    }
    else {
        Join-Path (Normalize-PathValue -Path $RequestedOutputRoot) (Join-Path $safeCategory $safeLabel)
    }

    $outputRoot = Join-Path $outputParent $runId
    $logPath = Join-Path $outputRoot $LogFileName
    $reportPath = Join-Path $outputRoot $ReportFolderName

    New-Item -ItemType Directory -Path $outputRoot -Force | Out-Null
    New-Item -ItemType Directory -Path (Split-Path -Parent $logPath) -Force | Out-Null
    New-Item -ItemType Directory -Path $reportPath -Force | Out-Null

    return [PSCustomObject]@{
        Category   = $safeCategory
        Label      = $safeLabel
        RunId      = $runId
        OutputRoot = $outputRoot
        LogPath    = $logPath
        ReportPath = $reportPath
    }
}

function Get-ExecutionScopeKeyPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProjectRoot,

        [int]$ExecutionSlot = 0
    )

    $normalizedProjectRoot = Normalize-PathValue -Path $ProjectRoot
    if ($ExecutionSlot -le 0) {
        return $normalizedProjectRoot
    }

    return ('{0}#slot-{1}' -f $normalizedProjectRoot, $ExecutionSlot)
}

function Get-NamedMutexName {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Scope,

        [Parameter(Mandatory = $true)]
        [string]$KeyPath
    )

    $normalizedScope = ConvertTo-SafeLabel -Value $Scope -Fallback 'scope'
    $normalizedKeyPath = Normalize-PathValue -Path $KeyPath
    $sha256 = [System.Security.Cryptography.SHA256]::Create()
    try {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($normalizedKeyPath.ToUpperInvariant())
        $hashBytes = $sha256.ComputeHash($bytes)
        $hashText = ([System.BitConverter]::ToString($hashBytes)).Replace('-', '').Substring(0, 24)
        return "Global\AngelscriptProject_{0}_{1}" -f $normalizedScope, $hashText
    }
    finally {
        $sha256.Dispose()
    }
}

function Acquire-NamedMutex {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [int]$TimeoutMs = 0,

        [int]$PollIntervalMs = 5000,

        [scriptblock]$OnWait
    )

    [System.Threading.Monitor]::Enter($script:HeldMutexSyncRoot)
    try {
        if ($script:HeldMutexNames.Contains($Name)) {
            return $null
        }
    }
    finally {
        [System.Threading.Monitor]::Exit($script:HeldMutexSyncRoot)
    }

    $mutex = New-Object System.Threading.Mutex($false, $Name)
    try {
        if ($TimeoutMs -le 0) {
            try {
                $acquired = $mutex.WaitOne(0)
            }
            catch [System.Threading.AbandonedMutexException] {
                $acquired = $true
            }

            if ($acquired) {
                [System.Threading.Monitor]::Enter($script:HeldMutexSyncRoot)
                try {
                    if ($script:HeldMutexNames.Contains($Name)) {
                        $mutex.Dispose()
                        return $null
                    }

                    [void]$script:HeldMutexNames.Add($Name)
                }
                finally {
                    [System.Threading.Monitor]::Exit($script:HeldMutexSyncRoot)
                }

                $mutex | Add-Member -NotePropertyName MutexName -NotePropertyValue $Name -Force
                return $mutex
            }

            $mutex.Dispose()
            return $null
        }

        $deadlineUtc = [DateTime]::UtcNow.AddMilliseconds($TimeoutMs)
        while ($true) {
            $remainingMs = [int][Math]::Max(0, ($deadlineUtc - [DateTime]::UtcNow).TotalMilliseconds)
            if ($remainingMs -le 0) {
                $mutex.Dispose()
                return $null
            }

            $waitChunkMs = [int][Math]::Min([Math]::Max($PollIntervalMs, 1), $remainingMs)
            try {
                $acquired = $mutex.WaitOne($waitChunkMs)
            }
            catch [System.Threading.AbandonedMutexException] {
                $acquired = $true
            }

            if ($acquired) {
                [System.Threading.Monitor]::Enter($script:HeldMutexSyncRoot)
                try {
                    if ($script:HeldMutexNames.Contains($Name)) {
                        $mutex.Dispose()
                        return $null
                    }

                    [void]$script:HeldMutexNames.Add($Name)
                }
                finally {
                    [System.Threading.Monitor]::Exit($script:HeldMutexSyncRoot)
                }

                $mutex | Add-Member -NotePropertyName MutexName -NotePropertyValue $Name -Force
                return $mutex
            }

            if ($null -ne $OnWait) {
                $currentRemainingMs = [int][Math]::Max(0, ($deadlineUtc - [DateTime]::UtcNow).TotalMilliseconds)
                $elapsedMs = [int]($TimeoutMs - $currentRemainingMs)
                & $OnWait $elapsedMs $currentRemainingMs
            }
        }
    }
    catch {
        try {
            $mutex.Dispose()
        }
        catch {
        }
        throw
    }
}

function Release-NamedMutex {
    param(
        [Parameter(Mandatory = $true)]
        [System.Threading.Mutex]$Mutex
    )

    $mutexNameProperty = $Mutex.PSObject.Properties['MutexName']
    if ($null -ne $mutexNameProperty -and -not [string]::IsNullOrWhiteSpace([string]$mutexNameProperty.Value)) {
        [System.Threading.Monitor]::Enter($script:HeldMutexSyncRoot)
        try {
            [void]$script:HeldMutexNames.Remove([string]$mutexNameProperty.Value)
        }
        finally {
            [System.Threading.Monitor]::Exit($script:HeldMutexSyncRoot)
        }
    }

    try {
        $Mutex.ReleaseMutex()
    }
    catch {
    }
    finally {
        $Mutex.Dispose()
    }
}

function Get-ConsolePowerShellPath {
    $candidateNames = @('powershell.exe', 'pwsh.exe')
    foreach ($candidateName in $candidateNames) {
        $command = Get-Command $candidateName -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($null -ne $command -and -not [string]::IsNullOrWhiteSpace($command.Source)) {
            return $command.Source
        }
    }

    throw 'Could not resolve a console PowerShell executable.'
}

function ConvertTo-QuotedProcessArgument {
    param(
        [AllowNull()]
        [string]$Argument
    )

    if ($null -eq $Argument -or $Argument.Length -eq 0) {
        return '""'
    }

    $requiresQuotes = $Argument -match '[\s"]'
    if (-not $requiresQuotes) {
        return $Argument
    }

    $builder = New-Object System.Text.StringBuilder
    [void]$builder.Append('"')
    $backslashCount = 0
    foreach ($character in $Argument.ToCharArray()) {
        if ($character -eq '\') {
            $backslashCount++
            continue
        }

        if ($character -eq '"') {
            [void]$builder.Append('\', ($backslashCount * 2) + 1)
            [void]$builder.Append('"')
            $backslashCount = 0
            continue
        }

        if ($backslashCount -gt 0) {
            [void]$builder.Append('\', $backslashCount)
            $backslashCount = 0
        }

        [void]$builder.Append($character)
    }

    if ($backslashCount -gt 0) {
        [void]$builder.Append('\', $backslashCount * 2)
    }

    [void]$builder.Append('"')
    return $builder.ToString()
}

function ConvertTo-ProcessArgumentString {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$ArgumentList
    )

    return (($ArgumentList | ForEach-Object { ConvertTo-QuotedProcessArgument -Argument $_ }) -join ' ')
}

function Get-DescendantProcessIds {
    param(
        [Parameter(Mandatory = $true)]
        [int]$RootProcessId
    )

    $descendantIds = New-Object System.Collections.Generic.List[int]
    $queue = New-Object System.Collections.Generic.Queue[int]
    $queue.Enqueue($RootProcessId)

    while ($queue.Count -gt 0) {
        $currentProcessId = $queue.Dequeue()
        foreach ($childProcess in @(Get-CimInstance Win32_Process -Filter "ParentProcessId = $currentProcessId" -ErrorAction SilentlyContinue)) {
            $childProcessId = [int]$childProcess.ProcessId
            $descendantIds.Add($childProcessId) | Out-Null
            $queue.Enqueue($childProcessId)
        }
    }

    return $descendantIds
}

function Stop-ProcessTree {
    param(
        [Parameter(Mandatory = $true)]
        [int]$ProcessId
    )

    try {
        & taskkill /PID $ProcessId /T /F 2>$null | Out-Null
    }
    catch {
    }

    foreach ($descendantId in @(Get-DescendantProcessIds -RootProcessId $ProcessId)) {
        try {
            Stop-Process -Id $descendantId -Force -ErrorAction SilentlyContinue
        }
        catch {
        }
    }

    try {
        Stop-Process -Id $ProcessId -Force -ErrorAction SilentlyContinue
    }
    catch {
    }
}

function Invoke-StreamingProcess {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath,

        [Parameter(Mandatory = $true)]
        [string[]]$ArgumentList,

        [Parameter(Mandatory = $true)]
        [string]$WorkingDirectory,

        [Parameter(Mandatory = $true)]
        [int]$TimeoutMs,

        [Parameter(Mandatory = $true)]
        [string]$LogPath,

        [string]$Label = 'process',

        [scriptblock]$OnLine,

        [hashtable]$Environment = @{}
    )

    $resolvedTimeoutMs = Resolve-TimeoutMs -RequestedTimeoutMs $TimeoutMs -DefaultTimeoutMs $TimeoutMs -ParameterName 'TimeoutMs'
    $resolvedWorkingDirectory = Normalize-PathValue -Path $WorkingDirectory
    $resolvedLogPath = Normalize-PathValue -Path $LogPath

    $logDirectory = Split-Path -Parent $resolvedLogPath
    if (-not [string]::IsNullOrWhiteSpace($logDirectory)) {
        New-Item -ItemType Directory -Path $logDirectory -Force | Out-Null
    }

    $state = [ordered]@{
        TimedOut      = $false
        CallbackError = $null
        StartedAtUtc  = [DateTime]::UtcNow
    }

    $stdoutPath = Join-Path $logDirectory ("{0}.stdout.tmp" -f [Guid]::NewGuid().ToString('N'))
    $stderrPath = Join-Path $logDirectory ("{0}.stderr.tmp" -f [Guid]::NewGuid().ToString('N'))
    New-Item -ItemType File -Path $stdoutPath -Force | Out-Null
    New-Item -ItemType File -Path $stderrPath -Force | Out-Null

    $logWriter = New-Object System.IO.StreamWriter($resolvedLogPath, $false, (New-Object System.Text.UTF8Encoding($false)))
    $logWriter.AutoFlush = $true

    $emitLine = {
        param(
            [string]$StreamName,
            [string]$LineText
        )

        if ([string]::IsNullOrWhiteSpace($LineText)) {
            return
        }

        $logLine = if ($StreamName -eq 'stderr') { "[stderr] $LineText" } else { $LineText }
        if ($StreamName -eq 'stderr') {
            [System.Console]::Error.WriteLine($LineText)
        }
        else {
            [System.Console]::Out.WriteLine($LineText)
        }

        $logWriter.WriteLine($logLine)

        if ($null -ne $OnLine) {
            try {
                & $OnLine $StreamName $LineText
            }
            catch {
                if ($null -eq $state.CallbackError) {
                    $state.CallbackError = $_.Exception
                }
            }
        }
    }

    $syncOutputFile = {
        param(
            [string]$Path,
            [int]$KnownLineCount,
            [string]$StreamName
        )

        if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
            return $KnownLineCount
        }

        try {
            $lines = @(Get-Content -LiteralPath $Path -Encoding UTF8)
        }
        catch {
            return $KnownLineCount
        }

        if ($lines.Count -le $KnownLineCount) {
            return $KnownLineCount
        }

        for ($lineIndex = $KnownLineCount; $lineIndex -lt $lines.Count; $lineIndex++) {
            & $emitLine $StreamName ([string]$lines[$lineIndex])
        }

        return $lines.Count
    }

    $previousEnvironment = @{}
    foreach ($environmentEntry in $Environment.GetEnumerator()) {
        $environmentKey = [string]$environmentEntry.Key
        $existingEnvironmentVariable = [System.Environment]::GetEnvironmentVariable($environmentKey, 'Process')
        $previousEnvironment[$environmentKey] = if ($null -eq $existingEnvironmentVariable) { [string]::Empty } else { $existingEnvironmentVariable }
        [System.Environment]::SetEnvironmentVariable($environmentKey, [string]$environmentEntry.Value, 'Process')
    }

    $stdoutLineCount = 0
    $stderrLineCount = 0
    $process = $null
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    $argumentString = ConvertTo-ProcessArgumentString -ArgumentList $ArgumentList
    try {
        $process = Start-Process -FilePath $FilePath -ArgumentList $argumentString -WorkingDirectory $resolvedWorkingDirectory -PassThru -NoNewWindow -RedirectStandardOutput $stdoutPath -RedirectStandardError $stderrPath
        $null = $process.Handle

        while ($true) {
            $stdoutLineCount = & $syncOutputFile $stdoutPath $stdoutLineCount 'stdout'
            $stderrLineCount = & $syncOutputFile $stderrPath $stderrLineCount 'stderr'

            if ($process.HasExited) {
                break
            }

            if ($stopwatch.ElapsedMilliseconds -gt $resolvedTimeoutMs) {
                $state.TimedOut = $true
                & $emitLine 'stderr' ("[{0}] timed out after {1} ms. Terminating process tree rooted at PID {2}." -f $Label, $resolvedTimeoutMs, $process.Id)
                Stop-ProcessTree -ProcessId $process.Id
                break
            }

            Start-Sleep -Milliseconds 100
            $process.Refresh()
        }

        if ($null -ne $process) {
            $process.WaitForExit()
            $process.Refresh()
        }

        for ($drainAttempt = 0; $drainAttempt -lt 20; $drainAttempt++) {
            $previousStdOutLineCount = $stdoutLineCount
            $previousStdErrLineCount = $stderrLineCount
            $stdoutLineCount = & $syncOutputFile $stdoutPath $stdoutLineCount 'stdout'
            $stderrLineCount = & $syncOutputFile $stderrPath $stderrLineCount 'stderr'
            if ($previousStdOutLineCount -eq $stdoutLineCount -and $previousStdErrLineCount -eq $stderrLineCount) {
                break
            }

            Start-Sleep -Milliseconds 50
        }
    }
    finally {
        $stopwatch.Stop()
        foreach ($environmentKey in $previousEnvironment.Keys) {
            $previousValue = [string]$previousEnvironment[$environmentKey]
            if ($previousValue.Length -eq 0) {
                [System.Environment]::SetEnvironmentVariable($environmentKey, $null, 'Process')
            }
            else {
                [System.Environment]::SetEnvironmentVariable($environmentKey, $previousValue, 'Process')
            }
        }

        $logWriter.Dispose()
        Remove-Item -LiteralPath $stdoutPath -Force -ErrorAction SilentlyContinue
        Remove-Item -LiteralPath $stderrPath -Force -ErrorAction SilentlyContinue
    }

    if ($null -ne $state.CallbackError) {
        throw $state.CallbackError
    }

    $resolvedExitCode = if ($state.TimedOut) {
        124
    }
    elseif ($null -ne $process -and $null -ne $process.ExitCode) {
        [int]$process.ExitCode
    }
    else {
        0
    }

    return [PSCustomObject]@{
        FilePath         = $FilePath
        ArgumentList     = @($ArgumentList)
        WorkingDirectory = $resolvedWorkingDirectory
        LogPath          = $resolvedLogPath
        ExitCode         = $resolvedExitCode
        TimedOut         = [bool]$state.TimedOut
        ProcessId        = if ($null -ne $process) { $process.Id } else { 0 }
        DurationMs       = [int][Math]::Round($stopwatch.Elapsed.TotalMilliseconds)
        StartedAtUtc     = $state.StartedAtUtc
    }
}

function Get-PreferredDotNetArchitecture {
    $processorArchitecture = [string]$env:PROCESSOR_ARCHITECTURE
    if ($processorArchitecture -eq 'ARM64') {
        return 'win-arm64'
    }

    if ($processorArchitecture -eq 'AMD64' -and -not [string]::IsNullOrWhiteSpace(${env:ProgramFiles(Arm)})) {
        return 'win-arm64'
    }

    return 'win-x64'
}

function Resolve-DotNetExecutablePath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$EngineRoot
    )

    if ($env:UE_USE_SYSTEM_DOTNET -eq '1') {
        $systemDotNet = Get-Command dotnet.exe -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($null -eq $systemDotNet) {
            throw 'UE_USE_SYSTEM_DOTNET=1 is set, but dotnet.exe could not be resolved from PATH.'
        }

        return [PSCustomObject]@{
            DotNetExecutablePath = $systemDotNet.Source
            Environment          = @{}
            Source               = 'System'
        }
    }

    $architecture = Get-PreferredDotNetArchitecture
    $bundledDotNetDirectory = Join-Path (Normalize-PathValue -Path $EngineRoot) ("Engine\Binaries\ThirdParty\DotNet\{0}\{1}" -f $script:UnrealBundledDotNetVersion, $architecture)
    $bundledDotNetExecutable = Join-Path $bundledDotNetDirectory 'dotnet.exe'
    if (-not (Test-Path -LiteralPath $bundledDotNetExecutable -PathType Leaf)) {
        $systemDotNet = Get-Command dotnet.exe -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($null -eq $systemDotNet) {
            throw "Bundled dotnet.exe was not found at '$bundledDotNetExecutable', and dotnet.exe was not found on PATH."
        }

        return [PSCustomObject]@{
            DotNetExecutablePath = $systemDotNet.Source
            Environment          = @{}
            Source               = 'SystemFallback'
        }
    }

    return [PSCustomObject]@{
        DotNetExecutablePath = $bundledDotNetExecutable
        Environment          = @{
            UE_DOTNET_VERSION        = $script:UnrealBundledDotNetVersion
            UE_DOTNET_ARCH           = $architecture
            UE_DOTNET_DIR            = $bundledDotNetDirectory
            DOTNET_ROOT              = $bundledDotNetDirectory
            DOTNET_MULTILEVEL_LOOKUP = '0'
            DOTNET_ROLL_FORWARD      = 'LatestMajor'
            PATH                     = "{0};{1}" -f $bundledDotNetDirectory, $env:PATH
        }
        Source               = 'Bundled'
    }
}

function Resolve-UbtPaths {
    param(
        [Parameter(Mandatory = $true)]
        [string]$EngineRoot
    )

    $resolvedEngineRoot = Normalize-PathValue -Path $EngineRoot
    $dotNet = Resolve-DotNetExecutablePath -EngineRoot $resolvedEngineRoot
    $ubtDllPath = Join-Path $resolvedEngineRoot 'Engine\Binaries\DotNET\UnrealBuildTool\UnrealBuildTool.dll'
    if (-not (Test-Path -LiteralPath $ubtDllPath -PathType Leaf)) {
        throw "UnrealBuildTool.dll was not found: $ubtDllPath"
    }

    return [PSCustomObject]@{
        EngineRoot           = $resolvedEngineRoot
        DotNetExecutablePath = $dotNet.DotNetExecutablePath
        DotNetSource         = $dotNet.Source
        Environment          = $dotNet.Environment
        UbtDllPath           = $ubtDllPath
        WorkingDirectory     = Join-Path $resolvedEngineRoot 'Engine\Source'
    }
}

function Resolve-AgentConfiguration {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProjectRoot,

        [string]$ConfigPath = ''
    )

    $resolvedProjectRoot = Normalize-PathValue -Path $ProjectRoot
    $resolvedConfigPath = if ([string]::IsNullOrWhiteSpace($ConfigPath)) {
        Join-Path $resolvedProjectRoot 'AgentConfig.ini'
    }
    else {
        Normalize-PathValue -Path $ConfigPath
    }

    if (-not (Test-Path -LiteralPath $resolvedConfigPath -PathType Leaf)) {
        throw "AgentConfig.ini was not found: $resolvedConfigPath. Run Tools\Bootstrap\BootstrapWorktree.bat to initialize this worktree."
    }

    $config = Read-IniFile -Path $resolvedConfigPath
    $engineRoot = Normalize-PathValue -Path (Get-IniValue -Config $config -Section 'Paths' -Key 'EngineRoot' -Required)
    $projectFiles = @(Get-ChildItem -LiteralPath $resolvedProjectRoot -Filter *.uproject -File)
    if ($projectFiles.Count -eq 0) {
        throw "Could not resolve a .uproject file from '$resolvedProjectRoot'."
    }

    $resolvedProjectFileCandidates = @($projectFiles | ForEach-Object { Normalize-PathValue -Path $_.FullName })

    $projectFile = Get-IniValue -Config $config -Section 'Paths' -Key 'ProjectFile'
    if ([string]::IsNullOrWhiteSpace($projectFile)) {
        $projectFile = $resolvedProjectFileCandidates[0]
    }

    $resolvedProjectFile = Normalize-PathValue -Path $projectFile
    if ($resolvedProjectFileCandidates -notcontains $resolvedProjectFile) {
        throw "AgentConfig.ini [Paths] ProjectFile does not belong to project root '$resolvedProjectRoot'. Run Tools\Bootstrap\BootstrapWorktree.bat for this worktree."
    }

    return [PSCustomObject]@{
        ProjectRoot           = $resolvedProjectRoot
        ConfigPath            = $resolvedConfigPath
        Config                = $config
        EngineRoot            = $engineRoot
        ProjectFile           = $resolvedProjectFile
        EditorTarget          = Get-IniValue -Config $config -Section 'Build' -Key 'EditorTarget' -DefaultValue 'AngelscriptProjectEditor'
        Platform              = Get-IniValue -Config $config -Section 'Build' -Key 'Platform' -DefaultValue 'Win64'
        Configuration         = Get-IniValue -Config $config -Section 'Build' -Key 'Configuration' -DefaultValue 'Development'
        Architecture          = Get-IniValue -Config $config -Section 'Build' -Key 'Architecture' -DefaultValue 'x64'
        BuildDefaultTimeoutMs = [int](Get-IniValue -Config $config -Section 'Build' -Key 'DefaultTimeoutMs' -DefaultValue '180000')
        TestDefaultTimeoutMs  = [int](Get-IniValue -Config $config -Section 'Test' -Key 'DefaultTimeoutMs' -DefaultValue '600000')
    }
}

function Ensure-TargetInfoJson {
    param(
        [Parameter(Mandatory = $true)]
        [string]$EngineRoot,

        [Parameter(Mandatory = $true)]
        [string]$ProjectFile,

        [Parameter(Mandatory = $true)]
        [string]$ProjectRoot,

        [int]$TimeoutMs = 120000
    )

    $resolvedProjectRoot = Normalize-PathValue -Path $ProjectRoot
    $targetInfoPath = Join-Path $resolvedProjectRoot 'Intermediate\TargetInfo.json'

    if (Test-Path -LiteralPath $targetInfoPath -PathType Leaf) {
        $targetInfoMatchesProjectScope = $false
        try {
            $targetInfo = Get-Content -LiteralPath $targetInfoPath -Raw -Encoding UTF8 | ConvertFrom-Json
            $targetInfoDirectory = Split-Path -Parent $targetInfoPath
            $targetInfoTargets = @($targetInfo.Targets)
            $targetInfoMatchesProjectScope = $targetInfoTargets.Count -gt 0

            foreach ($target in $targetInfoTargets) {
                $targetPath = [string]$target.Path
                if ([string]::IsNullOrWhiteSpace($targetPath)) {
                    continue
                }

                $resolvedTargetPath = [System.IO.Path]::GetFullPath((Join-Path $targetInfoDirectory $targetPath))
                if (-not $resolvedTargetPath.StartsWith($resolvedProjectRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
                    $targetInfoMatchesProjectScope = $false
                    break
                }
            }
        }
        catch {
            $targetInfoMatchesProjectScope = $false
        }

        if ($targetInfoMatchesProjectScope) {
            return [PSCustomObject]@{
                Status         = 'Skipped'
                TargetInfoPath = $targetInfoPath
                DurationMs     = 0
                Message        = 'TargetInfo.json already exists and matches project scope.'
            }
        }

        Remove-Item -LiteralPath $targetInfoPath -Force
    }

    $intermediateDir = Join-Path $resolvedProjectRoot 'Intermediate'
    if (-not (Test-Path -LiteralPath $intermediateDir -PathType Container)) {
        New-Item -ItemType Directory -Path $intermediateDir -Force | Out-Null
    }

    $ubt = Resolve-UbtPaths -EngineRoot $EngineRoot
    $resolvedProjectFile = Normalize-PathValue -Path $ProjectFile

    $ubtArguments = @(
        $ubt.UbtDllPath
        '-Mode=QueryTargets'
        "-Project=$resolvedProjectFile"
        "-Output=$targetInfoPath"
        '-IncludeAllTargets'
        '-DontIncludeParentAssembly'
    )

    Write-Host '[prewarm] TargetInfo.json not found. Running UBT QueryTargets to generate it...' -ForegroundColor Cyan
    Write-Host "[prewarm] dotnet $($ubt.UbtDllPath) -Mode=QueryTargets" -ForegroundColor DarkGray

    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    $previousEnvironment = @{}
    foreach ($entry in $ubt.Environment.GetEnumerator()) {
        $key = [string]$entry.Key
        $previousEnvironment[$key] = [System.Environment]::GetEnvironmentVariable($key, 'Process')
        [System.Environment]::SetEnvironmentVariable($key, [string]$entry.Value, 'Process')
    }

    try {
        $process = Start-Process -FilePath $ubt.DotNetExecutablePath -ArgumentList (ConvertTo-ProcessArgumentString -ArgumentList $ubtArguments) -WorkingDirectory $ubt.WorkingDirectory -PassThru -NoNewWindow

        $deadline = [DateTime]::UtcNow.AddMilliseconds($TimeoutMs)
        while (-not $process.HasExited) {
            if ([DateTime]::UtcNow -gt $deadline) {
                Stop-ProcessTree -ProcessId $process.Id
                $stopwatch.Stop()
                return [PSCustomObject]@{
                    Status         = 'TimedOut'
                    TargetInfoPath = $targetInfoPath
                    DurationMs     = [int][Math]::Round($stopwatch.Elapsed.TotalMilliseconds)
                    Message        = "UBT QueryTargets timed out after ${TimeoutMs}ms."
                }
            }
            Start-Sleep -Milliseconds 500
            $process.Refresh()
        }

        $process.WaitForExit()
        $stopwatch.Stop()
        $exitCode = if ($null -ne $process -and $null -ne $process.ExitCode) { [int]$process.ExitCode } else { -1 }
        $elapsedMs = [int][Math]::Round($stopwatch.Elapsed.TotalMilliseconds)

        if (Test-Path -LiteralPath $targetInfoPath -PathType Leaf) {
            $fileSize = (Get-Item -LiteralPath $targetInfoPath).Length
            if ($fileSize -gt 0) {
                Write-Host "[prewarm] TargetInfo.json generated ($fileSize bytes, ${elapsedMs}ms)." -ForegroundColor Green
                return [PSCustomObject]@{
                    Status         = 'Generated'
                    TargetInfoPath = $targetInfoPath
                    DurationMs     = $elapsedMs
                    FileSize       = $fileSize
                    ExitCode       = $exitCode
                    Message        = 'TargetInfo.json generated successfully.'
                }
            }
        }

        return [PSCustomObject]@{
            Status         = 'Failed'
            TargetInfoPath = $targetInfoPath
            DurationMs     = $elapsedMs
            ExitCode       = $exitCode
            Message        = "UBT QueryTargets exited with code $exitCode and TargetInfo.json was not created."
        }
    }
    finally {
        foreach ($key in $previousEnvironment.Keys) {
            $prev = $previousEnvironment[$key]
            if ($null -eq $prev) {
                [System.Environment]::SetEnvironmentVariable($key, $null, 'Process')
            }
            else {
                [System.Environment]::SetEnvironmentVariable($key, $prev, 'Process')
            }
        }
    }
}

function Get-BuildBatLockPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$EngineRoot
    )

    $buildBatPath = Join-Path (Normalize-PathValue -Path $EngineRoot) 'Engine\Build\BatchFiles\Build.bat'
    $lockFile = $buildBatPath.Replace('\', '-')
    $lockFile = $lockFile.Replace(':', '')
    return Join-Path $env:TEMP ($lockFile + '.lock')
}

function Wait-BuildBatLockRelease {
    param(
        [Parameter(Mandatory = $true)]
        [string]$EngineRoot,

        [int]$TimeoutMs = 120000,

        [int]$PollIntervalMs = 1000
    )

    $lockPath = Get-BuildBatLockPath -EngineRoot $EngineRoot
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    $announcedWait = $false

    while ($true) {
        $handle = $null
        try {
            $directory = Split-Path -Parent $lockPath
            if (-not [string]::IsNullOrWhiteSpace($directory) -and -not (Test-Path -LiteralPath $directory -PathType Container)) {
                New-Item -ItemType Directory -Path $directory -Force | Out-Null
            }

            $handle = [System.IO.File]::Open($lockPath, [System.IO.FileMode]::OpenOrCreate, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::None)
            $stopwatch.Stop()
            return [PSCustomObject]@{
                Status     = if ($announcedWait) { 'Waited' } else { 'Ready' }
                DurationMs = [int][Math]::Round($stopwatch.Elapsed.TotalMilliseconds)
                LockPath    = $lockPath
            }
        }
        catch [System.IO.IOException] {
            if (-not $announcedWait) {
                Write-Host ('[wait] Build.bat global lock is busy. Waiting for release: {0}' -f $lockPath) -ForegroundColor Yellow
                $announcedWait = $true
            }

            if ($stopwatch.ElapsedMilliseconds -ge $TimeoutMs) {
                $stopwatch.Stop()
                return [PSCustomObject]@{
                    Status     = 'TimedOut'
                    DurationMs = [int][Math]::Round($stopwatch.Elapsed.TotalMilliseconds)
                    LockPath    = $lockPath
                }
            }

            Start-Sleep -Milliseconds $PollIntervalMs
        }
        finally {
            if ($null -ne $handle) {
                $handle.Dispose()
            }
        }
    }
}

function Get-DefinedAutomationGroups {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProjectRoot
    )

    $configPath = Join-Path (Normalize-PathValue -Path $ProjectRoot) 'Config\DefaultEngine.ini'
    if (-not (Test-Path -LiteralPath $configPath -PathType Leaf)) {
        return @()
    }

    $sectionsToCheck = @(
        '/Script/AutomationController.AutomationControllerSettings',
        '/Script/AutomationTest.AutomationTestSettings'
    )
    $groupsBySection = @{}
    foreach ($sectionName in $sectionsToCheck) {
        $groupsBySection[$sectionName] = New-Object System.Collections.Generic.List[string]
    }

    $currentSection = ''
    foreach ($line in Get-Content -LiteralPath $configPath -Encoding UTF8) {
        $trimmedLine = $line.Trim()
        if ($trimmedLine.StartsWith('[') -and $trimmedLine.EndsWith(']')) {
            $currentSection = $trimmedLine.Substring(1, $trimmedLine.Length - 2)
            continue
        }

        if ($line -match '\+Groups=\(Name="([^"]+)"' -and $groupsBySection.ContainsKey($currentSection)) {
            $groupsBySection[$currentSection].Add($matches[1]) | Out-Null
        }
    }

    foreach ($sectionName in $sectionsToCheck) {
        if ($groupsBySection[$sectionName].Count -gt 0) {
            return @($groupsBySection[$sectionName] | Select-Object -Unique)
        }
    }

    return @()
}

function Get-GitWorktreeMap {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot
    )

    $resolvedRepositoryRoot = Normalize-PathValue -Path $RepositoryRoot
    $gitOutput = & git -C $resolvedRepositoryRoot worktree list --porcelain 2>$null
    if ($LASTEXITCODE -ne 0 -or $null -eq $gitOutput) {
        return @()
    }

    $entries = New-Object System.Collections.Generic.List[object]
    $currentEntry = $null

    foreach ($line in $gitOutput) {
        if ([string]::IsNullOrWhiteSpace($line)) {
            if ($null -ne $currentEntry) {
                $entries.Add([PSCustomObject]$currentEntry) | Out-Null
                $currentEntry = $null
            }
            continue
        }

        if ($line.StartsWith('worktree ')) {
            if ($null -ne $currentEntry) {
                $entries.Add([PSCustomObject]$currentEntry) | Out-Null
            }

            $currentEntry = [ordered]@{
                WorktreeRoot = Normalize-PathValue -Path ($line.Substring(9))
                Head         = ''
                Branch       = ''
            }
            continue
        }

        if ($null -eq $currentEntry) {
            continue
        }

        if ($line.StartsWith('HEAD ')) {
            $currentEntry.Head = $line.Substring(5)
            continue
        }

        if ($line.StartsWith('branch ')) {
            $branchName = $line.Substring(7)
            if ($branchName.StartsWith('refs/heads/')) {
                $branchName = $branchName.Substring(11)
            }
            $currentEntry.Branch = $branchName
            continue
        }

        if ($line -eq 'detached') {
            $currentEntry.Branch = 'detached'
        }
    }

    if ($null -ne $currentEntry) {
        $entries.Add([PSCustomObject]$currentEntry) | Out-Null
    }

    return @($entries.ToArray())
}

function Resolve-UbtCommandDescriptor {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProcessName,

        [Parameter(Mandatory = $true)]
        [string]$CommandLine,

        [object[]]$WorktreeMap = @()
    )

    $normalizedCommandLine = ([string]$CommandLine).Replace('/', '\')
    $normalizedProcessName = [System.IO.Path]::GetFileName([string]$ProcessName)

    $kind = 'Unknown'
    if ($normalizedProcessName -ieq 'dotnet.exe' -and $normalizedCommandLine -match 'UnrealBuildTool\.dll') {
        $kind = 'DotNetUbt'
    }
    elseif ($normalizedProcessName -ieq 'UnrealBuildTool.exe') {
        $kind = 'NativeUbt'
    }
    elseif ($normalizedProcessName -ieq 'cmd.exe' -and $normalizedCommandLine -match 'Build\.bat') {
        $kind = 'BuildBat'
    }
    elseif ($normalizedProcessName -ieq 'cmd.exe' -and $normalizedCommandLine -match 'RunUBT\.bat') {
        $kind = 'RunUbtBat'
    }

    $projectFile = $null
    $projectMatch = [regex]::Match($normalizedCommandLine, '(?i)-Project=(?:"(?<path>[^"]+?\.uproject)"|(?<path>[^\s"]+?\.uproject))')
    if ($projectMatch.Success) {
        $projectFile = Normalize-PathValue -Path $projectMatch.Groups['path'].Value
    }
    else {
        $uprojectMatch = [regex]::Match($normalizedCommandLine, '(?i)(?<path>[A-Za-z]:\\[^"]+?\.uproject)')
        if ($uprojectMatch.Success) {
            $projectFile = Normalize-PathValue -Path $uprojectMatch.Groups['path'].Value
        }
    }

    $target = $null
    $platform = $null
    $configuration = $null
    $targetMatch = [regex]::Match($normalizedCommandLine, 'UnrealBuildTool(?:\.dll|\.exe)"?\s+(?<target>\S+)\s+(?<platform>\S+)\s+(?<configuration>\S+)')
    if ($targetMatch.Success) {
        $target = $targetMatch.Groups['target'].Value
        $platform = $targetMatch.Groups['platform'].Value
        $configuration = $targetMatch.Groups['configuration'].Value
    }

    $worktreeRoot = $null
    if (-not [string]::IsNullOrWhiteSpace([string]$projectFile)) {
        $worktreeRoot = Normalize-PathValue -Path (Split-Path -Parent $projectFile)
    }

    $matchedWorktree = @()
    if ($null -ne $worktreeRoot) {
        $matchedWorktree = @($WorktreeMap | Where-Object { $_.WorktreeRoot -eq $worktreeRoot } | Select-Object -First 1)
    }

    if ($matchedWorktree.Count -eq 0) {
        $matchedWorktree = @(
            $WorktreeMap |
                Sort-Object { $_.WorktreeRoot.Length } -Descending |
                Where-Object { $normalizedCommandLine.IndexOf($_.WorktreeRoot, [System.StringComparison]::OrdinalIgnoreCase) -ge 0 } |
                Select-Object -First 1
        )
    }

    $selectedWorktree = if ($matchedWorktree.Count -gt 0) { $matchedWorktree[0] } else { $null }

    return [PSCustomObject]@{
        Kind                = $kind
        ProcessName         = $normalizedProcessName
        CommandLine         = $normalizedCommandLine
        ProjectFile         = $projectFile
        WorktreeRoot        = if ($null -ne $selectedWorktree) { $selectedWorktree.WorktreeRoot } else { $worktreeRoot }
        Branch              = if ($null -ne $selectedWorktree) { $selectedWorktree.Branch } else { $null }
        Head                = if ($null -ne $selectedWorktree) { $selectedWorktree.Head } else { $null }
        Target              = $target
        Platform            = $platform
        Configuration       = $configuration
        UsesNoMutex         = $normalizedCommandLine -match '(^|\s)-NoMutex(\s|$)'
        UsesWaitMutex       = $normalizedCommandLine -match '(^|\s)-WaitMutex(\s|$)'
        UsesNoEngineChanges = $normalizedCommandLine -match '(^|\s)-NoEngineChanges(\s|$)'
    }
}

function Get-UbtProcessInfo {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot,

        [string]$WorktreeRoot = ''
    )

    $resolvedWorktreeFilter = if ([string]::IsNullOrWhiteSpace($WorktreeRoot)) { '' } else { Normalize-PathValue -Path $WorktreeRoot }
    $worktreeMap = @(Get-GitWorktreeMap -RepositoryRoot $RepositoryRoot)
    $processes = @(Get-CimInstance Win32_Process -ErrorAction SilentlyContinue)

    $results = New-Object System.Collections.Generic.List[object]
    foreach ($process in $processes) {
        $processName = [string]$process.Name
        if ($processName -notin @('dotnet.exe', 'UnrealBuildTool.exe', 'cmd.exe')) {
            continue
        }

        $commandLine = [string]$process.CommandLine
        if ([string]::IsNullOrWhiteSpace($commandLine)) {
            continue
        }

        if ($commandLine -notmatch 'UnrealBuildTool|Build\.bat|RunUBT\.bat') {
            continue
        }

        $descriptor = Resolve-UbtCommandDescriptor -ProcessName $processName -CommandLine $commandLine -WorktreeMap $worktreeMap
        if ($descriptor.Kind -eq 'Unknown') {
            continue
        }

        if (-not [string]::IsNullOrWhiteSpace($resolvedWorktreeFilter) -and $descriptor.WorktreeRoot -ne $resolvedWorktreeFilter) {
            continue
        }

        $startedAt = $null
        if (-not [string]::IsNullOrWhiteSpace([string]$process.CreationDate)) {
            try {
                $startedAt = [System.Management.ManagementDateTimeConverter]::ToDateTime($process.CreationDate)
            }
            catch {
                $startedAt = $null
            }
        }

        $results.Add([PSCustomObject]@{
                ProcessId           = [int]$process.ProcessId
                ParentProcessId     = [int]$process.ParentProcessId
                ProcessName         = $processName
                Kind                = $descriptor.Kind
                StartedAt           = $startedAt
                Branch              = $descriptor.Branch
                Head                = $descriptor.Head
                WorktreeRoot        = $descriptor.WorktreeRoot
                ProjectFile         = $descriptor.ProjectFile
                Target              = $descriptor.Target
                Platform            = $descriptor.Platform
                Configuration       = $descriptor.Configuration
                UsesNoMutex         = $descriptor.UsesNoMutex
                UsesWaitMutex       = $descriptor.UsesWaitMutex
                UsesNoEngineChanges = $descriptor.UsesNoEngineChanges
                CommandLine         = $descriptor.CommandLine
            }) | Out-Null
    }

    $sortedResults = @($results.ToArray() | Sort-Object StartedAt, ProcessId)
    return $sortedResults
}
