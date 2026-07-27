[CmdletBinding()]
param(
	[string]$ProjectRoot,
	[switch]$Apply
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($ProjectRoot))
{
	$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..\..')).Path
}

$SdkRoot = Join-Path $ProjectRoot 'Plugins\Angelscript\Source\AngelscriptTest\AngelScriptSDK'

# These are ordinary source literals whose direct host accepts std::string, or
# whose existing ASTEST_AS_ANSI wrapper only needs Allman/indent cleanup.
# const char* hosts and byte-sensitive frontend inputs are deliberately absent.
$Targets = @{
	'Compiler/AngelscriptNativeBuilderEditorOnlyTests.cpp' = @(58, 131, 184, 189)
	'Compiler/AngelscriptNativeBuilderLayoutTests.cpp' = @(164, 193, 227)
	'Compiler/AngelscriptNativeBuilderLifecycleTests.cpp' = @(163, 184, 193, 210)
	'Compiler/AngelscriptNativeCompilerCoreTests.cpp' = @(107)
	'Conformance/AngelscriptNativeInterfaceSemanticsTests.cpp' = @(50)
	'Embedding/AngelscriptNativeCallFunctionTests.cpp' = @(228)
	'Language/AngelscriptNativeConstructorsTests.cpp' = @(186)
	'Language/AngelscriptNativeControlFlowTests.cpp' = @(16)
	'Language/AngelscriptNativeConversionsTests.cpp' = @(41, 88, 154, 204, 293)
	'Language/AngelscriptNativeExpressionsTests.cpp' = @(33, 68, 91, 126, 145, 171, 206)
	'Language/AngelscriptNativeFunctionsTests.cpp' = @(23, 48, 129, 192)
	'Language/AngelscriptNativeOperatorsTests.cpp' = @(27, 52, 75)
	'Language/AngelscriptNativeReferencesTests.cpp' = @(20, 49, 78)
	'Module/AngelscriptNativeModuleImportTests.cpp' = @(38, 71, 77, 115, 121, 156, 162, 168, 224, 241, 247)
	'Module/AngelscriptNativeModuleSaveLoadTests.cpp' = @(55, 193)
	'Module/AngelscriptNativeModuleSectionTests.cpp' = @(230, 233)
	'Runtime/AngelscriptNativeContextControlTests.cpp' = @(34, 76, 125, 174, 229, 272)
	'TypeSystem/AngelscriptNativeDefaultTraitTests.cpp' = @(37)
	'TypeSystem/AngelscriptNativeEnumTypeTests.cpp' = @(76)
	'TypeSystem/AngelscriptNativePrimitiveTypeTests.cpp' = @(175)
	'TypeSystem/AngelscriptNativeVariableScopeTests.cpp' = @(44, 62, 88, 118, 150, 170, 211, 252)
}

