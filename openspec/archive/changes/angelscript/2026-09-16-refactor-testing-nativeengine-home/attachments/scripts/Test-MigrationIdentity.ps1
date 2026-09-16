# Purpose: compare Unreal Automation reports by fullTestPath/state against an
# explicit old-to-new identity map. Detect missing, duplicate, colliding,
# wrong-layer, unmapped, and count-preserving-loss failures.
# Dependencies: Windows PowerShell 7+, the sibling data/migration-identity-map.json
# schema. This helper never launches Unreal or Harness ue.* routes.

[CmdletBinding()]
param(
    [string] $BeforeReport,
    [string] $AfterReport,
    [string] $MapPath,
    [string] $Tenant,
    [switch] $SelfTest
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:AllowedNativeEngineLayers = @(
    'Basic', 'Lexer', 'Parser', 'AST', 'Sema', 'Compile', 'SourceExecution',
    'Diagnostics', 'Tooling', 'Definitions', 'Identity', 'TypeOwnership',
    'Registration', 'VM'
)

function New-TempDirectory {
    $path = Join-Path ([System.IO.Path]::GetTempPath()) ("as-mig-id-" + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $path | Out-Null
    return $path
}

function Write-JsonFile {
    param(
        [Parameter(Mandatory = $true)][string] $Path,
        [Parameter(Mandatory = $true)] $Document
    )
    $json = $Document | ConvertTo-Json -Depth 12
    [System.IO.File]::WriteAllText($Path, $json)
}

function ConvertTo-TestRecordList {
    param($TestsValue)

    if ($null -eq $TestsValue) { return @() }
    return @($TestsValue)
}

function Get-AutomationIdentities {
    param(
        [Parameter(Mandatory = $true)][string] $ReportPath,
        [string] $Prefix
    )

    if (-not (Test-Path -LiteralPath $ReportPath -PathType Leaf)) {
        throw "Automation report is missing: $ReportPath"
    }

    $document = Get-Content -LiteralPath $ReportPath -Raw -Encoding UTF8 | ConvertFrom-Json -Depth 100
    if ($null -eq $document) {
        throw "Automation report root must be a JSON object: $ReportPath"
    }

    $records = [System.Collections.Generic.List[object]]::new()
    $seen = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    $duplicates = [System.Collections.Generic.List[string]]::new()

    foreach ($test in (ConvertTo-TestRecordList $document.tests)) {
        if ($null -eq $test) {
            throw "Every tests entry must be a JSON object in $ReportPath"
        }
        $fullTestPath = [string] $test.fullTestPath
        $state = [string] $test.state
        if ([string]::IsNullOrWhiteSpace($fullTestPath)) {
            throw "Automation test 'fullTestPath' cannot be empty in $ReportPath"
        }
        if ([string]::IsNullOrWhiteSpace($state)) {
            throw "Automation test '$fullTestPath' is missing state in $ReportPath"
        }
        if ($Prefix -and -not $fullTestPath.StartsWith($Prefix, [StringComparison]::Ordinal)) {
            continue
        }
        if (-not $seen.Add($fullTestPath)) {
            $duplicates.Add($fullTestPath)
        }
        $records.Add([pscustomobject]@{
                FullTestPath = $fullTestPath
                State        = $state
            })
    }

    return [pscustomobject]@{
        Path       = $ReportPath
        Records    = $records.ToArray()
        Duplicates = $duplicates.ToArray()
    }
}

function Get-NativeEngineLayer {
    param([Parameter(Mandatory = $true)][string] $Identity)

    $parts = $Identity.Split('.')
    if ($parts.Length -lt 6) { return $null }
    if ($parts[0] -cne 'Angelscript' -or $parts[1] -cne 'UnitTest' -or $parts[2] -cne 'NativeEngine') {
        return $null
    }
    return $parts[3]
}

function Get-NativeEngineTail {
    param([Parameter(Mandatory = $true)][string] $Identity)

    $parts = $Identity.Split('.')
    if ($parts.Length -lt 6) { return $null }
    if ($parts[0] -cne 'Angelscript' -or $parts[1] -cne 'UnitTest' -or $parts[2] -cne 'NativeEngine') {
        return $null
    }
    return ($parts[4..($parts.Length - 1)] -join '.')
}

function Read-IdentityMap {
    param(
        [Parameter(Mandatory = $true)][string] $Path,
        [string] $TenantName
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Identity map is missing: $Path"
    }

    $document = Get-Content -LiteralPath $Path -Raw -Encoding UTF8 | ConvertFrom-Json -Depth 100
    if ($null -eq $document -or $null -eq $document.tenants) {
        throw "Identity map must contain a tenants object: $Path"
    }

    $tenants = @{}
    foreach ($property in $document.tenants.PSObject.Properties) {
        $name = [string] $property.Name
        if ($TenantName -and $name -cne $TenantName) { continue }
        $tenant = $property.Value
        $mappings = [System.Collections.Generic.List[object]]::new()
        foreach ($entry in @(ConvertTo-TestRecordList $tenant.mappings)) {
            $mappings.Add([pscustomobject]@{
                    Old         = [string] $entry.old
                    New         = [string] $entry.new
                    Disposition = if ($entry.disposition) { [string] $entry.disposition } else { 'one-to-one' }
                    Layer       = if ($entry.PSObject.Properties['layer']) { [string] $entry.layer } else { $null }
                    OldFile     = if ($entry.PSObject.Properties['oldFile']) { [string] $entry.oldFile } else { $null }
                    NewFile     = if ($entry.PSObject.Properties['newFile']) { [string] $entry.newFile } else { $null }
                })
        }
        $expectedEmpty = @()
        if ($tenant.PSObject.Properties['expectedEmptyLayers'] -and $null -ne $tenant.expectedEmptyLayers) {
            $expectedEmpty = @($tenant.expectedEmptyLayers | ForEach-Object { [string] $_ })
        }
        $tenants[$name] = [pscustomobject]@{
            Name               = $name
            OldPrefix          = [string] $tenant.oldPrefix
            NewPrefix          = [string] $tenant.newPrefix
            IdentityPreserving = [bool] $tenant.identityPreserving
            ExpectedEmptyLayers = $expectedEmpty
            Mappings           = $mappings.ToArray()
        }
    }

    if ($TenantName -and -not $tenants.ContainsKey($TenantName)) {
        throw "Identity map has no tenant '$TenantName'."
    }

    return [pscustomobject]@{
        Path    = $Path
        Tenants = $tenants
    }
}

function Test-IdentityReconciliation {
    param(
        [Parameter(Mandatory = $true)] $Before,
        [Parameter(Mandatory = $true)] $After,
        [Parameter(Mandatory = $true)] $Map,
        [string] $TenantName
    )

    $failures = [System.Collections.Generic.List[string]]::new()
    $tenantNames = @($Map.Tenants.Keys)
    if ($TenantName) { $tenantNames = @($TenantName) }

    foreach ($name in $tenantNames) {
        $tenant = $Map.Tenants[$name]
        $oldByPath = @{}
        foreach ($record in $Before.Records) {
            if ($tenant.OldPrefix -and -not $record.FullTestPath.StartsWith($tenant.OldPrefix, [StringComparison]::Ordinal)) {
                continue
            }
            $oldByPath[$record.FullTestPath] = $record
        }

        $afterByPath = @{}
        foreach ($record in $After.Records) {
            if ($tenant.NewPrefix -and -not $record.FullTestPath.StartsWith($tenant.NewPrefix, [StringComparison]::Ordinal)) {
                continue
            }
            if ($afterByPath.ContainsKey($record.FullTestPath)) {
                $failures.Add("[$name] duplicate after identity '$($record.FullTestPath)'")
            }
            else {
                $afterByPath[$record.FullTestPath] = $record
            }
        }

        foreach ($duplicate in $Before.Duplicates) {
            $failures.Add("[$name] duplicate before identity '$duplicate'")
        }
        foreach ($duplicate in $After.Duplicates) {
            if ($tenant.NewPrefix -and -not $duplicate.StartsWith($tenant.NewPrefix, [StringComparison]::Ordinal)) {
                continue
            }
            $failures.Add("[$name] duplicate after identity '$duplicate'")
        }

        $mappedOld = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
        $mappedNew = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
        $expectedNew = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)

        foreach ($mapping in $tenant.Mappings) {
            if ([string]::IsNullOrWhiteSpace($mapping.Old) -or [string]::IsNullOrWhiteSpace($mapping.New)) {
                $failures.Add("[$name] mapping is missing old or new identity")
                continue
            }
            if (-not $mappedOld.Add($mapping.Old)) {
                $failures.Add("[$name] colliding map source '$($mapping.Old)'")
            }
            if (-not $mappedNew.Add($mapping.New)) {
                $failures.Add("[$name] colliding map destination '$($mapping.New)'")
            }
            [void] $expectedNew.Add($mapping.New)

            if ($tenant.IdentityPreserving -and $mapping.Old -cne $mapping.New -and $mapping.Disposition -cne 'explicit-rename') {
                $failures.Add("[$name] identity-preserving tenant changed '$($mapping.Old)' -> '$($mapping.New)' without explicit-rename")
            }

            $oldOptional = $mapping.Disposition -cin @('unregistered-old', 'collision-rename')
            if (-not $oldByPath.ContainsKey($mapping.Old) -and -not $oldOptional) {
                $failures.Add("[$name] mapped old identity is absent from the before report: '$($mapping.Old)'")
            }

            $expectedLayer = $mapping.Layer
            if (-not $expectedLayer -and -not $tenant.IdentityPreserving) {
                $expectedLayer = Get-NativeEngineLayer $mapping.New
            }
            $actualLayer = Get-NativeEngineLayer $mapping.New
            if ($expectedLayer) {
                if ($actualLayer -cne $expectedLayer) {
                    $failures.Add("[$name] wrong-layer map destination '$($mapping.New)' (expected $expectedLayer)")
                }
                elseif ($script:AllowedNativeEngineLayers -notcontains $expectedLayer) {
                    $failures.Add("[$name] unknown NativeEngine layer '$expectedLayer' on '$($mapping.New)'")
                }
            }

            if (-not $afterByPath.ContainsKey($mapping.New)) {
                $failures.Add("[$name] missing mapped destination '$($mapping.New)'")
                $wantedTail = Get-NativeEngineTail $mapping.New
                if ($wantedTail) {
                    foreach ($afterPath in $afterByPath.Keys) {
                        $afterTail = Get-NativeEngineTail $afterPath
                        $afterLayer = Get-NativeEngineLayer $afterPath
                        if ($afterTail -ceq $wantedTail -and $expectedLayer -and $afterLayer -cne $expectedLayer) {
                            $failures.Add("[$name] wrong-layer after identity '$afterPath' (expected $expectedLayer)")
                        }
                    }
                }
                continue
            }

            $afterLayer = Get-NativeEngineLayer $afterByPath[$mapping.New].FullTestPath
            if ($expectedLayer -and $afterLayer -cne $expectedLayer) {
                $failures.Add("[$name] wrong-layer after identity '$($afterByPath[$mapping.New].FullTestPath)' (expected $expectedLayer)")
            }

            $beforeState = if ($oldByPath.ContainsKey($mapping.Old)) { $oldByPath[$mapping.Old].State } else { $null }
            $afterState = $afterByPath[$mapping.New].State
            if ($beforeState -and $afterState -cne $beforeState -and $mapping.Disposition -cne 'state-change') {
                $failures.Add("[$name] state changed for '$($mapping.New)' ($beforeState -> $afterState)")
            }
        }

        foreach ($oldPath in $oldByPath.Keys) {
            if (-not $mappedOld.Contains($oldPath)) {
                $failures.Add("[$name] unmapped old identity '$oldPath'")
            }
        }

        foreach ($newPath in $afterByPath.Keys) {
            if (-not $expectedNew.Contains($newPath)) {
                $failures.Add("[$name] unexpected after identity '$newPath'")
            }
        }

        foreach ($layer in $tenant.ExpectedEmptyLayers) {
            $present = @($afterByPath.Keys | Where-Object { (Get-NativeEngineLayer $_) -ceq $layer })
            if ($present.Count -gt 0) {
                $failures.Add("[$name] expected-empty layer '$layer' contains $($present.Count) identities")
            }
        }

        if ($oldByPath.Count -eq $afterByPath.Count -and $failures.Count -gt 0) {
            $hasIdentityFailure = $failures | Where-Object { $_ -match 'missing mapped|unexpected after|unmapped old|wrong-layer|duplicate after|colliding map' }
            if ($hasIdentityFailure) {
                $failures.Add("[$name] count-preserving identity loss (before=$($oldByPath.Count) after=$($afterByPath.Count))")
            }
        }
    }

    return [pscustomobject]@{
        Passed   = ($failures.Count -eq 0)
        Failures = $failures.ToArray()
    }
}

function New-FixtureReport {
    param([Parameter(Mandatory = $true)][object[]] $Tests)

    $success = @($Tests | Where-Object { $_.state -ceq 'Success' }).Count
    return [ordered]@{
        reportCreatedOn       = '2026.09.15-00.00.00'
        succeeded             = $success
        succeededWithWarnings = 0
        failed                = $Tests.Count - $success
        notRun                = 0
        inProcess             = 0
        tests                 = $Tests
    }
}

function New-FixtureMap {
    param(
        [Parameter(Mandatory = $true)][object[]] $Mappings,
        [string[]] $ExpectedEmptyLayers = @()
    )

    return [ordered]@{
        schemaVersion = 1
        tenants       = [ordered]@{
            NativeEngine = [ordered]@{
                oldPrefix             = 'Angelscript.UnitTest.NativeEngine'
                newPrefix             = 'Angelscript.UnitTest.NativeEngine'
                identityPreserving    = $false
                expectedEmptyLayers   = $ExpectedEmptyLayers
                mappings              = $Mappings
            }
        }
    }
}

function Invoke-SelfTestCase {
    param(
        [Parameter(Mandatory = $true)][string] $Name,
        [Parameter(Mandatory = $true)] $BeforeDoc,
        [Parameter(Mandatory = $true)] $AfterDoc,
        [Parameter(Mandatory = $true)] $MapDoc,
        [Parameter(Mandatory = $true)][bool] $ShouldPass,
        [string[]] $RequiredFailurePatterns = @()
    )

    $root = New-TempDirectory
    try {
        $beforePath = Join-Path $root 'before.json'
        $afterPath = Join-Path $root 'after.json'
        $mapPath = Join-Path $root 'map.json'
        Write-JsonFile -Path $beforePath -Document $BeforeDoc
        Write-JsonFile -Path $afterPath -Document $AfterDoc
        Write-JsonFile -Path $mapPath -Document $MapDoc

        $before = Get-AutomationIdentities -ReportPath $beforePath
        $after = Get-AutomationIdentities -ReportPath $afterPath
        $map = Read-IdentityMap -Path $mapPath
        $result = Test-IdentityReconciliation -Before $before -After $after -Map $map -TenantName 'NativeEngine'

        if ($ShouldPass) {
            if (-not $result.Passed) {
                throw "$Name expected pass but failed: $($result.Failures -join '; ')"
            }
            return
        }

        if ($result.Passed) {
            throw "$Name expected failure but passed."
        }
        foreach ($pattern in $RequiredFailurePatterns) {
            $hit = $result.Failures | Where-Object { $_ -match $pattern }
            if (-not $hit) {
                throw "$Name missing failure /$pattern/. Actual: $($result.Failures -join '; ')"
            }
        }
    }
    finally {
        Remove-Item -LiteralPath $root -Recurse -Force -ErrorAction SilentlyContinue
    }
}

function Invoke-SelfTest {
    $oldA = 'Angelscript.UnitTest.NativeEngine.Foo.A'
    $oldB = 'Angelscript.UnitTest.NativeEngine.Foo.B'
    $newA = 'Angelscript.UnitTest.NativeEngine.Lexer.Foo.A'
    $newB = 'Angelscript.UnitTest.NativeEngine.Lexer.Foo.B'
    $newC = 'Angelscript.UnitTest.NativeEngine.Lexer.Foo.C'
    $wrongA = 'Angelscript.UnitTest.NativeEngine.Sema.Foo.A'

    $mapAB = New-FixtureMap -Mappings @(
        [ordered]@{ old = $oldA; new = $newA; disposition = 'one-to-one'; layer = 'Lexer' }
        [ordered]@{ old = $oldB; new = $newB; disposition = 'one-to-one'; layer = 'Lexer' }
    ) -ExpectedEmptyLayers @('Parser')

    $passBefore = New-FixtureReport -Tests @(
        [ordered]@{ testDisplayName = 'A'; fullTestPath = $oldA; state = 'Success'; warnings = 0; errors = 0 }
        [ordered]@{ testDisplayName = 'B'; fullTestPath = $oldB; state = 'Success'; warnings = 0; errors = 0 }
    )
    $passAfter = New-FixtureReport -Tests @(
        [ordered]@{ testDisplayName = 'A'; fullTestPath = $newA; state = 'Success'; warnings = 0; errors = 0 }
        [ordered]@{ testDisplayName = 'B'; fullTestPath = $newB; state = 'Success'; warnings = 0; errors = 0 }
    )
    Invoke-SelfTestCase -Name 'mapped A/B pass' -BeforeDoc $passBefore -AfterDoc $passAfter -MapDoc $mapAB -ShouldPass $true

    $missingAfter = New-FixtureReport -Tests @(
        [ordered]@{ testDisplayName = 'B'; fullTestPath = $newB; state = 'Success'; warnings = 0; errors = 0 }
        [ordered]@{ testDisplayName = 'C'; fullTestPath = $newC; state = 'Success'; warnings = 0; errors = 0 }
    )
    Invoke-SelfTestCase -Name 'missing A plus extra C' -BeforeDoc $passBefore -AfterDoc $missingAfter -MapDoc $mapAB -ShouldPass $false -RequiredFailurePatterns @(
        'missing mapped destination',
        'unexpected after identity',
        'count-preserving identity loss'
    )

    $duplicateAfter = New-FixtureReport -Tests @(
        [ordered]@{ testDisplayName = 'A'; fullTestPath = $newA; state = 'Success'; warnings = 0; errors = 0 }
        [ordered]@{ testDisplayName = 'B'; fullTestPath = $newB; state = 'Success'; warnings = 0; errors = 0 }
        [ordered]@{ testDisplayName = 'B2'; fullTestPath = $newB; state = 'Success'; warnings = 0; errors = 0 }
    )
    Invoke-SelfTestCase -Name 'duplicate B' -BeforeDoc $passBefore -AfterDoc $duplicateAfter -MapDoc $mapAB -ShouldPass $false -RequiredFailurePatterns @(
        'duplicate after identity'
    )

    $wrongLayerAfter = New-FixtureReport -Tests @(
        [ordered]@{ testDisplayName = 'A'; fullTestPath = $wrongA; state = 'Success'; warnings = 0; errors = 0 }
        [ordered]@{ testDisplayName = 'B'; fullTestPath = $newB; state = 'Success'; warnings = 0; errors = 0 }
    )
    Invoke-SelfTestCase -Name 'wrong layer' -BeforeDoc $passBefore -AfterDoc $wrongLayerAfter -MapDoc $mapAB -ShouldPass $false -RequiredFailurePatterns @(
        'wrong-layer after identity',
        'missing mapped destination'
    )

    $unmappedBefore = New-FixtureReport -Tests @(
        [ordered]@{ testDisplayName = 'A'; fullTestPath = $oldA; state = 'Success'; warnings = 0; errors = 0 }
        [ordered]@{ testDisplayName = 'B'; fullTestPath = $oldB; state = 'Success'; warnings = 0; errors = 0 }
        [ordered]@{ testDisplayName = 'C'; fullTestPath = 'Angelscript.UnitTest.NativeEngine.Foo.C'; state = 'Success'; warnings = 0; errors = 0 }
    )
    Invoke-SelfTestCase -Name 'unmapped old identity' -BeforeDoc $unmappedBefore -AfterDoc $passAfter -MapDoc $mapAB -ShouldPass $false -RequiredFailurePatterns @(
        'unmapped old identity'
    )

    Write-Output 'SelfTest passed: mapped A/B pass; missing A plus extra C, duplicate B, wrong layer, and unmapped old identity fail.'
}

if ($SelfTest) {
    Invoke-SelfTest
    exit 0
}

if (-not $BeforeReport -or -not $AfterReport -or -not $MapPath) {
    throw 'Compare mode requires -BeforeReport, -AfterReport, and -MapPath. Use -SelfTest for synthetic fixtures.'
}

$before = Get-AutomationIdentities -ReportPath $BeforeReport
$after = Get-AutomationIdentities -ReportPath $AfterReport
$map = Read-IdentityMap -Path $MapPath -TenantName $Tenant
$result = Test-IdentityReconciliation -Before $before -After $after -Map $map -TenantName $Tenant

if ($result.Passed) {
    $beforeCount = @($before.Records).Count
    $afterCount = @($after.Records).Count
    Write-Output "Identity reconciliation passed (before=$beforeCount after=$afterCount)."
    exit 0
}

Write-Error ("Identity reconciliation failed:`n" + ($result.Failures -join "`n"))
exit 1
