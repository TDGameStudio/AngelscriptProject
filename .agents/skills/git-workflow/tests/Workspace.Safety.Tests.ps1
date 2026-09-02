[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) {
        throw "Assertion failed: $Message"
    }
}

function Assert-Equal {
    param($Expected, $Actual, [string]$Message)
    if ($Expected -ne $Actual) {
        throw "Assertion failed: $Message (expected '$Expected', actual '$Actual')"
    }
}

function Assert-ThrowsMatch {
    param([scriptblock]$Action, [string]$Pattern, [string]$Message)
    $caught = $null
    try {
        & $Action
    }
    catch {
        $caught = $_
    }
    if ($null -eq $caught -or $caught.Exception.Message -notmatch $Pattern) {
        $actual = if ($null -eq $caught) { '<no exception>' } else { $caught.Exception.Message }
        throw "Assertion failed: $Message (actual '$actual')"
    }
}

function Assert-BytesEqual {
    param([byte[]]$Expected, [byte[]]$Actual, [string]$Message)
    $same = $Expected.Length -eq $Actual.Length
    if ($same) {
        for ($index = 0; $index -lt $Expected.Length; $index++) {
            if ($Expected[$index] -ne $Actual[$index]) {
                $same = $false
                break
            }
        }
    }
    Assert-True $same $Message
}

function Invoke-TestGit {
    param(
        [Parameter(Mandatory = $true)][string]$Repository,
        [Parameter(Mandatory = $true)][string[]]$Arguments,
        [switch]$AllowFailure
    )

    $oldAllow = $env:GIT_ALLOW_PROTOCOL
    $oldPreference = $ErrorActionPreference
    $env:GIT_ALLOW_PROTOCOL = 'file'
    $ErrorActionPreference = 'Continue'
    try {
        $output = & git -C $Repository @Arguments 2>&1
        $exitCode = $LASTEXITCODE
    }
    finally {
        $env:GIT_ALLOW_PROTOCOL = $oldAllow
        $ErrorActionPreference = $oldPreference
    }
    if (-not $AllowFailure -and $exitCode -ne 0) {
        throw "git -C '$Repository' $($Arguments -join ' ') failed ($exitCode): $($output -join [Environment]::NewLine)"
    }
    return [pscustomobject]@{ ExitCode = $exitCode; Output = @($output | ForEach-Object { [string]$_ }) }
}

function Initialize-TestRepository {
    param([Parameter(Mandatory = $true)][string]$Path)

    [void](New-Item -ItemType Directory -Path $Path -Force)
    & git -C $Path init --initial-branch=main 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        & git -C $Path init 2>&1 | Out-Null
        [void](Invoke-TestGit -Repository $Path -Arguments @('checkout', '-b', 'main'))
    }
    [void](Invoke-TestGit -Repository $Path -Arguments @('config', 'user.name', 'Hardness Safety Fixture'))
    [void](Invoke-TestGit -Repository $Path -Arguments @('config', 'user.email', 'hardness-safety@example.invalid'))
}

function New-SimpleParentFixture {
    param([Parameter(Mandatory = $true)][string]$FixtureRoot)

    $parent = Join-Path $FixtureRoot 'parent'
    Initialize-TestRepository -Path $parent
    [System.IO.File]::WriteAllText((Join-Path $parent '.gitignore'), ".worktrees/`nlocal.payload`n")
    [System.IO.File]::WriteAllText((Join-Path $parent 'README.md'), "fixture`n")
    [void](Invoke-TestGit -Repository $parent -Arguments @('add', '.gitignore', 'README.md'))
    [void](Invoke-TestGit -Repository $parent -Arguments @('commit', '-m', 'parent base'))
    return $parent
}

