[CmdletBinding()]
param(
	[Parameter(Mandatory = $true)]
	[string] $SourceRoot,

	[Parameter(Mandatory = $true)]
	[string] $OutputCsv,

	[Parameter(Mandatory = $true)]
	[string] $ProviderCsv,

	[Parameter(Mandatory = $true)]
	[string] $DescriptorCsv,

	[Parameter(Mandatory = $true)]
	[string] $SummaryJson
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-MaskedCppText
{
	param([Parameter(Mandatory = $true)][string] $Text)

	$tokenPattern = '(?ms)R"(?<delimiter>[^ ()\\\t\r\n]{0,16})\(.*?\)\k<delimiter>"|//[^\r\n]*|/\*.*?\*/|"(?:\\.|[^"\\])*"|''(?:\\.|[^''\\])*'''
	return [regex]::Replace(
		$Text,
		$tokenPattern,
		{
			param($match)
			return [regex]::Replace($match.Value, '[^\r\n]', ' ')
		})
}

function Find-MatchingParenthesis
{
	param(
		[Parameter(Mandatory = $true)][string] $MaskedText,
		[Parameter(Mandatory = $true)][int] $OpenIndex)

	$depth = 0
	for ($index = $OpenIndex; $index -lt $MaskedText.Length; ++$index)
	{
		switch ($MaskedText[$index])
		{
			'(' { ++$depth; break }
			')'
			{
				--$depth
				if ($depth -eq 0)
				{
					return $index
				}
				break
			}
		}
	}
	return -1
}

function Find-MatchingBrace
{
	param(
		[Parameter(Mandatory = $true)][string] $MaskedText,
		[Parameter(Mandatory = $true)][int] $OpenIndex)

	$depth = 0
	for ($index = $OpenIndex; $index -lt $MaskedText.Length; ++$index)
	{
		switch ($MaskedText[$index])
		{
			'{' { ++$depth; break }
			'}'
			{
				--$depth
				if ($depth -eq 0)
				{
					return $index
				}
				break
			}
		}
	}
	return -1
}

function Get-NamedVoidFunctionRanges
{
	param(
		[Parameter(Mandatory = $true)][string] $OriginalText,
		[Parameter(Mandatory = $true)][string] $MaskedText)

	$ranges = [System.Collections.Generic.List[object]]::new()
	$pattern = [regex]::new(
		'(?m)^\s*(?:(?:static|inline|FORCEINLINE)\s+)*void\s+(?<name>[A-Za-z_][A-Za-z0-9_]*)\s*\([^;{}]*\)\s*(?:const\s*)?\{',
		[System.Text.RegularExpressions.RegexOptions]::CultureInvariant)
	foreach ($match in @($pattern.Matches($MaskedText)))
	{
		$openBrace = $MaskedText.IndexOf('{', $match.Index + $match.Length - 1)
		$closeBrace = Find-MatchingBrace -MaskedText $MaskedText -OpenIndex $openBrace
		if ($closeBrace -lt 0)
		{
			throw "Unbalanced named void helper at line $(Get-LineNumber -Text $OriginalText -Offset $match.Index)"
		}
		$ranges.Add([pscustomobject] [ordered] @{
			Name = $match.Groups['name'].Value
			Offset = $match.Index
			OpenBrace = $openBrace
			CloseBrace = $closeBrace
		})
	}
	return $ranges
}

function Get-CalledKnownHelperNames
{
	param(
		[AllowEmptyString()][string] $MaskedExpression,
		[Parameter(Mandatory = $true)][AllowEmptyCollection()][System.Collections.Generic.HashSet[string]] $KnownNames)

	$names = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
	if ([string]::IsNullOrWhiteSpace($MaskedExpression))
	{
		return @()
	}
	foreach ($match in @([regex]::Matches($MaskedExpression, '\b(?<name>[A-Za-z_][A-Za-z0-9_]*)\s*\(')))
	{
		$name = $match.Groups['name'].Value
		if ($KnownNames.Contains($name))
		{
			$null = $names.Add($name)
		}
	}
	return @($names | Sort-Object)
}

function Split-TopLevelArguments
{
	param(
		[Parameter(Mandatory = $true)][string] $OriginalText,
		[Parameter(Mandatory = $true)][string] $MaskedText,
		[Parameter(Mandatory = $true)][int] $StartIndex,
		[Parameter(Mandatory = $true)][int] $EndIndex)

	$arguments = [System.Collections.Generic.List[string]]::new()
	$argumentStart = $StartIndex
	$parenthesisDepth = 0
	$bracketDepth = 0
	$braceDepth = 0

	for ($index = $StartIndex; $index -lt $EndIndex; ++$index)
	{
		switch ($MaskedText[$index])
		{
			'(' { ++$parenthesisDepth; break }
			')' { --$parenthesisDepth; break }
			'[' { ++$bracketDepth; break }
			']' { --$bracketDepth; break }
			'{' { ++$braceDepth; break }
			'}' { --$braceDepth; break }
			','
			{
				if ($parenthesisDepth -eq 0 -and $bracketDepth -eq 0 -and $braceDepth -eq 0)
				{
					$arguments.Add($OriginalText.Substring($argumentStart, $index - $argumentStart).Trim())
					$argumentStart = $index + 1
				}
				break
			}
		}
	}

	if ($argumentStart -le $EndIndex)
	{
		$arguments.Add($OriginalText.Substring($argumentStart, $EndIndex - $argumentStart).Trim())
	}
	return $arguments.ToArray()
}

function Normalize-CppSnippet
{
	param([AllowEmptyString()][string] $Value)
	if ([string]::IsNullOrWhiteSpace($Value))
	{
		return ''
	}
	return [regex]::Replace($Value.Trim(), '\s+', ' ')
}

function Get-LiteralDeclaration
{
	param([AllowEmptyString()][string] $Expression)
	if ([string]::IsNullOrWhiteSpace($Expression))
	{
		return ''
	}
	$parts = [regex]::Matches($Expression, '"(?<value>(?:\\.|[^"\\])*)"')
	if ($parts.Count -eq 0)
	{
		return ''
	}
	return (($parts | ForEach-Object { $_.Groups['value'].Value }) -join '')
}

function Get-LastDescriptorPropertyExpression
{
	param(
		[Parameter(Mandatory = $true)][string] $OriginalText,
		[Parameter(Mandatory = $true)][string] $DescriptorVariable,
		[Parameter(Mandatory = $true)][string] $Property,
		[Parameter(Mandatory = $true)][int] $EndOffset)

	if ($EndOffset -le 0)
	{
		return ''
	}

	$prefix = $OriginalText.Substring(0, [Math]::Min($EndOffset, $OriginalText.Length))
	$propertyPattern = '(?ms)\b' + [regex]::Escape($DescriptorVariable) + '\s*\.\s*' + [regex]::Escape($Property) + '\s*=\s*(?<value>.*?);'
	$pattern = [regex]::new(
		$propertyPattern,
		[System.Text.RegularExpressions.RegexOptions]::CultureInvariant)
	$matches = @($pattern.Matches($prefix))
	if ($matches.Count -eq 0)
	{
		return ''
	}
	return Normalize-CppSnippet -Value $matches[-1].Groups['value'].Value
}

function Get-LineNumber
{
	param(
		[Parameter(Mandatory = $true)][string] $Text,
		[Parameter(Mandatory = $true)][int] $Offset)
	return 1 + [regex]::Matches($Text.Substring(0, $Offset), "`n").Count
}

function Get-AssignedBoundFunctionVariable
{
	param(
		[Parameter(Mandatory = $true)][string] $OriginalText,
		[Parameter(Mandatory = $true)][int] $CallOffset)

	$statementStart = -1
	foreach ($separator in @(';', '{', '}'))
	{
		$statementStart = [Math]::Max(
			$statementStart,
			$OriginalText.LastIndexOf($separator, [Math]::Max(0, $CallOffset - 1)))
	}
	$prefixStart = $statementStart + 1
	$prefix = $OriginalText.Substring($prefixStart, $CallOffset - $prefixStart)
	$match = [regex]::Match(
		$prefix,
		'\bFAngelscriptBoundFunction\s+(?<variable>[A-Za-z_][A-Za-z0-9_]*)\s*=')
	return $match.Success ? $match.Groups['variable'].Value : ''
}

function Get-FluentNativeFormFacts
{
	param([AllowEmptyString()][string] $Tail)

	$methods = [System.Collections.Generic.List[string]]::new()
	$displayExpressions = [System.Collections.Generic.List[string]]::new()
	$literalDisplays = [System.Collections.Generic.List[string]]::new()
	$headerExpressions = [System.Collections.Generic.List[string]]::new()
	$literalHeaders = [System.Collections.Generic.List[string]]::new()
	$argumentCounts = [System.Collections.Generic.List[string]]::new()
	if (-not [string]::IsNullOrWhiteSpace($Tail))
	{
		$maskedTail = Get-MaskedCppText -Text $Tail
		$nativePattern = [regex]::new('\.(?<method>Native[A-Za-z0-9_]*)\s*\(', [System.Text.RegularExpressions.RegexOptions]::CultureInvariant)
		foreach ($nativeMatch in $nativePattern.Matches($maskedTail))
		{
			$openIndex = $nativeMatch.Index + $nativeMatch.Length - 1
			$closeIndex = Find-MatchingParenthesis -MaskedText $maskedTail -OpenIndex $openIndex
			if ($closeIndex -lt 0)
			{
				throw "Unbalanced fluent native-form call: $Tail"
			}
			$method = $nativeMatch.Groups['method'].Value
			$arguments = @(Split-TopLevelArguments -OriginalText $Tail -MaskedText $maskedTail -StartIndex ($openIndex + 1) -EndIndex $closeIndex)
			if ($arguments.Count -eq 1 -and [string]::IsNullOrWhiteSpace($arguments[0]))
			{
				$arguments = @()
			}
			$displayIndex = $method -eq 'NativeUFunction' ? 1 : 0
			$headerIndex = $method -eq 'NativeFunctionHeader' ? 1 : -1
			$displayExpression = $arguments.Count -gt $displayIndex ? $arguments[$displayIndex] : ''
			$headerExpression = $headerIndex -ge 0 -and $arguments.Count -gt $headerIndex ? $arguments[$headerIndex] : ''

			$methods.Add($method)
			$displayExpressions.Add((Normalize-CppSnippet -Value $displayExpression))
			$literalDisplays.Add((Get-LiteralDeclaration -Expression $displayExpression))
			$headerExpressions.Add((Normalize-CppSnippet -Value $headerExpression))
			$literalHeaders.Add((Get-LiteralDeclaration -Expression $headerExpression))
			$argumentCounts.Add([string]$arguments.Count)
		}
	}

	return [pscustomobject] [ordered] @{
		Methods = $methods -join ';'
		ArgumentCounts = $argumentCounts -join ';'
		DisplayExpressions = $displayExpressions -join ';'
		LiteralDisplays = $literalDisplays -join ';'
		HeaderExpressions = $headerExpressions -join ';'
		LiteralHeaders = $literalHeaders -join ';'
		Count = $methods.Count
	}
}

function Get-ImplicitMacroNativeFormFacts
{
	param([AllowEmptyString()][string] $TargetExpression)

	$result = [ordered] @{
		Macro = ''
		Method = ''
		CallableDisplay = ''
		Trivial = ''
	}
	if ([string]::IsNullOrWhiteSpace($TargetExpression))
	{
		return [pscustomobject]$result
	}

	$maskedTarget = Get-MaskedCppText -Text $TargetExpression
	$macroMatch = [regex]::Match(
		$maskedTarget,
		'^\s*(?<macro>METHODPR_TRIVIAL|METHOD_TRIVIAL|METHODPR|METHOD|FUNCPR_TRIVIAL|FUNC_TRIVIAL_CUSTOMNATIVE|FUNC_CUSTOMNATIVE|FUNC_TRIVIAL|FUNCPR|FUNC)\s*\(',
		[System.Text.RegularExpressions.RegexOptions]::CultureInvariant)
	if (-not $macroMatch.Success)
	{
		return [pscustomobject]$result
	}

	$openIndex = $macroMatch.Index + $macroMatch.Length - 1
	$closeIndex = Find-MatchingParenthesis -MaskedText $maskedTarget -OpenIndex $openIndex
	if ($closeIndex -lt 0)
	{
		throw "Unbalanced native-form macro target: $TargetExpression"
	}
	$arguments = @(Split-TopLevelArguments -OriginalText $TargetExpression -MaskedText $maskedTarget -StartIndex ($openIndex + 1) -EndIndex $closeIndex)
	$macro = $macroMatch.Groups['macro'].Value
	$displayIndex = switch -Regex ($macro)
	{
		'^METHODPR' { 2; break }
		'^METHOD' { 1; break }
		'^FUNCPR' { 1; break }
		'^FUNC_(?:TRIVIAL_)?CUSTOMNATIVE$' { 1; break }
		default { 0 }
	}
	$result.Macro = $macro
	$result.Method = $macro.StartsWith('METHOD') ? 'NativeMethod' : 'NativeFunction'
	$result.CallableDisplay = if ($arguments.Count -gt $displayIndex)
	{
		Normalize-CppSnippet -Value $arguments[$displayIndex]
	}
	else
	{
		''
	}
	$result.Trivial = $macro.Contains('TRIVIAL') ? 'true' : 'false'
	return [pscustomobject]$result
}

function Get-ProviderCallbackFacts
{
	param([AllowEmptyString()][string] $Expression)

	$normalized = Normalize-CppSnippet -Value $Expression
	if ($normalized -match '^\[[^\]]*\]\s*\(')
	{
		return [pscustomobject] [ordered] @{
			Kind = 'InlineLambda'
			Display = '<inline-lambda>'
		}
	}
	return [pscustomobject] [ordered] @{
		Kind = [string]::IsNullOrEmpty($normalized) ? '' : 'FunctionPointer'
		Display = $normalized
	}
}

$registrationApis = @(
	'BindGlobalFunctionForTarget',
	'BindGlobalGenericFunctionForTarget',
	'BindGlobalFunctionDirectForTarget',
	'BindMethodDirectForTarget',
	'GenericMethod',
	'Method',
	'Constructor',
	'Destructor',
	'BindBehaviour',
	'BindExternBehaviour',
	'BindStaticBehaviour',
	'RegisterFunctionBindingForTarget')
$apiAlternation = ($registrationApis | ForEach-Object { [regex]::Escape($_) }) -join '|'
$callPattern = [regex]::new("\.(?<api>$apiAlternation)\s*\(", [System.Text.RegularExpressions.RegexOptions]::CultureInvariant)
$providerPattern = [regex]::new('\bFAngelscriptBind\s+(?<provider>[A-Za-z_][A-Za-z0-9_]*)\s*\(', [System.Text.RegularExpressions.RegexOptions]::CultureInvariant)
$reviewedDescriptorPattern = [regex]::new(
	'\b(?<helper>AttachReviewed[A-Za-z0-9_]*)\s*\(',
	[System.Text.RegularExpressions.RegexOptions]::CultureInvariant)
$directDescriptorPattern = [regex]::new(
	'\b(?<bound>[A-Za-z_][A-Za-z0-9_]*)\s*\.\s*ExternalNativeCall\s*\(',
	[System.Text.RegularExpressions.RegexOptions]::CultureInvariant)

$resolvedSourceRoot = (Resolve-Path -LiteralPath $SourceRoot).Path
$normalizedResolvedSourceRoot = $resolvedSourceRoot.Replace('\', '/')
$runtimeSourceSuffix = 'Plugins/Angelscript/Source/AngelscriptRuntime'
$summarySourceRoot = if ($normalizedResolvedSourceRoot.EndsWith(
	$runtimeSourceSuffix,
	[System.StringComparison]::OrdinalIgnoreCase))
{
	$runtimeSourceSuffix
}
else
{
	[System.IO.Path]::GetFileName($resolvedSourceRoot)
}
$files = @(Get-ChildItem -LiteralPath $resolvedSourceRoot -Recurse -File -Filter '*.cpp' | Sort-Object FullName)
if ($files.Count -eq 0)
{
	throw "No Runtime .cpp files found beneath $resolvedSourceRoot"
}
$bindCppFileCount = @(Get-ChildItem -LiteralPath $resolvedSourceRoot -Recurse -File -Filter 'Bind_*.cpp').Count

$rows = [System.Collections.Generic.List[object]]::new()
$providerRows = [System.Collections.Generic.List[object]]::new()
$descriptorRows = [System.Collections.Generic.List[object]]::new()
$providerCount = 0
$registrationFileCount = 0

foreach ($file in $files)
{
	$original = [System.IO.File]::ReadAllText($file.FullName)
	$masked = Get-MaskedCppText -Text $original
	if ($masked.Length -ne $original.Length)
	{
		throw "Mask length drifted for $($file.FullName)"
	}
	$relativePath = [System.IO.Path]::GetRelativePath($resolvedSourceRoot, $file.FullName).Replace('\', '/')
	$descriptorFacts = [System.Collections.Generic.List[object]]::new()
	$functionRanges = @(Get-NamedVoidFunctionRanges -OriginalText $original -MaskedText $masked)
	$knownFunctionNames = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
	foreach ($functionRange in $functionRanges)
	{
		$null = $knownFunctionNames.Add($functionRange.Name)
	}
	$helperCallsByName = @{}
	foreach ($functionRange in $functionRanges)
	{
		if (-not $helperCallsByName.ContainsKey($functionRange.Name))
		{
			$helperCallsByName[$functionRange.Name] = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
		}
		$body = $masked.Substring(
			$functionRange.OpenBrace + 1,
			$functionRange.CloseBrace - $functionRange.OpenBrace - 1)
		foreach ($calledName in @(Get-CalledKnownHelperNames -MaskedExpression $body -KnownNames $knownFunctionNames))
		{
			$null = $helperCallsByName[$functionRange.Name].Add($calledName)
		}
	}
	foreach ($descriptorMatch in @($reviewedDescriptorPattern.Matches($masked)))
	{
		$descriptorOpenIndex = $descriptorMatch.Index + $descriptorMatch.Length - 1
		$descriptorCloseIndex = Find-MatchingParenthesis -MaskedText $masked -OpenIndex $descriptorOpenIndex
		if ($descriptorCloseIndex -lt 0)
		{
			throw "Unbalanced reviewed external descriptor attachment at $($file.FullName):$(Get-LineNumber -Text $original -Offset $descriptorMatch.Index)"
		}
		$descriptorArguments = @(Split-TopLevelArguments -OriginalText $original -MaskedText $masked -StartIndex ($descriptorOpenIndex + 1) -EndIndex $descriptorCloseIndex)
		$boundFunctionExpression = $descriptorArguments.Count -gt 0 ? (Normalize-CppSnippet -Value $descriptorArguments[0]) : ''
		if ($boundFunctionExpression -match '\bFAngelscriptBoundFunction\b')
		{
			continue
		}
		$helper = $descriptorMatch.Groups['helper'].Value
		$symbolExpression = $descriptorArguments.Count -gt 1 ? (Normalize-CppSnippet -Value $descriptorArguments[1]) : ''
		$includeExpression = $descriptorArguments.Count -gt 2 ? (Normalize-CppSnippet -Value $descriptorArguments[2]) : ''
		$owningModuleExpression = $descriptorArguments.Count -gt 3 ? (Normalize-CppSnippet -Value $descriptorArguments[3]) : ''
		$descriptorFact = [pscustomobject] [ordered] @{
			SourceFile = $relativePath
			SourceLine = Get-LineNumber -Text $original -Offset $descriptorMatch.Index
			AttachmentKind = 'reviewed-helper'
			Helper = $helper
			BoundFunctionExpression = $boundFunctionExpression
			DescriptorExpression = ''
			Linkage = $helper -match 'HeaderInline' ? 'HeaderInline' : ''
			SymbolExpression = $symbolExpression
			Symbol = Get-LiteralDeclaration -Expression $symbolExpression
			IncludeExpression = $includeExpression
			Include = Get-LiteralDeclaration -Expression $includeExpression
			OwningModuleExpression = $owningModuleExpression
			OwningModule = Get-LiteralDeclaration -Expression $owningModuleExpression
			Association = 'bound-function-variable'
		}
		$descriptorFacts.Add($descriptorFact)
		$descriptorRows.Add($descriptorFact)
	}
	foreach ($descriptorMatch in @($directDescriptorPattern.Matches($masked)))
	{
		$descriptorOpenIndex = $descriptorMatch.Index + $descriptorMatch.Length - 1
		$descriptorCloseIndex = Find-MatchingParenthesis -MaskedText $masked -OpenIndex $descriptorOpenIndex
		if ($descriptorCloseIndex -lt 0)
		{
			throw "Unbalanced direct external descriptor attachment at $($file.FullName):$(Get-LineNumber -Text $original -Offset $descriptorMatch.Index)"
		}

		$boundFunctionExpression = $descriptorMatch.Groups['bound'].Value
		$containingHelper = @($functionRanges | Where-Object {
			$descriptorMatch.Index -gt $_.OpenBrace -and $descriptorMatch.Index -lt $_.CloseBrace
		} | Sort-Object { $_.CloseBrace - $_.OpenBrace } | Select-Object -First 1)
		if ($containingHelper.Count -eq 1)
		{
			$helperSignature = $original.Substring(
				$containingHelper[0].Offset,
				$containingHelper[0].OpenBrace - $containingHelper[0].Offset)
			$boundParameterPattern = '\bFAngelscriptBoundFunction\b[^)]*\b' + [regex]::Escape($boundFunctionExpression) + '\b'
			if ($helperSignature -match $boundParameterPattern)
			{
				continue
			}
		}

		$descriptorArguments = @(Split-TopLevelArguments -OriginalText $original -MaskedText $masked -StartIndex ($descriptorOpenIndex + 1) -EndIndex $descriptorCloseIndex)
		$descriptorExpression = $descriptorArguments.Count -gt 0 ? (Normalize-CppSnippet -Value $descriptorArguments[0]) : ''
		if ($descriptorExpression -notmatch '^[A-Za-z_][A-Za-z0-9_]*$')
		{
			continue
		}

		$linkageExpression = Get-LastDescriptorPropertyExpression -OriginalText $original -DescriptorVariable $descriptorExpression -Property 'Linkage' -EndOffset $descriptorMatch.Index
		$symbolExpression = Get-LastDescriptorPropertyExpression -OriginalText $original -DescriptorVariable $descriptorExpression -Property 'Symbol' -EndOffset $descriptorMatch.Index
		$includeExpression = Get-LastDescriptorPropertyExpression -OriginalText $original -DescriptorVariable $descriptorExpression -Property 'Include' -EndOffset $descriptorMatch.Index
		$owningModuleExpression = Get-LastDescriptorPropertyExpression -OriginalText $original -DescriptorVariable $descriptorExpression -Property 'OwningModule' -EndOffset $descriptorMatch.Index
		$linkageMatch = [regex]::Match($linkageExpression, '::(?<name>[A-Za-z_][A-Za-z0-9_]*)\s*$')
		$descriptorFact = [pscustomobject] [ordered] @{
			SourceFile = $relativePath
			SourceLine = Get-LineNumber -Text $original -Offset $descriptorMatch.Index
			AttachmentKind = 'direct-attachment'
			Helper = ''
			BoundFunctionExpression = $boundFunctionExpression
			DescriptorExpression = $descriptorExpression
			Linkage = $linkageMatch.Success ? $linkageMatch.Groups['name'].Value : ''
			SymbolExpression = $symbolExpression
			Symbol = Get-LiteralDeclaration -Expression $symbolExpression
			IncludeExpression = $includeExpression
			Include = Get-LiteralDeclaration -Expression $includeExpression
			OwningModuleExpression = $owningModuleExpression
			OwningModule = Get-LiteralDeclaration -Expression $owningModuleExpression
			Association = 'bound-function-variable'
		}
		$descriptorFacts.Add($descriptorFact)
		$descriptorRows.Add($descriptorFact)
	}

	$providerMatches = @($providerPattern.Matches($masked))
	$providerCount += $providerMatches.Count
	$providerFacts = [System.Collections.Generic.List[object]]::new()
	foreach ($providerMatch in $providerMatches)
	{
		$providerOpenIndex = $providerMatch.Index + $providerMatch.Length - 1
		$providerCloseIndex = Find-MatchingParenthesis -MaskedText $masked -OpenIndex $providerOpenIndex
		if ($providerCloseIndex -lt 0)
		{
			throw "Unbalanced FAngelscriptBind provider declaration at $($file.FullName):$(Get-LineNumber -Text $original -Offset $providerMatch.Index)"
		}
		$providerArguments = @(Split-TopLevelArguments -OriginalText $original -MaskedText $masked -StartIndex ($providerOpenIndex + 1) -EndIndex $providerCloseIndex)
		$bindNameExpression = $providerArguments.Count -gt 0 ? $providerArguments[0] : ''
		$phaseExpression = $providerArguments.Count -gt 1 ? $providerArguments[1] : ''
		$callbackExpression = $providerArguments.Count -gt 2 ? $providerArguments[2] : ''
		$callbackFacts = Get-ProviderCallbackFacts -Expression $callbackExpression
		$ownerModuleExpression = $providerArguments.Count -gt 3 ? $providerArguments[3] : 'UE_MODULE_NAME'
		$providerFact = [pscustomobject] [ordered] @{
			Offset = $providerMatch.Index
			SourceLine = Get-LineNumber -Text $original -Offset $providerMatch.Index
			Variable = $providerMatch.Groups['provider'].Value
			BindNameExpression = Normalize-CppSnippet -Value $bindNameExpression
			BindName = Get-LiteralDeclaration -Expression $bindNameExpression
			CallbackExpression = $callbackExpression
		}
		$providerFacts.Add($providerFact)
		$providerRows.Add([pscustomobject] [ordered] @{
			SourceFile = $relativePath
			SourceLine = $providerFact.SourceLine
			ProviderVariable = $providerFact.Variable
			BindNameExpression = $providerFact.BindNameExpression
			Provider = $providerFact.BindName
			PhaseExpression = Normalize-CppSnippet -Value $phaseExpression
			CallbackKind = $callbackFacts.Kind
			CallbackExpression = $callbackFacts.Display
			OwnerModuleExpression = Normalize-CppSnippet -Value $ownerModuleExpression
			UsesDefaultSourceLocation = $providerArguments.Count -le 4
		})
	}
	$helperOwnersByName = @{}
	foreach ($providerFact in $providerFacts)
	{
		$callbackMasked = Get-MaskedCppText -Text $providerFact.CallbackExpression
		$pending = [System.Collections.Generic.Queue[string]]::new()
		foreach ($entryName in @(Get-CalledKnownHelperNames -MaskedExpression $callbackMasked -KnownNames $knownFunctionNames))
		{
			$pending.Enqueue($entryName)
		}
		if ($pending.Count -eq 0)
		{
			$functionPointerMatch = [regex]::Match(
				$callbackMasked,
				'&?(?:(?:[A-Za-z_][A-Za-z0-9_]*)::)*(?<name>[A-Za-z_][A-Za-z0-9_]*)\s*$')
			if ($functionPointerMatch.Success -and $knownFunctionNames.Contains($functionPointerMatch.Groups['name'].Value))
			{
				$pending.Enqueue($functionPointerMatch.Groups['name'].Value)
			}
		}
		$visited = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
		while ($pending.Count -gt 0)
		{
			$helperName = $pending.Dequeue()
			if (-not $visited.Add($helperName))
			{
				continue
			}
			if (-not $helperOwnersByName.ContainsKey($helperName))
			{
				$helperOwnersByName[$helperName] = [System.Collections.Generic.List[object]]::new()
			}
			$helperOwnersByName[$helperName].Add($providerFact)
			if ($helperCallsByName.ContainsKey($helperName))
			{
				foreach ($nestedName in @($helperCallsByName[$helperName] | Sort-Object))
				{
					$pending.Enqueue($nestedName)
				}
			}
		}
	}
	$calls = @($callPattern.Matches($masked))
	if ($calls.Count -gt 0)
	{
		++$registrationFileCount
	}
	foreach ($call in $calls)
	{
		$api = $call.Groups['api'].Value
		$openIndex = $call.Index + $call.Length - 1
		$closeIndex = Find-MatchingParenthesis -MaskedText $masked -OpenIndex $openIndex
		if ($closeIndex -lt 0)
		{
			throw "Unbalanced registration call at $($file.FullName):$(Get-LineNumber -Text $original -Offset $call.Index)"
		}

		$arguments = @(Split-TopLevelArguments -OriginalText $original -MaskedText $masked -StartIndex ($openIndex + 1) -EndIndex $closeIndex)
		$declarationIndex = switch ($api)
		{
			'BindMethodDirectForTarget' { 1 }
			'BindBehaviour' { 1 }
			'BindExternBehaviour' { 1 }
			'BindStaticBehaviour' { 1 }
			default { 0 }
		}
		$targetIndex = switch ($api)
		{
			'BindMethodDirectForTarget' { 2 }
			'BindBehaviour' { 2 }
			'BindExternBehaviour' { 2 }
			'BindStaticBehaviour' { 2 }
			default { 1 }
		}

		$declarationExpression = $arguments.Count -gt $declarationIndex ? $arguments[$declarationIndex] : ''
		$targetExpression = $arguments.Count -gt $targetIndex ? $arguments[$targetIndex] : ''
		$semicolonIndex = $masked.IndexOf(';', $closeIndex + 1)
		if ($semicolonIndex -lt 0)
		{
			$semicolonIndex = $closeIndex
		}
		$tailLength = [Math]::Min($semicolonIndex - $closeIndex, 4096)
		$fluentTail = $tailLength -gt 0 ? $original.Substring($closeIndex + 1, $tailLength) : ''

		$providerFact = $null
		$providerAttribution = ''
		$containingFunction = @($functionRanges | Where-Object {
			$call.Index -gt $_.OpenBrace -and $call.Index -lt $_.CloseBrace
		} | Sort-Object { $_.CloseBrace - $_.OpenBrace } | Select-Object -First 1)
		if ($containingFunction.Count -eq 1 -and $helperOwnersByName.ContainsKey($containingFunction[0].Name))
		{
			$ownerCandidates = @($helperOwnersByName[$containingFunction[0].Name] |
				Sort-Object Variable -Unique)
			if ($ownerCandidates.Count -eq 1)
			{
				$providerFact = $ownerCandidates[0]
				$providerAttribution = 'unique-helper-call-graph'
			}
		}
		foreach ($candidateProvider in @($providerFacts))
		{
			if ($null -ne $providerFact)
			{
				break
			}
			if ($candidateProvider.Offset -gt $call.Index)
			{
				break
			}
			$providerFact = $candidateProvider
			$providerAttribution = 'lexical-preceding-provider'
		}
		if ($null -eq $providerFact -and $providerFacts.Count -eq 1)
		{
			$providerFact = $providerFacts[0]
			$providerAttribution = 'single-provider-file'
		}
		$providerVariable = $null -ne $providerFact ? $providerFact.Variable : ''
		$providerBindNameExpression = $null -ne $providerFact ? $providerFact.BindNameExpression : ''
		$providerBindName = $null -ne $providerFact ? $providerFact.BindName : ''
		$providerSourceLine = $null -ne $providerFact ? $providerFact.SourceLine : 0

		$normalizedTail = Normalize-CppSnippet -Value $fluentTail
		$nativeFormFacts = Get-FluentNativeFormFacts -Tail $fluentTail
		$implicitNativeFormFacts = Get-ImplicitMacroNativeFormFacts -TargetExpression $targetExpression
		$hasExplicitNativeForm = $nativeFormFacts.Count -gt 0
		$hasImplicitNativeForm = -not [string]::IsNullOrEmpty($implicitNativeFormFacts.Method)
		$effectiveNativeFormMethods = if ($hasExplicitNativeForm)
		{
			$nativeFormFacts.Methods
		}
		else
		{
			$implicitNativeFormFacts.Method
		}
		$effectiveNativeCallableDisplays = if ($hasExplicitNativeForm)
		{
			$nativeFormFacts.LiteralDisplays
		}
		else
		{
			$implicitNativeFormFacts.CallableDisplay
		}
		$boundFunctionVariable = Get-AssignedBoundFunctionVariable -OriginalText $original -CallOffset $call.Index
		$associatedDescriptorFacts = @($descriptorFacts | Where-Object {
			(-not [string]::IsNullOrEmpty($boundFunctionVariable)) -and
			$_.BoundFunctionExpression -eq $boundFunctionVariable
		})
		$hasFluentExternalDescriptor = $normalizedTail -match '\.ExternalNativeCall\s*\('
		$hasDirectDescriptorAttachment = @($associatedDescriptorFacts | Where-Object {
			$_.AttachmentKind -eq 'direct-attachment'
		}).Count -gt 0
		$externalDescriptorSource = if ($hasFluentExternalDescriptor)
		{
			'registration-fluent'
		}
		elseif ($hasDirectDescriptorAttachment)
		{
			'direct-attachment'
		}
		elseif ($associatedDescriptorFacts.Count -gt 0)
		{
			'reviewed-helper'
		}
		else
		{
			''
		}
		$literalDeclaration = Get-LiteralDeclaration -Expression $declarationExpression
		$hasExternalDescriptor = $hasFluentExternalDescriptor -or $associatedDescriptorFacts.Count -gt 0
		$compileOutMethods = @([regex]::Matches(
			$normalizedTail,
			'\.(CompileOut[A-Za-z0-9_]*)\s*\(') |
			ForEach-Object { $_.Groups[1].Value }) -join ';'
		$hasCompileOut = -not [string]::IsNullOrEmpty($compileOutMethods)
		$hasNativeForm = $hasExplicitNativeForm -or $hasImplicitNativeForm
		$sourceEvidenceDisposition = ''
		$sourceEvidenceReason = ''
		$requiredInstalledAuthority = ''
		if ($hasCompileOut)
		{
			$sourceEvidenceDisposition = 'compile-out-rule-review'
			$sourceEvidenceReason = 'source-compile-out-rule-does-not-prove-target-profile-rewrite'
			$requiredInstalledAuthority = 'target-profile-compile-out-selection-and-non-rewritten-call-disposition'
		}
		elseif ($hasExternalDescriptor)
		{
			$sourceEvidenceDisposition = 'direct-descriptor-candidate'
			$sourceEvidenceReason = 'explicit-reviewed-external-descriptor'
			$requiredInstalledAuthority = 'installed-descriptor-scalar-abi-routing-and-lifetime-validation'
		}
		elseif ($hasNativeForm)
		{
			$sourceEvidenceDisposition = 'bridge-candidate'
			$sourceEvidenceReason = 'native-form-without-external-descriptor'
			$requiredInstalledAuthority = 'installed-scalar-abi-routing-lifetime-and-current-caller-validation'
		}
		else
		{
			$sourceEvidenceDisposition = 'bridge-or-unsupported-review'
			$sourceEvidenceReason = 'no-external-descriptor-or-native-form'
			$requiredInstalledAuthority = 'installed-callable-kind-scalar-abi-routing-lifetime-and-current-caller-validation'
		}
		if ([string]::IsNullOrEmpty($literalDeclaration))
		{
			$requiredInstalledAuthority += ';dynamic-declaration-expansion'
		}
		if ([string]::IsNullOrEmpty($providerBindName))
		{
			$requiredInstalledAuthority += ';installed-provider-provenance'
		}
		$rows.Add([pscustomobject] [ordered] @{
			SourceFile = $relativePath
			SourceLine = Get-LineNumber -Text $original -Offset $call.Index
			Provider = $providerBindName
			ProviderVariable = $providerVariable
			ProviderBindNameExpression = $providerBindNameExpression
			ProviderSourceLine = $providerSourceLine
			ProviderAttribution = $providerAttribution
			RegistrationApi = $api
			BoundFunctionVariable = $boundFunctionVariable
			ArgumentCount = $arguments.Count
			DeclarationExpression = Normalize-CppSnippet -Value $declarationExpression
			LiteralDeclaration = $literalDeclaration
			CppTargetExpression = Normalize-CppSnippet -Value $targetExpression
			FluentTraits = $normalizedTail
			HasNativeForm = $hasNativeForm
			NativeFormSource = $hasExplicitNativeForm ? 'explicit-fluent' : ($hasImplicitNativeForm ? 'implicit-macro' : '')
			EffectiveNativeFormMethods = $effectiveNativeFormMethods
			EffectiveNativeCallableDisplays = $effectiveNativeCallableDisplays
			NativeFormMethods = $nativeFormFacts.Methods
			NativeFormArgumentCounts = $nativeFormFacts.ArgumentCounts
			NativeCallableDisplayExpressions = $nativeFormFacts.DisplayExpressions
			NativeCallableLiteralDisplays = $nativeFormFacts.LiteralDisplays
			NativeHeaderExpressions = $nativeFormFacts.HeaderExpressions
			NativeLiteralHeaders = $nativeFormFacts.LiteralHeaders
			ImplicitNativeFormMacro = $implicitNativeFormFacts.Macro
			ImplicitNativeFormMethod = $implicitNativeFormFacts.Method
			ImplicitNativeCallableDisplay = $implicitNativeFormFacts.CallableDisplay
			ImplicitNativeTrivial = $implicitNativeFormFacts.Trivial
			HasExternalDescriptor = $hasExternalDescriptor
			ExternalDescriptorSource = $externalDescriptorSource
			ExternalDescriptorSourceLines = ($associatedDescriptorFacts | ForEach-Object { [string]$_.SourceLine }) -join ';'
			ExternalDescriptorHelpers = ($associatedDescriptorFacts | ForEach-Object { $_.Helper } | Where-Object { -not [string]::IsNullOrEmpty($_) }) -join ';'
			ExternalDescriptorLinkages = ($associatedDescriptorFacts | ForEach-Object { $_.Linkage } | Where-Object { -not [string]::IsNullOrEmpty($_) }) -join ';'
			ExternalDescriptorSymbols = ($associatedDescriptorFacts | ForEach-Object { $_.Symbol } | Where-Object { -not [string]::IsNullOrEmpty($_) }) -join ';'
			ExternalDescriptorIncludes = ($associatedDescriptorFacts | ForEach-Object { $_.Include } | Where-Object { -not [string]::IsNullOrEmpty($_) }) -join ';'
			ExternalDescriptorOwningModules = ($associatedDescriptorFacts | ForEach-Object { $_.OwningModule } | Where-Object { -not [string]::IsNullOrEmpty($_) }) -join ';'
			HasCompileOut = $hasCompileOut
			CompileOutMethods = $compileOutMethods
			SourceEvidenceDisposition = $sourceEvidenceDisposition
			SourceEvidenceReason = $sourceEvidenceReason
			RequiredInstalledAuthority = $requiredInstalledAuthority
			JoinStatus = 'source-callsite-awaiting-installed-provenance'
		})
	}
}

$outputDirectory = Split-Path -Parent $OutputCsv
$providerOutputDirectory = Split-Path -Parent $ProviderCsv
$descriptorOutputDirectory = Split-Path -Parent $DescriptorCsv
$summaryDirectory = Split-Path -Parent $SummaryJson
New-Item -ItemType Directory -Force -Path $outputDirectory | Out-Null
New-Item -ItemType Directory -Force -Path $providerOutputDirectory | Out-Null
New-Item -ItemType Directory -Force -Path $descriptorOutputDirectory | Out-Null
New-Item -ItemType Directory -Force -Path $summaryDirectory | Out-Null

$sortedRows = @($rows | Sort-Object SourceFile, SourceLine, RegistrationApi, CppTargetExpression)
$sortedRows | Export-Csv -LiteralPath $OutputCsv -NoTypeInformation -Encoding utf8NoBOM
$sortedProviderRows = @($providerRows | Sort-Object SourceFile, SourceLine, ProviderVariable, Provider)
$sortedProviderRows | Export-Csv -LiteralPath $ProviderCsv -NoTypeInformation -Encoding utf8NoBOM
$sortedDescriptorRows = @($descriptorRows | Sort-Object SourceFile, SourceLine, Helper, BoundFunctionExpression)
$sortedDescriptorRows | Export-Csv -LiteralPath $DescriptorCsv -NoTypeInformation -Encoding utf8NoBOM

$apiCounts = [ordered] @{}
foreach ($entry in $sortedRows | Group-Object RegistrationApi | Sort-Object Name)
{
	$apiCounts[$entry.Name] = $entry.Count
}

$nativeFormMethodCounts = [ordered] @{}
foreach ($row in $sortedRows)
{
	foreach ($method in @($row.EffectiveNativeFormMethods -split ';' | Where-Object { -not [string]::IsNullOrEmpty($_) }))
	{
		if (-not $nativeFormMethodCounts.Contains($method))
		{
			$nativeFormMethodCounts[$method] = 0
		}
		$nativeFormMethodCounts[$method] = [int]$nativeFormMethodCounts[$method] + 1
	}
}
$orderedNativeFormMethodCounts = [ordered] @{}
foreach ($method in @($nativeFormMethodCounts.Keys | Sort-Object))
{
	$orderedNativeFormMethodCounts[$method] = $nativeFormMethodCounts[$method]
}

$sourceEvidenceDispositionCounts = [ordered] @{}
foreach ($entry in $sortedRows | Group-Object SourceEvidenceDisposition | Sort-Object Name)
{
	$sourceEvidenceDispositionCounts[$entry.Name] = $entry.Count
}

$summary = [ordered] @{
	Schema = 'typed-aot-native-call-source-callsites-v12'
	SourceRoot = $summarySourceRoot
	SourceCppFileCount = $files.Count
	BindCppFileCount = $bindCppFileCount
	RegistrationCppFileCount = $registrationFileCount
	ProviderDeclarationCount = $providerCount
	ProviderLiteralBindNameCount = @($sortedProviderRows | Where-Object { -not [string]::IsNullOrEmpty($_.Provider) }).Count
	DistinctProviderIdentityCount = @($sortedProviderRows | Group-Object Provider, PhaseExpression).Count
	ProviderAttributedCallsiteCount = @($sortedRows | Where-Object { -not [string]::IsNullOrEmpty($_.Provider) }).Count
	ProviderUnattributedCallsiteCount = @($sortedRows | Where-Object { [string]::IsNullOrEmpty($_.Provider) }).Count
	LexicalProviderCallsiteCount = @($sortedRows | Where-Object { $_.ProviderAttribution -eq 'lexical-preceding-provider' }).Count
	SingleProviderFileCallsiteCount = @($sortedRows | Where-Object { $_.ProviderAttribution -eq 'single-provider-file' }).Count
	UniqueHelperCallGraphCallsiteCount = @($sortedRows | Where-Object { $_.ProviderAttribution -eq 'unique-helper-call-graph' }).Count
	RegistrationCallsiteCount = $sortedRows.Count
	LiteralDeclarationCount = @($sortedRows | Where-Object { -not [string]::IsNullOrEmpty($_.LiteralDeclaration) }).Count
	DynamicDeclarationCount = @($sortedRows | Where-Object { [string]::IsNullOrEmpty($_.LiteralDeclaration) }).Count
	NativeFormCallsiteCount = @($sortedRows | Where-Object { $_.HasNativeForm -eq $true }).Count
	ExplicitNativeFormCallsiteCount = @($sortedRows | Where-Object { $_.NativeFormSource -eq 'explicit-fluent' }).Count
	ImplicitMacroNativeFormCallsiteCount = @($sortedRows | Where-Object { $_.NativeFormSource -eq 'implicit-macro' }).Count
	NativeFormLiteralDisplayCallsiteCount = @($sortedRows | Where-Object { -not [string]::IsNullOrEmpty($_.NativeCallableLiteralDisplays) }).Count
	NativeFormLiteralHeaderCallsiteCount = @($sortedRows | Where-Object { -not [string]::IsNullOrEmpty($_.NativeLiteralHeaders) }).Count
	ExternalDescriptorCallsiteCount = @($sortedRows | Where-Object { $_.HasExternalDescriptor -eq $true }).Count
	ExternalDescriptorAttachmentCount = $sortedDescriptorRows.Count
	ReviewedHelperDescriptorAttachmentCount = @($sortedDescriptorRows | Where-Object { $_.AttachmentKind -eq 'reviewed-helper' }).Count
	CompileOutCallsiteCount = @($sortedRows | Where-Object { $_.HasCompileOut -eq $true }).Count
	SourceEvidenceDispositions = $sourceEvidenceDispositionCounts
	InstalledAuthorityPendingCount = @($sortedRows | Where-Object { -not [string]::IsNullOrEmpty($_.RequiredInstalledAuthority) }).Count
	RegistrationApis = $apiCounts
	NativeFormMethods = $orderedNativeFormMethodCounts
	Completeness = 'source-callsites-only'
	KnownGap = 'Every row now has a source-evidence disposition, but none is a final installed disposition. One source callsite may install zero, one, or many functions. Provider declaration source and registration callsite source are distinct. Reviewed helper attachment discovery is source evidence, while the final Engine descriptor registry is authoritative. Runtime provider provenance plus canonical declaration/native-form/descriptor/scalar-ABI/routing/lifetime data is required to resolve unattributed or dynamic callsites and decide final direct, bridge, compile-out, or unsupported disposition.'
}
$summary | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $SummaryJson -Encoding utf8NoBOM

Write-Output "SOURCE_CPP_FILES=$($files.Count)"
Write-Output "BIND_CPP_FILES=$bindCppFileCount"
Write-Output "REGISTRATION_CPP_FILES=$registrationFileCount"
Write-Output "PROVIDER_DECLARATIONS=$providerCount"
Write-Output "REGISTRATION_CALLSITES=$($sortedRows.Count)"
Write-Output "CSV=$OutputCsv"
Write-Output "PROVIDER_CSV=$ProviderCsv"
Write-Output "DESCRIPTOR_CSV=$DescriptorCsv"
Write-Output "SUMMARY=$SummaryJson"
