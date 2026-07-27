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
	$OutputPath = Join-Path (Resolve-Path (Join-Path $PSScriptRoot '..\audits')).Path 'inline-source-baseline.csv'
}

$SdkRoot = Join-Path $ProjectRoot 'Plugins\Angelscript\Source\AngelscriptTest\AngelScriptSDK'
$ExceptionPath = Join-Path (Resolve-Path (Join-Path $PSScriptRoot '..\catalogs')).Path 'inline-source-exceptions.csv'
$Exceptions = @(Import-Csv -LiteralPath $ExceptionPath)
$ExceptionKeys = @{}
$AllowedExceptionClassifications = @('ExactTokenizerInput', 'ExactLayoutSource')
foreach ($Exception in $Exceptions)
{
	foreach ($Field in @('File', 'Line', 'Classification', 'Reason', 'ExpectedLayout'))
	{
		if ([string]::IsNullOrWhiteSpace([string]$Exception.$Field))
		{
			throw "Inline source exception is missing $Field."
		}
	}
	if ($Exception.Classification -notin $AllowedExceptionClassifications)
	{
		throw "Inline source exception has unsupported classification '$($Exception.Classification)'."
	}
	$ExceptionKeys["$($Exception.File)|$($Exception.Line)"] = $Exception
}

$Rows = [System.Collections.Generic.List[object]]::new()
$EscapedNewlineRows = [System.Collections.Generic.List[object]]::new()

