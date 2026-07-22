param(
	[ValidateSet('Structure', 'Complete')]
	[string]$Phase,
	[string]$RepositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..\..')).Path
)

$ErrorActionPreference = 'Stop'

$SdkRoot = Join-Path $RepositoryRoot 'Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK'
$TestRoot = Join-Path $RepositoryRoot 'Plugins/Angelscript/Source/AngelscriptTest'
$ChangeRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$LedgerPath = Join-Path $ChangeRoot 'audits/test-methods.csv'
$ScenarioPath = Join-Path $ChangeRoot 'audits/test-scenarios.md'
$RequiredDomains = @('Engine', 'Frontend', 'Compiler', 'Runtime', 'Module', 'TypeSystem', 'Language', 'Embedding', 'Conformance')
$Failures = [Collections.Generic.List[string]]::new()

function Add-AuditFailure([string]$Message)
{
	$Failures.Add($Message)
}

function Get-SourceMatches([string]$Pattern, [string[]]$Paths)
{
	return @(rg -n --glob '*.h' --glob '*.cpp' --glob '*.inl' $Pattern @Paths 2>$null)
}

function Get-FinalTestSourcePath([string]$FinalFile)
{
	if ([string]::IsNullOrWhiteSpace($FinalFile))
	{
		return $null
	}

	return Join-Path $TestRoot $FinalFile
}

if (-not (Test-Path -LiteralPath $SdkRoot))
{
	throw "Native SDK test root is missing: $SdkRoot"
}

$SdkSources = @(Get-ChildItem -LiteralPath $SdkRoot -Recurse -File -Include '*.cpp', '*.h')
$RegisteringSources = @($SdkSources | Where-Object {
	(Select-String -LiteralPath $_.FullName -Pattern 'TEST_CLASS_WITH_FLAGS' -Quiet)
})

$LegacyHelpers = @('AngelscriptSDKTestUtilities.h', 'AngelscriptSDKTestExecutionHelpers.h', 'AngelscriptBuilderTestSupport.h')
foreach ($LegacyHelper in $LegacyHelpers)
{
	$LegacyPath = Join-Path $SdkRoot $LegacyHelper
	if (Test-Path -LiteralPath $LegacyPath)
	{
		Add-AuditFailure("Legacy SDK helper still exists: $LegacyHelper")
	}

	$References = @(rg -n --glob '*.cpp' --glob '*.h' ([regex]::Escape($LegacyHelper)) $SdkRoot 2>$null)
	if ($References.Count -gt 0)
	{
		Add-AuditFailure("Legacy SDK helper is still included or referenced: $LegacyHelper")
	}
}

$FalseGates = @(Get-SourceMatches 'WITH_ANGELSCRIPT_UNITTESTS\s*&&\s*0|#if\s+0\b' @($SdkRoot))
if ($FalseGates.Count -gt 0)
{
	Add-AuditFailure('Native SDK source still contains a constant-false test gate')
}

$DefaultMessageCollector = @(Get-SourceMatches 'GetDefaultMessageCollector|CreateNativeEngine\s*\([^\)]*=\s*nullptr' @($SdkRoot))
if ($DefaultMessageCollector.Count -gt 0)
{
	Add-AuditFailure('Native SDK support retains a default global message-collector path')
}

$MissingBodyGates = @($RegisteringSources | Where-Object {
	-not (Select-String -LiteralPath $_.FullName -Pattern '#if\s+WITH_ANGELSCRIPT_UNITTESTS\b' -Quiet)
})
foreach ($Source in $MissingBodyGates)
{
	Add-AuditFailure("Registering source lacks WITH_ANGELSCRIPT_UNITTESTS body gate: $($Source.FullName)")
}

$StreamDefinitions = @(Get-SourceMatches '^\s*class\s+FMemoryBinaryStream\s+final' @($SdkRoot))
if ($StreamDefinitions.Count -ne 1)
{
	Add-AuditFailure("Expected exactly one FMemoryBinaryStream definition, found $($StreamDefinitions.Count)")
}

