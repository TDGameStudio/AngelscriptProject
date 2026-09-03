$script:UnrealEngineLaneSlotCount = 16
$script:UnrealProgressTailBytes = 512 * 1024
$script:UnrealProgressTextLimit = 512

function Get-UnrealSha256Text {
    param([Parameter(Mandatory = $true)][string] $Value)
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($Value.ToUpperInvariant())
    return [System.Convert]::ToHexString([System.Security.Cryptography.SHA256]::HashData($bytes)).ToLowerInvariant()
}

function Get-UnrealMutexName {
    param(
        [Parameter(Mandatory = $true)][ValidatePattern('^[A-Za-z][A-Za-z0-9-]{0,31}$')][string] $Scope,
        [Parameter(Mandatory = $true)][string] $Key
    )
    $hash = Get-UnrealSha256Text -Value $Key
    return "AngelscriptProject.Hardness.Unreal.$Scope.$($hash.Substring(0, 32))"
}

function Enter-UnrealLease {
    param(
        [Parameter(Mandatory = $true)][string] $Scope,
        [Parameter(Mandatory = $true)][string] $Key,
        [Parameter(Mandatory = $true)][ValidateSet('Auto', 'Wait', 'Fail')][string] $Policy,
        [Parameter(Mandatory = $true)][int] $TimeoutMs
    )
    $name = Get-UnrealMutexName -Scope $Scope -Key $Key
    $mutex = [System.Threading.Mutex]::new($false, $name)
    $acquired = $false
    try {
        $waitMs = if ($Policy -eq 'Fail') { 0 } else { [Math]::Max(0, $TimeoutMs) }
        try {
            $acquired = $mutex.WaitOne($waitMs)
        }
        catch [System.Threading.AbandonedMutexException] {
            $acquired = $true
        }
        if (-not $acquired) {
            $mutex.Dispose()
            return $null
        }
        return [pscustomobject]@{ Name = $name; Scope = $Scope; Mutex = $mutex }
    }
    catch {
        if (-not $acquired) { $mutex.Dispose() }
        throw
    }
}

function Exit-UnrealLease {
    param($Lease)
    if ($null -eq $Lease) { return }
    try { $Lease.Mutex.ReleaseMutex() }
    catch [System.ApplicationException] { }
    finally { $Lease.Mutex.Dispose() }
}

function Enter-UnrealNamedMutex {
    param(
        [Parameter(Mandatory = $true)][string] $Name,
        [Parameter(Mandatory = $true)][int] $TimeoutMs
    )
    $mutex = [System.Threading.Mutex]::new($false, $Name)
    $acquired = $false
    try {
        try {
            $acquired = $mutex.WaitOne([Math]::Max(0, $TimeoutMs))
        }
        catch [System.Threading.AbandonedMutexException] {
            $acquired = $true
        }
        if (-not $acquired) {
            $mutex.Dispose()
            return $null
        }
        return $mutex
    }
    catch {
        if (-not $acquired) { $mutex.Dispose() }
        throw
    }
}

function Exit-UnrealNamedMutex {
    param([AllowNull()][System.Threading.Mutex] $Mutex)
    if ($null -eq $Mutex) { return }
    try { $Mutex.ReleaseMutex() }
    catch [System.ApplicationException] { }
    finally { $Mutex.Dispose() }
}

function Get-UnrealLeaseWaitMilliseconds {
    param(
        [Parameter(Mandatory = $true)][DateTimeOffset] $Deadline,
        [Parameter(Mandatory = $true)][ValidateSet('Auto', 'Wait', 'Fail')][string] $Policy
    )
    if ($Policy -eq 'Fail') { return 0 }
    return [Math]::Max(0, [int] ($Deadline - [DateTimeOffset]::UtcNow).TotalMilliseconds)
}

function Enter-UnrealEngineLane {
    param(
        [Parameter(Mandatory = $true)][string] $EngineRoot,
        [Parameter(Mandatory = $true)][ValidateSet('Shared', 'Exclusive')][string] $Mode,
        [Parameter(Mandatory = $true)][ValidateSet('Auto', 'Wait', 'Fail')][string] $Policy,
        [Parameter(Mandatory = $true)][int] $TimeoutMs
    )
    $root = ConvertTo-UnrealCanonicalPath -Path $EngineRoot
    $deadline = [DateTimeOffset]::UtcNow.AddMilliseconds([Math]::Max(0, $TimeoutMs))
    $gateName = Get-UnrealMutexName -Scope 'engine-gate' -Key $root
    $slotNames = @(0..($script:UnrealEngineLaneSlotCount - 1) | ForEach-Object {
        Get-UnrealMutexName -Scope 'engine-slot' -Key ("{0}|{1}" -f $root, $_)
    })

    if ($Mode -eq 'Exclusive') {
        $gate = Enter-UnrealNamedMutex -Name $gateName -TimeoutMs (Get-UnrealLeaseWaitMilliseconds -Deadline $deadline -Policy $Policy)
        if ($null -eq $gate) { return $null }
        $slots = [System.Collections.Generic.List[System.Threading.Mutex]]::new()
        try {
            foreach ($slotName in $slotNames) {
                $slot = Enter-UnrealNamedMutex -Name $slotName -TimeoutMs (Get-UnrealLeaseWaitMilliseconds -Deadline $deadline -Policy $Policy)
                if ($null -eq $slot) { return $null }
                $slots.Add($slot)
            }
            return [pscustomobject]@{
                Mode       = 'Exclusive'
                EngineRoot = $root
                Gate       = $gate
                Slots      = @($slots)
            }
        }
        finally {
            if ($slots.Count -ne $script:UnrealEngineLaneSlotCount) {
                for ($index = $slots.Count - 1; $index -ge 0; $index--) { Exit-UnrealNamedMutex -Mutex $slots[$index] }
                Exit-UnrealNamedMutex -Mutex $gate
            }
        }
    }

    while ($true) {
        $remaining = Get-UnrealLeaseWaitMilliseconds -Deadline $deadline -Policy $Policy
        $gate = Enter-UnrealNamedMutex -Name $gateName -TimeoutMs $remaining
        if ($null -eq $gate) { return $null }
        $slot = $null
        try {
            foreach ($slotName in $slotNames) {
                $slot = Enter-UnrealNamedMutex -Name $slotName -TimeoutMs 0
                if ($null -ne $slot) { break }
            }
        }
        finally { Exit-UnrealNamedMutex -Mutex $gate }
        if ($null -ne $slot) {
            return [pscustomobject]@{
                Mode       = 'Shared'
                EngineRoot = $root
                Gate       = $null
                Slots      = @($slot)
            }
        }
        if ($Policy -eq 'Fail' -or [DateTimeOffset]::UtcNow -ge $deadline) { return $null }
        Start-Sleep -Milliseconds 25
    }
}