function New-SubmoduleFixture {
    param([Parameter(Mandatory = $true)][string]$FixtureRoot)

    $child = Join-Path $FixtureRoot 'child'
    $parent = Join-Path $FixtureRoot 'parent'
    Initialize-TestRepository -Path $child
    [System.IO.File]::WriteAllText((Join-Path $child 'stable.txt'), "stable`n")
    [void](Invoke-TestGit -Repository $child -Arguments @('add', 'stable.txt'))
    [void](Invoke-TestGit -Repository $child -Arguments @('commit', '-m', 'child A'))
    $commitA = ((Invoke-TestGit -Repository $child -Arguments @('rev-parse', 'HEAD')).Output | Select-Object -Last 1).Trim()
    [System.IO.File]::WriteAllText((Join-Path $child 'later.txt'), "later`n")
    [void](Invoke-TestGit -Repository $child -Arguments @('add', 'later.txt'))
    [void](Invoke-TestGit -Repository $child -Arguments @('commit', '-m', 'child B'))
    $commitB = ((Invoke-TestGit -Repository $child -Arguments @('rev-parse', 'HEAD')).Output | Select-Object -Last 1).Trim()

    Initialize-TestRepository -Path $parent
    [System.IO.File]::WriteAllText((Join-Path $parent '.gitignore'), ".worktrees/`n")
    [System.IO.File]::WriteAllText((Join-Path $parent 'README.md'), "fixture`n")
    [void](Invoke-TestGit -Repository $parent -Arguments @('add', '.gitignore', 'README.md'))
    [void](Invoke-TestGit -Repository $parent -Arguments @('commit', '-m', 'parent base'))
    [void](Invoke-TestGit -Repository $parent -Arguments @('-c', 'protocol.file.allow=always', 'submodule', 'add', '--name', 'sdk', $child, 'Modules/Child'))
    $parentChild = Join-Path $parent 'Modules/Child'
    [void](Invoke-TestGit -Repository $parentChild -Arguments @('checkout', '--detach', $commitA))
    [void](Invoke-TestGit -Repository $parent -Arguments @('add', '.gitmodules', 'Modules/Child'))
    [void](Invoke-TestGit -Repository $parent -Arguments @('commit', '-m', 'pin child A'))

    return [pscustomobject]@{ Parent = $parent; Child = $child; CommitA = $commitA; CommitB = $commitB }
}

