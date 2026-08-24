[CmdletBinding()]
param([string]$RepoRoot)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module (Join-Path $PSScriptRoot 'GenerationInventoryCommon.psm1') -Force
$ChangeRoot = Resolve-GenerationPlanRoot -ScriptRoot $PSScriptRoot
$RepositoryRoot = Resolve-RepositoryRoot -ChangeRoot $ChangeRoot -RepoRoot $RepoRoot
$CoverageRoot = Join-Path $RepositoryRoot 'Plugins/Angelscript/Source/AngelscriptTest/Coverage'
if (-not (Test-Path -LiteralPath $CoverageRoot -PathType Container))
{
	throw "Coverage root not found: $CoverageRoot"
}

$Rows = [System.Collections.Generic.List[object]]::new()
$FileRows = [System.Collections.Generic.List[object]]::new()
$Files = Get-ChildItem -LiteralPath $CoverageRoot -Recurse -File -Filter '*.cpp' | Sort-Object FullName
foreach ($File in $Files)
{
	$Text = [System.IO.File]::ReadAllText($File.FullName)
	$LineStarts = Get-LineStarts -Text $Text
	$Relative = [System.IO.Path]::GetRelativePath($CoverageRoot, $File.FullName).Replace('\', '/')
	$ClassMatches = @([regex]::Matches($Text, '\bTEST_CLASS(?:_WITH_FLAGS)?\s*\(\s*(?<name>[^,\)]+)'))
	$MethodMatches = @([regex]::Matches($Text, '\bTEST_METHOD\s*\(\s*(?<name>[^\)]+)\)'))
	$FileRows.Add([pscustomobject][ordered]@{
		File = "Plugins/Angelscript/Source/AngelscriptTest/Coverage/$Relative"
		MethodCount = $MethodMatches.Count
		Role = if ($MethodMatches.Count -eq 0) { 'SupportOnly' } else { 'TestOwner' }
		Reference = "Plugins/Angelscript/Source/AngelscriptTest/Coverage/$Relative"
	})

	for ($MethodIndex = 0; $MethodIndex -lt $MethodMatches.Count; ++$MethodIndex)
	{
		$MethodMatch = $MethodMatches[$MethodIndex]
		$NextOffset = if ($MethodIndex + 1 -lt $MethodMatches.Count) { $MethodMatches[$MethodIndex + 1].Index } else { $Text.Length }
		$BodyLength = [Math]::Max(0, $NextOffset - $MethodMatch.Index)
		$Body = $Text.Substring($MethodMatch.Index, $BodyLength)
		$Method = $MethodMatch.Groups['name'].Value.Trim()
		$Class = Get-NearestNamedMatch -Matches $ClassMatches -Offset $MethodMatch.Index -GroupName 'name' -Fallback '<anonymous-test-class>'
		$Line = Get-LineNumberAtOffset -LineStarts $LineStarts -Offset $MethodMatch.Index
		$Disposition = Get-GenerationDisposition -RelativePath $Relative -Method $Method -Content $Body
		$Shape = Get-SourceShape -Content $Body
		$Oracle = Get-OracleKinds -Context $Body
		$Domain = ($Relative -split '/')[0]
		if ($Relative -notmatch '/') { $Domain = [System.IO.Path]::GetFileNameWithoutExtension($Relative) }

		$Axes = switch ($Disposition.Recipe)
		{
			'expression-product' { 'value-type;operator;operand-form;boundary-class;parenthesization' }
			'function-mode-product' { 'value-type;parameter-direction;parameter-position;call-form;return-form' }
			'uclass-property-family' { 'property-type;declaration-form;default-value;read-write-path;metadata-form' }
			'ufunction-signature-product' { 'return-type;parameter-type;direction;position;arity;call-form' }
			'container-element-product' { 'container-kind;element-or-key-type;operation;empty-state;boundary-state' }
			'ue-definition-product' { 'definition-kind;specifier;member-kind;scope;publication-order' }
			'compile-fail-mutation' { 'valid-baseline;single-invalid-mutation;diagnostic-anchor;recovery-form' }
			default { 'authored-inputs;authored-observations;host-state' }
		}

		$HostRequirements = if ($Disposition.Disposition -eq 'SpecializedScenario')
		{
			'Preserve the existing UE fixture, world/object lifetime, module setup, and cleanup sequence.'
		}
		elseif ($Disposition.Disposition -eq 'AuthoredExport')
		{
			'Preserve the existing host harness; export only the AS source ownership boundary.'
		}
		else
		{
			'Portable rule generation first; retain the current C++ harness as the behavior oracle until later adoption.'
		}

		$CaseKey = "Coverage/$($Relative -replace '\.cpp$', '')/$Method"
		$Rows.Add([pscustomobject][ordered]@{
			DispositionId = ('COV-{0:D4}' -f ($Rows.Count + 1))
			File = "Plugins/Angelscript/Source/AngelscriptTest/Coverage/$Relative"
			Class = $Class
			Method = $Method
			Line = $Line
			Domain = $Domain
			SourceShape = $Shape
			ExistingOracle = $Oracle
			Disposition = $Disposition.Disposition
			CandidateRecipe = $Disposition.Recipe
			ProductAxes = $Axes
			GeneratedAsScope = if ($Disposition.Disposition -eq 'GeneratedRecipe') { "Generate the AS declaration/body cells for $Method; preserve every explicit axis and typed observation represented by the current method." } else { "Keep the method's AS source authored; catalog its inputs, expected observations, and knowledge comments without synthesizing host behavior." }
			HostRequirements = $HostRequirements
			Rationale = if ($Disposition.Disposition -eq 'GeneratedRecipe') { 'The method name and source shape expose a finite repeatable product suitable for a declarative recipe.' } elseif ($Disposition.Disposition -eq 'AuthoredExport') { 'The case has source ownership value but no proven finite product; retain authored semantics.' } else { 'The case is coupled to a specialized UE host story and is not a safe generator target.' }
			ReferenceProducts = '<none assigned; exact overlap is resolved during rule implementation>'
			FutureCaseKey = $CaseKey
		})
	}
}

$Output = Join-Path $ChangeRoot 'catalogs/coverage-generation-disposition.csv'
Write-PlanCsv -Rows $Rows.ToArray() -Path $Output
$FileOutput = Join-Path $ChangeRoot 'catalogs/coverage-file-registry.csv'
Write-PlanCsv -Rows $FileRows.ToArray() -Path $FileOutput

Write-Host "Coverage inventory: $($Files.Count) files, $($Rows.Count) TEST_METHOD rows -> $Output; $FileOutput"
if ($Files.Count -ne 90 -or $Rows.Count -ne 1022)
{
	throw "Coverage baseline drift: expected 90 files / 1022 TEST_METHOD rows, found $($Files.Count) / $($Rows.Count)."
}