function Exit-UnrealEngineLane {
    param($Lease)
    if ($null -eq $Lease) { return }
    $slots = @($Lease.Slots)
    for ($index = $slots.Count - 1; $index -ge 0; $index--) { Exit-UnrealNamedMutex -Mutex $slots[$index] }
    Exit-UnrealNamedMutex -Mutex $Lease.Gate
}

function Assert-UnrealRunId {
    param([Parameter(Mandatory = $true)][string] $RunId)
    if ($RunId -notmatch '^[a-f0-9]{32}$') {
        throw "RunId must be exactly 32 lowercase hexadecimal characters: $RunId"
    }
    return $RunId
}

function Get-UnrealRunPaths {
    param(
        [Parameter(Mandatory = $true)][string] $WorkspaceRoot,
        [Parameter(Mandatory = $true)][string] $RunId
    )
    [void](Assert-UnrealRunId -RunId $RunId)
    $root = ConvertTo-UnrealCanonicalPath -Path $WorkspaceRoot
    $runsRoot = [System.IO.Path]::GetFullPath((Join-Path $root 'Saved/Hardness/Unreal/Runs'))
    $runRoot = [System.IO.Path]::GetFullPath((Join-Path $runsRoot $RunId))
    [void](Assert-UnrealPathContained -Root $runsRoot -Path $runRoot -Purpose 'Unreal run directory')
    return [pscustomobject][ordered]@{
        RunsRoot     = $runsRoot
        RunRoot      = $runRoot
        RequestPath  = Join-Path $runRoot 'Request.json'
        MetadataPath = Join-Path $runRoot 'RunMetadata.json'
        LogPath      = Join-Path $runRoot 'Command.log'
        StdOutPath   = Join-Path $runRoot 'Command.stdout.log'
        StdErrPath   = Join-Path $runRoot 'Command.stderr.log'
        UnrealLogPath = Join-Path $runRoot 'Unreal.log'
        UbtLogPath   = Join-Path $runRoot 'UBT.log'
        TargetsPath  = Join-Path $runRoot 'Targets.json'
        EntriesRoot  = Join-Path $runRoot 'Entries'
        ReportPath   = Join-Path $runRoot 'AutomationReport'
        SummaryPath  = Join-Path $runRoot 'Summary.json'
        TempPath     = Join-Path $runRoot 'Temp'
    }
}

function Assert-UnrealRequestPaths {
    param(
        [Parameter(Mandatory = $true)] $Request,
        [Parameter(Mandatory = $true)] $ExpectedPaths
    )
    foreach ($name in @('RunsRoot', 'RunRoot', 'RequestPath', 'MetadataPath', 'LogPath', 'StdOutPath', 'StdErrPath', 'UnrealLogPath', 'UbtLogPath', 'TargetsPath', 'EntriesRoot', 'ReportPath', 'SummaryPath', 'TempPath')) {
        $actualProperty = $Request.paths.PSObject.Properties[$name]
        if ($null -eq $actualProperty -or -not (Test-UnrealPathEqual -Left ([string] $actualProperty.Value) -Right ([string] $ExpectedPaths.$name))) {
            throw "Run request path '$name' does not match its contained run directory."
        }
    }
}

function Read-UnrealBoundedTail {
    param(
        [Parameter(Mandatory = $true)][string] $Path,
        [ValidateRange(1024, 1048576)][int] $MaximumBytes = $script:UnrealProgressTailBytes
    )
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        return [pscustomobject]@{ Text = ''; BytesInspected = 0L; Truncated = $false }
    }
    $stream = [System.IO.File]::Open($Path, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite -bor [System.IO.FileShare]::Delete)
    try {
        $length = [long] $stream.Length
        $count = [int] [Math]::Min([long] $MaximumBytes, $length)
        $truncated = $length -gt $count
        if ($count -eq 0) {
            return [pscustomobject]@{ Text = ''; BytesInspected = 0L; Truncated = $false }
        }
        if ($truncated) { [void] $stream.Seek(-$count, [System.IO.SeekOrigin]::End) }
        $buffer = [byte[]]::new($count)
        $offset = 0
        while ($offset -lt $count) {
            $read = $stream.Read($buffer, $offset, $count - $offset)
            if ($read -le 0) { break }
            $offset += $read
        }
        $text = [System.Text.UTF8Encoding]::new($false, $false).GetString($buffer, 0, $offset)
        if ($truncated) {
            $newline = $text.IndexOf("`n", [System.StringComparison]::Ordinal)
            $text = if ($newline -lt 0) { '' } else { $text.Substring($newline + 1) }
        }
        return [pscustomobject]@{ Text = $text; BytesInspected = [long] $offset; Truncated = $truncated }
    }
    finally { $stream.Dispose() }
}

function New-UnrealUnknownBuildProgress {
    param([string] $ObservedAtUtc = '')
    if ([string]::IsNullOrWhiteSpace($ObservedAtUtc)) { $ObservedAtUtc = [DateTimeOffset]::UtcNow.ToString('o') }
    return [pscustomobject][ordered]@{
        ProgressKnown  = $false
        Current        = $null
        Total          = $null
        Percent        = $null
        Text           = ''
        Source         = 'None'
        EvidencePath   = ''
        ObservedAtUtc  = $ObservedAtUtc
        BytesInspected = 0L
        Truncated      = $false
    }
}

