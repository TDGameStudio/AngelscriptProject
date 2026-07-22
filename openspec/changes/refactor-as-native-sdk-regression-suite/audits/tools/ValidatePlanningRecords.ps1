param(
	[string]$RepositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..\..\..')).Path,
	[switch]$AllowMovedSources
)

$ErrorActionPreference = 'Stop'

$ChangeRoot = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$SdkRoot = Join-Path $RepositoryRoot 'Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK'
$LedgerPath = Join-Path $ChangeRoot 'audits/test-methods.csv'
$FileMapPath = Join-Path $ChangeRoot 'audits/file-map.md'
$ScenarioPath = Join-Path $ChangeRoot 'audits/test-scenarios.md'
$CompatibilityPath = Join-Path $ChangeRoot 'audits/upstream-compatibility.md'
$TasksPath = Join-Path $ChangeRoot 'tasks.md'

function Assert-Planning([bool]$Condition, [string]$Message)
{
	if (-not $Condition) { throw $Message }
}

if (-not $AllowMovedSources)
{
	$ActualFiles = @(Get-ChildItem $SdkRoot -File | Select-Object -ExpandProperty Name)
	Assert-Planning ($ActualFiles.Count -eq 82) "Expected 82 current SDK files, found $($ActualFiles.Count)"

	$FileMapLines = Get-Content $FileMapPath
	$MappedCurrentFiles = [Collections.Generic.List[string]]::new()
	foreach ($Line in $FileMapLines)
	{
		if ($Line -match '^\| `([^`]+)` \|' -and $ActualFiles -contains $Matches[1])
		{
			$MappedCurrentFiles.Add($Matches[1])
		}
	}

	Assert-Planning ($MappedCurrentFiles.Count -eq 82) "Expected 82 current-file rows in file-map.md, found $($MappedCurrentFiles.Count)"
	Assert-Planning ((@($MappedCurrentFiles | Sort-Object -Unique)).Count -eq 82) 'Current-file rows in file-map.md are not unique'
	Assert-Planning (-not @($ActualFiles | Where-Object { $_ -notin $MappedCurrentFiles })) 'file-map.md is missing a current SDK file'
}

$Rows = @(Import-Csv $LedgerPath)
Assert-Planning ($Rows.Count -eq 433) "Expected 433 method-ledger rows, found $($Rows.Count)"

$SourceKeys = @($Rows | ForEach-Object { "$($_.CurrentFile)|$($_.CurrentLine)|$($_.CurrentMethodSha256)" })
Assert-Planning ((@($SourceKeys | Sort-Object -Unique)).Count -eq 433) 'Method-ledger source keys are not unique'

$AllowedDispositions = @('Retain', 'Move', 'Rename', 'Merge', 'Replace', 'DeleteDuplicate', 'DeleteInvalid')
Assert-Planning (-not @($Rows | Where-Object Disposition -notin $AllowedDispositions)) 'Method ledger contains an unsupported disposition'

$RequiredFields = @('CurrentFile','CurrentClass','CurrentMethod','CurrentLine','CurrentMethodSha256','CurrentPrefix','Disposition','FinalDomain','FinalFile','FinalClass','FinalMethod','Classification','Rationale')
foreach ($Field in $RequiredFields)
{
	Assert-Planning (-not @($Rows | Where-Object { [string]::IsNullOrWhiteSpace($_.$Field) })) "Method ledger contains an empty $Field"
}

$ReplacementRows = @($Rows | Where-Object Disposition -eq 'Replace')
Assert-Planning ($ReplacementRows.Count -eq 12) "Expected 12 replaced constant-false methods, found $($ReplacementRows.Count)"
$ReplacementFiles = @($ReplacementRows.CurrentFile | Sort-Object -Unique)
Assert-Planning ($ReplacementFiles.Count -eq 3) "Expected replacements from three files, found $($ReplacementFiles.Count)"
Assert-Planning (-not @($ReplacementFiles | Where-Object { $_ -notin @('AngelscriptAtomicTests.cpp','AngelscriptThreadTests.cpp','AngelscriptStringUtilTests.cpp') })) 'Unexpected file contributes constant-false replacements'

$ForbiddenFinalTokens = @(('M' + 'atrix'), 'Compat', 'OrDocument', 'IfSupported', 'ASSDK')
foreach ($Token in $ForbiddenFinalTokens)
{
	Assert-Planning (-not @($Rows | Where-Object { $_.FinalFile -match [regex]::Escape($Token) -or $_.FinalClass -match [regex]::Escape($Token) -or $_.FinalMethod -match [regex]::Escape($Token) })) "Final ledger names contain forbidden token $Token"
}

Assert-Planning (-not @($Rows | Where-Object { $_.FinalFile -match 'NativeReference(Compiler|Parser|Script|Context|Save|Tokenizer)' -or $_.FinalClass -match 'NativeReference(Compiler|Parser|Script|Context|Save|Tokenizer)' -or $_.FinalMethod -match 'NativeReference(Compiler|Parser|Script|Context|Save|Tokenizer)' })) 'Final ledger names retain a historical reference-port subject'

$FileMapText = Get-Content -Raw $FileMapPath
foreach ($FinalFile in @($Rows.FinalFile | Sort-Object -Unique))
{
	$RelativeFinalFile = $FinalFile -replace '^AngelScriptSDK/', ''
	Assert-Planning ($FileMapText.Contains($RelativeFinalFile) -or $FileMapText.Contains($FinalFile)) "Final ledger file is absent from file-map.md: $FinalFile"
}

$ScenarioText = Get-Content -Raw $ScenarioPath
foreach ($Domain in @('Engine','Frontend','Compiler','Runtime','Module','TypeSystem','Language','Embedding','Conformance'))
{
	Assert-Planning ($ScenarioText -match "## $Domain domain") "test-scenarios.md is missing the $Domain domain"
}

foreach ($Theme in @('Declarations','Functions','Variables','Properties','Constructors','Destructors','Inheritance','References','Expressions','Operators','Conversions','ControlFlow','Foreach','Exceptions'))
{
	Assert-Planning ($ScenarioText -match "### $Theme(\r?\n)") "test-scenarios.md is missing the $Theme language theme"
}

$CompatibilityText = Get-Content -Raw $CompatibilityPath
foreach ($Capability in @('using namespace','member initialization','special-member','bool context','anonymous functions','variadic script functions','function templates','context stack serialization','JIT V2','computed-goto'))
{
	Assert-Planning ($CompatibilityText.Contains($Capability)) "upstream-compatibility.md is missing $Capability"
}

$TaskLines = @(Get-Content $TasksPath | Where-Object { $_ -match '^- \[[ x]\] \d+\.\d+ ' })
Assert-Planning ($TaskLines.Count -gt 100) "Expected the expanded task checklist, found $($TaskLines.Count) tasks"
Assert-Planning (-not @($TaskLines | Where-Object { $_ -notmatch '<!-- (TDD|Non-TDD) -->' })) 'A task lacks a TDD/Non-TDD marker'

if ($AllowMovedSources)
{
	Write-Output "Planning records valid after source moves: 433 methods, 12 replacements, 9 domains, 14 language themes, $($TaskLines.Count) labeled tasks."
}
else
{
	Write-Output "Planning records valid: 82 files, 433 methods, 12 replacements, 9 domains, 14 language themes, $($TaskLines.Count) labeled tasks."
}
