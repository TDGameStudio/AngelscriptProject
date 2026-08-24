[CmdletBinding()]
param([string]$RepoRoot)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module (Join-Path $PSScriptRoot 'GenerationInventoryCommon.psm1') -Force
$ChangeRoot = Resolve-GenerationPlanRoot -ScriptRoot $PSScriptRoot
$RepositoryRoot = Resolve-RepositoryRoot -ChangeRoot $ChangeRoot -RepoRoot $RepoRoot
$Failures = [System.Collections.Generic.List[string]]::new()
$Checks = [System.Collections.Generic.List[object]]::new()

function Add-Check
{
	param([string]$Name, [bool]$Passed, [string]$Detail)
	$Checks.Add([pscustomobject][ordered]@{ Name=$Name; Passed=$Passed; Detail=$Detail })
	if (-not $Passed) { $Failures.Add("$Name`: $Detail") }
}

function Test-ExactSet
{
	param([object[]]$Left, [object[]]$Right)
	$LeftSorted = @($Left | ForEach-Object { [string]$_ } | Sort-Object -Unique)
	$RightSorted = @($Right | ForEach-Object { [string]$_ } | Sort-Object -Unique)
	return $LeftSorted.Count -eq $RightSorted.Count -and -not (Compare-Object -ReferenceObject $LeftSorted -DifferenceObject $RightSorted)
}

function Test-RequiredValues
{
	param([object[]]$Rows, [string[]]$Fields, [string]$CatalogName)
	$Missing = [System.Collections.Generic.List[string]]::new()
	for ($Index = 0; $Index -lt $Rows.Count; ++$Index)
	{
		foreach ($Field in $Fields)
		{
			if (-not ($Rows[$Index].PSObject.Properties.Name -contains $Field) -or [string]::IsNullOrWhiteSpace([string]$Rows[$Index].$Field))
			{
				$Missing.Add("row=$($Index + 1),field=$Field")
				if ($Missing.Count -ge 20) { break }
			}
		}
		if ($Missing.Count -ge 20) { break }
	}
	Add-Check -Name "$CatalogName required fields" -Passed ($Missing.Count -eq 0) -Detail $(if ($Missing.Count -eq 0) { "$($Rows.Count) rows complete" } else { $Missing -join '; ' })
}

$RequiredFiles = @(
	'.openspec.yaml','proposal.md','design.md','tasks.md','verification.md',
	'specs/as-test-source-generation-rules/spec.md',
	'specs/as-test-code-static-release/spec.md',
	'specs/as-test-source-generation-inventory/spec.md',
	'catalogs/authored-testsource-static-functions.csv',
	'catalogs/sdk-generated-product-rules.csv',
	'catalogs/coverage-file-registry.csv',
	'catalogs/coverage-generation-disposition.csv',
	'catalogs/inline-as-generation-disposition.csv',
	'catalogs/recipe-family-registry.csv',
	'catalogs/static-function-registry.csv',
	'research/current-python-generator.md',
	'research/native-sdk-generation.md',
	'research/coverage-generation.md',
	'research/legacy-testcode.md',
	'research/generator-reference-lessons.md',
	'attachments/planning/progress.md',
	'attachments/planning/issues.md',
	'attachments/planning/decisions.md',
	'attachments/implementation/progress.md',
	'attachments/implementation/issues.md',
	'attachments/implementation/openspec-refactors.md',
	'attachments/implementation/task-body-template.md',
	'scripts/GenerationInventoryCommon.psm1',
	'scripts/ExportCoverageMethodInventory.ps1',
	'scripts/ExportCurrentInlineAsInventory.ps1',
	'scripts/BuildGenerationTaskCatalogs.ps1',
	'scripts/ValidateGenerationRulePlan.ps1'
)
$MissingFiles = @($RequiredFiles | Where-Object { -not (Test-Path -LiteralPath (Join-Path $ChangeRoot $_) -PathType Leaf) })
Add-Check -Name 'Required artifact files' -Passed ($MissingFiles.Count -eq 0) -Detail $(if ($MissingFiles.Count -eq 0) { "$($RequiredFiles.Count) required files present" } else { $MissingFiles -join '; ' })

