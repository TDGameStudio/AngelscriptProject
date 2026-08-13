[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$FixtureRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$ValidatorPath = Join-Path $FixtureRoot 'Validate-Fixtures.ps1'
$Assertions = 0

function Assert-True
{
	param(
		[Parameter(Mandatory = $true)]
		[bool] $Condition,

		[Parameter(Mandatory = $true)]
		[string] $Message
	)

	if (-not $Condition)
	{
		throw "ASSERT FAILED: $Message"
	}

	$script:Assertions++
}

function Invoke-FixtureValidator
{
	param(
		[Parameter(Mandatory = $true)]
		[string] $Root
	)

	$Output = @(
		& powershell.exe -NoProfile -ExecutionPolicy Bypass `
			-File $ValidatorPath -FixtureRoot $Root 2>&1
	)

	return [pscustomobject]@{
		ExitCode = $LASTEXITCODE
		Text = ($Output -join [Environment]::NewLine)
	}
}

function Get-CanonicalTextHash
{
	param(
		[Parameter(Mandatory = $true)]
		[string] $Path
	)

	$Text = [System.IO.File]::ReadAllText($Path).Replace("`r`n", "`n").Replace("`r", "`n")
	$Bytes = [System.Text.UTF8Encoding]::new($false).GetBytes($Text)
	$Sha256 = [System.Security.Cryptography.SHA256]::Create()
	try
	{
		return ([System.BitConverter]::ToString(
			$Sha256.ComputeHash($Bytes))).Replace('-', '').ToLowerInvariant()
	}
	finally
	{
		$Sha256.Dispose()
	}
}

function Update-ManifestHash
{
	param(
		[Parameter(Mandatory = $true)]
		[string] $Root,

		[Parameter(Mandatory = $true)]
		[string] $CaseName,

		[Parameter(Mandatory = $true)]
		[string] $ArtifactName,

		[Parameter(Mandatory = $true)]
		[string] $RelativePath
	)

	$ManifestPath = Join-Path $Root 'manifest.json'
	$Manifest = Get-Content -LiteralPath $ManifestPath -Raw | ConvertFrom-Json
	$Case = @($Manifest.cases | Where-Object { $_.name -eq $CaseName })
	Assert-True ($Case.Count -eq 1) "Expected exactly one '$CaseName' manifest entry."

	$ArtifactPath = Join-Path $Root $RelativePath
	$Case[0].sha256.$ArtifactName = Get-CanonicalTextHash -Path $ArtifactPath

	$ManifestJson = $Manifest | ConvertTo-Json -Depth 32
	[System.IO.File]::WriteAllText(
		$ManifestPath,
		$ManifestJson + [Environment]::NewLine,
		[System.Text.UTF8Encoding]::new($false))
}

Assert-True (Test-Path -LiteralPath $ValidatorPath -PathType Leaf) `
	"Validate-Fixtures.ps1 must exist before the fixture contract can pass."

$Canonical = Invoke-FixtureValidator -Root $FixtureRoot
Assert-True ($Canonical.ExitCode -eq 0) `
	"Canonical fixture corpus should pass. Output: $($Canonical.Text)"
Assert-True ($Canonical.Text -match 'PASS semantic-aot-v1 fixtures: 10/10') `
	"Canonical fixture corpus should report the stable 10/10 summary."

$TemporaryRoot = Join-Path ([System.IO.Path]::GetTempPath()) `
	("semantic-aot-v1-tests-" + [guid]::NewGuid().ToString('N'))

try
{
	$LineEndingRoot = Join-Path $TemporaryRoot 'line-ending-normalization'
	Copy-Item -LiteralPath $FixtureRoot -Destination $LineEndingRoot -Recurse
	$LineEndingSourcePath = Join-Path $LineEndingRoot 'scalar-branch/input.as'
	$LineEndingSource = [System.IO.File]::ReadAllText($LineEndingSourcePath)
	$LineEndingSource = $LineEndingSource.Replace("`r`n", "`n").Replace("`n", "`r`n")
	[System.IO.File]::WriteAllText(
		$LineEndingSourcePath,
		$LineEndingSource,
		[System.Text.UTF8Encoding]::new($false))

	$LineEndingResult = Invoke-FixtureValidator -Root $LineEndingRoot
	Assert-True ($LineEndingResult.ExitCode -eq 0) `
		"Changing only text line endings must preserve canonical fixture hashes. Output: $($LineEndingResult.Text)"

	$DanglingRoot = Join-Path $TemporaryRoot 'dangling-supported-case'
	Copy-Item -LiteralPath $FixtureRoot -Destination $DanglingRoot -Recurse
	$DanglingHirRelativePath = 'scalar-branch/hir.json'
	$DanglingHirPath = Join-Path $DanglingRoot $DanglingHirRelativePath
	$DanglingHir = Get-Content -LiteralPath $DanglingHirPath -Raw | ConvertFrom-Json
	$DanglingHir.statements[0].initializerExpression = 999
	[System.IO.File]::WriteAllText(
		$DanglingHirPath,
		($DanglingHir | ConvertTo-Json -Depth 32) + [Environment]::NewLine,
		[System.Text.UTF8Encoding]::new($false))
	Update-ManifestHash -Root $DanglingRoot -CaseName 'scalar-branch' `
		-ArtifactName 'hir' -RelativePath $DanglingHirRelativePath

	$DanglingResult = Invoke-FixtureValidator -Root $DanglingRoot
	Assert-True ($DanglingResult.ExitCode -ne 0) `
		"A dangling expression in a supported case must fail validation."
	Assert-True ($DanglingResult.Text -match 'DanglingExpressionId') `
		"Dangling-expression failure should expose the stable error code."

	$ReceiverRoot = Join-Path $TemporaryRoot 'receiver-alias-type-mismatch'
	Copy-Item -LiteralPath $FixtureRoot -Destination $ReceiverRoot -Recurse
	$ReceiverHirRelativePath = 'external-implicit-this/hir.json'
	$ReceiverHirPath = Join-Path $ReceiverRoot $ReceiverHirRelativePath
	$ReceiverHir = Get-Content -LiteralPath $ReceiverHirPath -Raw | ConvertFrom-Json
	$ReceiverHir.functionHeader.receiver.type = 'UWrongReceiver'
	[System.IO.File]::WriteAllText(
		$ReceiverHirPath,
		($ReceiverHir | ConvertTo-Json -Depth 32) + [Environment]::NewLine,
		[System.Text.UTF8Encoding]::new($false))
	Update-ManifestHash -Root $ReceiverRoot -CaseName 'external-implicit-this' `
		-ArtifactName 'hir' -RelativePath $ReceiverHirRelativePath

	$ReceiverResult = Invoke-FixtureValidator -Root $ReceiverRoot
	Assert-True ($ReceiverResult.ExitCode -ne 0) `
		"A mismatched external receiver alias type must fail validation."
	Assert-True ($ReceiverResult.Text -match 'InvalidEffectiveReceiver') `
		"Receiver-alias failure should expose the stable error code."

	$CallOrderRoot = Join-Path $TemporaryRoot 'duplicate-call-evaluation'
	Copy-Item -LiteralPath $FixtureRoot -Destination $CallOrderRoot -Recurse
	$CallOrderHirRelativePath = 'call-reverse-evaluation/hir.json'
	$CallOrderHirPath = Join-Path $CallOrderRoot $CallOrderHirRelativePath
	$CallOrderHir = Get-Content -LiteralPath $CallOrderHirPath -Raw | ConvertFrom-Json
	$OuterCall = @($CallOrderHir.expressions | Where-Object {
		$_.kind -eq 'ResolvedCall' -and $_.resolvedTarget -like 'int Collect*'
	})
	Assert-True ($OuterCall.Count -eq 1) `
		"Expected one outer Collect call in the reverse-evaluation fixture."
	$OuterCall[0].evaluationSequence[1].formalIndex = 2
	$OuterCall[0].evaluationSequence[1].expression = 5
	[System.IO.File]::WriteAllText(
		$CallOrderHirPath,
		($CallOrderHir | ConvertTo-Json -Depth 32) + [Environment]::NewLine,
		[System.Text.UTF8Encoding]::new($false))
	Update-ManifestHash -Root $CallOrderRoot -CaseName 'call-reverse-evaluation' `
		-ArtifactName 'hir' -RelativePath $CallOrderHirRelativePath

	$CallOrderResult = Invoke-FixtureValidator -Root $CallOrderRoot
	Assert-True ($CallOrderResult.ExitCode -ne 0) `
		"Duplicating one call input and omitting another must fail validation."
	Assert-True ($CallOrderResult.Text -match 'InvalidCallEvaluationSequence') `
		"Call-order failure should expose the stable error code."

	$ControlTargetRoot = Join-Path $TemporaryRoot 'continue-targets-switch'
	Copy-Item -LiteralPath $FixtureRoot -Destination $ControlTargetRoot -Recurse
	$ControlTargetHirRelativePath = 'loop-switch/hir.json'
	$ControlTargetHirPath = Join-Path $ControlTargetRoot $ControlTargetHirRelativePath
	$ControlTargetHir = Get-Content -LiteralPath $ControlTargetHirPath -Raw | ConvertFrom-Json
	$ContinueStatement = @($ControlTargetHir.statements | Where-Object {
		$_.kind -eq 'Continue'
	})
	Assert-True ($ContinueStatement.Count -eq 1) `
		"Expected one continue statement in the loop-switch fixture."
	$ContinueStatement[0] | Add-Member -NotePropertyName targetStatement `
		-NotePropertyValue 8 -Force
	[System.IO.File]::WriteAllText(
		$ControlTargetHirPath,
		($ControlTargetHir | ConvertTo-Json -Depth 32) + [Environment]::NewLine,
		[System.Text.UTF8Encoding]::new($false))
	Update-ManifestHash -Root $ControlTargetRoot -CaseName 'loop-switch' `
		-ArtifactName 'hir' -RelativePath $ControlTargetHirRelativePath

	$ControlTargetResult = Invoke-FixtureValidator -Root $ControlTargetRoot
	Assert-True ($ControlTargetResult.ExitCode -ne 0) `
		"A continue that targets a switch instead of its loop must fail validation."
	Assert-True ($ControlTargetResult.Text -match 'InvalidControlTarget') `
		"Control-target failure should expose the stable error code."

	$ForbiddenRoot = Join-Path $TemporaryRoot 'forbidden-cpp-token'
	Copy-Item -LiteralPath $FixtureRoot -Destination $ForbiddenRoot -Recurse
	$CppRelativePath = 'scalar-branch/expected.cpp'
	$CppPath = Join-Path $ForbiddenRoot $CppRelativePath
	[System.IO.File]::AppendAllText(
		$CppPath,
		"`n// GetByteCode() must be rejected by the research validator.`n",
		[System.Text.UTF8Encoding]::new($false))
	Update-ManifestHash -Root $ForbiddenRoot -CaseName 'scalar-branch' `
		-ArtifactName 'cpp' -RelativePath $CppRelativePath

	$ForbiddenResult = Invoke-FixtureValidator -Root $ForbiddenRoot
	Assert-True ($ForbiddenResult.ExitCode -ne 0) `
		"A forbidden bytecode token in Semantic C++ must fail validation."
	Assert-True ($ForbiddenResult.Text -match 'ForbiddenCppToken') `
		"Forbidden C++ token failure should expose the stable error code."
}
finally
{
	if (Test-Path -LiteralPath $TemporaryRoot)
	{
		Remove-Item -LiteralPath $TemporaryRoot -Recurse -Force
	}
}

Write-Output "PASS semantic-aot-v1 validator tests: $Assertions assertions"
