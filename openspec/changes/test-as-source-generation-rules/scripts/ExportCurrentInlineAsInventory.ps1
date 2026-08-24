[CmdletBinding()]
param([string]$RepoRoot)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module (Join-Path $PSScriptRoot 'GenerationInventoryCommon.psm1') -Force
$ChangeRoot = Resolve-GenerationPlanRoot -ScriptRoot $PSScriptRoot
$RepositoryRoot = Resolve-RepositoryRoot -ChangeRoot $ChangeRoot -RepoRoot $RepoRoot
$TestRoot = Join-Path $RepositoryRoot 'Plugins/Angelscript/Source/AngelscriptTest'
if (-not (Test-Path -LiteralPath $TestRoot -PathType Container))
{
	throw "AngelscriptTest root not found: $TestRoot"
}

$Rows = [System.Collections.Generic.List[object]]::new()
$Files = Get-ChildItem -LiteralPath $TestRoot -Recurse -File | Where-Object { $_.Extension -in @('.cpp', '.h') } | Sort-Object FullName
foreach ($File in $Files)
{
	$Text = [System.IO.File]::ReadAllText($File.FullName)
	if ($Text -notmatch 'ASTEST_AS|R"') { continue }

	$Relative = [System.IO.Path]::GetRelativePath($TestRoot, $File.FullName).Replace('\', '/')
	$LineStarts = Get-LineStarts -Text $Text
	$ClassMatches = @([regex]::Matches($Text, '\bTEST_CLASS(?:_WITH_FLAGS)?\s*\(\s*(?<name>[^,\)]+)'))
	$MethodMatches = @([regex]::Matches($Text, '\bTEST_METHOD\s*\(\s*(?<name>[^\)]+)\)'))
	$RawStarts = @([regex]::Matches($Text, 'R"(?<delimiter>[A-Za-z0-9_]*)\('))
	$MacroMatches = @([regex]::Matches($Text, '\b(?<macro>ASTEST_AS[A-Z0-9_]*)\s*\('))
	$ConsumedRawOffsets = [System.Collections.Generic.HashSet[int]]::new()
	$Occurrences = [System.Collections.Generic.List[object]]::new()

	foreach ($MacroMatch in $MacroMatches)
	{
		$Raw = $null
		foreach ($RawStart in $RawStarts)
		{
			if ($RawStart.Index -lt $MacroMatch.Index) { continue }
			if ($RawStart.Index - $MacroMatch.Index -gt 4096) { break }
			$Between = $Text.Substring($MacroMatch.Index, $RawStart.Index - $MacroMatch.Index)
			if ($Between -match ';') { break }
			$Raw = Get-RawStringLiteral -Text $Text -StartMatch $RawStart
			[void]$ConsumedRawOffsets.Add($RawStart.Index)
			break
		}
		$Occurrences.Add([pscustomobject]@{
			Offset = $MacroMatch.Index
			ExtractionForm = $MacroMatch.Groups['macro'].Value
			Content = if ($null -ne $Raw) { $Raw.Content } else { '' }
		})
	}

	foreach ($RawStart in $RawStarts)
	{
		if ($ConsumedRawOffsets.Contains($RawStart.Index)) { continue }
		$Raw = Get-RawStringLiteral -Text $Text -StartMatch $RawStart
		$WindowStart = [Math]::Max(0, $RawStart.Index - 300)
		$WindowLength = [Math]::Min($Text.Length - $WindowStart, 600)
		$Nearby = $Text.Substring($WindowStart, $WindowLength)
		if (-not (Test-LikelyAngelScriptLiteral -RelativePath $Relative -Delimiter $Raw.Delimiter -Content $Raw.Content -NearbyText $Nearby)) { continue }
		$Occurrences.Add([pscustomobject]@{
			Offset = $RawStart.Index
			ExtractionForm = if ([string]::IsNullOrWhiteSpace($Raw.Delimiter)) { 'RawStringLiteral' } else { "RawStringLiteral:$($Raw.Delimiter)" }
			Content = $Raw.Content
		})
	}

	$OrdinalByOwner = @{}
	foreach ($Occurrence in ($Occurrences | Sort-Object Offset, ExtractionForm))
	{
		$Method = Get-NearestNamedMatch -Matches $MethodMatches -Offset $Occurrence.Offset -GroupName 'name' -Fallback '<file-scope>'
		$Class = Get-NearestNamedMatch -Matches $ClassMatches -Offset $Occurrence.Offset -GroupName 'name' -Fallback '<file-scope>'
		$OwnerKey = "$Class::$Method"
		if (-not $OrdinalByOwner.ContainsKey($OwnerKey)) { $OrdinalByOwner[$OwnerKey] = 0 }
		$OrdinalByOwner[$OwnerKey] = [int]$OrdinalByOwner[$OwnerKey] + 1
		$OwnerOrdinal = $OrdinalByOwner[$OwnerKey]
		$Line = Get-LineNumberAtOffset -LineStarts $LineStarts -Offset $Occurrence.Offset
		$ContextStart = [Math]::Max(0, $Occurrence.Offset - 1200)
		$ContextLength = [Math]::Min($Text.Length - $ContextStart, 3000)
		$Context = $Text.Substring($ContextStart, $ContextLength)
		$Disposition = Get-GenerationDisposition -RelativePath $Relative -Method $Method -Content $Occurrence.Content
		$PathKey = $Relative -replace '\.(cpp|h)$', ''
		$CaseKey = "Inline/$PathKey/$Method/$OwnerOrdinal"
		$Symbol = if ($Disposition.Disposition -eq 'GeneratedRecipe') { "GT_$((ConvertTo-PlanSlug -Value $CaseKey).ToUpperInvariant())" } else { '<none until explicitly promoted>' }

		$Rows.Add([pscustomobject][ordered]@{
			InlineId = ('IAS-{0:D5}' -f ($Rows.Count + 1))
			File = "Plugins/Angelscript/Source/AngelscriptTest/$Relative"
			Class = $Class
			Method = $Method
			Line = $Line
			ExtractionForm = $Occurrence.ExtractionForm
			SourceUnitCount = 1
			ApproxShape = Get-SourceShape -Content $Occurrence.Content
			ExistingExecutionKind = Get-ExecutionKind -Context $Context
			ExistingOracle = Get-OracleKinds -Context $Context
			ReturnTypes = Get-ReturnTypes -Content $Occurrence.Content
			Disposition = $Disposition.Disposition
			RecipeFamily = $Disposition.Recipe
			FutureCaseKey = $CaseKey
			GeneratedCppSymbol = $Symbol
			GeneratedAsScope = if ($Disposition.Disposition -eq 'GeneratedRecipe') { 'Generate only the repeatable AS declaration/body product; preserve the current C++ host oracle and explicit negative/recovery structure.' } elseif ($Disposition.Disposition -eq 'AuthoredExport') { 'Preserve this AS source as authored content and export it through a stable CaseKey only after an explicit adoption task.' } else { 'Keep the AS scenario authored and colocated with its specialized UE fixture; do not synthesize host lifecycle behavior.' }
			References = "Plugins/Angelscript/Source/AngelscriptTest/$Relative`:$Line"
			Rationale = if ($Disposition.Disposition -eq 'GeneratedRecipe') { 'A named finite source pattern is visible in the current case.' } elseif ($Disposition.Disposition -eq 'AuthoredExport') { 'No safe finite product is proven; authored source remains the semantic authority.' } else { 'The source depends on scenario-specific UE state or sequencing.' }
		})
	}
}

$Output = Join-Path $ChangeRoot 'catalogs/inline-as-generation-disposition.csv'
Write-PlanCsv -Rows $Rows.ToArray() -Path $Output

$MacroRows = @($Rows | Where-Object { $_.ExtractionForm -like 'ASTEST_AS*' }).Count
$SourceMacroCount = 0
foreach ($File in $Files)
{
	$SourceMacroCount += [regex]::Matches([System.IO.File]::ReadAllText($File.FullName), '\bASTEST_AS[A-Z0-9_]*\s*\(').Count
}
Write-Host "Inline AS inventory: $($Rows.Count) source units ($MacroRows ASTEST_AS macro units) -> $Output"
if ($MacroRows -ne $SourceMacroCount)
{
	throw "ASTEST_AS inventory drift: source has $SourceMacroCount macro units, catalog has $MacroRows."
}