$ManualPath = Join-Path $RepositoryRoot 'openspec/changes/test-as-manual-bind-source-coverage/inventory/planned-test-sources.csv'
$RegistryPath = Join-Path $RepositoryRoot 'openspec/changes/test-as-native-sdk-comprehensive-coverage/catalogs/generated-source-registry.csv'
$CardinalityPath = Join-Path $RepositoryRoot 'openspec/changes/test-as-native-sdk-comprehensive-coverage/audits/product-cardinalities.csv'
$Authored = @(Import-Csv -LiteralPath (Join-Path $ChangeRoot 'catalogs/authored-testsource-static-functions.csv'))
$Sdk = @(Import-Csv -LiteralPath (Join-Path $ChangeRoot 'catalogs/sdk-generated-product-rules.csv'))
$CoverageFileRegistry = @(Import-Csv -LiteralPath (Join-Path $ChangeRoot 'catalogs/coverage-file-registry.csv'))
$Coverage = @(Import-Csv -LiteralPath (Join-Path $ChangeRoot 'catalogs/coverage-generation-disposition.csv'))
$Inline = @(Import-Csv -LiteralPath (Join-Path $ChangeRoot 'catalogs/inline-as-generation-disposition.csv'))
$Recipes = @(Import-Csv -LiteralPath (Join-Path $ChangeRoot 'catalogs/recipe-family-registry.csv'))
$Static = @(Import-Csv -LiteralPath (Join-Path $ChangeRoot 'catalogs/static-function-registry.csv'))
$Manual = @(Import-Csv -LiteralPath $ManualPath)
$Registry = @(Import-Csv -LiteralPath $RegistryPath)
$Cardinalities = @(Import-Csv -LiteralPath $CardinalityPath)

Add-Check -Name 'Authored row count' -Passed ($Authored.Count -eq 614) -Detail "expected=614 actual=$($Authored.Count)"
Add-Check -Name 'Authored paths exact' -Passed (Test-ExactSet -Left $Authored.SourcePath -Right $Manual.TargetPath) -Detail 'authored SourcePath set must equal manual TargetPath set'
Add-Check -Name 'Authored task IDs exact' -Passed (Test-ExactSet -Left $Authored.ManualBindTaskId -Right $Manual.TaskId) -Detail 'authored ManualBindTaskId set must equal manual TaskId set'
Add-Check -Name 'Authored CaseKeys unique' -Passed ((@($Authored.CaseKey | Sort-Object -Unique)).Count -eq $Authored.Count) -Detail "rows=$($Authored.Count) unique=$(@($Authored.CaseKey | Sort-Object -Unique).Count)"
Test-RequiredValues -Rows $Authored -CatalogName 'Authored catalog' -Fields @('TaskId','CaseKey','SourcePath','ManualBindTaskId','BindIds','SurfaceIds','ReferenceIds','SourceShape','PlannedSymbols','GeneratedCppSymbol','TestScope','Inputs','ExpectedObservations','ExpectedComments','Harness','Dependencies','Status')

