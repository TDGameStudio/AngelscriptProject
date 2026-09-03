function Assert-UnrealPowerShell {
    if ($PSVersionTable.PSEdition -ne 'Core' -or $PSVersionTable.PSVersion.Major -lt 7) {
        throw 'unreal-engine-develop requires PowerShell 7 Core or later.'
    }
}

function ConvertTo-UnrealCanonicalPath {
    param(
        [Parameter(Mandatory = $true)][string] $Path,
        [switch] $AllowMissing
    )

    if ([string]::IsNullOrWhiteSpace($Path)) {
        throw 'Path cannot be empty.'
    }
    try {
        $fullPath = [System.IO.Path]::GetFullPath($Path).TrimEnd('\', '/')
    }
    catch {
        throw "Path is invalid: $Path"
    }
    if (-not $AllowMissing -and -not (Test-Path -LiteralPath $fullPath)) {
        throw "Path does not exist: $fullPath"
    }
    return $fullPath
}

function Test-UnrealPathEqual {
    param(
        [Parameter(Mandatory = $true)][string] $Left,
        [Parameter(Mandatory = $true)][string] $Right
    )
    $leftPath = ConvertTo-UnrealCanonicalPath -Path $Left -AllowMissing
    $rightPath = ConvertTo-UnrealCanonicalPath -Path $Right -AllowMissing
    return $leftPath.Equals($rightPath, [System.StringComparison]::OrdinalIgnoreCase)
}

function Assert-UnrealPathContained {
    param(
        [Parameter(Mandatory = $true)][string] $Root,
        [Parameter(Mandatory = $true)][string] $Path,
        [string] $Purpose = 'Unreal path'
    )
    $rootPath = ConvertTo-UnrealCanonicalPath -Path $Root -AllowMissing
    $targetPath = ConvertTo-UnrealCanonicalPath -Path $Path -AllowMissing
    $prefix = $rootPath + [System.IO.Path]::DirectorySeparatorChar
    if (-not (Test-UnrealPathEqual -Left $rootPath -Right $targetPath) -and
        -not $targetPath.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "$Purpose escapes its allowed root '$rootPath': $targetPath"
    }
    return $targetPath
}

function Read-UnrealJsonFile {
    param([Parameter(Mandatory = $true)][string] $Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "JSON file was not found: $Path"
    }
    try {
        return Get-Content -LiteralPath $Path -Raw -Encoding UTF8 | ConvertFrom-Json -Depth 100 -ErrorAction Stop
    }
    catch {
        throw "JSON file is invalid '$Path': $($_.Exception.Message)"
    }
}

function Write-UnrealJsonFileAtomic {
    param(
        [Parameter(Mandatory = $true)][string] $Path,
        [Parameter(Mandatory = $true)] $Value
    )
    $directory = Split-Path -Parent $Path
    if ([string]::IsNullOrWhiteSpace($directory)) {
        throw "JSON output requires a parent directory: $Path"
    }
    [void][System.IO.Directory]::CreateDirectory($directory)
    $temporary = Join-Path $directory ('.{0}.{1}.tmp' -f [System.IO.Path]::GetFileName($Path), [guid]::NewGuid().ToString('N'))
    try {
        $json = $Value | ConvertTo-Json -Depth 100
        [System.IO.File]::WriteAllText($temporary, $json, [System.Text.UTF8Encoding]::new($false))
        [System.IO.File]::Move($temporary, $Path, $true)
    }
    finally {
        if (Test-Path -LiteralPath $temporary -PathType Leaf) {
            Remove-Item -LiteralPath $temporary -Force
        }
    }
}

function Get-UnrealDataDocument {
    param([Parameter(Mandatory = $true)][ValidatePattern('^[A-Za-z0-9.-]+\.json$')][string] $Name)
    return Read-UnrealJsonFile -Path (Join-Path $script:UnrealDataRoot $Name)
}

function Import-UnrealWorkspaceModule {
    $manifest = Join-Path $script:UnrealSkillRoot '../workspace-lifecycle/scripts/WorkspaceLifecycle.psd1'
    $manifest = [System.IO.Path]::GetFullPath($manifest)
    if (-not (Test-Path -LiteralPath $manifest -PathType Leaf)) {
        throw "workspace-lifecycle module was not found: $manifest"
    }
    Import-Module $manifest -ErrorAction Stop
    return Get-Module WorkspaceLifecycle -ErrorAction Stop
}

function Get-UnrealWorkspaceConfiguration {
    param(
        [Parameter(Mandatory = $true)][string] $WorkspaceRoot,
        [switch] $RequireExecutionGuard,
        [string] $CallerPath = ''
    )

    Assert-UnrealPowerShell
    $workspaceModule = Import-UnrealWorkspaceModule
    $valuesCommand = $workspaceModule.ExportedCommands['Get-HarnessWorkspaceConfigValues']
    if ($null -eq $valuesCommand) {
        throw 'workspace-lifecycle does not expose the required batched configuration API.'
    }
    $root = ConvertTo-UnrealCanonicalPath -Path $WorkspaceRoot
    $entries = @(
        [pscustomobject]@{ Section = 'Paths'; Key = 'EngineRoot' }
        [pscustomobject]@{ Section = 'Paths'; Key = 'ProjectFile' }
        [pscustomobject]@{ Section = 'Build'; Key = 'EditorTarget' }
        [pscustomobject]@{ Section = 'Build'; Key = 'Platform' }
        [pscustomobject]@{ Section = 'Build'; Key = 'Configuration' }
        [pscustomobject]@{ Section = 'Build'; Key = 'Architecture' }
        [pscustomobject]@{ Section = 'Build'; Key = 'DefaultTimeoutMs' }
        [pscustomobject]@{ Section = 'Test'; Key = 'DefaultTimeoutMs' }
    )
    $snapshotParameters = @{
        ProjectRoot = $root
        Entries     = $entries
    }
    if ($RequireExecutionGuard) {
        $snapshotParameters.RequireExecutionGuard = $true
        $snapshotParameters.CallerPath = $CallerPath
    }
    $snapshot = & $valuesCommand @snapshotParameters

    $values = @{}
    foreach ($result in @($snapshot.Values)) {
        $values["$($result.Section).$($result.Key)"] = if ($result.Exists) { [string] $result.Value } else { '' }
    }

    $projectFile = [string] $values['Paths.ProjectFile']
    if ([string]::IsNullOrWhiteSpace($projectFile) -or -not (Test-Path -LiteralPath $projectFile -PathType Leaf)) {
        throw "AgentConfig.ini Paths.ProjectFile is missing or invalid for '$root'."
    }
    [void](Assert-UnrealPathContained -Root $root -Path $projectFile -Purpose 'Configured project file')

    return [pscustomobject][ordered]@{
        WorkspaceRoot         = $root
        Identity              = $snapshot.Identity
        ConfigPath            = $snapshot.ConfigPath
        ProjectFile           = ConvertTo-UnrealCanonicalPath -Path $projectFile
        EngineRoot            = [string] $values['Paths.EngineRoot']
        EditorTarget          = [string] $values['Build.EditorTarget']
        Platform              = [string] $values['Build.Platform']
        Configuration         = [string] $values['Build.Configuration']
        Architecture          = [string] $values['Build.Architecture']
        BuildDefaultTimeoutMs = [string] $values['Build.DefaultTimeoutMs']
        TestDefaultTimeoutMs  = [string] $values['Test.DefaultTimeoutMs']
    }
}

function Resolve-UnrealPositiveTimeout {
    param(
        [int] $TimeoutMs,
        [string] $ConfiguredValue,
        [int] $FallbackMs,
        [int] $MaximumMs = 3600000
    )
    $candidate = $TimeoutMs
    if ($candidate -le 0 -and -not [string]::IsNullOrWhiteSpace($ConfiguredValue)) {
        $parsed = 0
        if ([int]::TryParse($ConfiguredValue, [ref] $parsed)) {
            $candidate = $parsed
        }
    }
    if ($candidate -le 0) {
        $candidate = $FallbackMs
    }
    if ($candidate -le 0 -or $candidate -gt $MaximumMs) {
        throw "TimeoutMs must be between 1 and $MaximumMs; received $candidate."
    }
    return $candidate
}

function Assert-UnrealArgumentArray {
    param([AllowEmptyCollection()][string[]] $Arguments)
    foreach ($argument in @($Arguments)) {
        if ($null -eq $argument -or $argument.Contains([char] 0) -or $argument.Contains("`r") -or $argument.Contains("`n")) {
            throw 'Native arguments must be non-null single-line strings without NUL characters.'
        }
    }
}