function Remove-JunctionOnly {
    param([Parameter(Mandatory = $true)][string]$Path)

    if (Test-Path -LiteralPath $Path) {
        $item = Get-Item -LiteralPath $Path -Force
        if (($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
            [System.IO.Directory]::Delete($Path)
        }
    }
}

function Remove-TestFixture {
    param([Parameter(Mandatory = $true)][string]$FixtureRoot)

    if (-not (Test-Path -LiteralPath $FixtureRoot)) {
        return
    }
    foreach ($item in @(Get-ChildItem -LiteralPath $FixtureRoot -Recurse -Force -ErrorAction SilentlyContinue | Sort-Object FullName -Descending)) {
        if (($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
            if ($item.PSIsContainer) {
                [System.IO.Directory]::Delete($item.FullName)
            }
            else {
                [System.IO.File]::Delete($item.FullName)
            }
        }
    }
    Remove-Item -LiteralPath $FixtureRoot -Recurse -Force -ErrorAction SilentlyContinue
}

$manifest = Join-Path $PSScriptRoot '..\scripts\Workspace.psd1'
$moduleFile = Join-Path $PSScriptRoot '..\scripts\Workspace.psm1'
$tokens = $null
$parseErrors = $null
[void][System.Management.Automation.Language.Parser]::ParseFile($moduleFile, [ref]$tokens, [ref]$parseErrors)
Assert-Equal 0 @($parseErrors).Count 'Workspace.psm1 must parse without errors'
Import-Module $manifest -Force
$workspaceModule = Get-Module Workspace

$regressions = @(
    [pscustomobject]@{
        Name = 'pre-existing junction container is rejected before create'
        Action = {
            $fixture = Join-Path ([System.IO.Path]::GetTempPath()) ("hardness-junction-create-{0}" -f [guid]::NewGuid().ToString('N'))
            try {
                [void](New-Item -ItemType Directory -Path $fixture -Force)
                $parent = New-SimpleParentFixture -FixtureRoot $fixture
                $external = Join-Path $fixture 'external-container'
                [void](New-Item -ItemType Directory -Path $external -Force)
                [void](New-Item -ItemType Junction -Path (Join-Path $parent '.worktrees') -Target $external)
                Assert-ThrowsMatch {
                    New-HardnessWorkspace -Name 'escaped-physical' -RepositoryRoot $parent | Out-Null
                } 'reparse|physical|canonical' 'creation refuses a junction-backed canonical container'
                Assert-True (-not (Test-Path -LiteralPath (Join-Path $external 'escaped-physical'))) 'refused creation writes nothing through the junction'
            }
            finally {
                Remove-TestFixture -FixtureRoot $fixture
            }
        }
    },
    [pscustomobject]@{
        Name = 'post-registration junction swap is rejected before remove'
        Action = {
            $fixture = Join-Path ([System.IO.Path]::GetTempPath()) ("hardness-junction-remove-{0}" -f [guid]::NewGuid().ToString('N'))
            try {
                [void](New-Item -ItemType Directory -Path $fixture -Force)
                $parent = New-SimpleParentFixture -FixtureRoot $fixture
                $created = New-HardnessWorkspace -Name 'swapped' -RepositoryRoot $parent
                $container = Join-Path $parent '.worktrees'
                $external = Join-Path $fixture 'external-container'
                [void](New-Item -ItemType Directory -Path $external -Force)
                $externalTarget = Join-Path $external 'swapped'
                Move-Item -LiteralPath $created.WorktreeRoot -Destination $externalTarget
                Remove-Item -LiteralPath $container -Force
                [void](New-Item -ItemType Junction -Path $container -Target $external)
                $payload = Join-Path $externalTarget 'local.payload'
                [System.IO.File]::WriteAllText($payload, "preserve me`n")

                Assert-ThrowsMatch {
                    Remove-HardnessWorkspace -WorktreeRoot (Join-Path $container 'swapped') -RepositoryRoot $parent -DiscardIgnoredFiles | Out-Null
                } 'reparse|physical|canonical' 'remove refuses after the canonical container is replaced by a junction'
                Assert-True (Test-Path -LiteralPath $payload -PathType Leaf) 'refused removal preserves the external physical payload'
            }
            finally {
                Remove-TestFixture -FixtureRoot $fixture
            }
        }
    },
    [pscustomobject]@{
        Name = 'bootstrap preserves dirty tracked work and HEAD before update'
        Action = {
            $fixture = Join-Path ([System.IO.Path]::GetTempPath()) ("hardness-dirty-tracked-{0}" -f [guid]::NewGuid().ToString('N'))
            try {
                [void](New-Item -ItemType Directory -Path $fixture -Force)
                $data = New-SubmoduleFixture -FixtureRoot $fixture
                $worktree = (New-HardnessWorkspace -Name 'tracked' -RepositoryRoot $data.Parent).WorktreeRoot
                $submodule = Join-Path $worktree 'Modules/Child'
                [void](Invoke-TestGit -Repository $submodule -Arguments @('checkout', '--detach', $data.CommitB))
                $marker = Join-Path $submodule 'stable.txt'
                [System.IO.File]::AppendAllText($marker, "dirty tracked`n")
                $beforeBytes = [System.IO.File]::ReadAllBytes($marker)

                Assert-ThrowsMatch {
                    Initialize-HardnessWorkspace -ProjectRoot $worktree | Out-Null
                } 'dirty|cannot be moved|refus' 'bootstrap refuses before moving a dirty tracked submodule'
                $afterHead = ((Invoke-TestGit -Repository $submodule -Arguments @('rev-parse', 'HEAD')).Output | Select-Object -Last 1).Trim()
                Assert-Equal $data.CommitB $afterHead 'dirty tracked submodule HEAD remains unchanged'
                Assert-BytesEqual $beforeBytes ([System.IO.File]::ReadAllBytes($marker)) 'dirty tracked content remains byte-for-byte unchanged'
            }
            finally {
                Remove-TestFixture -FixtureRoot $fixture
            }
        }
    },
    [pscustomobject]@{
        Name = 'bootstrap preserves untracked work and HEAD before update'
        Action = {
            $fixture = Join-Path ([System.IO.Path]::GetTempPath()) ("hardness-dirty-untracked-{0}" -f [guid]::NewGuid().ToString('N'))
            try {
                [void](New-Item -ItemType Directory -Path $fixture -Force)
                $data = New-SubmoduleFixture -FixtureRoot $fixture
                $worktree = (New-HardnessWorkspace -Name 'untracked' -RepositoryRoot $data.Parent).WorktreeRoot
                $submodule = Join-Path $worktree 'Modules/Child'
                [void](Invoke-TestGit -Repository $submodule -Arguments @('checkout', '--detach', $data.CommitB))
                $payload = Join-Path $submodule 'untracked.bin'
                $beforeBytes = [byte[]](0, 1, 2, 13, 10, 255)
                [System.IO.File]::WriteAllBytes($payload, $beforeBytes)

                Assert-ThrowsMatch {
                    Initialize-HardnessWorkspace -ProjectRoot $worktree | Out-Null
                } 'dirty|cannot be moved|refus' 'bootstrap refuses before moving a submodule with untracked content'
                $afterHead = ((Invoke-TestGit -Repository $submodule -Arguments @('rev-parse', 'HEAD')).Output | Select-Object -Last 1).Trim()
                Assert-Equal $data.CommitB $afterHead 'untracked submodule HEAD remains unchanged'
                Assert-BytesEqual $beforeBytes ([System.IO.File]::ReadAllBytes($payload)) 'untracked content remains byte-for-byte unchanged'
            }
            finally {
                Remove-TestFixture -FixtureRoot $fixture
            }
        }
    },
    [pscustomobject]@{
        Name = 'remove refuses a clean submodule at the wrong HEAD despite ignore=all'
        Action = {
            $fixture = Join-Path ([System.IO.Path]::GetTempPath()) ("hardness-remove-wrong-head-{0}" -f [guid]::NewGuid().ToString('N'))
            try {
                [void](New-Item -ItemType Directory -Path $fixture -Force)
                $data = New-SubmoduleFixture -FixtureRoot $fixture
                $worktree = (New-HardnessWorkspace -Name 'wrong-head' -RepositoryRoot $data.Parent).WorktreeRoot
                $submodule = Join-Path $worktree 'Modules/Child'
                [void](Invoke-TestGit -Repository $submodule -Arguments @('checkout', '--detach', $data.CommitB))
                [void](Invoke-TestGit -Repository $data.Parent -Arguments @('config', 'submodule.sdk.ignore', 'all'))

                Assert-ThrowsMatch {
                    Remove-HardnessWorkspace -WorktreeRoot $worktree -RepositoryRoot $data.Parent | Out-Null
                } 'exact|expected|submodule|valid' 'remove refuses a clean non-exact submodule even when the parent hides it'
                Assert-True (Test-Path -LiteralPath $worktree -PathType Container) 'refused non-exact removal preserves the worktree'
                $afterHead = ((Invoke-TestGit -Repository $submodule -Arguments @('rev-parse', 'HEAD')).Output | Select-Object -Last 1).Trim()
                Assert-Equal $data.CommitB $afterHead 'refused non-exact removal preserves submodule HEAD'
            }
            finally {
                Remove-TestFixture -FixtureRoot $fixture
            }
        }
    },
    [pscustomobject]@{
        Name = 'remove refuses payload under a deinitialized submodule path'
        Action = {
            $fixture = Join-Path ([System.IO.Path]::GetTempPath()) ("hardness-remove-deinitialized-{0}" -f [guid]::NewGuid().ToString('N'))
            try {
                [void](New-Item -ItemType Directory -Path $fixture -Force)
                $data = New-SubmoduleFixture -FixtureRoot $fixture
                $worktree = (New-HardnessWorkspace -Name 'deinitialized' -RepositoryRoot $data.Parent).WorktreeRoot
                [void](Invoke-TestGit -Repository $worktree -Arguments @('submodule', 'deinit', '-f', '--', 'Modules/Child'))
                $submodulePath = Join-Path $worktree 'Modules/Child'
                [void](New-Item -ItemType Directory -Path $submodulePath -Force)
                $payload = Join-Path $submodulePath 'local-only.txt'
                [System.IO.File]::WriteAllText($payload, "preserve me`n")

                Assert-ThrowsMatch {
                    Remove-HardnessWorkspace -WorktreeRoot $worktree -RepositoryRoot $data.Parent | Out-Null
                } 'not initialized|payload|submodule|refus' 'remove refuses a deinitialized submodule path that contains local payload'
                Assert-True (Test-Path -LiteralPath $payload -PathType Leaf) 'refused deinitialized removal preserves local payload'
            }
            finally {
                Remove-TestFixture -FixtureRoot $fixture
            }
        }
    },
    [pscustomobject]@{
        Name = 'malicious logical names and reparse stores cannot escape modules root'
        Action = {
            $fixture = Join-Path ([System.IO.Path]::GetTempPath()) ("hardness-store-containment-{0}" -f [guid]::NewGuid().ToString('N'))
            try {
                [void](New-Item -ItemType Directory -Path $fixture -Force)
                $parent = New-SimpleParentFixture -FixtureRoot $fixture
                $outside = Join-Path $fixture 'outside-store'
                [void](New-Item -ItemType Directory -Path $outside -Force)
                $sentinel = Join-Path $outside 'sentinel.bin'
                $sentinelBytes = [byte[]](9, 8, 7, 6, 5)
                [System.IO.File]::WriteAllBytes($sentinel, $sentinelBytes)

                Assert-ThrowsMatch {
                    & $workspaceModule { param($root) Get-WorkspaceSubmoduleStore -Repository $root -Name '../../../../outside-store' } $parent | Out-Null
                } 'name|escape|outside|modules|invalid' 'logical traversal cannot resolve outside the module-store root'
                Assert-BytesEqual $sentinelBytes ([System.IO.File]::ReadAllBytes($sentinel)) 'malicious logical-name rejection does not modify an outside sentinel'

                $common = (& $workspaceModule { param($root) Get-WorkspaceCommonGitDirectory -Repository $root } $parent)
                $modules = Join-Path $common 'modules'
                [void](New-Item -ItemType Directory -Path $modules -Force)
                $escape = Join-Path $modules 'escape'
                [void](New-Item -ItemType Junction -Path $escape -Target $outside)
                Assert-ThrowsMatch {
                    & $workspaceModule { param($root) Get-WorkspaceSubmoduleStore -Repository $root -Name 'escape/nested' } $parent | Out-Null
                } 'reparse|physical|escape|outside|modules' 'logical nested names cannot cross a reparse point in the module-store chain'
                Assert-BytesEqual $sentinelBytes ([System.IO.File]::ReadAllBytes($sentinel)) 'reparse-store rejection does not modify an outside sentinel'

                Remove-JunctionOnly -Path $escape
                $safeNested = (& $workspaceModule { param($root) Get-WorkspaceSubmoduleStore -Repository $root -Name 'vendor/sdk' } $parent)
                Assert-True $safeNested.StartsWith(($modules.TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar), [System.StringComparison]::OrdinalIgnoreCase) 'legitimate nested logical names stay under the module-store root'
            }
            finally {
                Remove-TestFixture -FixtureRoot $fixture
            }
        }
    }
)

$failures = New-Object System.Collections.Generic.List[string]
foreach ($regression in $regressions) {
    try {
        & $regression.Action
    }
    catch {
        $failures.Add("$($regression.Name): $($_.Exception.Message)") | Out-Null
    }
}

Remove-Module Workspace -Force -ErrorAction SilentlyContinue
if ($failures.Count -gt 0) {
    throw "Workspace safety regressions failed ($($failures.Count)):$([Environment]::NewLine)$($failures -join [Environment]::NewLine)"
}

Write-Output 'Workspace.Safety.Tests.ps1: PASS'
