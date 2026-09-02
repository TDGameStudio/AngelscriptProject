[CmdletBinding()]
param(
    [string]$RepositoryRoot = '',
    [switch]$Check
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($RepositoryRoot))
{
    $RepositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../../..')).Path
}

$ChangeRoot = Split-Path -Parent $PSScriptRoot
$PlanPath = Join-Path $ChangeRoot 'inventory/planned-test-sources.csv'
$ReviewCsvPath = Join-Path $ChangeRoot 'inventory/testsource-implementation-review.csv'
$SummaryJsonPath = Join-Path $ChangeRoot 'inventory/testsource-review-summary.json'

if (-not (Test-Path -LiteralPath $PlanPath))
{
    throw "Planned source inventory not found: $PlanPath"
}

function Get-RegexCount
{
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$Text,

        [Parameter(Mandatory = $true)]
        [string]$Pattern,

        [System.Text.RegularExpressions.RegexOptions]$Options = [System.Text.RegularExpressions.RegexOptions]::None
    )

    return [System.Text.RegularExpressions.Regex]::Matches($Text, $Pattern, $Options).Count
}

function Get-ImmediatelyCommentedObserveCount
{
    param([AllowEmptyString()][string[]]$Lines)

    $Count = 0
    for ($LineIndex = 0; $LineIndex -lt $Lines.Count; ++$LineIndex)
    {
        if ($Lines[$LineIndex] -notmatch '^\s*[A-Za-z_][A-Za-z0-9_:<>,@&\[\]\?\s]*\s+Observe_[A-Za-z0-9_]+\s*\(')
        {
            continue
        }

        $PreviousIndex = $LineIndex - 1
        while ($PreviousIndex -ge 0 -and [string]::IsNullOrWhiteSpace($Lines[$PreviousIndex]))
        {
            --$PreviousIndex
        }

        if ($PreviousIndex -ge 0 -and ($Lines[$PreviousIndex] -match '^\s*//' -or $Lines[$PreviousIndex] -match '\*/\s*$'))
        {
            ++$Count
        }
    }

    return $Count
}

$PlanRows = @(Import-Csv -LiteralPath $PlanPath)
$ReviewRows = [System.Collections.Generic.List[object]]::new()

