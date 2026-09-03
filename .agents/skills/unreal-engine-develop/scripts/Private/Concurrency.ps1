function Get-UnrealConcurrencyDecision {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][ValidateSet('Build', 'QueryTargets', 'Ubt', 'Test', 'Commandlet', 'Suite')][string] $Operation,
        [Parameter(Mandatory = $true)][string] $EngineRoot,
        [ValidateSet('Auto', 'Wait', 'Fail')][string] $Policy = 'Auto',
        [bool] $InstalledEngine = $false,
        [ValidateSet('Auto', 'Parallel', 'Serialize')][string] $BuildConcurrency = 'Auto',
        [switch] $TypedProjectBuild
    )

    $root = ConvertTo-UnrealCanonicalPath -Path $EngineRoot
    $ubtOperation = $Operation -in @('Build', 'QueryTargets', 'Ubt')
    $leaseBehavior = if ($Policy -eq 'Fail') { 'FailIfBusy' } else { 'WaitWithinTimeout' }
    $arguments = [System.Collections.Generic.List[string]]::new()
    $reasons = [System.Collections.Generic.List[string]]::new()
    $selectedBuildConcurrency = 'NotApplicable'
    $engineLane = 'None'
    $decision = 'CrossWorkspaceNonUbt'

    if ($Operation -eq 'Build' -and $TypedProjectBuild) {
        if ($BuildConcurrency -eq 'Parallel' -and -not $InstalledEngine) {
            throw 'BuildConcurrency Parallel requires an ordinary installed-engine project build. Use Serialize for source or unknown engines.'
        }
        $selectedBuildConcurrency = if ($BuildConcurrency -eq 'Auto') {
            if ($InstalledEngine) { 'Parallel' } else { 'Serialize' }
        }
        else {
            $BuildConcurrency
        }

        if ($selectedBuildConcurrency -eq 'Parallel') {
            $arguments.Add('-NoMutex')
            $arguments.Add('-NoEngineChanges')
            $engineLane = 'Shared'
            $decision = 'ParallelInstalledProjectBuild'
            $reasons.Add('An ordinary installed-engine project build may share the Harness engine lane across distinct workspace leases.')
            $reasons.Add('Harness owns the paired NoMutex and NoEngineChanges guards plus run-local temp and log paths.')
        }
        else {
            $arguments.Add('-WaitMutex')
            if ($InstalledEngine) { $arguments.Add('-NoEngineChanges') }
            $engineLane = 'Exclusive'
            $decision = 'SerializedEngineUbt'
            $reasons.Add('The typed project build explicitly or conservatively selected the exclusive Harness engine lane.')
            $reasons.Add('UBT WaitMutex also coordinates with external UBT processes using the same assembly mutex.')
        }
    }
    elseif ($ubtOperation) {
        if ($BuildConcurrency -ne 'Auto') {
            throw 'BuildConcurrency applies only to the typed project build operation.'
        }
        $selectedBuildConcurrency = 'Serialize'
        $engineLane = 'Exclusive'
        $decision = 'SerializedEngineUbt'
        $arguments.Add('-WaitMutex')
        $reasons.Add("$Operation is a conservative UBT operation and uses the exclusive Harness engine lane keyed by canonical EngineRoot.")
        $reasons.Add('UBT WaitMutex also coordinates with external UBT processes using the same assembly mutex.')
        if ($Operation -eq 'Build' -and $InstalledEngine) {
            $arguments.Add('-NoEngineChanges')
            $reasons.Add('The installed-engine guard remains a fail-fast defense for the generic build request.')
        }
    }
    else {
        if ($BuildConcurrency -ne 'Auto') {
            throw 'BuildConcurrency applies only to Unreal build operations.'
        }
        $reasons.Add("$Operation is a non-UBT operation and uses only the exact workspace lease.")
        $reasons.Add('It may overlap only with operations in distinct workspaces.')
    }

    return [pscustomobject][ordered]@{
        Policy                 = $Policy
        Decision               = $decision
        Operation              = $Operation
        EngineRoot             = $root
        RequiresWorkspaceLease = $true
        RequiresEngineLease    = $ubtOperation
        WorkspaceLeaseBehavior = $leaseBehavior
        EngineLeaseBehavior    = if ($ubtOperation) { $leaseBehavior } else { 'NotRequired' }
        EngineLeaseKey         = if ($ubtOperation) { $root.ToUpperInvariant() } else { '' }
        EngineLane             = $engineLane
        RequestedBuildConcurrency = if ($Operation -eq 'Build' -and $TypedProjectBuild) { $BuildConcurrency } else { 'NotApplicable' }
        BuildConcurrency       = $selectedBuildConcurrency
        InstalledEngine        = $InstalledEngine
        UbtArguments           = @($arguments)
        Reasons                = @($reasons)
    }
}
