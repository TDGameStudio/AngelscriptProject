Set-StrictMode -Version Latest

function Resolve-GenerationPlanRoot
{
	param([Parameter(Mandatory = $true)][string]$ScriptRoot)

	$ChangeRoot = [System.IO.Path]::GetFullPath((Join-Path $ScriptRoot '..'))
	if ((Split-Path $ChangeRoot -Leaf) -ne 'test-as-source-generation-rules')
	{
		throw "Inventory scripts must execute from test-as-source-generation-rules/scripts. Resolved: $ChangeRoot"
	}
	return $ChangeRoot
}

function Resolve-RepositoryRoot
{
	param(
		[Parameter(Mandatory = $true)][string]$ChangeRoot,
		[string]$RepoRoot
	)

	if ([string]::IsNullOrWhiteSpace($RepoRoot))
	{
		$Resolved = [System.IO.Path]::GetFullPath((Join-Path $ChangeRoot '../../..'))
	}
	else
	{
		$Resolved = [System.IO.Path]::GetFullPath($RepoRoot)
	}

	if (-not (Test-Path -LiteralPath (Join-Path $Resolved 'openspec') -PathType Container))
	{
		throw "Repository root does not contain openspec/: $Resolved"
	}
	return $Resolved
}

function Get-LineStarts
{
	param([Parameter(Mandatory = $true)][AllowEmptyString()][string]$Text)

	$Starts = [System.Collections.Generic.List[int]]::new()
	$Starts.Add(0)
	for ($Index = 0; $Index -lt $Text.Length; ++$Index)
	{
		if ($Text[$Index] -eq "`n")
		{
			$Starts.Add($Index + 1)
		}
	}
	return $Starts.ToArray()
}

function Get-LineNumberAtOffset
{
	param(
		[Parameter(Mandatory = $true)][int[]]$LineStarts,
		[Parameter(Mandatory = $true)][int]$Offset
	)

	$Low = 0
	$High = $LineStarts.Length - 1
	while ($Low -le $High)
	{
		$Middle = [int](($Low + $High) / 2)
		if ($LineStarts[$Middle] -le $Offset)
		{
			$Low = $Middle + 1
		}
		else
		{
			$High = $Middle - 1
		}
	}
	return $High + 1
}

function Get-NearestNamedMatch
{
	param(
		[Parameter(Mandatory = $true)][AllowEmptyCollection()][System.Text.RegularExpressions.Match[]]$Matches,
		[Parameter(Mandatory = $true)][int]$Offset,
		[Parameter(Mandatory = $true)][string]$GroupName,
		[string]$Fallback = '<file-scope>'
	)

	$Name = $Fallback
	foreach ($Match in $Matches)
	{
		if ($Match.Index -gt $Offset)
		{
			break
		}
		$Candidate = $Match.Groups[$GroupName].Value.Trim()
		if (-not [string]::IsNullOrWhiteSpace($Candidate))
		{
			$Name = $Candidate
		}
	}
	return $Name
}

function ConvertTo-PlanSlug
{
	param([Parameter(Mandatory = $true)][AllowEmptyString()][string]$Value)

	$Slug = $Value -replace '\\', '/'
	$Slug = $Slug -replace '\.[^.\/]+$', ''
	$Slug = $Slug -replace '[^A-Za-z0-9]+', '_'
	$Slug = $Slug.Trim('_')
	if ([string]::IsNullOrWhiteSpace($Slug))
	{
		return 'Unnamed'
	}
	return $Slug
}

function Get-RawStringLiteral
{
	param(
		[Parameter(Mandatory = $true)][string]$Text,
		[Parameter(Mandatory = $true)][System.Text.RegularExpressions.Match]$StartMatch
	)

	$Delimiter = $StartMatch.Groups['delimiter'].Value
	$ContentStart = $StartMatch.Index + $StartMatch.Length
	$Closing = ")$Delimiter`""
	$ContentEnd = $Text.IndexOf($Closing, $ContentStart, [System.StringComparison]::Ordinal)
	if ($ContentEnd -lt 0)
	{
		return [pscustomobject]@{
			Start = $StartMatch.Index
			End = $Text.Length
			Delimiter = $Delimiter
			Content = $Text.Substring($ContentStart)
			Closed = $false
		}
	}

	return [pscustomobject]@{
		Start = $StartMatch.Index
		End = $ContentEnd + $Closing.Length
		Delimiter = $Delimiter
		Content = $Text.Substring($ContentStart, $ContentEnd - $ContentStart)
		Closed = $true
	}
}