function FormatInlineAngelScript([string]$Body)
{
	$Text = $Body.Replace("`r`n", "`n").Replace("`r", "`n").Trim([char[]]"`n")
	$Lines = [System.Collections.Generic.List[string]]::new()
	$Current = [System.Text.StringBuilder]::new()
	$Depth = 0
	$ParenDepth = 0
	$Index = 0
	$Length = $Text.Length

	function Flush-Line
	{
		$Value = $Current.ToString().Trim()
		$Current.Clear() | Out-Null
		if ($Value.Length -gt 0)
		{
			$Lines.Add(("`t" * $Depth) + $Value)
		}
	}

	function Append-Space
	{
		if ($Current.Length -gt 0 -and $Current[$Current.Length - 1] -ne ' ')
		{
			$Current.Append(' ') | Out-Null
		}
	}

	while ($Index -lt $Length)
	{
		$Character = $Text[$Index]
		$Next = if ($Index + 1 -lt $Length) { $Text[$Index + 1] } else { [char]0 }

		if ($Character -eq '/' -and $Next -eq '/')
		{
			$CommentEnd = $Text.IndexOf("`n", $Index)
			if ($CommentEnd -lt 0) { $CommentEnd = $Length }
			$Current.Append($Text.Substring($Index, $CommentEnd - $Index)) | Out-Null
			Flush-Line
			$Index = $CommentEnd + 1
			continue
		}

		if ($Character -eq '/' -and $Next -eq '*')
		{
			$CommentEnd = $Text.IndexOf('*/', $Index + 2, [System.StringComparison]::Ordinal)
			if ($CommentEnd -lt 0) { throw 'Unterminated block comment in targeted AngelScript source.' }
			$Current.Append($Text.Substring($Index, $CommentEnd + 2 - $Index)) | Out-Null
			$Index = $CommentEnd + 2
			continue
		}

		if ($Character -eq '"' -or $Character -eq "'")
		{
			$Quote = $Character
			$Current.Append($Character) | Out-Null
			$Index++
			while ($Index -lt $Length)
			{
				$Quoted = $Text[$Index]
				$Current.Append($Quoted) | Out-Null
				if ($Quoted -eq '\' -and $Index + 1 -lt $Length)
				{
					$Index++
					$Current.Append($Text[$Index]) | Out-Null
				}
				elseif ($Quoted -eq $Quote)
				{
					$Index++
					break
				}
				$Index++
			}
			continue
		}

		if ($Character -eq "`n")
		{
			Flush-Line
			$Index++
			continue
		}

		if ([char]::IsWhiteSpace($Character))
		{
			Append-Space
			$Index++
			continue
		}

		if ($Character -eq '(')
		{
			$ParenDepth++
			$Current.Append($Character) | Out-Null
			$Index++
			continue
		}

		if ($Character -eq ')')
		{
			$ParenDepth = [Math]::Max(0, $ParenDepth - 1)
			$Current.Append($Character) | Out-Null
			$Index++
			continue
		}

		if ($Character -eq '{')
		{
			Flush-Line
			$Lines.Add(("`t" * $Depth) + '{')
			$Depth++
			$Index++
			continue
		}

		if ($Character -eq '}')
		{
			Flush-Line
			$Depth = [Math]::Max(0, $Depth - 1)
			$Lines.Add(("`t" * $Depth) + '}')
			$Index++
			continue
		}

		if ($Character -eq ';' -and $ParenDepth -eq 0)
		{
			$Current.Append($Character) | Out-Null
			Flush-Line
			$Index++
			continue
		}

		$Current.Append($Character) | Out-Null
		$Index++
	}
	Flush-Line

	$Combined = [System.Collections.Generic.List[string]]::new()
	for ($LineIndex = 0; $LineIndex -lt $Lines.Count; $LineIndex++)
	{
		$Line = $Lines[$LineIndex]
		if ($Line.Trim() -eq '}' -and $LineIndex + 1 -lt $Lines.Count -and $Lines[$LineIndex + 1].Trim() -eq ';')
		{
			$Combined.Add($Line + ';')
			$LineIndex++
			continue
		}
		$Combined.Add($Line)
	}

	$Result = [System.Collections.Generic.List[string]]::new()
	$ResultDepth = 0
	for ($LineIndex = 0; $LineIndex -lt $Combined.Count; $LineIndex++)
	{
		$Line = $Combined[$LineIndex]
		$Trimmed = $Line.Trim()
		$Result.Add($Line)
		if ($Trimmed -eq '}' -or $Trimmed -eq '};')
		{
			$ResultDepth = [Math]::Max(0, $ResultDepth - 1)
			if ($ResultDepth -eq 0 -and $LineIndex + 1 -lt $Combined.Count)
			{
				$Result.Add('')
			}
		}
		elseif ($Trimmed -eq '{')
		{
			$ResultDepth++
		}
	}

	return ($Result -join "`n").TrimEnd()
}

$Changes = [System.Collections.Generic.List[object]]::new()
foreach ($Entry in $Targets.GetEnumerator() | Sort-Object Key)
{
	$RelativePath = $Entry.Key
	$Path = Join-Path $SdkRoot $RelativePath
	$Input = Get-Content -LiteralPath $Path -Raw
	$UsesCrLf = $Input.Contains("`r`n")
	$Original = [regex]::Replace($Input, "`r+`n", "`n").Replace("`r", "`n")
	$Matches = [regex]::Matches($Original, 'R"(?<Delimiter>[A-Za-z0-9_]*)\((?<Body>.*?)\)\k<Delimiter>"', [System.Text.RegularExpressions.RegexOptions]::Singleline)
	$Replacements = [System.Collections.Generic.List[object]]::new()

	foreach ($Match in $Matches)
	{
		$Line = ($Original.Substring(0, $Match.Index) -split "`n").Count
		if ($Line -notin $Entry.Value)
		{
			continue
		}

		$LineStart = $Original.LastIndexOf("`n", $Match.Index) + 1
		$LinePrefix = $Original.Substring($LineStart, $Match.Index - $LineStart)
		$IndentMatch = [regex]::Match($LinePrefix, '^[\t ]*')
		$BaseIndent = $IndentMatch.Value
		$WindowStart = [Math]::Max(0, $Match.Index - 160)
		$Before = $Original.Substring($WindowStart, $Match.Index - $WindowStart)
		$WrapperMatch = [regex]::Match($Before, '(?<Wrapper>ASTEST_AS(?:_ANSI)?(?:_PRESERVE_LINES)?\s*\()\s*$')
		$Start = $Match.Index
		$End = $Match.Index + $Match.Length
		if ($WrapperMatch.Success)
		{
			$Start = $WindowStart + $WrapperMatch.Groups['Wrapper'].Index
			if ($End -ge $Original.Length -or $Original[$End] -ne ')')
			{
				throw "Wrapped raw source does not have a closing macro parenthesis: ${RelativePath}:$Line"
			}
			$End++
		}

		$FormattedBody = FormatInlineAngelScript $Match.Groups['Body'].Value
		$IndentedBody = ($FormattedBody -split "`n" | ForEach-Object {
			if ([string]::IsNullOrWhiteSpace($_)) { '' } else { $BaseIndent + "`t" + $_ }
		}) -join "`n"
		$Replacement = "ASTEST_AS_ANSI(R`"AS(`n$IndentedBody`n$BaseIndent)AS`")"
		$Replacements.Add([pscustomobject]@{
			Start = $Start
			Length = $End - $Start
			Value = $Replacement
			Line = $Line
		})
	}

	foreach ($Replacement in $Replacements | Sort-Object Start -Descending)
	{
		$Original = $Original.Remove($Replacement.Start, $Replacement.Length).Insert($Replacement.Start, $Replacement.Value)
		$Changes.Add([pscustomobject]@{ File = $RelativePath; Line = $Replacement.Line })
	}

	if ($Apply -and $Replacements.Count -gt 0)
	{
		$Output = if ($UsesCrLf) { $Original.Replace("`n", "`r`n") } else { $Original }
		[System.IO.File]::WriteAllText($Path, $Output, [System.Text.UTF8Encoding]::new($false))
	}
}

[pscustomobject]@{
	Mode = $(if ($Apply) { 'Applied' } else { 'Preview' })
	Changes = $Changes.Count
	Files = @($Changes.File | Sort-Object -Unique).Count
	Targets = ($Changes | Sort-Object File, Line | ForEach-Object { "$($_.File):$($_.Line)" }) -join '; '
}
