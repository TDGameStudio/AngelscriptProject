[CmdletBinding()]
param(
	[string]$ProjectRoot,
	[string]$OutputPath,
	[switch]$RequireComplete
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($ProjectRoot))
{
	$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..\..')).Path
}
else
{
	$ProjectRoot = (Resolve-Path -LiteralPath $ProjectRoot).Path
}
if ([string]::IsNullOrWhiteSpace($OutputPath))
{
	$OutputPath = Join-Path (Resolve-Path (Join-Path $PSScriptRoot '..\audits')).Path 'api-use.csv'
}

$AuditRoot = Resolve-Path (Join-Path $PSScriptRoot '..\audits')
$SdkRoot = Join-Path $ProjectRoot 'Plugins\Angelscript\Source\AngelscriptTest\AngelScriptSDK'
$SourceFiles = @(Get-ChildItem -LiteralPath $SdkRoot -Recurse -Include '*.cpp', '*.h' -File)
$Sources = foreach ($File in $SourceFiles)
{
	[pscustomobject]@{
		File = $File.FullName.Substring($SdkRoot.Length).TrimStart([char[]]@('\', '/')).Replace('\', '/')
		Text = Get-Content -LiteralPath $File.FullName -Raw
	}
}

function Test-TypedReceiverCall
{
	param(
		[Parameter(Mandatory)]
		[string]$Text,

		[Parameter(Mandatory)]
		[string[]]$ReceiverTypes,

		[Parameter(Mandatory)]
		[string]$Method
	)

	foreach ($ReceiverType in $ReceiverTypes)
	{
		$OwnerPattern = [regex]::Escape($ReceiverType)
		$DeclarationPattern =
			'\b' + $OwnerPattern +
			'\s*(?:(?:\*|&)\s*)?(?:(?:const|volatile)\s+)?(?<Name>[A-Za-z_][A-Za-z0-9_]*)'
		$ReceiverNames = @(
			[regex]::Matches($Text, $DeclarationPattern) |
				ForEach-Object { $_.Groups['Name'].Value } |
				Sort-Object -Unique
		)
		foreach ($ReceiverName in $ReceiverNames)
		{
			$CallPattern =
				'\b' + [regex]::Escape($ReceiverName) +
				'\s*(?:->|\.)\s*' + [regex]::Escape($Method) + '\s*\('
			if ($Text -match $CallPattern)
			{
				return $true
			}
		}

		$ExplicitCastPattern =
			'(?:static_cast|reinterpret_cast|const_cast)\s*<\s*' +
			$OwnerPattern + '\s*\*\s*>\s*\([^;]*?\)\s*->\s*' +
			[regex]::Escape($Method) + '\s*\('
		if ($Text -match $ExplicitCastPattern)
		{
			return $true
		}
	}
	return $false
}

$PublicApis = @(Import-Csv -LiteralPath (Join-Path $AuditRoot 'public-api.csv'))
$ReceiverTypesByInterface = @{
	asIScriptEngine = @('asIScriptEngine', 'asCScriptEngine')
	asIScriptContext = @('asIScriptContext', 'asCContext')
	asIScriptModule = @('asIScriptModule', 'asCModule', 'FScopedNativeModule')
	asIStringFactory = @('asIStringFactory', 'FNativeReviewStringFactory', 'FTrackingStringFactory')
	asIBinaryStream = @('asIBinaryStream', 'FMemoryBinaryStream', 'FSDKBytecodeStream')
}
$Rows = [System.Collections.Generic.List[object]]::new()
foreach ($Api in $PublicApis)
{
	$ReceiverTypes = @($Api.Interface)
	if ($ReceiverTypesByInterface.ContainsKey($Api.Interface))
	{
		$ReceiverTypes = @($ReceiverTypesByInterface[$Api.Interface])
	}
	$Matches = @(
		$Sources |
			Where-Object {
				Test-TypedReceiverCall -Text $_.Text -ReceiverTypes $ReceiverTypes -Method $Api.Method
			}
	)
	$ContractDisposition = $Api.CurrentStatus
	$HasContractDisposition =
		$ContractDisposition -in @('ContractCovered', 'SupersededByContract') -and
		-not [string]::IsNullOrWhiteSpace($Api.FinalCoverageIds)
	$IsDeferred =
		$ContractDisposition -eq 'ApiDeferred' -and
		-not [string]::IsNullOrWhiteSpace($Api.FinalCoverageIds)
	$Rows.Add([pscustomobject]@{
		Surface = 'Public'
		Owner = $Api.Interface
		Method = $Api.Method
		RequiredDisposition = 'DirectOrContract'
		OccurrenceFiles = $Matches.Count
		Files = (@($Matches.File | Sort-Object -Unique) -join ';')
		FinalCoverageIds = $Api.FinalCoverageIds
		MatchStrategy = 'TypedReceiver'
		State = $(
			if ($Matches.Count -gt 0) { 'Observed' }
			elseif ($HasContractDisposition) { 'ContractCovered' }
			elseif ($IsDeferred) { 'Deferred' }
			else { 'MissingDirectUse' }
		)
	})
}

foreach ($Api in Import-Csv -LiteralPath (Join-Path $AuditRoot 'debug-api.csv'))
{
	$Pattern = '(?:->|\.)\s*' + [regex]::Escape($Api.Api) + '\s*\('
	if ($Api.Api -eq 'DebugFramePtr')
	{
		$Pattern = '\bDebugFramePtr\b'
	}
	$Matches = @($Sources | Where-Object { $_.Text -match $Pattern })
	$Rows.Add([pscustomobject]@{
		Surface = 'Debug'
		Owner = $Api.Surface
		Method = $Api.Api
		RequiredDisposition = $(if ($Api.Classification -eq 'ApiDeferred') { 'Deferred' } else { 'DirectRequired' })
		OccurrenceFiles = $Matches.Count
		Files = (@($Matches.File | Sort-Object -Unique) -join ';')
		FinalCoverageIds = $Api.FinalCoverageIds
		MatchStrategy = 'DebugMethodName'
		State = $(if ($Api.Classification -eq 'ApiDeferred') { 'Deferred' } elseif ($Matches.Count -gt 0) { 'Observed' } else { 'MissingDirectUse' })
	})
}

$Rows | Export-Csv -LiteralPath $OutputPath -NoTypeInformation -Encoding utf8
$DirectFailures = @($Rows | Where-Object { $_.RequiredDisposition -eq 'DirectRequired' -and $_.State -ne 'Observed' })
$ContractFailures = @(
	$Rows |
		Where-Object {
			$_.RequiredDisposition -eq 'DirectOrContract' -and
			$_.State -notin @('Observed', 'ContractCovered', 'Deferred')
		}
)
$Failures = @($DirectFailures) + @($ContractFailures)
if ($RequireComplete -and $Failures.Count -gt 0)
{
	throw "Native SDK API-use audit has $($Failures.Count) unresolved API contracts ($($DirectFailures.Count) direct-only, $($ContractFailures.Count) direct-or-contract). First: $($Failures[0].Owner).$($Failures[0].Method)"
}

[pscustomobject]@{
	Rows = $Rows.Count
	Observed = @($Rows | Where-Object State -eq 'Observed').Count
	ContractCovered = @($Rows | Where-Object State -eq 'ContractCovered').Count
	Deferred = @($Rows | Where-Object State -eq 'Deferred').Count
	MissingDirectCalls = $DirectFailures.Count
	MissingDirectOrContract = $ContractFailures.Count
	Incomplete = $Failures.Count
	Output = $OutputPath
}
