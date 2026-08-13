[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$Assertions = 0

function Assert-Equal
{
	param(
		[Parameter(Mandatory = $true)] $Expected,
		[Parameter(Mandatory = $true)] $Actual,
		[Parameter(Mandatory = $true)] [string] $Message
	)

	if ($Expected -ne $Actual)
	{
		throw "ASSERT FAILED: $Message Expected '$Expected', actual '$Actual'."
	}
	$script:Assertions++
}

function New-Execution
{
	return [pscustomobject]@{
		Failed = $false
		Primary = $null
		ReportCount = 0
		Effects = [System.Collections.Generic.List[string]]::new()
		CleanupTrace = [System.Collections.Generic.List[string]]::new()
	}
}

function Set-PrimaryFailure
{
	param(
		[Parameter(Mandatory = $true)] $Execution,
		[Parameter(Mandatory = $true)] [string] $Kind,
		[Parameter(Mandatory = $true)] [string] $Message,
		[Parameter(Mandatory = $true)] [string] $Origin,
		[Parameter(Mandatory = $true)] [string] $Route,
		[bool] $AlreadyReported = $false
	)

	$Execution.Failed = $true
	if ($null -eq $Execution.Primary)
	{
		$Execution.Primary = [pscustomobject]@{
			Kind = $Kind
			Message = $Message
			Origin = $Origin
			Route = $Route
			Reported = $AlreadyReported
		}
	}
	if (-not $Execution.Primary.Reported)
	{
		$Execution.Primary.Reported = $true
		$Execution.ReportCount++
	}
}

function Invoke-Effect
{
	param(
		[Parameter(Mandatory = $true)] $Execution,
		[Parameter(Mandatory = $true)] [string] $Name
	)

	if (-not $Execution.Failed)
	{
		$Execution.Effects.Add($Name)
	}
}

function Adopt-BridgeFailure
{
	param(
		[Parameter(Mandatory = $true)] $Outer,
		[Parameter(Mandatory = $true)] $Inner
	)

	if ($Inner.Failed)
	{
		Set-PrimaryFailure -Execution $Outer `
			-Kind $Inner.Primary.Kind `
			-Message $Inner.Primary.Message `
			-Origin $Inner.Primary.Origin `
			-Route 'VMBridge' `
			-AlreadyReported $Inner.Primary.Reported
	}
}

function Get-CleanupPlan
{
	param([object[]] $Slots)

	return @($Slots |
		Where-Object { $_.Constructed -and -not $_.Destroyed -and $_.ScopeActive } |
		Sort-Object -Property DeclarationOrder -Descending)
}

function Invoke-CleanupPlan
{
	param(
		[Parameter(Mandatory = $true)] $Execution,
		[object[]] $Plan,
		[string] $ThrowingSlot = ''
	)

	foreach ($Slot in @($Plan))
	{
		$Execution.CleanupTrace.Add($Slot.Name)
		$Slot.Destroyed = $true
		if ($Slot.Name -eq $ThrowingSlot)
		{
			Set-PrimaryFailure -Execution $Execution `
				-Kind 'CleanupFailure' `
				-Message "cleanup:$($Slot.Name)" `
				-Origin $Slot.Name `
				-Route 'Cleanup'
		}
	}
}

$Direct = New-Execution
Invoke-Effect -Execution $Direct -Name 'arg2'
Set-PrimaryFailure -Execution $Direct -Kind ScriptThrow -Message stop `
	-Origin Helper -Route DirectSemantic
Invoke-Effect -Execution $Direct -Name 'arg1'
Invoke-Effect -Execution $Direct -Name 'target'
Assert-Equal 'arg2' ($Direct.Effects -join ',') `
	'Direct failure must suppress every later operand and target effect.'
Assert-Equal 'stop' $Direct.Primary.Message `
	'Direct failure must retain the exact primary message.'
Assert-Equal 'Helper' $Direct.Primary.Origin `
	'Direct failure must retain the throwing helper rather than the root.'
Assert-Equal 1 $Direct.ReportCount `
	'Direct primary failure must be reported exactly once.'

Set-PrimaryFailure -Execution $Direct -Kind OutOfBounds -Message replacement `
	-Origin Caller -Route DirectSemantic
Assert-Equal 'stop' $Direct.Primary.Message `
	'A later failure must not replace the first primary exception.'
Assert-Equal 1 $Direct.ReportCount `
	'Reobserving an existing primary failure must not report it again.'

$Inner = New-Execution
Set-PrimaryFailure -Execution $Inner -Kind DivideByZero -Message 'divide by zero' `
	-Origin VmHelper -Route VM -AlreadyReported $false
$Outer = New-Execution
Adopt-BridgeFailure -Outer $Outer -Inner $Inner
Assert-Equal $true $Outer.Failed `
	'VM bridge must mark the outer execution as failed.'
Assert-Equal 'divide by zero' $Outer.Primary.Message `
	'VM bridge must adopt the inner exception text.'
Assert-Equal 'VmHelper' $Outer.Primary.Origin `
	'VM bridge must adopt the inner exception origin.'
Assert-Equal 'VMBridge' $Outer.Primary.Route `
	'VM bridge must describe the adoption route without replacing origin.'
Assert-Equal 0 $Outer.ReportCount `
	'Adopting an already reported inner exception must not report it twice.'

$Slots = @(
	[pscustomobject]@{ Name = 'First'; DeclarationOrder = 0; Constructed = $true; Destroyed = $false; ScopeActive = $true }
	[pscustomobject]@{ Name = 'Second'; DeclarationOrder = 1; Constructed = $true; Destroyed = $false; ScopeActive = $true }
	[pscustomobject]@{ Name = 'Partial'; DeclarationOrder = 2; Constructed = $false; Destroyed = $false; ScopeActive = $true }
	[pscustomobject]@{ Name = 'NormalExit'; DeclarationOrder = 3; Constructed = $true; Destroyed = $true; ScopeActive = $true }
	[pscustomobject]@{ Name = 'ExitedScope'; DeclarationOrder = 4; Constructed = $true; Destroyed = $false; ScopeActive = $false }
)
$Plan = @(Get-CleanupPlan -Slots $Slots)
Assert-Equal 'Second,First' (($Plan | ForEach-Object Name) -join ',') `
	'Cleanup plan must contain only live owned slots in reverse declaration order.'

$CleanupExecution = New-Execution
Set-PrimaryFailure -Execution $CleanupExecution -Kind ScriptThrow `
	-Message primary -Origin Body -Route DirectSemantic
Invoke-CleanupPlan -Execution $CleanupExecution -Plan $Plan -ThrowingSlot Second
Assert-Equal 'Second,First' ($CleanupExecution.CleanupTrace -join ',') `
	'Cleanup execution must follow the verified reverse plan.'
Assert-Equal 'primary' $CleanupExecution.Primary.Message `
	'Cleanup failure must not replace the primary body exception.'
Assert-Equal $true $Slots[0].Destroyed `
	'Earlier live slot must be destroyed exactly once after the later slot.'
Assert-Equal $true $Slots[1].Destroyed `
	'Later live slot must be destroyed exactly once.'
Assert-Equal $false $Slots[2].Destroyed `
	'Partially constructed slot must not be destroyed as live.'
Assert-Equal $true $Slots[3].Destroyed `
	'Previously destroyed slot must remain destroyed without a second cleanup.'
Assert-Equal $false $Slots[4].Destroyed `
	'An exited-scope slot must not be reintroduced into failure cleanup.'

$RemainingPlan = @(Get-CleanupPlan -Slots $Slots)
Assert-Equal 0 $RemainingPlan.Count `
	'Recomputing cleanup after successful actions must produce no duplicate destruction.'

Write-Output "PASS semantic exception/cleanup contract: $Assertions assertions"
Write-Output 'Contract: first failure wins, bridge adoption does not re-report, and only live slots clean up once in reverse declaration order.'