function ConvertFrom-UnrealBuildProgressText {
    param([AllowEmptyString()][string] $Text)
    $last = $null
    foreach ($lineValue in @($Text -split "`r?`n")) {
        $line = ([string] $lineValue).Trim()
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        $progressMatch = [regex]::Match($line, '(?i)@progress\s+(?:''(?<single>[^'']*)''|"(?<double>[^"]*)")\s+(?<percent>\d{1,3}(?:\.\d+)?)%')
        if (-not $progressMatch.Success) {
            $progressMatch = [regex]::Match($line, '(?i)@progress\s+(?<percent>\d{1,3}(?:\.\d+)?)%\s*(?<plain>.*)$')
        }
        if ($progressMatch.Success) {
            $percent = [double]::Parse($progressMatch.Groups['percent'].Value, [Globalization.CultureInfo]::InvariantCulture)
            if ($percent -ge 0 -and $percent -le 100) {
                $progressText = @('single', 'double', 'plain' | ForEach-Object {
                    if ($progressMatch.Groups[$_].Success) { [string] $progressMatch.Groups[$_].Value }
                } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -First 1)
                $label = if ($progressText.Count -eq 0) { '' } else { [string] $progressText[0] }
                if ($label.Length -gt $script:UnrealProgressTextLimit) { $label = $label.Substring(0, $script:UnrealProgressTextLimit) }
                $last = [pscustomobject]@{ Current = $null; Total = $null; Percent = [Math]::Round($percent, 2); Text = $label }
            }
        }

        $actionMatch = [regex]::Match($line, '(?:^|\s)\[(?<current>\d{1,7})/(?<total>\d{1,7})\]\s*(?<text>.*)$')
        if ($actionMatch.Success) {
            $current = [int] $actionMatch.Groups['current'].Value
            $total = [int] $actionMatch.Groups['total'].Value
            if ($total -gt 0 -and $current -ge 0 -and $current -le $total) {
                $actionText = ([string] $actionMatch.Groups['text'].Value).Trim()
                if ($actionText.Length -gt $script:UnrealProgressTextLimit) { $actionText = $actionText.Substring(0, $script:UnrealProgressTextLimit) }
                $last = [pscustomobject]@{
                    Current = $current
                    Total   = $total
                    Percent = [Math]::Round((100.0 * $current / $total), 2)
                    Text    = $actionText
                }
            }
        }
    }
    return $last
}

function Get-UnrealBuildProgressSnapshot {
    param([Parameter(Mandatory = $true)] $Paths)
    $observedAt = [DateTimeOffset]::UtcNow.ToString('o')
    $runRoot = ConvertTo-UnrealCanonicalPath -Path ([string] $Paths.RunRoot) -AllowMissing
    if ($null -ne $Paths.PSObject.Properties['RunsRoot']) {
        [void](Assert-UnrealPathContained -Root ([string] $Paths.RunsRoot) -Path $runRoot -Purpose 'Unreal progress run directory')
    }
    $inspected = 0L
    $truncated = $false
    foreach ($candidate in @(
        [pscustomobject]@{ Name = 'UbtLog'; Path = [string] $Paths.UbtLogPath }
        [pscustomobject]@{ Name = 'StdOut'; Path = [string] $Paths.StdOutPath }
    )) {
        $path = Assert-UnrealPathContained -Root $runRoot -Path $candidate.Path -Purpose 'Unreal build progress evidence'
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { continue }
        $tail = Read-UnrealBoundedTail -Path $path
        $inspected += [long] $tail.BytesInspected
        $truncated = $truncated -or [bool] $tail.Truncated
        $parsed = ConvertFrom-UnrealBuildProgressText -Text ([string] $tail.Text)
        if ($null -eq $parsed) { continue }
        return [pscustomobject][ordered]@{
            ProgressKnown  = $true
            Current        = $parsed.Current
            Total          = $parsed.Total
            Percent        = $parsed.Percent
            Text           = [string] $parsed.Text
            Source         = [string] $candidate.Name
            EvidencePath   = $path
            ObservedAtUtc  = $observedAt
            BytesInspected = [long] $tail.BytesInspected
            Truncated      = [bool] $tail.Truncated
        }
    }
    $unknown = New-UnrealUnknownBuildProgress -ObservedAtUtc $observedAt
    $unknown.BytesInspected = $inspected
    $unknown.Truncated = $truncated
    return $unknown
}

function Get-UnrealSharedEngineUhtTimestampConflict {
    param(
        [Parameter(Mandatory = $true)] $Paths,
        [Parameter(Mandatory = $true)][string] $EngineRoot
    )
    $runRoot = ConvertTo-UnrealCanonicalPath -Path ([string] $Paths.RunRoot) -AllowMissing
    $engine = ConvertTo-UnrealCanonicalPath -Path $EngineRoot
    $matches = [System.Collections.Generic.List[string]]::new()
    $seen = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    $evidence = [System.Collections.Generic.List[string]]::new()
    $bytes = 0L
    $truncated = $false
    $pattern = [regex]::new('(?im)(?<path>[A-Za-z]:[\\/][^''"\r\n]*?[\\/]UHT[\\/]Timestamp)(?:''|")?[^\r\n]{0,512}?(?:being used by another process|used by another process)')
    foreach ($pathValue in @($Paths.UbtLogPath, $Paths.StdOutPath, $Paths.StdErrPath, $Paths.LogPath)) {
        $path = Assert-UnrealPathContained -Root $runRoot -Path ([string] $pathValue) -Purpose 'UHT contention evidence'
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { continue }
        $tail = Read-UnrealBoundedTail -Path $path -MaximumBytes (256 * 1024)
        $bytes += [long] $tail.BytesInspected
        $truncated = $truncated -or [bool] $tail.Truncated
        foreach ($match in $pattern.Matches([string] $tail.Text)) {
            $matchedPath = ConvertTo-UnrealCanonicalPath -Path ([string] $match.Groups['path'].Value) -AllowMissing
            try { [void](Assert-UnrealPathContained -Root $engine -Path $matchedPath -Purpose 'shared-engine UHT Timestamp') }
            catch { continue }
            if ($seen.Add($matchedPath) -and $matches.Count -lt 8) { $matches.Add($matchedPath) }
            if (-not $evidence.Contains($path)) { $evidence.Add($path) }
        }
    }
    return [pscustomobject][ordered]@{
        Detected       = $matches.Count -gt 0
        Paths          = @($matches)
        EvidencePaths  = @($evidence)
        BytesInspected = $bytes
        Truncated      = $truncated
    }
}

function Test-UnrealIgnoredRunRoot {
    param([Parameter(Mandatory = $true)][string] $WorkspaceRoot)
    $previousPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        & git -C $WorkspaceRoot check-ignore --quiet -- 'Saved/Hardness/Unreal/Runs/__probe__'
        $exitCode = $LASTEXITCODE
    }
    finally { $ErrorActionPreference = $previousPreference }
    return $exitCode -eq 0
}

