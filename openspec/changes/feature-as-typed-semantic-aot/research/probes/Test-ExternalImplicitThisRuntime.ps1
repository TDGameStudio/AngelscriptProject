[CmdletBinding()]
param(
	[string] $HostPath,
	[switch] $KeepArtifacts
)

$ErrorActionPreference = 'Stop'

function Find-ProjectRoot
{
	param([string] $StartPath)

	$Cursor = [System.IO.DirectoryInfo]::new(
		[System.IO.Path]::GetFullPath($StartPath))
	while ($null -ne $Cursor)
	{
		if ((Test-Path -LiteralPath (Join-Path $Cursor.FullName 'AGENTS.md') -PathType Leaf) -and
			(Test-Path -LiteralPath (Join-Path $Cursor.FullName 'Plugins/Angelscript') -PathType Container))
		{
			return $Cursor.FullName
		}

		$Cursor = $Cursor.Parent
	}

	throw "Could not locate the AngelscriptProject root above '$StartPath'."
}
$ProjectRoot = Find-ProjectRoot -StartPath $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($HostPath))
{
	$Candidates = @(
		'Plugins/Angelscript/Standalone/out/build/win64-msvc/Debug/as-standalone.exe',
		'Plugins/Angelscript/Standalone/out/build/win64-msvc/Release/as-standalone.exe'
	)
	foreach ($Candidate in $Candidates)
	{
		$ResolvedCandidate = Join-Path $ProjectRoot $Candidate
		if (Test-Path -LiteralPath $ResolvedCandidate -PathType Leaf)
		{
			$HostPath = $ResolvedCandidate
			break
		}
	}
}

if ([string]::IsNullOrWhiteSpace($HostPath) -or
	-not (Test-Path -LiteralPath $HostPath -PathType Leaf))
{
	throw @'
No Standalone host was found. Build it first from the repository root:
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTestSuite.ps1 -Suite Standalone -TimeoutMs 600000
'@
}

$HostPath = (Resolve-Path -LiteralPath $HostPath).Path
$ArtifactRoot = Join-Path (
	[System.IO.Path]::GetTempPath()) (
	'AngelscriptExternalThisProbe-' + [System.Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $ArtifactRoot | Out-Null
$Succeeded = $false

try
{
	& $HostPath run `
		--script-root $PSScriptRoot `
		--entry 'external-implicit-this-native.as' `
		--output $ArtifactRoot `
		--diagnostics text
	if ($LASTEXITCODE -ne 0)
	{
		throw "Standalone runtime probe failed with exit code $LASTEXITCODE. Artifacts: $ArtifactRoot"
	}

	$Succeeded = $true
	Write-Output 'PASS external_implicit_this native runtime probe'
	Write-Output 'Observed: parameter 0 is addressable by name, supplies unqualified property/method lookup, and is mutated by the callee.'
}
finally
{
	if ($Succeeded -and -not $KeepArtifacts)
	{
		$ResolvedArtifactRoot = [System.IO.Path]::GetFullPath($ArtifactRoot)
		$ResolvedTempRoot = [System.IO.Path]::GetFullPath(
			[System.IO.Path]::GetTempPath())
		$Leaf = Split-Path -Path $ResolvedArtifactRoot -Leaf
		if (-not $ResolvedArtifactRoot.StartsWith(
			$ResolvedTempRoot,
			[System.StringComparison]::OrdinalIgnoreCase) -or
			-not $Leaf.StartsWith(
				'AngelscriptExternalThisProbe-',
				[System.StringComparison]::Ordinal))
		{
			throw "Refusing to remove unexpected probe path '$ResolvedArtifactRoot'."
		}

		[System.IO.Directory]::Delete($ResolvedArtifactRoot, $true)
	}
}
