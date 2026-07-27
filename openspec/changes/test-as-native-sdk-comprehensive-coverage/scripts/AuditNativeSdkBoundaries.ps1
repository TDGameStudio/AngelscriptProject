[CmdletBinding()]
param(
	[string]$ProjectRoot,
	[string]$OutputPath,
	[switch]$RequireClean
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
	$OutputPath = Join-Path (Resolve-Path (Join-Path $PSScriptRoot '..\audits')).Path 'boundary-violations.csv'
}

$SdkRoot = Join-Path $ProjectRoot 'Plugins\Angelscript\Source\AngelscriptTest\AngelScriptSDK'
$Rows = [System.Collections.Generic.List[object]]::new()
$Rules = @(
	@{ Id = 'NoSdkAddon'; Pattern = '(?i)(sdk[/\\]add_on|add_on[/\\]|scriptarray|scriptdictionary|scriptstdstring)'; Message = 'External SDK add-on dependency is outside the core suite.' },
	@{ Id = 'NoPluginEngineWrapper'; Pattern = '\bFAngelscriptEngine\b'; Message = 'Raw SDK tests must not use the plugin engine wrapper.' },
	@{ Id = 'NoWorldActor'; Pattern = '\b(?:UWorld|AActor|UObject|FWorldContext)\b'; Message = 'Raw SDK tests must not depend on UE world/object integration.' },
	@{ Id = 'NoUEDebugIntegration'; Pattern = '\b(?:DebugServer|DAP|SourceNavigation|VSCode)\b'; Message = 'Raw SDK debug tests own core context/function behavior only.' },
	@{ Id = 'NoCompiledOutTests'; Pattern = '#if\s+0\b|&&\s*0\b'; Message = 'Future and negative coverage must remain registered, not compiled out.' },
	@{ Id = 'ExactInvocationLookup'; Pattern = 'GetFunctionByName\s*\([^;\r\n]*\).*?(?:Prepare|Execute)'; Message = 'Invocation must resolve an exact declaration rather than a name-only lookup.' }
)

foreach ($File in Get-ChildItem -LiteralPath $SdkRoot -Recurse -Include '*.cpp', '*.h' -File | Sort-Object FullName)
{
	$Text = Get-Content -LiteralPath $File.FullName -Raw
	$RelativePath = $File.FullName.Substring($SdkRoot.Length).TrimStart([char[]]@('\', '/')).Replace('\', '/')
	foreach ($Rule in $Rules)
	{
		foreach ($Match in [regex]::Matches($Text, $Rule.Pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline))
		{
			$Rows.Add([pscustomobject]@{
				Rule = $Rule.Id
				File = $RelativePath
				Line = ($Text.Substring(0, $Match.Index) -split "`n").Count
				Message = $Rule.Message
				Disposition = 'MustFix'
			})
		}
	}

	if ($RelativePath -match '238Tests\.cpp$')
	{
		if ($Text -notmatch 'EAutomationTestFlags::Disabled' -or $Text -notmatch '#as-v238-backport')
		{
			$Rows.Add([pscustomobject]@{
				Rule = 'Future238Registration'
				File = $RelativePath
				Line = 1
				Message = 'Selected 2.38 tests must be compiled, Disabled, and tagged #as-v238-backport.'
				Disposition = 'MustFix'
			})
		}
	}
}

$GeneratedRegistryPath = Join-Path (Resolve-Path (Join-Path $PSScriptRoot '..\catalogs')).Path 'generated-source-registry.csv'
foreach ($Owner in Import-Csv -LiteralPath $GeneratedRegistryPath)
{
	$OwnerPath = Join-Path $SdkRoot $Owner.File.Replace('/', '\')
	if (-not (Test-Path -LiteralPath $OwnerPath))
	{
		$Rows.Add([pscustomobject]@{
			Rule = 'GeneratedSourceOwner'
			File = $Owner.File
			Line = 1
			Message = 'Registered generated-source owner file does not exist.'
			Disposition = 'MustFix'
		})
		continue
	}

	$OwnerText = Get-Content -LiteralPath $OwnerPath -Raw
	if ($OwnerText -notmatch '\bPrintGeneratedAsSource\s*\(')
	{
		$Rows.Add([pscustomobject]@{
			Rule = 'GeneratedSourcePrinting'
			File = $Owner.File
			Line = 1
			Message = 'Generated AngelScript source must be printed before compilation.'
			Disposition = 'MustFix'
		})
	}
}

$Rows | Export-Csv -LiteralPath $OutputPath -NoTypeInformation -Encoding utf8
if ($RequireClean -and $Rows.Count -gt 0)
{
	throw "Native SDK boundary audit found $($Rows.Count) violations. First: $($Rows[0].File):$($Rows[0].Line) $($Rows[0].Rule)"
}

[pscustomobject]@{
	Violations = $Rows.Count
	Output = $OutputPath
}