function New-UnrealRunRequest {
    param(
        [Parameter(Mandatory = $true)][string] $WorkspaceRoot,
        [Parameter(Mandatory = $true)][string] $EngineRoot,
        [Parameter(Mandatory = $true)][string] $ProjectFile,
        [Parameter(Mandatory = $true)][ValidateSet('Build', 'QueryTargets', 'Ubt', 'Test', 'Commandlet', 'Suite')][string] $Operation,
        [Parameter(Mandatory = $true)][string] $FilePath,
        [AllowEmptyCollection()][string[]] $Arguments = @(),
        [Parameter(Mandatory = $true)][string] $WorkingDirectory,
        [Parameter(Mandatory = $true)][int] $TimeoutMs,
        [Parameter(Mandatory = $true)] $ConcurrencyDecision,
        [hashtable] $Environment = @{},
        [bool] $EnforceAutomationReport = $false,
        [string] $Label = ''
    )
    Assert-UnrealPowerShell
    Assert-UnrealArgumentArray -Arguments $Arguments
    if ($TimeoutMs -le 0 -or $TimeoutMs -gt 3600000) {
        throw "TimeoutMs must be between 1 and 3600000; received $TimeoutMs."
    }
    $configuration = Get-UnrealWorkspaceConfiguration -WorkspaceRoot $WorkspaceRoot -RequireExecutionGuard -CallerPath $WorkspaceRoot
    $canonicalEngine = ConvertTo-UnrealCanonicalPath -Path $EngineRoot
    $canonicalProject = ConvertTo-UnrealCanonicalPath -Path $ProjectFile
    if (-not (Test-UnrealPathEqual -Left $configuration.EngineRoot -Right $canonicalEngine)) {
        throw "Run EngineRoot '$canonicalEngine' does not match the selected workspace configuration '$($configuration.EngineRoot)'."
    }
    if (-not (Test-UnrealPathEqual -Left $configuration.ProjectFile -Right $canonicalProject)) {
        throw "Run ProjectFile '$canonicalProject' does not match the selected workspace configuration '$($configuration.ProjectFile)'."
    }
    $executable = ConvertTo-UnrealCanonicalPath -Path $FilePath
    if (-not (Test-Path -LiteralPath $executable -PathType Leaf)) { throw "Native executable was not found: $executable" }
    $working = ConvertTo-UnrealCanonicalPath -Path $WorkingDirectory
    if (-not (Test-Path -LiteralPath $working -PathType Container)) { throw "Native working directory was not found: $working" }
    foreach ($key in @($Environment.Keys)) {
        if ([string] $key -notmatch '^[A-Za-z_][A-Za-z0-9_]*$') { throw "Child environment key is invalid: $key" }
        if ([string] $Environment[$key] -match "`0") { throw "Child environment value contains NUL: $key" }
    }
    foreach ($required in @('Policy', 'Decision', 'RequiresEngineLease', 'Reasons')) {
        if ($required -notin @($ConcurrencyDecision.PSObject.Properties.Name)) { throw "Concurrency decision is missing '$required'." }
    }
    if ([string] $ConcurrencyDecision.Policy -notin @('Auto', 'Wait', 'Fail')) { throw "Concurrency policy is invalid: $($ConcurrencyDecision.Policy)" }

    $runId = [guid]::NewGuid().ToString('N')
    $paths = Get-UnrealRunPaths -WorkspaceRoot $configuration.WorkspaceRoot -RunId $runId
    return [pscustomobject][ordered]@{
        schemaVersion           = $script:UnrealRequestSchema
        runId                   = $runId
        createdAtUtc            = [DateTimeOffset]::UtcNow.ToString('o')
        operation               = $Operation
        label                   = $Label
        workspaceRoot           = $configuration.WorkspaceRoot
        primaryRoot             = $configuration.Identity.PrimaryRoot
        gitCommonDir            = $configuration.Identity.GitCommonDir
        engineRoot              = $canonicalEngine
        projectFile             = $canonicalProject
        filePath                = $executable
        arguments               = @($Arguments | ForEach-Object { [string] $_ })
        workingDirectory        = $working
        timeoutMs               = $TimeoutMs
        environment             = [pscustomobject] $Environment
        concurrency             = [pscustomobject][ordered]@{
            policy              = [string] $ConcurrencyDecision.Policy
            decision            = [string] $ConcurrencyDecision.Decision
            requiresEngineLease = [bool] $ConcurrencyDecision.RequiresEngineLease
            engineLane          = if ($null -eq $ConcurrencyDecision.PSObject.Properties['EngineLane']) {
                if ([bool] $ConcurrencyDecision.RequiresEngineLease) { 'Exclusive' } else { 'None' }
            } else { [string] $ConcurrencyDecision.EngineLane }
            requestedBuildConcurrency = if ($null -eq $ConcurrencyDecision.PSObject.Properties['RequestedBuildConcurrency']) { 'NotApplicable' } else { [string] $ConcurrencyDecision.RequestedBuildConcurrency }
            buildConcurrency    = if ($null -eq $ConcurrencyDecision.PSObject.Properties['BuildConcurrency']) { 'NotApplicable' } else { [string] $ConcurrencyDecision.BuildConcurrency }
            ubtArguments        = if ($null -eq $ConcurrencyDecision.PSObject.Properties['UbtArguments']) { @() } else { @($ConcurrencyDecision.UbtArguments | ForEach-Object { [string] $_ }) }
            reasons             = @($ConcurrencyDecision.Reasons | ForEach-Object { [string] $_ })
        }
        enforceAutomationReport = $EnforceAutomationReport
        paths                   = $paths
    }
}

function Set-UnrealRunCommand {
    param(
        [Parameter(Mandatory = $true)] $Request,
        [AllowEmptyCollection()][string[]] $Arguments = @(),
        [System.Collections.IDictionary] $Environment = @{}
    )
    Assert-UnrealArgumentArray -Arguments $Arguments
    $expectedPaths = Get-UnrealRunPaths -WorkspaceRoot ([string] $Request.workspaceRoot) -RunId ([string] $Request.runId)
    Assert-UnrealRequestPaths -Request $Request -ExpectedPaths $expectedPaths
    foreach ($key in @($Environment.Keys)) {
        if ([string] $key -notmatch '^[A-Za-z_][A-Za-z0-9_]*$') { throw "Child environment key is invalid: $key" }
        if ([string] $Environment[$key] -match "`0") { throw "Child environment value contains NUL: $key" }
    }
    $environmentValues = [ordered]@{}
    foreach ($key in @($Environment.Keys | Sort-Object)) {
        $environmentValues[[string] $key] = [string] $Environment[$key]
    }
    $Request.arguments = @($Arguments | ForEach-Object { [string] $_ })
    $Request.environment = [pscustomobject] $environmentValues
    return $Request
}

