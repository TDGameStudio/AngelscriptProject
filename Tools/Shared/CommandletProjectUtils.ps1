Set-StrictMode -Version Latest

function Resolve-AngelscriptCommandletProjectContext {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot,

        [Parameter(Mandatory = $true)]
        [string]$ConfiguredProjectFile,

        [string]$ProjectFileOverride = ''
    )

    $normalizedRepositoryRoot = [System.IO.Path]::GetFullPath(
        $RepositoryRoot.Trim().Trim('"')).TrimEnd('\', '/')
    $selectedProjectFile = if ([string]::IsNullOrWhiteSpace($ProjectFileOverride)) {
        $ConfiguredProjectFile
    }
    else {
        $ProjectFileOverride
    }
    $selectedProjectFile = $selectedProjectFile.Trim().Trim('"')
    if (-not [System.IO.Path]::IsPathRooted($selectedProjectFile)) {
        $selectedProjectFile = Join-Path $normalizedRepositoryRoot $selectedProjectFile
    }
    $selectedProjectFile = [System.IO.Path]::GetFullPath($selectedProjectFile)

    if (-not [string]::Equals(
            [System.IO.Path]::GetExtension($selectedProjectFile),
            '.uproject',
            [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Commandlet project must be a .uproject file: $selectedProjectFile"
    }
    if (-not (Test-Path -LiteralPath $selectedProjectFile -PathType Leaf)) {
        throw "Commandlet project was not found: $selectedProjectFile"
    }

    $selectedProjectRoot = Split-Path -Parent $selectedProjectFile
    return [PSCustomObject]@{
        RepositoryRoot = $normalizedRepositoryRoot
        ProjectFile = $selectedProjectFile
        ProjectRoot = $selectedProjectRoot
        TargetInfoPath = Join-Path $selectedProjectRoot 'Intermediate\TargetInfo.json'
        IsOverride = -not [string]::IsNullOrWhiteSpace($ProjectFileOverride)
    }
}

function New-AngelscriptCommandletArgumentList {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProjectFile,

        [Parameter(Mandatory = $true)]
        [string]$Commandlet,

        [Parameter(Mandatory = $true)]
        [string]$LogPath,

        [switch]$Render,

        [string[]]$ExtraArgs = @()
    )

    $arguments = @(
        $ProjectFile
        "-run=$Commandlet"
        '-BUILDMACHINE'
        '-Unattended'
        '-NoPause'
        '-NoSplash'
        '-stdout'
        '-FullStdOutLogOutput'
        '-UTF8Output'
        "-ABSLOG=$LogPath"
        '-NOSOUND'
    )
    if (-not $Render) {
        $arguments += '-NullRHI'
    }
    if ($null -ne $ExtraArgs -and $ExtraArgs.Count -gt 0) {
        $arguments += $ExtraArgs
    }
    return @($arguments)
}

function Resolve-AngelscriptCommandletExtraArguments {
    param(
        [string[]]$InlineArguments = @(),

        [string]$ArgumentsFile = ''
    )

    $resolvedArguments = @($InlineArguments)
    if ([string]::IsNullOrWhiteSpace($ArgumentsFile)) {
        return @($resolvedArguments)
    }

    $normalizedArgumentsFile = [System.IO.Path]::GetFullPath(
        $ArgumentsFile.Trim().Trim('"'))
    if (-not (Test-Path -LiteralPath $normalizedArgumentsFile -PathType Leaf)) {
        throw "Commandlet extra-arguments file was not found: $normalizedArgumentsFile"
    }

    try {
        $parsedArguments = Get-Content -LiteralPath $normalizedArgumentsFile -Raw -Encoding UTF8 |
            ConvertFrom-Json
    }
    catch {
        throw "Commandlet extra-arguments file is not valid JSON: $normalizedArgumentsFile"
    }
    $fileArguments = if ($parsedArguments -is [System.Array]) {
        $parsedArguments
    }
    else {
        @($parsedArguments)
    }
    foreach ($fileArgument in $fileArguments) {
        if ($fileArgument -isnot [string] -or [string]::IsNullOrWhiteSpace($fileArgument)) {
            throw "Commandlet extra-arguments file must contain only non-empty strings: $normalizedArgumentsFile"
        }
        $resolvedArguments += [string]$fileArgument
    }
    return @($resolvedArguments)
}

function Resolve-AngelscriptCommandletExitCode {
    param(
        [int]$ProcessExitCode,
        [switch]$TimedOut
    )

    if ($TimedOut) {
        return 2
    }
    if ($ProcessExitCode -eq 0) {
        return 0
    }
    return 1
}