function Test-LikelyAngelScriptLiteral
{
	param(
		[Parameter(Mandatory = $true)][string]$RelativePath,
		[Parameter(Mandatory = $true)][AllowEmptyString()][string]$Delimiter,
		[Parameter(Mandatory = $true)][AllowEmptyString()][string]$Content,
		[Parameter(Mandatory = $true)][AllowEmptyString()][string]$NearbyText
	)

	if ($Delimiter -match '(?i)AS|SCRIPT') { return $true }
	if ($Content -match '(?m)\b(UCLASS|USTRUCT|UINTERFACE|UENUM|UPROPERTY|UFUNCTION|mixin|namespace|class|struct|interface|enum|funcdef|import)\b') { return $true }
	if ($Content -match '(?m)\b(void|bool|int8|int16|int|int64|uint8|uint16|uint|uint64|float32|float64|FString|FName)\s+[A-Za-z_]\w*\s*\(') { return $true }
	if ($NearbyText -match '(?i)(Compile|BuildModule|AddScriptSection|Execute|ASTEST|Angelscript|ScriptSource|ExpectedError)') { return $true }
	if ($RelativePath -match '(?i)(^|/)(Syntax|AngelScriptSDK|Coverage|Preprocessor|HotReload|StaticJIT)(/|$)') { return $true }
	return $false
}

function Get-SourceShape
{
	param([Parameter(Mandatory = $true)][AllowEmptyString()][string]$Content)

	if ($Content -match '(?m)\bUCLASS\b' -and $Content -match '(?m):\s*(AActor|APawn|ACharacter)\b') { return 'UClassActor' }
	if ($Content -match '(?m)\bUCLASS\b') { return 'UClass' }
	if ($Content -match '(?m)\bUSTRUCT\b') { return 'UStruct' }
	if ($Content -match '(?m)\bUINTERFACE\b|\binterface\b') { return 'UInterface' }
	if ($Content -match '(?m)\bUENUM\b|\benum\b') { return 'UEnum' }
	if ($Content -match '(?m)\b(class|struct)\s+[A-Za-z_]\w*') { return 'ScriptType' }
	if ($Content -match '(?m)\b(void|bool|int8|int16|int|int64|uint8|uint16|uint|uint64|float32|float64|FString|FName)\s+[A-Za-z_]\w*\s*\(') { return 'FreeFunctions' }
	return 'RawSnippet'
}

function Get-ReturnTypes
{
	param([Parameter(Mandatory = $true)][AllowEmptyString()][string]$Content)

	$Types = [System.Collections.Generic.SortedSet[string]]::new([System.StringComparer]::Ordinal)
	$Pattern = '(?m)^\s*(?<type>void|bool|int8|int16|int|int64|uint8|uint16|uint|uint64|float32|float64|FString|FName|FText|FVector|FRotator|FTransform|[AUF][A-Za-z_]\w*(?:@|&|\s*<[^>]+>)?)\s+[A-Za-z_]\w*\s*\('
	foreach ($Match in [regex]::Matches($Content, $Pattern))
	{
		[void]$Types.Add($Match.Groups['type'].Value.Trim())
	}
	if ($Types.Count -eq 0) { return '<not-statically-inferred>' }
	return ($Types -join ';')
}

function Get-ExecutionKind
{
	param([Parameter(Mandatory = $true)][AllowEmptyString()][string]$Context)

	if ($Context -match '(?i)(CompileAndExpectFailure|FailsToCompile|Expect.*Error|ExpectedDiagnostic|CompileError)') { return 'CompileAndExpectFailure' }
	if ($Context -match '(?i)(Expect.*Exception|ExceptionThrown|ExecuteAndExpectException)') { return 'ExecuteAndExpectException' }
	if ($Context -match '(?i)(ExecuteAndExpectInt|ReturnValue|GetReturn)') { return 'ExecuteAndObserveReturn' }
	return 'CustomCppAssert'
}