Add-Check -Name 'SDK row count' -Passed ($Sdk.Count -eq 271) -Detail "expected=271 actual=$($Sdk.Count)"
Add-Check -Name 'SDK products exact registry' -Passed (Test-ExactSet -Left $Sdk.ProductId -Right $Registry.ProductId) -Detail 'SDK ProductId set must equal generated-source registry'
$CardinalityProductIds = @($Cardinalities.ProductId)
Add-Check -Name 'SDK products exist in cardinalities' -Passed (@($Sdk.ProductId | Where-Object { $_ -notin $CardinalityProductIds }).Count -eq 0) -Detail 'every SDK source product requires a cardinality row'
$SdkCellSum = ($Sdk | Measure-Object -Property ExpandedCells -Sum).Sum
Add-Check -Name 'SDK mandatory cell sum' -Passed ([int]$SdkCellSum -eq 45760) -Detail "expected=45760 actual=$SdkCellSum"
Add-Check -Name 'SDK ProductIds unique' -Passed ((@($Sdk.ProductId | Sort-Object -Unique)).Count -eq $Sdk.Count) -Detail "rows=$($Sdk.Count) unique=$(@($Sdk.ProductId | Sort-Object -Unique).Count)"
Add-Check -Name 'SDK no-replacement status' -Passed (@($Sdk | Where-Object RuleStatus -ne 'PlannedNoReplacement').Count -eq 0) -Detail 'every SDK product must remain PlannedNoReplacement'
Test-RequiredValues -Rows $Sdk -CatalogName 'SDK catalog' -Fields @('TaskId','ProductId','LegacyFile','LegacyClass','LegacyMethod','LegacyGenerator','Theme','Axes','ExpandedCells','Classification','Evidence','RecipeFamily','GeneratedCppSymbol','GeneratedAsScope','OracleScope','FixedInputs','RandomSlots','Constraints','NegativeMutation','RecoverySource','CommentKnowledge','References','RuleStatus')

$CoverageFiles = @($CoverageFileRegistry.File | Sort-Object -Unique)
Add-Check -Name 'Coverage file count' -Passed ($CoverageFileRegistry.Count -eq 90 -and $CoverageFiles.Count -eq 90) -Detail "expected=90 rows=$($CoverageFileRegistry.Count) unique=$($CoverageFiles.Count)"
Add-Check -Name 'Coverage file method total' -Passed ([int](($CoverageFileRegistry | Measure-Object -Property MethodCount -Sum).Sum) -eq 1022) -Detail "expected=1022 actual=$(($CoverageFileRegistry | Measure-Object -Property MethodCount -Sum).Sum)"
Add-Check -Name 'Coverage support-only file' -Passed (@($CoverageFileRegistry | Where-Object Role -eq 'SupportOnly').Count -eq 1 -and @($CoverageFileRegistry | Where-Object Role -eq 'SupportOnly')[0].File -like '*AngelscriptCoverageGCTestHelpers.cpp') -Detail 'exactly AngelscriptCoverageGCTestHelpers.cpp has no TEST_METHOD'
Test-RequiredValues -Rows $CoverageFileRegistry -CatalogName 'Coverage file registry' -Fields @('File','MethodCount','Role','Reference')
Add-Check -Name 'Coverage method row count' -Passed ($Coverage.Count -eq 1022) -Detail "expected=1022 actual=$($Coverage.Count)"
Add-Check -Name 'Coverage disposition IDs unique' -Passed ((@($Coverage.DispositionId | Sort-Object -Unique)).Count -eq $Coverage.Count) -Detail "rows=$($Coverage.Count) unique=$(@($Coverage.DispositionId | Sort-Object -Unique).Count)"
Add-Check -Name 'Coverage owner tuples unique' -Passed ((@($Coverage | ForEach-Object { "$($_.File)|$($_.Class)|$($_.Method)" } | Sort-Object -Unique)).Count -eq $Coverage.Count) -Detail 'file/class/method must identify every method once'
Test-RequiredValues -Rows $Coverage -CatalogName 'Coverage catalog' -Fields @('DispositionId','File','Class','Method','Line','Domain','SourceShape','ExistingOracle','Disposition','CandidateRecipe','ProductAxes','GeneratedAsScope','HostRequirements','Rationale','ReferenceProducts','FutureCaseKey')

$CurrentCoverageRoot = Join-Path $RepositoryRoot 'Plugins/Angelscript/Source/AngelscriptTest/Coverage'
$CurrentCoverageFiles = @(Get-ChildItem -LiteralPath $CurrentCoverageRoot -Recurse -File -Filter '*.cpp')
$CurrentCoverageMethods = 0
foreach ($File in $CurrentCoverageFiles) { $CurrentCoverageMethods += [regex]::Matches([System.IO.File]::ReadAllText($File.FullName), '\bTEST_METHOD\s*\(').Count }
Add-Check -Name 'Current Coverage baseline' -Passed ($CurrentCoverageFiles.Count -eq 90 -and $CurrentCoverageMethods -eq 1022) -Detail "files=$($CurrentCoverageFiles.Count) methods=$CurrentCoverageMethods"