function New-UnrealRunMetadata {
    param([Parameter(Mandatory = $true)] $Request)
    $artifacts = [System.Collections.Generic.List[string]]::new()
    foreach ($path in @($Request.paths.RequestPath, $Request.paths.MetadataPath, $Request.paths.LogPath)) {
        $artifacts.Add([string] $path)
    }
    if ([string] $Request.operation -in @('Build', 'QueryTargets', 'Ubt')) {
        $artifacts.Add([string] $Request.paths.UbtLogPath)
    }
    if ([string] $Request.operation -eq 'QueryTargets') {
        $artifacts.Add([string] $Request.paths.TargetsPath)
    }
    if ([string] $Request.operation -in @('Test', 'Commandlet')) {
        $artifacts.Add([string] $Request.paths.UnrealLogPath)
    }
    if ([string] $Request.operation -eq 'Test' -and [bool] $Request.enforceAutomationReport) {
        $artifacts.Add([string] $Request.paths.ReportPath)
        $artifacts.Add([string] $Request.paths.SummaryPath)
    }
    if ([string] $Request.operation -eq 'Suite') {
        $artifacts.Add([string] $Request.paths.SummaryPath)
    }
    return [pscustomobject][ordered]@{
        schemaVersion      = $script:UnrealRunSchema
        runId              = [string] $Request.runId
        operation          = [string] $Request.operation
        state              = 'Queued'
        createdAtUtc       = [string] $Request.createdAtUtc
        updatedAtUtc       = [DateTimeOffset]::UtcNow.ToString('o')
        workspaceRoot      = [string] $Request.workspaceRoot
        engineRoot         = [string] $Request.engineRoot
        concurrency        = $Request.concurrency
        workerPid          = $null
        workerStartedAtUtc = $null
        nativePid          = $null
        nativeStartedAtUtc = $null
        completedAtUtc     = $null
        exitCode           = $null
        timedOut           = $false
        message            = ''
        durationMs         = 0
        artifacts          = @($artifacts)
    }
}

function Test-UnrealRunStateTransition {
    param(
        [Parameter(Mandatory = $true)][string] $CurrentState,
        [Parameter(Mandatory = $true)][string] $NextState
    )
    if ($CurrentState -eq $NextState) { return $true }
    $allowed = switch ($CurrentState) {
        'Queued' { @('WaitingWorkspace', 'Failed', 'TimedOut', 'Cancelled') }
        'WaitingWorkspace' { @('WaitingEngine', 'Running', 'Failed', 'TimedOut', 'Cancelled') }
        'WaitingEngine' { @('Running', 'Failed', 'TimedOut', 'Cancelled') }
        'Running' { @('Succeeded', 'Failed', 'TimedOut', 'Cancelled') }
        default { @() }
    }
    return $NextState -in $allowed
}

function Update-UnrealRunMetadata {
    param(
        [Parameter(Mandatory = $true)][string] $Path,
        [Parameter(Mandatory = $true)][hashtable] $Changes
    )
    $lease = Enter-UnrealLease -Scope 'metadata' -Key $Path -Policy Wait -TimeoutMs 5000
    if ($null -eq $lease) { throw "Timed out acquiring run metadata lease: $Path" }
    try {
        $current = Read-UnrealJsonFile -Path $Path
        $values = [ordered]@{}
        foreach ($property in $current.PSObject.Properties) { $values[$property.Name] = $property.Value }
        $currentState = [string] $values.state
        if ($Changes.ContainsKey('state')) {
            $nextState = [string] $Changes.state
            if ($currentState -in $script:UnrealTerminalStates -and $nextState -ne $currentState) { return $current }
            if (-not (Test-UnrealRunStateTransition -CurrentState $currentState -NextState $nextState)) {
                throw "Illegal Unreal run state transition: $currentState -> $nextState"
            }
        }
        foreach ($key in @($Changes.Keys)) { $values[$key] = $Changes[$key] }
        $values.updatedAtUtc = [DateTimeOffset]::UtcNow.ToString('o')
        $updated = [pscustomobject] $values
        Write-UnrealJsonFileAtomic -Path $Path -Value $updated
        return $updated
    }
    finally { Exit-UnrealLease -Lease $lease }
}

function Test-UnrealProcessAlive {
    param([AllowNull()][object] $ProcessId)
    if ($null -eq $ProcessId) { return $false }
    $idValue = 0
    if (-not [int]::TryParse([string] $ProcessId, [ref] $idValue) -or $idValue -le 0) { return $false }
    return $null -ne (Get-Process -Id $idValue -ErrorAction SilentlyContinue)
}

function Get-UnrealRunStatusRecord {
    param(
        [Parameter(Mandatory = $true)][string] $WorkspaceRoot,
        [Parameter(Mandatory = $true)][string] $RunId
    )
    $root = ConvertTo-UnrealCanonicalPath -Path $WorkspaceRoot
    $paths = Get-UnrealRunPaths -WorkspaceRoot $root -RunId $RunId
    $metadata = Read-UnrealJsonFile -Path $paths.MetadataPath
    if ([string] $metadata.runId -ne $RunId -or [string] $metadata.schemaVersion -ne $script:UnrealRunSchema) { throw "Run metadata identity is invalid: $($paths.MetadataPath)" }
    $recordedState = [string] $metadata.state
    $effectiveState = $recordedState
    if ($recordedState -notin $script:UnrealTerminalStates -and $null -ne $metadata.workerPid -and -not (Test-UnrealProcessAlive -ProcessId $metadata.workerPid)) { $effectiveState = 'Orphaned' }
    $progress = if ([string] $metadata.operation -eq 'Build') {
        Get-UnrealBuildProgressSnapshot -Paths $paths
    }
    else {
        New-UnrealUnknownBuildProgress
    }
    return [pscustomobject][ordered]@{
        RunId         = $RunId
        Operation     = [string] $metadata.operation
        State         = $effectiveState
        RecordedState = $recordedState
        ExitCode      = $metadata.exitCode
        TimedOut      = [bool] $metadata.timedOut
        Message       = [string] $metadata.message
        WorkerPid     = $metadata.workerPid
        NativePid     = $metadata.nativePid
        DurationMs    = [long] $metadata.durationMs
        RequestPath   = $paths.RequestPath
        MetadataPath  = $paths.MetadataPath
        LogPath       = $paths.LogPath
        ReportPath    = $paths.ReportPath
        SummaryPath   = $paths.SummaryPath
        Concurrency   = $metadata.concurrency
        Progress      = $progress
        Artifacts     = @($metadata.artifacts | ForEach-Object { [string] $_ })
    }
}