function Get-OracleKinds
{
	param([Parameter(Mandatory = $true)][AllowEmptyString()][string]$Context)

	$Kinds = [System.Collections.Generic.List[string]]::new()
	if ($Context -match '(?i)(Compile|BuildModule)') { $Kinds.Add('compile') }
	if ($Context -match '(?i)(Diagnostic|Error|Message|FailsToCompile)') { $Kinds.Add('diagnostic') }
	if ($Context -match '(?i)(Return|Result|Verify|Assert|Check|Expect|Equals)') { $Kinds.Add('typed-value') }
	if ($Context -match '(?i)(Metadata|Property|FunctionByName|TypeInfo)') { $Kinds.Add('metadata') }
	if ($Context -match '(?i)(Exception|Cleanup|Destructor|GC|Lifecycle)') { $Kinds.Add('lifecycle') }
	if ($Context -match '(?i)(Bytecode|JIT|Opcode)') { $Kinds.Add('bytecode') }
	if ($Context -match '(?i)(World|Actor|Component|Object|Reference|Handle)') { $Kinds.Add('object-state') }
	if ($Kinds.Count -eq 0) { $Kinds.Add('host-observation') }
	return (($Kinds | Select-Object -Unique) -join ';')
}

function Get-GenerationDisposition
{
	param(
		[Parameter(Mandatory = $true)][string]$RelativePath,
		[Parameter(Mandatory = $true)][string]$Method,
		[Parameter(Mandatory = $true)][AllowEmptyString()][string]$Content
	)

	$Key = "$RelativePath/$Method"
	$Recipe = ''
	if ($Key -match '(?i)(Int|Float|Bool)(Expression|BinaryOperator|UnaryOperator|Assignment)') { $Recipe = 'expression-product' }
	elseif ($Key -match '(?i)(Int|Float|Bool)Function') { $Recipe = 'function-mode-product' }
	elseif ($Key -match '(?i)(Int|Float|Bool|FString)Propert') { $Recipe = 'uclass-property-family' }
	elseif ($Key -match '(?i)UFunction.*(Width|Parameter|Return|Direction|Position)') { $Recipe = 'ufunction-signature-product' }
	elseif ($Key -match '(?i)(Array|Map|Set).*(Element|Key|Value|Type)') { $Recipe = 'container-element-product' }
	elseif ($Key -match '(?i)(UClass|UStruct|UEnum|UInterface).*(Specifier|Declaration|Member|Flag|Metadata|Layout)') { $Recipe = 'ue-definition-product' }
	elseif ($Key -match '(?i)(Reject|Invalid|Failure|Diagnostic|FailsToCompile)') { $Recipe = 'compile-fail-mutation' }

	if (-not [string]::IsNullOrWhiteSpace($Recipe))
	{
		return [pscustomobject]@{ Disposition = 'GeneratedRecipe'; Recipe = $Recipe }
	}

	if ($Key -match '(?i)(World|Actor|Component|Network|Replication|Timer|Input|Physics|Asset|Widget|HotReload|Debugger|DebugServer|Subsystem|GameInstance)')
	{
		return [pscustomobject]@{ Disposition = 'SpecializedScenario'; Recipe = 'authored-host-scenario' }
	}

	return [pscustomobject]@{ Disposition = 'AuthoredExport'; Recipe = 'authored-source-export' }
}

function Write-PlanCsv
{
	param(
		[Parameter(Mandatory = $true)][object[]]$Rows,
		[Parameter(Mandatory = $true)][string]$Path
	)

	$Parent = Split-Path $Path -Parent
	if (-not (Test-Path -LiteralPath $Parent))
	{
		[void](New-Item -ItemType Directory -Path $Parent -Force)
	}
	$Rows | Export-Csv -LiteralPath $Path -NoTypeInformation -Encoding utf8NoBOM
}

Export-ModuleMember -Function @(
	'Resolve-GenerationPlanRoot',
	'Resolve-RepositoryRoot',
	'Get-LineStarts',
	'Get-LineNumberAtOffset',
	'Get-NearestNamedMatch',
	'ConvertTo-PlanSlug',
	'Get-RawStringLiteral',
	'Test-LikelyAngelScriptLiteral',
	'Get-SourceShape',
	'Get-ReturnTypes',
	'Get-ExecutionKind',
	'Get-OracleKinds',
	'Get-GenerationDisposition',
	'Write-PlanCsv'
)