foreach ($File in Get-ChildItem -LiteralPath $SdkRoot -Recurse -Filter '*.cpp' -File | Sort-Object FullName)
{
	$Text = Get-Content -LiteralPath $File.FullName -Raw
	$RelativePath = $File.FullName.Substring($SdkRoot.Length).TrimStart([char[]]@('\', '/')).Replace('\', '/')
	$RawMatches = [regex]::Matches($Text, 'R"(?<Delimiter>[A-Za-z0-9_]*)\((?<Body>.*?)\)\k<Delimiter>"', [System.Text.RegularExpressions.RegexOptions]::Singleline)

	foreach ($RawMatch in $RawMatches)
	{
		$Line = ($Text.Substring(0, $RawMatch.Index) -split "`n").Count
		$PrefixStart = [Math]::Max(0, $RawMatch.Index - 120)
		$Prefix = $Text.Substring($PrefixStart, $RawMatch.Index - $PrefixStart)
		$Wrapper = if ($Prefix -match 'ASTEST_AS_ANSI_PRESERVE_LINES\s*\($') { 'ASTEST_AS_ANSI_PRESERVE_LINES' } elseif ($Prefix -match 'ASTEST_AS_ANSI\s*\($') { 'ASTEST_AS_ANSI' } elseif ($Prefix -match 'ASTEST_AS_PRESERVE_LINES\s*\($') { 'ASTEST_AS_PRESERVE_LINES' } elseif ($Prefix -match 'ASTEST_AS\s*\($') { 'ASTEST_AS' } else { '' }
		$Body = $RawMatch.Groups['Body'].Value
		$BodyLines = @([regex]::Split($Body, "\r?\n"))
		$NonEmptyLines = @($BodyLines | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
		$FirstNonEmpty = if ($NonEmptyLines.Count -gt 0) { $NonEmptyLines[0] } else { '' }
		$ContentIndented = [string]::IsNullOrEmpty($FirstNonEmpty) -or $FirstNonEmpty -match '^[ \t]+'
		$LineStart = $Text.LastIndexOf("`n", $RawMatch.Index) + 1
		$OpenLine = $Text.Substring($LineStart, $RawMatch.Index - $LineStart)
		$CloseIndex = $RawMatch.Index + $RawMatch.Length - ($RawMatch.Groups['Delimiter'].Value.Length + 2)
		$CloseLineStart = $Text.LastIndexOf("`n", $CloseIndex) + 1
		$ClosePrefix = $Text.Substring($CloseLineStart, $CloseIndex - $CloseLineStart)
		$ClosingIndented = $ClosePrefix -match '^[ \t]+'
		$DelimiterIsAs = $RawMatch.Groups['Delimiter'].Value -eq 'AS'
		$HasKrBrace = $Body -match '(?m)\)[ \t]*\{' -or $Body -match '(?m)^\s*(?:if|else|for|foreach|while|switch|class|struct|namespace)\b[^\r\n{]*\{'
		$HasSingleLineBody = $Body -match '(?m)\{[^\r\n{}]+\}'
		$IsExactLayout = $Wrapper -match 'PRESERVE_LINES'
		$IsFrontendFragment = $RelativePath -match '^Frontend/' -and $Body -notmatch '(?m)^\s*(?:class|struct|namespace|(?:const\s+)?[A-Za-z_][A-Za-z0-9_:<>@&\s]*\s+[A-Za-z_][A-Za-z0-9_]*\s*\()'
		$Classification = if ($IsExactLayout) { 'ExactLayoutSource' } elseif ($IsFrontendFragment) { 'TokenOrParserFragment' } elseif ([string]::IsNullOrWhiteSpace($Wrapper)) { 'ViolationUnwrappedSource' } else { 'OrdinaryScript' }
		$Violations = [System.Collections.Generic.List[string]]::new()

		if ([string]::IsNullOrWhiteSpace($Wrapper)) { $Violations.Add('MissingDedentWrapper') }
		if (-not $DelimiterIsAs) { $Violations.Add('NonAsRawDelimiter') }
		if (-not $ContentIndented) { $Violations.Add('ContentStartsAtColumnZero') }
		if (-not $ClosingIndented) { $Violations.Add('ClosingDelimiterStartsAtColumnZero') }
		if ($HasKrBrace) { $Violations.Add('OpeningBraceSharesStatementLine') }
		if ($HasSingleLineBody) { $Violations.Add('SingleLineBody') }

		$ExceptionKey = "$RelativePath|$Line"
		$RegisteredException = $ExceptionKeys.ContainsKey($ExceptionKey)
		$Exception = if ($RegisteredException) { $ExceptionKeys[$ExceptionKey] } else { $null }
		$RegisteredExactLayout = $RegisteredException -and $Exception.Classification -eq 'ExactLayoutSource'
		if ($IsExactLayout -and -not $RegisteredExactLayout)
		{
			$Violations.Add('UnregisteredExactLayoutSource')
		}
		if ($RegisteredException -and -not $IsExactLayout)
		{
			$Violations.Add('UnexpectedExactLayoutRegistration')
		}

		$Rows.Add([pscustomobject]@{
			File = $RelativePath
			Line = $Line
			Classification = $Classification
			Wrapper = $Wrapper
			Delimiter = $RawMatch.Groups['Delimiter'].Value
			ContentIndented = $ContentIndented
			ClosingIndented = $ClosingIndented
			RegisteredException = $RegisteredException
			Violations = ($Violations -join ';')
			Disposition = $(if ($RegisteredExactLayout -and $Violations.Count -eq 0) { 'RegisteredExactInput' } elseif ($Violations.Count -eq 0) { 'Conforming' } else { 'MustReformatOrRegister' })
		})
	}

	$EscapedMatches = [regex]::Matches($Text, '"[^"\r\n]*\\n"\s*')
	foreach ($EscapedMatch in $EscapedMatches)
	{
		$Line = ($Text.Substring(0, $EscapedMatch.Index) -split "`n").Count
		$ExceptionKey = "$RelativePath|$Line"
		$RegisteredException = $ExceptionKeys.ContainsKey($ExceptionKey)
		$Exception = if ($RegisteredException) { $ExceptionKeys[$ExceptionKey] } else { $null }
		$RegisteredExactTokenizerInput = $RegisteredException -and $Exception.Classification -eq 'ExactTokenizerInput'
		$Violations = if ($RegisteredExactTokenizerInput) { '' } else { 'EscapedNewlineConcatenation' }
		$EscapedNewlineRows.Add([pscustomobject]@{
			File = $RelativePath
			Line = $Line
			Classification = $(if ($RegisteredExactTokenizerInput) { 'ExactTokenizerInput' } else { 'EscapedNewlineSource' })
			Wrapper = ''
			Delimiter = ''
			ContentIndented = $false
			ClosingIndented = $false
			RegisteredException = $RegisteredExactTokenizerInput
			Violations = $Violations
			Disposition = $(if ($RegisteredExactTokenizerInput) { 'RegisteredExactInput' } else { 'MustReformatOrRegister' })
		})
	}
}

$AllRows = @($Rows) + @($EscapedNewlineRows)
$AllRows | Export-Csv -LiteralPath $OutputPath -NoTypeInformation -Encoding utf8
$ViolationRows = @($AllRows | Where-Object { -not [string]::IsNullOrWhiteSpace($_.Violations) })

if ($RequireClean -and $ViolationRows.Count -gt 0)
{
	$First = $ViolationRows[0]
	throw "Inline AngelScript formatting audit found $($ViolationRows.Count) violations. First: $($First.File):$($First.Line) $($First.Violations)"
}

[pscustomobject]@{
	RawSources = $Rows.Count
	EscapedNewlineSources = $EscapedNewlineRows.Count
	Conforming = @($AllRows | Where-Object Disposition -eq 'Conforming').Count
	Violations = $ViolationRows.Count
	Output = $OutputPath
}