foreach ($PlanRow in $PlanRows)
{
    $SourcePath = Join-Path $RepositoryRoot $PlanRow.TargetPath
    $Layer = if ($PlanRow.TargetPath -like 'TestSource/Bindings/*') { 'Bindings' } else { 'TestFramework' }
    $Exists = Test-Path -LiteralPath $SourcePath
    $Content = if ($Exists) { Get-Content -LiteralPath $SourcePath -Raw } else { '' }
    $Lines = if ($Exists) { @(Get-Content -LiteralPath $SourcePath) } else { @() }
    $CodeContent = [System.Text.RegularExpressions.Regex]::Replace($Content, '(?s)/\*.*?\*/', '')
    $CodeContent = [System.Text.RegularExpressions.Regex]::Replace($CodeContent, '(?m)^\s*//[^\r\n]*(?:\r?\n|$)', '')

    $PlannedSymbols = @($PlanRow.PlannedSymbols -split ';' | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    $MissingSymbols = @($PlannedSymbols | Where-Object { -not $Content.Contains($_) })

    $ObservePattern = '(?m)^\s*(?<ReturnType>[A-Za-z_][A-Za-z0-9_:<>,@&\[\]\?\s]*?)\s+(?<Name>Observe_[A-Za-z0-9_]+)\s*\((?<Parameters>[^)]*)\)\s*\{'
    $ObserveMatches = [System.Text.RegularExpressions.Regex]::Matches($CodeContent, $ObservePattern)
    $ObserveFunctionCount = $ObserveMatches.Count
    $VoidNoArgObserveCount = @($ObserveMatches | Where-Object {
        $_.Groups['ReturnType'].Value.Trim() -eq 'void' -and [string]::IsNullOrWhiteSpace($_.Groups['Parameters'].Value)
    }).Count
    $NonVoidObserveCount = @($ObserveMatches | Where-Object { $_.Groups['ReturnType'].Value.Trim() -ne 'void' }).Count
    $ObserveWithParametersCount = @($ObserveMatches | Where-Object { -not [string]::IsNullOrWhiteSpace($_.Groups['Parameters'].Value) }).Count
    $ImmediatelyCommentedObserveCount = if ($Exists) { Get-ImmediatelyCommentedObserveCount -Lines $Lines } else { 0 }

    $ReturnStatementCount = Get-RegexCount -Text $CodeContent -Pattern '(?m)^\s*return(?:\s+[^;]+)?;'
    $AssertionCallCount = Get-RegexCount -Text $CodeContent -Pattern '\b(?:Assert[A-Za-z0-9_]*|Fail)\s*\('
    $DiscardedObservationLocalCount = Get-RegexCount -Text $CodeContent -Pattern '(?m)^\s*bool\s+b[A-Za-z0-9_]*(?:Observation|Observations|Hold|Holds|Returned)[A-Za-z0-9_]*\s*='

    $BooleanComplementTautologyCount = Get-RegexCount -Text $CodeContent -Pattern '\(\s*(?<BoolName>b[A-Za-z_][A-Za-z0-9_]*)\s*\|\|\s*!\s*\k<BoolName>\s*\)'
    $NullIdentityTautologyCount = Get-RegexCount -Text $CodeContent -Pattern '\(\s*(?<NullName>[A-Za-z_][A-Za-z0-9_\.]*)\s*==\s*nullptr\s*\|\|\s*\k<NullName>\s*!=\s*nullptr\s*\)'
    $SelfEqualityTautologyCount = Get-RegexCount -Text $CodeContent -Pattern '\b(?<SelfName>[A-Za-z_][A-Za-z0-9_\.]*)\s*==\s*\k<SelfName>\b'
    $ExhaustiveComparisonTautologyCount = Get-RegexCount -Text $CodeContent -Pattern '\(\s*(?<Left>[A-Za-z_][A-Za-z0-9_\.]*)\s*!=\s*(?<Right>[A-Za-z_][A-Za-z0-9_\.]*)\s*\|\|\s*\k<Left>\s*==\s*\k<Right>\s*\)'
    $TautologyCount = $BooleanComplementTautologyCount + $NullIdentityTautologyCount + $SelfEqualityTautologyCount + $ExhaustiveComparisonTautologyCount
    $PermissiveFixturePassCount = Get-RegexCount -Text $CodeContent -Pattern '\b(?:Spawned|Actor|World|Component|Object|Instance)[A-Za-z0-9_]*\s*==\s*nullptr\s*\|\|'

    $SpawnActorCallCount = Get-RegexCount -Text $CodeContent -Pattern '\bSpawn(?:Persistent)?Actor\s*\('
    $DestroyActorCallCount = Get-RegexCount -Text $CodeContent -Pattern '\bDestroyActor\s*\(|\.Destroy\s*\('
    $TimerSetCallCount = Get-RegexCount -Text $CodeContent -Pattern '\bSetTimer\s*\('
    $TimerCleanupCallCount = Get-RegexCount -Text $CodeContent -Pattern '\b(?:ClearTimer|ClearAndInvalidateTimerHandle)\s*\('
    $DangerousSideEffectCount = Get-RegexCount -Text $CodeContent -Pattern '\b(?:RequestExit|ServerTravel|LaunchURL|ClipboardCopy|ClipboardPaste)\s*\('
    $GenericSurfaceObserveCount = Get-RegexCount -Text $CodeContent -Pattern '\bObserve_Surface[0-9]+_[A-Za-z0-9_]+\s*\('
    $FrameworkMetadataCount = Get-RegexCount -Text $CodeContent -Pattern 'meta\s*=\s*\(\s*AngelscriptTest\s*\)'
    $ExternalOracleCommentCount = Get-RegexCount -Text $Content -Pattern 'C\+\+ oracle required:'

    $IssueIds = [System.Collections.Generic.List[string]]::new()
    $RequiredActions = [System.Collections.Generic.List[string]]::new()
    $Severity = 'Info'
    $Disposition = 'StructurallyComplete'

    if (-not $Exists)
    {
        $IssueIds.Add('MBSRC-REV-009')
        $RequiredActions.Add('Create the exact planned source path.')
        $Severity = 'Blocking'
        $Disposition = 'Missing'
    }
    elseif ($MissingSymbols.Count -gt 0)
    {
        $IssueIds.Add('MBSRC-REV-009')
        $RequiredActions.Add('Restore every planned namespace and callable declaration.')
        $Severity = 'Blocking'
        $Disposition = 'StructurallyIncomplete'
    }

    if ($Layer -eq 'Bindings' -and $ObserveFunctionCount -gt 0 -and $VoidNoArgObserveCount -eq $ObserveFunctionCount)
    {
        $IssueIds.Add('MBSRC-REV-001')
        $RequiredActions.Add('Give each scenario a runner-readable result, out record, or identified host-visible state contract.')
        $Severity = 'Blocking'
        $Disposition = 'BlockedLostOracle'
    }

    if ($Layer -eq 'Bindings' -and $DiscardedObservationLocalCount -gt 0)
    {
        $IssueIds.Add('MBSRC-REV-002')
        $RequiredActions.Add('Replace function-local hold variables with exact externally checked observations.')
        $Severity = 'Blocking'
        $Disposition = 'BlockedLostOracle'
    }

    if ($TautologyCount -gt 0 -or $PermissiveFixturePassCount -gt 0)
    {
        $IssueIds.Add('MBSRC-REV-003')
        $RequiredActions.Add('Replace tautologies and permissive null success branches with exact expected values or explicit setup failure.')
        if ($Severity -ne 'Blocking') { $Severity = 'High' }
        if ($Disposition -eq 'StructurallyComplete') { $Disposition = 'NeedsSemanticRewrite' }
    }

    if ($Layer -eq 'Bindings' -and $SpawnActorCallCount -gt $DestroyActorCallCount)
    {
        $IssueIds.Add('MBSRC-REV-005')
        $RequiredActions.Add('Assign ownership for spawned actors, finish deferred spawns, and guarantee teardown.')
        if ($Severity -ne 'Blocking') { $Severity = 'High' }
    }

    if ($Layer -eq 'Bindings' -and $TimerSetCallCount -gt $TimerCleanupCallCount)
    {
        $IssueIds.Add('MBSRC-REV-005')
        $RequiredActions.Add('Guarantee timer cancellation or invalidation during teardown.')
        if ($Severity -ne 'Blocking') { $Severity = 'High' }
    }

    if ($DangerousSideEffectCount -gt 0)
    {
        $IssueIds.Add('MBSRC-REV-006')
        $RequiredActions.Add('Classify this source as isolated, diagnostic-only, or never-default-run; add restoration where possible.')
        if ($Severity -ne 'Blocking') { $Severity = 'High' }
        if ($Disposition -eq 'StructurallyComplete') { $Disposition = 'UnsafeForDefaultExecution' }
    }

    if ($Layer -eq 'Bindings' -and $GenericSurfaceObserveCount -gt 0 -and $ImmediatelyCommentedObserveCount -lt $ObserveFunctionCount)
    {
        $IssueIds.Add('MBSRC-REV-007')
        $RequiredActions.Add('Explain the behavior and oracle beside generic Observe_Surface functions; do not rely only on a repeated file header.')
        if ($Severity -eq 'Info') { $Severity = 'Medium' }
    }

    if ($Layer -eq 'TestFramework')
    {
        $IssueIds.Add('MBSRC-REV-008')
        $RequiredActions.Add('Keep provisional until the external C++ oracle verifies discovery, counts, diagnostics, order, identity, and cleanup.')
        if ($Severity -eq 'Info') { $Severity = 'PendingExternalOracle' }
        if ($Disposition -eq 'StructurallyComplete') { $Disposition = 'ProvisionalExternalOracle' }
    }

    $ReviewRows.Add([pscustomobject][ordered]@{
        TaskId = $PlanRow.TaskId
        TargetPath = $PlanRow.TargetPath
        Layer = $Layer
        Exists = $Exists
        MissingPlannedSymbols = ($MissingSymbols -join ';')
        ObserveFunctions = $ObserveFunctionCount
        VoidNoArgObserveFunctions = $VoidNoArgObserveCount
        NonVoidObserveFunctions = $NonVoidObserveCount
        ObserveFunctionsWithParameters = $ObserveWithParametersCount
        ImmediatelyCommentedObserveFunctions = $ImmediatelyCommentedObserveCount
        ReturnStatements = $ReturnStatementCount
        AssertionCalls = $AssertionCallCount
        DiscardedObservationLocals = $DiscardedObservationLocalCount
        Tautologies = $TautologyCount
        PermissiveFixturePasses = $PermissiveFixturePassCount
        SpawnActorCalls = $SpawnActorCallCount
        DestroyActorCalls = $DestroyActorCallCount
        TimerSetCalls = $TimerSetCallCount
        TimerCleanupCalls = $TimerCleanupCallCount
        DangerousHostSideEffects = $DangerousSideEffectCount
        GenericSurfaceObserveFunctions = $GenericSurfaceObserveCount
        FrameworkTestMetadata = $FrameworkMetadataCount
        ExternalOracleComments = $ExternalOracleCommentCount
        Severity = $Severity
        Disposition = $Disposition
        IssueIds = (($IssueIds | Select-Object -Unique) -join ';')
        RequiredAction = (($RequiredActions | Select-Object -Unique) -join ' ')
    })
}

$BindingRows = @($ReviewRows | Where-Object Layer -eq 'Bindings')
$FrameworkRows = @($ReviewRows | Where-Object Layer -eq 'TestFramework')
$Summary = [pscustomobject][ordered]@{
    reviewBaselineDate = '2026-08-21'
    plannedSources = $PlanRows.Count
    existingSources = @($ReviewRows | Where-Object Exists).Count
    missingSources = @($ReviewRows | Where-Object { -not $_.Exists }).Count
    sourcesWithMissingPlannedSymbols = @($ReviewRows | Where-Object { -not [string]::IsNullOrWhiteSpace($_.MissingPlannedSymbols) }).Count
    bindingSources = $BindingRows.Count
    frameworkSources = $FrameworkRows.Count
    observeFunctions = [int](($BindingRows | Measure-Object ObserveFunctions -Sum).Sum)
    voidNoArgObserveFunctions = [int](($BindingRows | Measure-Object VoidNoArgObserveFunctions -Sum).Sum)
    nonVoidObserveFunctions = [int](($BindingRows | Measure-Object NonVoidObserveFunctions -Sum).Sum)
    observeFunctionsWithParameters = [int](($BindingRows | Measure-Object ObserveFunctionsWithParameters -Sum).Sum)
    immediatelyCommentedObserveFunctions = [int](($BindingRows | Measure-Object ImmediatelyCommentedObserveFunctions -Sum).Sum)
    bindingSourcesBlockedByLostOracle = @($BindingRows | Where-Object Disposition -eq 'BlockedLostOracle').Count
    bindingSourcesWithDiscardedObservationLocals = @($BindingRows | Where-Object DiscardedObservationLocals -gt 0).Count
    bindingSourcesWithTautologiesOrPermissiveFixtures = @($BindingRows | Where-Object { $_.Tautologies -gt 0 -or $_.PermissiveFixturePasses -gt 0 }).Count
    tautologies = [int](($BindingRows | Measure-Object Tautologies -Sum).Sum)
    permissiveFixturePasses = [int](($BindingRows | Measure-Object PermissiveFixturePasses -Sum).Sum)
    spawnActorCalls = [int](($BindingRows | Measure-Object SpawnActorCalls -Sum).Sum)
    destroyActorCalls = [int](($BindingRows | Measure-Object DestroyActorCalls -Sum).Sum)
    dangerousHostSideEffects = [int](($BindingRows | Measure-Object DangerousHostSideEffects -Sum).Sum)
    bindingSourcesWithDangerousHostSideEffects = @($BindingRows | Where-Object DangerousHostSideEffects -gt 0).Count
    genericSurfaceObserveFunctions = [int](($BindingRows | Measure-Object GenericSurfaceObserveFunctions -Sum).Sum)
    frameworkAssertionCalls = [int](($FrameworkRows | Measure-Object AssertionCalls -Sum).Sum)
    frameworkTestMetadata = [int](($FrameworkRows | Measure-Object FrameworkTestMetadata -Sum).Sum)
    frameworkSourcesWithExternalOracleComments = @($FrameworkRows | Where-Object ExternalOracleComments -gt 0).Count
    acceptedBindingSources = @($BindingRows | Where-Object Disposition -eq 'Accepted').Count
    acceptedFrameworkSources = @($FrameworkRows | Where-Object Disposition -eq 'Accepted').Count
}

if ($Check)
{
    if (-not (Test-Path -LiteralPath $ReviewCsvPath) -or -not (Test-Path -LiteralPath $SummaryJsonPath))
    {
        throw 'Review outputs are missing. Run this script once without -Check to generate them.'
    }

    $ExistingCsv = Get-Content -LiteralPath $ReviewCsvPath -Raw
    $TemporaryCsv = [System.IO.Path]::GetTempFileName()
    try
    {
        $ReviewRows | Export-Csv -LiteralPath $TemporaryCsv -NoTypeInformation -Encoding utf8
        $ExpectedCsv = Get-Content -LiteralPath $TemporaryCsv -Raw
        if ($ExistingCsv -ne $ExpectedCsv)
        {
            throw 'testsource-implementation-review.csv is stale. Regenerate the review inventory.'
        }

        # Windows PowerShell 5.1 and PowerShell 7 serialize the same object with
        # different whitespace and may spell integral sums as 2420 or 2420.0.
        # Compare the parsed property set and values so -Check verifies data,
        # not the host serializer's presentation.
        $ExistingSummary = Get-Content -LiteralPath $SummaryJsonPath -Raw | ConvertFrom-Json
        $ExpectedPropertyNames = @($Summary.PSObject.Properties.Name | Sort-Object)
        $ExistingPropertyNames = @($ExistingSummary.PSObject.Properties.Name | Sort-Object)
        $PropertyDiff = @(Compare-Object -ReferenceObject $ExpectedPropertyNames -DifferenceObject $ExistingPropertyNames)
        $ValueDiff = @()
        foreach ($PropertyName in $ExpectedPropertyNames)
        {
            $ExpectedText = [System.Convert]::ToString($Summary.$PropertyName, [System.Globalization.CultureInfo]::InvariantCulture)
            $ExistingText = [System.Convert]::ToString($ExistingSummary.$PropertyName, [System.Globalization.CultureInfo]::InvariantCulture)
            if ($ExpectedText -cne $ExistingText)
            {
                $ValueDiff += $PropertyName
            }
        }

        if ($PropertyDiff.Count -ne 0 -or $ValueDiff.Count -ne 0)
        {
            throw 'testsource-review-summary.json is stale. Regenerate the review summary.'
        }
    }
    finally
    {
        Remove-Item -LiteralPath $TemporaryCsv -Force
    }

    Write-Output "Review CSV is current: $ReviewCsvPath"
    Write-Output "Existing sources: $($Summary.existingSources)/$($Summary.plannedSources)"
    Write-Output "Binding sources blocked by lost oracle: $($Summary.bindingSourcesBlockedByLostOracle)/$($Summary.bindingSources)"
    return
}

$ReviewRows | Export-Csv -LiteralPath $ReviewCsvPath -NoTypeInformation -Encoding utf8
$Summary | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $SummaryJsonPath -Encoding utf8

Write-Output "Wrote review CSV: $ReviewCsvPath"
Write-Output "Wrote review summary: $SummaryJsonPath"
Write-Output "Existing sources: $($Summary.existingSources)/$($Summary.plannedSources)"
Write-Output "Binding sources blocked by lost oracle: $($Summary.bindingSourcesBlockedByLostOracle)/$($Summary.bindingSources)"
Write-Output "Framework sources pending external oracle: $($Summary.frameworkSources)/$($Summary.frameworkSources)"