function Get-HardnessUnrealRunStatus {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string] $WorkspaceRoot,
        [Parameter(Mandatory = $true)][string] $RunId
    )
    $configuration = Get-UnrealWorkspaceConfiguration -WorkspaceRoot $WorkspaceRoot
    return Get-UnrealRunStatusRecord -WorkspaceRoot $configuration.WorkspaceRoot -RunId $RunId
}

function Start-UnrealRunRequest {
    param([Parameter(Mandatory = $true)] $Request, [switch] $NoWait)
    if ([string] $Request.schemaVersion -ne $script:UnrealRequestSchema) { throw "Unsupported Unreal request schema: $($Request.schemaVersion)" }
    $paths = Get-UnrealRunPaths -WorkspaceRoot ([string] $Request.workspaceRoot) -RunId ([string] $Request.runId)
    Assert-UnrealRequestPaths -Request $Request -ExpectedPaths $paths
    if (-not (Test-UnrealIgnoredRunRoot -WorkspaceRoot ([string] $Request.workspaceRoot))) { throw 'Saved/Hardness/Unreal/Runs must be ignored before a run can start.' }
    if (Test-Path -LiteralPath $paths.RunRoot) { throw "Run directory already exists: $($paths.RunRoot)" }
    [void][System.IO.Directory]::CreateDirectory($paths.RunRoot)
    [void][System.IO.Directory]::CreateDirectory($paths.TempPath)
    Write-UnrealJsonFileAtomic -Path $paths.RequestPath -Value $Request
    Write-UnrealJsonFileAtomic -Path $paths.MetadataPath -Value (New-UnrealRunMetadata -Request $Request)

    $worker = ConvertTo-UnrealCanonicalPath -Path (Join-Path $PSScriptRoot '../Invoke-UnrealRunWorker.ps1')
    $pwsh = ConvertTo-UnrealCanonicalPath -Path (Join-Path $PSHOME 'pwsh.exe')
    $startInfo = [System.Diagnostics.ProcessStartInfo]::new()
    $startInfo.FileName = $pwsh
    $startInfo.WorkingDirectory = [string] $Request.workspaceRoot
    $startInfo.UseShellExecute = $false
    $startInfo.CreateNoWindow = $true
    foreach ($argument in @('-NoLogo', '-NoProfile', '-NonInteractive', '-File', $worker, '-RequestPath', $paths.RequestPath)) { [void] $startInfo.ArgumentList.Add([string] $argument) }
    $startInfo.Environment['HARDNESS_WORKSPACE_ROOT'] = [string] $Request.workspaceRoot
    $startInfo.Environment['HARDNESS_PRIMARY_ROOT'] = [string] $Request.primaryRoot
    $startInfo.Environment['HARDNESS_GIT_COMMON_DIR'] = [string] $Request.gitCommonDir
    $process = [System.Diagnostics.Process]::new()
    $process.StartInfo = $startInfo
    if (-not $process.Start()) {
        [void](Update-UnrealRunMetadata -Path $paths.MetadataPath -Changes @{ state = 'Failed'; exitCode = 1; completedAtUtc = [DateTimeOffset]::UtcNow.ToString('o'); message = 'Unable to start the Unreal worker.' })
        throw 'Unable to start the Unreal worker.'
    }
    [void](Update-UnrealRunMetadata -Path $paths.MetadataPath -Changes @{ workerPid = $process.Id; workerStartedAtUtc = [DateTimeOffset]::UtcNow.ToString('o') })
    if ($NoWait) { return Get-HardnessUnrealRunStatus -WorkspaceRoot ([string] $Request.workspaceRoot) -RunId ([string] $Request.runId) }

    $parentWaitMs = [Math]::Min([int]::MaxValue, [int64] $Request.timeoutMs + 30000)
    if (-not $process.WaitForExit([int] $parentWaitMs)) {
        Stop-UnrealProcessTree -ProcessId $process.Id
        [void](Update-UnrealRunMetadata -Path $paths.MetadataPath -Changes @{ state = 'TimedOut'; exitCode = 2; timedOut = $true; completedAtUtc = [DateTimeOffset]::UtcNow.ToString('o'); message = 'Worker exceeded the operation timeout plus shutdown allowance.' })
    }
    return Get-HardnessUnrealRunStatus -WorkspaceRoot ([string] $Request.workspaceRoot) -RunId ([string] $Request.runId)
}

function Get-UnrealRemainingTimeout {
    param([Parameter(Mandatory = $true)] $Request)
    $deadline = [DateTimeOffset]::Parse([string] $Request.createdAtUtc).AddMilliseconds([int] $Request.timeoutMs)
    return [Math]::Max(0, [int] ($deadline - [DateTimeOffset]::UtcNow).TotalMilliseconds)
}

function Stop-UnrealProcessTree {
    param([Parameter(Mandatory = $true)][int] $ProcessId)
    try {
        $process = [System.Diagnostics.Process]::GetProcessById($ProcessId)
    }
    catch [System.ArgumentException] {
        return
    }

    try {
        try {
            $process.Kill($true)
        }
        catch [System.InvalidOperationException] {
            if ($process.HasExited) { return }
            throw
        }
        if (-not $process.WaitForExit(5000)) {
            throw "Process tree rooted at PID $ProcessId did not stop within 5000 ms."
        }
    }
    finally {
        $process.Dispose()
    }
}