$AmbiguousLookup = @(Get-SourceMatches 'GetFunctionByName\([^\r\n]*\)[\s\S]{0,400}GetFunctionByDecl|GetFunctionCount\(\)\s*==\s*1' @($SdkRoot))
if ($AmbiguousLookup.Count -gt 0)
{
	Add-AuditFailure('SDK support retains an ambiguous declaration-lookup fallback')
}

if ($Phase -eq 'Complete')
{
	foreach ($Domain in $RequiredDomains)
	{
		$DomainPath = Join-Path $SdkRoot $Domain
		if (-not (Test-Path -LiteralPath $DomainPath))
		{
			Add-AuditFailure("Final SDK domain directory is missing: $Domain")
		}
	}

	$RootRegisteringSources = @($RegisteringSources | Where-Object { $_.DirectoryName -eq $SdkRoot })
	foreach ($Source in $RootRegisteringSources)
	{
		Add-AuditFailure("Final SDK registration source remains at the root: $($Source.Name)")
	}

	$ForbiddenNames = @(Get-SourceMatches 'ASSDK|NativeReference' @($SdkRoot))
	if ($ForbiddenNames.Count -gt 0)
	{
		Add-AuditFailure('SDK source retains a retired test naming token')
	}

	$AddonDependencies = @(Get-SourceMatches 'sdk[/\\]add_on|add_on[/\\]' @($SdkRoot))
	if ($AddonDependencies.Count -gt 0)
	{
		Add-AuditFailure('SDK test source depends on an excluded add-on library')
	}

	$FutureFiles = @($SdkSources | Where-Object { $_.Name -match '238' })
	foreach ($FutureFile in $FutureFiles)
	{
		$Text = Get-Content -LiteralPath $FutureFile.FullName -Raw
		if ($Text -notmatch 'TEST_CLASS_WITH_FLAGS_AND_TAGS' -or
			$Text -notmatch 'EAutomationTestFlags::Disabled' -or
			$Text -notmatch '#as-v238-backport')
		{
			Add-AuditFailure("Future 2.38 test does not use the required disabled tagged registration: $($FutureFile.Name)")
		}
	}

	if (-not (Test-Path -LiteralPath $LedgerPath))
	{
		Add-AuditFailure('Method disposition ledger is missing')
	}
	else
	{
		$Rows = @(Import-Csv -LiteralPath $LedgerPath)
		if ($Rows.Count -ne 433)
		{
			Add-AuditFailure("Method disposition ledger must retain 433 baseline rows, found $($Rows.Count)")
		}

		foreach ($Row in $Rows)
		{
			$FinalPath = Get-FinalTestSourcePath $Row.FinalFile
			if ($null -eq $FinalPath -or -not (Test-Path -LiteralPath $FinalPath))
			{
				Add-AuditFailure("Ledger final file is missing: $($Row.FinalFile) for $($Row.CurrentFile)::$($Row.CurrentMethod)")
				continue
			}

			$FinalText = Get-Content -LiteralPath $FinalPath -Raw
			if ($FinalText -notmatch [regex]::Escape("$($Row.FinalClass)"))
			{
				Add-AuditFailure("Ledger final class is absent: $($Row.FinalFile)::$($Row.FinalClass)")
			}
			if ($FinalText -notmatch [regex]::Escape("TEST_METHOD($($Row.FinalMethod))"))
			{
				Add-AuditFailure("Ledger final method is absent: $($Row.FinalFile)::$($Row.FinalMethod)")
			}
		}
	}

	if (-not (Test-Path -LiteralPath $ScenarioPath))
	{
		Add-AuditFailure('Behavior scenario record is missing')
	}
}

if ($Failures.Count -gt 0)
{
	$Failures | ForEach-Object { Write-Output "FAIL: $_" }
	throw "Native SDK $Phase audit failed with $($Failures.Count) issue(s)."
}

Write-Output "Native SDK $Phase audit passed: $($SdkSources.Count) source files, $($RegisteringSources.Count) registering sources."
