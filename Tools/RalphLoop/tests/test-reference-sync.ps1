param()

$ErrorActionPreference = 'Stop'

. "$PSScriptRoot\test-helpers.ps1"

function New-TestGitRepo {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [string]$FileName,

        [Parameter(Mandatory = $true)]
        [string]$Content
    )

    New-Item -ItemType Directory -Path $Path -Force | Out-Null
    Set-Content -Path (Join-Path $Path $FileName) -Value $Content -Encoding UTF8
    & git -c init.defaultBranch=main init $Path | Out-Null
    & git -C $Path add $FileName | Out-Null
    & git -C $Path -c user.name=codexloop -c user.email=codexloop@example.com commit -m "init" | Out-Null

    if ($LASTEXITCODE -ne 0) {
        throw "Failed to create test git repository at $Path"
    }
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$tmpRoot = Join-Path $PSScriptRoot '.tmp\reference-sync'
$sourceRoot = Join-Path $tmpRoot 'reference-sources'
$manifestPath = Join-Path $tmpRoot 'reference-manifest.psd1'
$destinationRoot = Join-Path $repoRoot 'Temp\reference-sync-tests\references'

Remove-Item -Path $tmpRoot -Recurse -Force -ErrorAction SilentlyContinue

if (Test-Path (Join-Path $repoRoot 'Temp\reference-sync-tests')) {
    Remove-Item -Path (Join-Path $repoRoot 'Temp\reference-sync-tests') -Recurse -Force
}

New-Item -ItemType Directory -Path $sourceRoot -Force | Out-Null

$repoOne = Join-Path $sourceRoot 'repo-one'
$repoTwo = Join-Path $sourceRoot 'repo-two'
New-TestGitRepo -Path $repoOne -FileName 'README.md' -Content '# repo one'
New-TestGitRepo -Path $repoTwo -FileName 'NOTES.md' -Content '# repo two'

$manifestText = @"
@{
    Repositories = @(
        @{
            Name = 'repo-one'
            Url  = '$($repoOne.Replace("'", "''"))'
            Path = 'repo-one'
        }
        @{
            Name = 'repo-two'
            Url  = '$($repoTwo.Replace("'", "''"))'
            Path = 'repo-two'
        }
    )
}
"@

Set-Content -Path $manifestPath -Value $manifestText -Encoding UTF8

$firstRunOutput = (& pwsh -NoProfile -ExecutionPolicy Bypass -File "$repoRoot\sync-references.ps1" -ManifestPath $manifestPath -DestinationRoot $destinationRoot | Out-String)
$firstRunExitCode = $LASTEXITCODE

Assert-Equal '0' "$firstRunExitCode" 'First reference sync run should succeed.'
Assert-True (Test-Path (Join-Path $destinationRoot 'repo-one\.git')) 'First reference repo should be cloned.'
Assert-True (Test-Path (Join-Path $destinationRoot 'repo-two\.git')) 'Second reference repo should be cloned.'
Assert-True (-not $destinationRoot.StartsWith((Join-Path $repoRoot 'tests\.tmp'), [System.StringComparison]::OrdinalIgnoreCase)) 'Reference destination must stay outside tests/.tmp.'
Assert-True (-not $destinationRoot.StartsWith((Join-Path $repoRoot '.codexloop'), [System.StringComparison]::OrdinalIgnoreCase)) 'Reference destination must stay outside .codexloop.'
Assert-True ($firstRunOutput -match '"status":\s+"cloned"') 'First sync run should report cloned repositories.'

$secondRunOutput = (& pwsh -NoProfile -ExecutionPolicy Bypass -File "$repoRoot\sync-references.ps1" -ManifestPath $manifestPath -DestinationRoot $destinationRoot | Out-String)
$secondRunExitCode = $LASTEXITCODE

Assert-Equal '0' "$secondRunExitCode" 'Second reference sync run should succeed.'
Assert-True ($secondRunOutput -match '"status":\s+"updated"') 'Second sync run should report updated repositories.'

$escapeManifestPath = Join-Path $tmpRoot 'reference-manifest-escape.psd1'
$escapeManifestText = @"
@{
    Repositories = @(
        @{
            Name = 'escape-repo'
            Url  = '$($repoOne.Replace("'", "''"))'
            Path = '..\escape-repo'
        }
    )
}
"@

Set-Content -Path $escapeManifestPath -Value $escapeManifestText -Encoding UTF8

$escapeOutput = (& pwsh -NoProfile -ExecutionPolicy Bypass -File "$repoRoot\sync-references.ps1" -ManifestPath $escapeManifestPath -DestinationRoot $destinationRoot 2>&1 | Out-String)
$escapeExitCode = $LASTEXITCODE

Assert-True ($escapeExitCode -ne 0) 'Reference sync should reject manifest paths that escape DestinationRoot.'
Assert-True ($escapeOutput -match 'must stay within DestinationRoot') 'Reference sync should explain the path-escape rejection.'

Write-Output 'reference sync tests passed'