function Merge-UnrealCommandLogs {
    param(
        [Parameter(Mandatory = $true)][string] $StdOutPath,
        [Parameter(Mandatory = $true)][string] $StdErrPath,
        [Parameter(Mandatory = $true)][string] $LogPath
    )
    $encoding = [System.Text.UTF8Encoding]::new($false)
    $destination = [System.IO.File]::Open($LogPath, [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write, [System.IO.FileShare]::Read)
    try {
        foreach ($entry in @(
            [pscustomobject]@{ Header = "--- stdout ---`n"; Path = $StdOutPath }
            [pscustomobject]@{ Header = "`n--- stderr ---`n"; Path = $StdErrPath }
        )) {
            $headerBytes = $encoding.GetBytes($entry.Header)
            $destination.Write($headerBytes, 0, $headerBytes.Length)
            if (Test-Path -LiteralPath $entry.Path -PathType Leaf) {
                $source = [System.IO.File]::Open($entry.Path, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
                try { $source.CopyTo($destination) }
                finally { $source.Dispose() }
            }
        }
    }
    finally { $destination.Dispose() }
}

function Invoke-UnrealNativeProcess {
    param([Parameter(Mandatory = $true)] $Request, [Parameter(Mandatory = $true)][string] $MetadataPath)
    $paths = $Request.paths
    $startInfo = [System.Diagnostics.ProcessStartInfo]::new()
    $startInfo.FileName = [string] $Request.filePath
    $startInfo.WorkingDirectory = [string] $Request.workingDirectory
    $startInfo.UseShellExecute = $false
    $startInfo.CreateNoWindow = $true
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    foreach ($argument in @($Request.arguments)) { [void] $startInfo.ArgumentList.Add([string] $argument) }
    foreach ($property in @($Request.environment.PSObject.Properties)) { $startInfo.Environment[$property.Name] = [string] $property.Value }
    $startInfo.Environment['HARDNESS_UNREAL_RUN_ID'] = [string] $Request.runId

    $stdoutStream = [System.IO.File]::Open([string] $paths.StdOutPath, [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write, [System.IO.FileShare]::Read)
    $stderrStream = [System.IO.File]::Open([string] $paths.StdErrPath, [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write, [System.IO.FileShare]::Read)
    $process = [System.Diagnostics.Process]::new()
    $process.StartInfo = $startInfo
    $timer = [System.Diagnostics.Stopwatch]::StartNew()
    try {
        if (-not $process.Start()) { throw "Unable to start native process: $($Request.filePath)" }
        [void](Update-UnrealRunMetadata -Path $MetadataPath -Changes @{ nativePid = $process.Id; nativeStartedAtUtc = [DateTimeOffset]::UtcNow.ToString('o') })
        $stdoutCopy = $process.StandardOutput.BaseStream.CopyToAsync($stdoutStream)
        $stderrCopy = $process.StandardError.BaseStream.CopyToAsync($stderrStream)
        $remaining = Get-UnrealRemainingTimeout -Request $Request
        $timedOut = $remaining -le 0 -or -not $process.WaitForExit($remaining)
        if ($timedOut) {
            Stop-UnrealProcessTree -ProcessId $process.Id
            [void] $process.WaitForExit(10000)
        }
        [void] $stdoutCopy.GetAwaiter().GetResult()
        [void] $stderrCopy.GetAwaiter().GetResult()
        $exitCode = if ($timedOut) { 2 } else { [int] $process.ExitCode }
        return [pscustomobject]@{ ExitCode = $exitCode; TimedOut = $timedOut; DurationMs = $timer.ElapsedMilliseconds }
    }
    finally {
        $timer.Stop()
        $stdoutStream.Dispose()
        $stderrStream.Dispose()
        $process.Dispose()
        Merge-UnrealCommandLogs -StdOutPath ([string] $paths.StdOutPath) -StdErrPath ([string] $paths.StdErrPath) -LogPath ([string] $paths.LogPath)
    }
}

function Invoke-UnrealRequestWorker {
    param([Parameter(Mandatory = $true)][string] $RequestPath)
    Assert-UnrealPowerShell
    $request = Read-UnrealJsonFile -Path $RequestPath
    if ([string] $request.schemaVersion -ne $script:UnrealRequestSchema) { throw "Unsupported Unreal request schema: $($request.schemaVersion)" }
    $paths = Get-UnrealRunPaths -WorkspaceRoot ([string] $request.workspaceRoot) -RunId ([string] $request.runId)
    if (-not (Test-UnrealPathEqual -Left $paths.RequestPath -Right $RequestPath)) { throw "Request path does not match its contained run identity: $RequestPath" }
    Assert-UnrealRequestPaths -Request $request -ExpectedPaths $paths
    [void](Get-UnrealWorkspaceConfiguration -WorkspaceRoot ([string] $request.workspaceRoot) -RequireExecutionGuard -CallerPath ([string] $request.workspaceRoot))

    $workspaceLease = $null
    $engineLease = $null
    $started = [DateTimeOffset]::UtcNow
    try {
        [void](Update-UnrealRunMetadata -Path $paths.MetadataPath -Changes @{ state = 'WaitingWorkspace' })
        $workspaceLease = Enter-UnrealLease -Scope 'workspace' -Key ([string] $request.workspaceRoot) -Policy ([string] $request.concurrency.policy) -TimeoutMs (Get-UnrealRemainingTimeout -Request $request)
        if ($null -eq $workspaceLease) {
            $state = if ([string] $request.concurrency.policy -eq 'Fail') { 'Failed' } else { 'TimedOut' }
            $code = if ($state -eq 'TimedOut') { 2 } else { 4 }
            return Update-UnrealRunMetadata -Path $paths.MetadataPath -Changes @{ state = $state; exitCode = $code; timedOut = $state -eq 'TimedOut'; completedAtUtc = [DateTimeOffset]::UtcNow.ToString('o'); message = 'Workspace lease was not acquired.' }
        }
        if ([bool] $request.concurrency.requiresEngineLease) {
            [void](Update-UnrealRunMetadata -Path $paths.MetadataPath -Changes @{ state = 'WaitingEngine' })
            $engineLane = if ($null -eq $request.concurrency.PSObject.Properties['engineLane']) { 'Exclusive' } else { [string] $request.concurrency.engineLane }
            if ($engineLane -notin @('Shared', 'Exclusive')) { throw "Run engine lane is invalid: $engineLane" }
            $engineLease = Enter-UnrealEngineLane `
                -EngineRoot ([string] $request.engineRoot) `
                -Mode $engineLane `
                -Policy ([string] $request.concurrency.policy) `
                -TimeoutMs (Get-UnrealRemainingTimeout -Request $request)
            if ($null -eq $engineLease) {
                $state = if ([string] $request.concurrency.policy -eq 'Fail') { 'Failed' } else { 'TimedOut' }
                $code = if ($state -eq 'TimedOut') { 2 } else { 5 }
                return Update-UnrealRunMetadata -Path $paths.MetadataPath -Changes @{ state = $state; exitCode = $code; timedOut = $state -eq 'TimedOut'; completedAtUtc = [DateTimeOffset]::UtcNow.ToString('o'); message = "$engineLane engine lane was not acquired." }
            }
        }
        [void](Update-UnrealRunMetadata -Path $paths.MetadataPath -Changes @{ state = 'Running' })
        $result = if ([string] $request.operation -eq 'Suite') {
            Invoke-UnrealSuiteRequest -Request $request -MetadataPath $paths.MetadataPath
        }
        else {
            Invoke-UnrealNativeProcess -Request $request -MetadataPath $paths.MetadataPath
        }
        $effectiveExitCode = [int] $result.ExitCode
        $automationSummary = $null
        $uhtConflict = $null
        if ([string] $request.operation -eq 'Test' -and [bool] $request.enforceAutomationReport) {
            $automationSummary = Get-UnrealAutomationSummary `
                -ReportPath ([string] $paths.ReportPath) `
                -LogPath ([string] $paths.UnrealLogPath) `
                -ProcessExitCode ([int] $result.ExitCode)
            Write-UnrealJsonFileAtomic -Path ([string] $paths.SummaryPath) -Value $automationSummary
            if (-not $automationSummary.Passed -and -not $result.TimedOut -and $effectiveExitCode -eq 0) {
                $effectiveExitCode = 6
            }
        }
        if ([string] $request.operation -eq 'Build') {
            $uhtConflict = Get-UnrealSharedEngineUhtTimestampConflict -Paths $paths -EngineRoot ([string] $request.engineRoot)
            if ($uhtConflict.Detected -and -not $result.TimedOut -and $effectiveExitCode -eq 0) {
                $effectiveExitCode = 7
            }
        }
        $state = if ($result.TimedOut) {
            'TimedOut'
        }
        elseif ($null -ne $uhtConflict -and $uhtConflict.Detected) {
            'Failed'
        }
        elseif ($null -ne $automationSummary -and -not $automationSummary.Passed) {
            'Failed'
        }
        elseif ($effectiveExitCode -eq 0) {
            'Succeeded'
        }
        else {
            'Failed'
        }
        $message = if ($result.TimedOut) {
            'Native process exceeded the total timeout.'
        }
        elseif ($null -ne $uhtConflict -and $uhtConflict.Detected) {
            'Shared-engine UHT Timestamp contention was detected in contained build evidence. Retry with -BuildConcurrency Serialize or use a dedicated EngineRoot.'
        }
        elseif ($null -ne $automationSummary -and -not $automationSummary.Passed) {
            $reasonText = @($automationSummary.Reasons | ForEach-Object { [string] $_ }) -join '; '
            if ([string]::IsNullOrWhiteSpace($reasonText)) { "UE Automation result is $($automationSummary.Outcome)." } else { $reasonText }
        }
        elseif ($null -ne $result.PSObject.Properties['Message'] -and -not [string]::IsNullOrWhiteSpace([string] $result.Message)) {
            [string] $result.Message
        }
        elseif ($effectiveExitCode -eq 0) {
            ''
        }
        else {
            "Native process exited with code $effectiveExitCode."
        }
        return Update-UnrealRunMetadata -Path $paths.MetadataPath -Changes @{ state = $state; exitCode = $effectiveExitCode; timedOut = [bool] $result.TimedOut; durationMs = [long] $result.DurationMs; completedAtUtc = [DateTimeOffset]::UtcNow.ToString('o'); message = $message }
    }
    catch {
        return Update-UnrealRunMetadata -Path $paths.MetadataPath -Changes @{ state = 'Failed'; exitCode = 1; completedAtUtc = [DateTimeOffset]::UtcNow.ToString('o'); durationMs = [long] ([DateTimeOffset]::UtcNow - $started).TotalMilliseconds; message = $_.Exception.Message }
    }
    finally {
        Exit-UnrealEngineLane -Lease $engineLease
        Exit-UnrealLease -Lease $workspaceLease
    }
}

function Get-UnrealProcessRecordById {
    param([Parameter(Mandatory = $true)][int] $ProcessId)
    try { return Get-CimInstance Win32_Process -Filter "ProcessId = $ProcessId" -ErrorAction Stop | Select-Object -First 1 }
    catch { return $null }
}

function Stop-HardnessUnrealRun {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory = $true)][string] $WorkspaceRoot,
        [Parameter(Mandatory = $true)][string] $RunId
    )
    $configuration = Get-UnrealWorkspaceConfiguration -WorkspaceRoot $WorkspaceRoot -RequireExecutionGuard -CallerPath $WorkspaceRoot
    $status = Get-UnrealRunStatusRecord -WorkspaceRoot $configuration.WorkspaceRoot -RunId $RunId
    if ($status.RecordedState -in $script:UnrealTerminalStates) { return $status }
    $paths = Get-UnrealRunPaths -WorkspaceRoot $configuration.WorkspaceRoot -RunId $RunId
    $metadata = Read-UnrealJsonFile -Path $paths.MetadataPath
    $workerId = 0
    if ($null -ne $metadata.workerPid) { [void][int]::TryParse([string] $metadata.workerPid, [ref] $workerId) }
    if ($workerId -gt 0) {
        $record = Get-UnrealProcessRecordById -ProcessId $workerId
        if ($null -ne $record) {
            $commandLine = [string] $record.CommandLine
            if ($commandLine -notmatch 'Invoke-UnrealRunWorker\.ps1' -or $commandLine.IndexOf($RunId, [System.StringComparison]::OrdinalIgnoreCase) -lt 0) {
                throw "Recorded worker PID $workerId does not match run '$RunId'; refusing cancellation."
            }
            if ($PSCmdlet.ShouldProcess("run $RunId (worker PID $workerId)", 'stop Unreal run process tree')) { Stop-UnrealProcessTree -ProcessId $workerId }
            else { return $status }
        }
    }
    [void](Update-UnrealRunMetadata -Path $paths.MetadataPath -Changes @{ state = 'Cancelled'; exitCode = 3; completedAtUtc = [DateTimeOffset]::UtcNow.ToString('o'); message = 'Run cancelled by explicit request.' })
    return Get-UnrealRunStatusRecord -WorkspaceRoot $configuration.WorkspaceRoot -RunId $RunId
}