Add-Check -Name 'Inline row count snapshot' -Passed ($Inline.Count -eq 3559) -Detail "expected=3559 actual=$($Inline.Count)"
Add-Check -Name 'Inline IDs unique' -Passed ((@($Inline.InlineId | Sort-Object -Unique)).Count -eq $Inline.Count) -Detail "rows=$($Inline.Count) unique=$(@($Inline.InlineId | Sort-Object -Unique).Count)"
$AllowedDispositions = @('AuthoredExport','GeneratedRecipe','SpecializedScenario')
$InvalidDispositions = @($Coverage.Disposition + $Inline.Disposition | Where-Object { $_ -notin $AllowedDispositions } | Sort-Object -Unique)
Add-Check -Name 'Disposition values' -Passed ($InvalidDispositions.Count -eq 0) -Detail $(if ($InvalidDispositions.Count -eq 0) { $AllowedDispositions -join ';' } else { $InvalidDispositions -join ';' })
Test-RequiredValues -Rows $Inline -CatalogName 'Inline catalog' -Fields @('InlineId','File','Class','Method','Line','ExtractionForm','SourceUnitCount','ApproxShape','ExistingExecutionKind','ExistingOracle','ReturnTypes','Disposition','RecipeFamily','FutureCaseKey','GeneratedCppSymbol','GeneratedAsScope','References','Rationale')

$CurrentMacroCount = 0
$TestRoot = Join-Path $RepositoryRoot 'Plugins/Angelscript/Source/AngelscriptTest'
foreach ($File in (Get-ChildItem -LiteralPath $TestRoot -Recurse -File | Where-Object { $_.Extension -in @('.cpp','.h') }))
{
	$CurrentMacroCount += [regex]::Matches([System.IO.File]::ReadAllText($File.FullName), '\bASTEST_AS[A-Z0-9_]*\s*\(').Count
}
$CatalogMacroCount = @($Inline | Where-Object ExtractionForm -like 'ASTEST_AS*').Count
Add-Check -Name 'Inline ASTEST_AS completeness' -Passed ($CurrentMacroCount -eq $CatalogMacroCount -and $CurrentMacroCount -eq 2374) -Detail "source=$CurrentMacroCount catalog=$CatalogMacroCount recorded=2374"

Add-Check -Name 'Recipe family count' -Passed ($Recipes.Count -eq 22) -Detail "expected=22 actual=$($Recipes.Count)"
Add-Check -Name 'Recipe IDs unique' -Passed ((@($Recipes.RecipeId | Sort-Object -Unique)).Count -eq $Recipes.Count) -Detail "rows=$($Recipes.Count) unique=$(@($Recipes.RecipeId | Sort-Object -Unique).Count)"
Test-RequiredValues -Rows $Recipes -CatalogName 'Recipe registry' -Fields @('RecipeId','Owner','InputSchema','ExplicitAxes','RandomSlots','Emits','OracleKinds','NegativePolicy','CommentPolicy','PrimaryReferences','InitialConsumers')

$ExpectedStaticCount = 614 + 271 + @($Coverage | Where-Object Disposition -eq 'GeneratedRecipe').Count + @($Inline | Where-Object { $_.Disposition -eq 'GeneratedRecipe' -and $_.File -notmatch '/Coverage/' }).Count
Add-Check -Name 'Static registry count' -Passed ($Static.Count -eq $ExpectedStaticCount -and $Static.Count -eq 1311) -Detail "expectedComputed=$ExpectedStaticCount recorded=1311 actual=$($Static.Count)"
Add-Check -Name 'Static CaseKeys unique' -Passed ((@($Static.CaseKey | Sort-Object -Unique)).Count -eq $Static.Count) -Detail "rows=$($Static.Count) unique=$(@($Static.CaseKey | Sort-Object -Unique).Count)"
Add-Check -Name 'Static symbols unique' -Passed ((@($Static.CppSymbol | Sort-Object -Unique)).Count -eq $Static.Count) -Detail "rows=$($Static.Count) unique=$(@($Static.CppSymbol | Sort-Object -Unique).Count)"
Add-Check -Name 'Static authored coverage' -Passed (Test-ExactSet -Left @($Static | Where-Object Origin -eq 'Authored' | ForEach-Object CaseKey) -Right $Authored.CaseKey) -Detail 'all and only authored CaseKeys require authored static entries'
Add-Check -Name 'Static SDK product granularity' -Passed (@($Static | Where-Object Origin -eq 'NativeSDK').Count -eq 271) -Detail "expected=271 actual=$(@($Static | Where-Object Origin -eq 'NativeSDK').Count)"
Test-RequiredValues -Rows $Static -CatalogName 'Static registry' -Fields @('CaseKey','CppSymbol','Origin','RecipeId','SourcePath','ProductId','RequestAxes','DefaultSeed','ReturnType','ReleaseShard','References')

$TasksPath = Join-Path $ChangeRoot 'tasks.md'
$TasksText = [System.IO.File]::ReadAllText($TasksPath)
$TaskMatches = @([regex]::Matches($TasksText, '(?m)^- \[ \] (?<id>\d+\.\d+) (?<title>.+)$'))
$CheckedTaskMatches = @([regex]::Matches($TasksText, '(?mi)^- \[[xX]\] '))
$ExpectedTaskCount = 28 + (2 * $Authored.Count) + (2 * $Sdk.Count) + (2 * @($Coverage | Where-Object Disposition -eq 'GeneratedRecipe').Count) + (2 * @($Inline | Where-Object { $_.Disposition -eq 'GeneratedRecipe' -and $_.File -notmatch '/Coverage/' }).Count) + @($Inline | Group-Object File).Count + 5
Add-Check -Name 'Task checkbox count' -Passed ($TaskMatches.Count -eq $ExpectedTaskCount -and $TaskMatches.Count -eq 3276) -Detail "expectedComputed=$ExpectedTaskCount recorded=3276 actual=$($TaskMatches.Count)"
Add-Check -Name 'Plan-only tasks remain unchecked' -Passed ($CheckedTaskMatches.Count -eq 0) -Detail "checked tasks=$($CheckedTaskMatches.Count)"
Add-Check -Name 'Task IDs unique' -Passed ((@($TaskMatches | ForEach-Object { $_.Groups['id'].Value } | Sort-Object -Unique)).Count -eq $TaskMatches.Count) -Detail 'every checkbox ID must be unique'
$RequiredTaskFields = @('Files','Reference','AS Scope','Axes','Oracle','Random/Frozen','Impact','Tests','Verify','Requirement','Dependencies')
$BadTaskBodies = [System.Collections.Generic.List[string]]::new()
for ($Index = 0; $Index -lt $TaskMatches.Count; ++$Index)
{
	$Start = $TaskMatches[$Index].Index
	$End = if ($Index + 1 -lt $TaskMatches.Count) { $TaskMatches[$Index + 1].Index } else { $TasksText.Length }
	$Body = $TasksText.Substring($Start, $End - $Start)
	foreach ($Field in $RequiredTaskFields)
	{
		if ($Body -notmatch "(?m)^  - $([regex]::Escape($Field)): \S")
		{
			$BadTaskBodies.Add("$($TaskMatches[$Index].Groups['id'].Value):$Field")
			break
		}
	}
	if ($BadTaskBodies.Count -ge 20) { break }
}
Add-Check -Name 'Task body completeness' -Passed ($BadTaskBodies.Count -eq 0) -Detail $(if ($BadTaskBodies.Count -eq 0) { "$($TaskMatches.Count) task bodies contain all $($RequiredTaskFields.Count) fields" } else { $BadTaskBodies -join '; ' })
$Placeholders = @([regex]::Matches($TasksText, '(?i)\b(TODO|TBD|FIXME)\b'))
Add-Check -Name 'Task placeholder absence' -Passed ($Placeholders.Count -eq 0) -Detail "placeholder matches=$($Placeholders.Count)"
Add-Check -Name 'Authored tasks represented' -Passed (@($Authored | Where-Object { $TasksText -notmatch [regex]::Escape($_.CaseKey) }).Count -eq 0) -Detail 'every authored CaseKey appears in tasks.md'
Add-Check -Name 'SDK tasks represented' -Passed (@($Sdk | Where-Object { $TasksText -notmatch [regex]::Escape($_.ProductId) }).Count -eq 0) -Detail 'every SDK ProductId appears in tasks.md'

$OpenSpecText = (($RequiredFiles | Where-Object { $_ -match '\.md$' } | ForEach-Object { [System.IO.File]::ReadAllText((Join-Path $ChangeRoot $_)) }) -join "`n")
$AbsoluteRepoEscaped = [regex]::Escape($RepositoryRoot)
Add-Check -Name 'No absolute repository paths in records' -Passed ($OpenSpecText -notmatch $AbsoluteRepoEscaped -and $TasksText -notmatch $AbsoluteRepoEscaped) -Detail 'records must use repository-relative references'

$StatusLines = @(& git -C $RepositoryRoot status --porcelain=v1 --untracked-files=all)
$ScopedStatus = @($StatusLines | Where-Object { $_ -match 'openspec/changes/test-as-source-generation-rules/' })
$UnrelatedStatus = @($StatusLines | Where-Object { $_ -notmatch 'openspec/changes/test-as-source-generation-rules/' })

$PassedCount = @($Checks | Where-Object Passed).Count
$Summary = [ordered]@{
	SchemaVersion = 1
	GeneratedAt = (Get-Date).ToString('o')
	RepositoryHead = (& git -C $RepositoryRoot rev-parse HEAD).Trim()
	Counts = [ordered]@{
		Authored = $Authored.Count
		SdkProducts = $Sdk.Count
		SdkMandatoryCells = [int]$SdkCellSum
		CoverageFiles = $CoverageFiles.Count
		CoverageMethods = $Coverage.Count
		InlineSourceUnits = $Inline.Count
		InlineMacroUnits = $CatalogMacroCount
		RecipeFamilies = $Recipes.Count
		StaticFunctions = $Static.Count
		Tasks = $TaskMatches.Count
	}
	ChecksPassed = $PassedCount
	ChecksTotal = $Checks.Count
	Failures = $Failures.ToArray()
	ScopedGitStatus = $ScopedStatus
	PreservedUnrelatedGitStatus = $UnrelatedStatus
	Checks = $Checks.ToArray()
}
$AuditRoot = Join-Path $ChangeRoot 'audits'
if (-not (Test-Path -LiteralPath $AuditRoot)) { [void](New-Item -ItemType Directory -Path $AuditRoot -Force) }
$SummaryPath = Join-Path $AuditRoot 'validation-summary.json'
$SummaryJson = $Summary | ConvertTo-Json -Depth 8
[System.IO.File]::WriteAllText($SummaryPath, $SummaryJson.Replace("`r`n", "`n") + "`n", [System.Text.UTF8Encoding]::new($false))

Write-Host "Validation checks: $PassedCount/$($Checks.Count) passed"
Write-Host "Counts: authored=$($Authored.Count), sdk=$($Sdk.Count), sdkCells=$SdkCellSum, coverage=$($Coverage.Count), inline=$($Inline.Count), static=$($Static.Count), tasks=$($TaskMatches.Count)"
Write-Host "Validation summary: $SummaryPath"
if ($Failures.Count -gt 0)
{
	foreach ($Failure in $Failures) { Write-Error $Failure }
	throw "$($Failures.Count) generation-plan validation checks failed."
}
