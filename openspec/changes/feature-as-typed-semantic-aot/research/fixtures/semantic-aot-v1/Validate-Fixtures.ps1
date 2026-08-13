[CmdletBinding()]
param(
	[string] $FixtureRoot
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($FixtureRoot))
{
	$FixtureRoot = $PSScriptRoot
}
$ExpectedSchemaVersion = 3
$Errors = [System.Collections.Generic.List[object]]::new()
$PassedCases = 0

function Add-ValidationError
{
	param(
		[Parameter(Mandatory = $true)]
		[string] $Code,

		[Parameter(Mandatory = $true)]
		[string] $CaseName,

		[Parameter(Mandatory = $true)]
		[string] $Detail,

		[System.Collections.Generic.List[object]] $Target = $script:Errors
	)

	$Target.Add([pscustomobject]@{
		Code = $Code
		CaseName = $CaseName
		Detail = $Detail
	})
}

function Resolve-FixtureArtifact
{
	param(
		[Parameter(Mandatory = $true)]
		[string] $Root,

		[Parameter(Mandatory = $true)]
		[string] $RelativePath,

		[Parameter(Mandatory = $true)]
		[string] $CaseName,

		[Parameter(Mandatory = $true)]
		[string] $ArtifactName,

		[System.Collections.Generic.List[object]] $Target = $script:Errors
	)

	$ResolvedRoot = [System.IO.Path]::GetFullPath($Root).TrimEnd(
		[System.IO.Path]::DirectorySeparatorChar,
		[System.IO.Path]::AltDirectorySeparatorChar)
	$ResolvedPath = [System.IO.Path]::GetFullPath((Join-Path $ResolvedRoot $RelativePath))
	$RequiredPrefix = $ResolvedRoot + [System.IO.Path]::DirectorySeparatorChar
	if (-not $ResolvedPath.StartsWith(
		$RequiredPrefix,
		[System.StringComparison]::OrdinalIgnoreCase))
	{
		Add-ValidationError -Code 'ArtifactPathEscape' -CaseName $CaseName `
			-Detail "$ArtifactName path '$RelativePath' escapes the fixture root." `
			-Target $Target
		return $null
	}

	if (-not (Test-Path -LiteralPath $ResolvedPath -PathType Leaf))
	{
		Add-ValidationError -Code 'MissingArtifact' -CaseName $CaseName `
			-Detail "$ArtifactName file '$RelativePath' does not exist." `
			-Target $Target
		return $null
	}

	return $ResolvedPath
}

function Test-ArtifactHash
{
	param(
		[Parameter(Mandatory = $true)]
		[string] $Path,

		[Parameter(Mandatory = $true)]
		[string] $ExpectedHash,

		[Parameter(Mandatory = $true)]
		[string] $CaseName,

		[Parameter(Mandatory = $true)]
		[string] $ArtifactName,

		[System.Collections.Generic.List[object]] $Target = $script:Errors
	)

	$Text = [System.IO.File]::ReadAllText($Path).Replace("`r`n", "`n").Replace("`r", "`n")
	$Bytes = [System.Text.UTF8Encoding]::new($false).GetBytes($Text)
	$Sha256 = [System.Security.Cryptography.SHA256]::Create()
	try
	{
		$ActualHash = ([System.BitConverter]::ToString(
			$Sha256.ComputeHash($Bytes))).Replace('-', '').ToLowerInvariant()
	}
	finally
	{
		$Sha256.Dispose()
	}
	if ($ExpectedHash -notmatch '^[0-9a-f]{64}$')
	{
		Add-ValidationError -Code 'InvalidManifestHash' -CaseName $CaseName `
			-Detail "$ArtifactName SHA-256 is not a lowercase 64-character digest." `
			-Target $Target
		return
	}

	if ($ActualHash -cne $ExpectedHash)
	{
		Add-ValidationError -Code 'ArtifactHashMismatch' -CaseName $CaseName `
			-Detail "$ArtifactName canonical-text SHA-256 mismatch: expected $ExpectedHash, actual $ActualHash." `
			-Target $Target
	}
}

function Format-Span
{
	param([object] $Span)

	if ($null -eq $Span)
	{
		return '<missing>'
	}

	return "$($Span.section)@$($Span.offset)+$($Span.length)"
}

function Format-ExpressionList
{
	param([object[]] $Values)

	return '[' + ((@($Values) | ForEach-Object { "E$_" }) -join ',') + ']'
}

function Format-StatementList
{
	param([object[]] $Values)

	return '[' + ((@($Values) | ForEach-Object { "T$_" }) -join ',') + ']'
}

function Format-FormalArguments
{
	param([object[]] $Values)

	return '[' + ((@($Values) | ForEach-Object {
		"F$($_.formalIndex)=E$($_.expression):$($_.origin)"
	}) -join ',') + ']'
}

function Format-EvaluationSequence
{
	param([object[]] $Values)

	return '[' + ((@($Values) | ForEach-Object {
		$Formal = if ($null -eq $_.formalIndex) { 'none' } else { "F$($_.formalIndex)" }
		"$($_.role)($Formal)=E$($_.expression)"
	}) -join ',') + ']'
}

function Format-CanonicalHir
{
	param([object] $Hir)

	$Lines = [System.Collections.Generic.List[string]]::new()
	$Lines.Add("function $($Hir.functionDeclaration)")
	$Header = $Hir.functionHeader
	$ReceiverSymbol = if ($null -eq $Header.receiver.symbol)
	{
		'none'
	}
	else
	{
		"S$($Header.receiver.symbol)"
	}
	$ReceiverType = if ($null -eq $Header.receiver.type)
	{
		'none'
	}
	else
	{
		[string] $Header.receiver.type
	}
	$Lines.Add(
		"header traits=$($Header.declaredTraitBits) invocation=$($Header.invocationKind) receiver=$($Header.receiver.kind) receiverSymbol=$ReceiverSymbol receiverParameter=$($Header.receiver.parameterIndex) receiverType=$ReceiverType compileOut=$($Header.compileOutType) hiddenArgument=$($Header.hiddenArgumentIndex) determinesOutputType=$($Header.determinesOutputTypeArgumentIndex) returnsOnStack=$(([string] $Header.returnsOnStack).ToLowerInvariant()) suspend=$(([string] $Header.hasSuspendState).ToLowerInvariant()) cleanup=$(([string] $Header.hasExceptionCleanup).ToLowerInvariant())")
	$Lines.Add("root=T$($Hir.rootStatement)")
	$Lines.Add('symbols:')
	foreach ($Symbol in @($Hir.symbols))
	{
		$Lines.Add(
			"  S$($Symbol.id) kind=$($Symbol.kind) name=$($Symbol.name) type=$($Symbol.type) span=$(Format-Span $Symbol.span)")
	}

	$Lines.Add('expressions:')
	foreach ($Expression in @($Hir.expressions))
	{
		$Detail = switch ($Expression.kind)
		{
			'Literal' { "value=$($Expression.value)" }
			'Symbol' { "symbol=S$($Expression.symbol)" }
			'Binary' { "operator=$($Expression.operator) operands=$(Format-ExpressionList $Expression.operands)" }
			'ShortCircuit' { "operator=$($Expression.operator) operands=$(Format-ExpressionList $Expression.operands)" }
			'Unary' { "operator=$($Expression.operator) operand=E$($Expression.operand)" }
			'Conversion' { "targetType=$($Expression.targetType) operand=E$($Expression.operand)" }
			'Assignment' { "operator=$($Expression.operator) target=E$($Expression.targetExpression) value=E$($Expression.valueExpression)" }
			'ResolvedCall' {
				"targetKind=$($Expression.targetKind) target=$($Expression.resolvedTarget) formal=$(Format-FormalArguments $Expression.formalArguments) evaluation=$(Format-EvaluationSequence $Expression.evaluationSequence) exception=$($Expression.exceptionBehavior)"
			}
			'Unsupported' { "category=$($Expression.category) operands=$(Format-ExpressionList $Expression.operands)" }
			default { 'detail=<unknown>' }
		}
		$Lines.Add(
			"  E$($Expression.id) kind=$($Expression.kind) type=$($Expression.type) $Detail span=$(Format-Span $Expression.span)")
	}

	$Lines.Add('statements:')
	foreach ($Statement in @($Hir.statements))
	{
		$Detail = switch ($Statement.kind)
		{
			'Block' { "children=$(Format-StatementList $Statement.children)" }
			'LocalDeclaration' { "symbol=S$($Statement.symbol) initializer=E$($Statement.initializerExpression)" }
			'Expression' { "expression=E$($Statement.expression)" }
			'If' {
				$Else = if ($null -eq $Statement.elseStatement) { 'none' } else { "T$($Statement.elseStatement)" }
				"condition=E$($Statement.conditionExpression) then=T$($Statement.thenStatement) else=$Else"
			}
			'For' {
				"initializer=T$($Statement.initializerStatement) condition=E$($Statement.conditionExpression) increment=E$($Statement.incrementExpression) body=T$($Statement.bodyStatement)"
			}
			'While' { "condition=E$($Statement.conditionExpression) body=T$($Statement.bodyStatement)" }
			'DoWhile' { "body=T$($Statement.bodyStatement) condition=E$($Statement.conditionExpression)" }
			'Switch' { "selector=E$($Statement.selectorExpression) cases=$(Format-StatementList $Statement.cases)" }
			'Case' {
				$Match = if ($null -eq $Statement.matchExpression) { 'default' } else { "E$($Statement.matchExpression)" }
				"match=$Match children=$(Format-StatementList $Statement.children)"
			}
			'Break' { "target=T$($Statement.targetStatement)" }
			'Continue' { "target=T$($Statement.targetStatement)" }
			'Return' {
				$Value = if ($null -eq $Statement.valueExpression) { 'void' } else { "E$($Statement.valueExpression)" }
				"value=$Value"
			}
			'Unsupported' { "category=$($Statement.category)" }
			default { 'detail=<unknown>' }
		}
		$Lines.Add(
			"  T$($Statement.id) kind=$($Statement.kind) $Detail span=$(Format-Span $Statement.span)")
	}

	return ($Lines -join "`n") + "`n"
}

function Test-FunctionHeader
{
	param(
		[object] $Header,
		[object[]] $Symbols,
		[string] $CaseName,
		[System.Collections.Generic.List[object]] $Target
	)

	if ($null -eq $Header)
	{
		Add-ValidationError -Code 'MissingFunctionHeader' -CaseName $CaseName `
			-Detail 'functionHeader must be present.' -Target $Target
		return
	}

	if (@('Global', 'InstanceMethod', 'Constructor', 'Destructor', 'Factory',
		'Imported', 'System', 'Funcdef', 'Synthesized') -notcontains
		[string] $Header.invocationKind)
	{
		Add-ValidationError -Code 'InvalidInvocationKind' -CaseName $CaseName `
			-Detail "Unknown invocationKind '$($Header.invocationKind)'." -Target $Target
	}

	if (@('CompileCalls', 'CompileOutEntirely', 'ReplaceWithFirstParam',
		'CompileOutAsMethodChain') -notcontains [string] $Header.compileOutType)
	{
		Add-ValidationError -Code 'InvalidCompileOutType' -CaseName $CaseName `
			-Detail "Unknown compileOutType '$($Header.compileOutType)'." -Target $Target
	}

	$Receiver = $Header.receiver
	if ($null -eq $Receiver)
	{
		Add-ValidationError -Code 'InvalidEffectiveReceiver' -CaseName $CaseName `
			-Detail 'functionHeader.receiver must be present.' -Target $Target
		return
	}

	$ReceiverKind = [string] $Receiver.kind
	if ($ReceiverKind -eq 'None')
	{
		if ($null -ne $Receiver.symbol -or [int] $Receiver.parameterIndex -ne -1 `
			-or $null -ne $Receiver.type)
		{
			Add-ValidationError -Code 'InvalidEffectiveReceiver' -CaseName $CaseName `
				-Detail 'None receiver must not name a symbol, parameter, or type.' -Target $Target
		}
		return
	}

	$ReceiverSymbol = 0
	if ($null -eq $Receiver.symbol `
		-or -not [int]::TryParse($Receiver.symbol.ToString(), [ref] $ReceiverSymbol) `
		-or $ReceiverSymbol -lt 0 -or $ReceiverSymbol -ge $Symbols.Count)
	{
		Add-ValidationError -Code 'InvalidEffectiveReceiver' -CaseName $CaseName `
			-Detail "Receiver references invalid symbol '$($Receiver.symbol)'." -Target $Target
		return
	}

	$Symbol = $Symbols[$ReceiverSymbol]
	if ($ReceiverKind -eq 'NativeObjectThis')
	{
		if ($Symbol.kind -ne 'Receiver' -or [int] $Receiver.parameterIndex -ne -1 `
			-or [string] $Symbol.type -cne [string] $Receiver.type)
		{
			Add-ValidationError -Code 'InvalidEffectiveReceiver' -CaseName $CaseName `
				-Detail 'NativeObjectThis must reference a matching synthetic Receiver symbol and no parameter.' `
				-Target $Target
		}
		return
	}

	if ($ReceiverKind -eq 'ExplicitParameterAlias' -or
		$ReceiverKind -eq 'MixinFirstParameter')
	{
		if ([int] $Receiver.parameterIndex -ne 0 -or $ReceiverSymbol -ne 0 `
			-or $Symbol.kind -ne 'Parameter' `
			-or [string] $Symbol.type -cne [string] $Receiver.type)
		{
			Add-ValidationError -Code 'InvalidEffectiveReceiver' -CaseName $CaseName `
				-Detail "$ReceiverKind must alias matching declared Parameter S0." -Target $Target
			return
		}

		$TraitBits = [uint32] $Header.declaredTraitBits
		$RequiredBit = if ($ReceiverKind -eq 'ExplicitParameterAlias')
		{
			[uint32] 0x200000
		}
		else
		{
			[uint32] 0x800
		}
		if (($TraitBits -band $RequiredBit) -eq 0)
		{
			Add-ValidationError -Code 'InvalidEffectiveReceiver' -CaseName $CaseName `
				-Detail "$ReceiverKind is missing its required function trait bit." -Target $Target
		}
		return
	}

	Add-ValidationError -Code 'InvalidEffectiveReceiver' -CaseName $CaseName `
		-Detail "Unknown receiver kind '$ReceiverKind'." -Target $Target
}

function Test-Reference
{
	param(
		[object] $Value,
		[int] $Count,
		[string] $Code,
		[string] $Owner,
		[string] $Field,
		[string] $CaseName,
		[System.Collections.Generic.List[object]] $Target
	)

	if ($null -eq $Value)
	{
		return
	}

	$IntegerValue = 0
	if (-not [int]::TryParse($Value.ToString(), [ref] $IntegerValue) `
		-or $IntegerValue -lt 0 -or $IntegerValue -ge $Count)
	{
		Add-ValidationError -Code $Code -CaseName $CaseName `
			-Detail "$Owner.$Field references invalid ID '$Value' (count: $Count)." `
			-Target $Target
	}
}

function Test-Span
{
	param(
		[object] $Span,
		[int] $SourceLength,
		[string] $Owner,
		[string] $CaseName,
		[System.Collections.Generic.List[object]] $Target
	)

	if ($null -eq $Span -or [string]::IsNullOrWhiteSpace([string] $Span.section))
	{
		Add-ValidationError -Code 'InvalidSourceSpan' -CaseName $CaseName `
			-Detail "$Owner has no owned source section." -Target $Target
		return
	}

	$Offset = 0
	$Length = 0
	if (-not [int]::TryParse($Span.offset.ToString(), [ref] $Offset) `
		-or -not [int]::TryParse($Span.length.ToString(), [ref] $Length) `
		-or $Offset -lt 0 -or $Length -lt 0 `
		-or ([long] $Offset + [long] $Length) -gt $SourceLength)
	{
		Add-ValidationError -Code 'InvalidSourceSpan' -CaseName $CaseName `
			-Detail "$Owner span $(Format-Span $Span) exceeds source length $SourceLength." `
			-Target $Target
	}
}

function Test-HirStructure
{
	param(
		[object] $Hir,
		[string] $SourceText,
		[string] $CaseName,
		[System.Collections.Generic.List[object]] $Target
	)

	if ($Hir.schemaVersion -ne $ExpectedSchemaVersion)
	{
		Add-ValidationError -Code 'UnsupportedHirSchema' -CaseName $CaseName `
			-Detail "HIR schemaVersion must be $ExpectedSchemaVersion." -Target $Target
	}

	if ([string]::IsNullOrWhiteSpace([string] $Hir.functionDeclaration))
	{
		Add-ValidationError -Code 'MissingFunctionDeclaration' -CaseName $CaseName `
			-Detail 'functionDeclaration must be present.' -Target $Target
	}

	$Symbols = @($Hir.symbols)
	$Expressions = @($Hir.expressions)
	$Statements = @($Hir.statements)
	Test-FunctionHeader -Header $Hir.functionHeader -Symbols $Symbols `
		-CaseName $CaseName -Target $Target
	for ($Index = 0; $Index -lt $Symbols.Count; $Index++)
	{
		if ($Symbols[$Index].id -ne $Index)
		{
			Add-ValidationError -Code 'NonContiguousSymbolId' -CaseName $CaseName `
				-Detail "symbols[$Index].id must equal $Index." -Target $Target
		}
		Test-Span -Span $Symbols[$Index].span -SourceLength $SourceText.Length `
			-Owner "S$Index" -CaseName $CaseName -Target $Target
	}

	for ($Index = 0; $Index -lt $Expressions.Count; $Index++)
	{
		$Expression = $Expressions[$Index]
		if ($Expression.id -ne $Index)
		{
			Add-ValidationError -Code 'NonContiguousExpressionId' -CaseName $CaseName `
				-Detail "expressions[$Index].id must equal $Index." -Target $Target
		}
		Test-Span -Span $Expression.span -SourceLength $SourceText.Length `
			-Owner "E$Index" -CaseName $CaseName -Target $Target

		foreach ($Operand in @($Expression.operands))
		{
			Test-Reference -Value $Operand -Count $Expressions.Count `
				-Code 'DanglingExpressionId' -Owner "E$Index" -Field 'operands' `
				-CaseName $CaseName -Target $Target
		}
		foreach ($Field in @('operand', 'targetExpression', 'valueExpression'))
		{
			$Property = $Expression.PSObject.Properties[$Field]
			if ($null -ne $Property)
			{
				Test-Reference -Value $Property.Value -Count $Expressions.Count `
					-Code 'DanglingExpressionId' -Owner "E$Index" -Field $Field `
					-CaseName $CaseName -Target $Target
			}
		}
		foreach ($Argument in @($Expression.arguments))
		{
			Test-Reference -Value $Argument -Count $Expressions.Count `
				-Code 'DanglingExpressionId' -Owner "E$Index" -Field 'arguments' `
				-CaseName $CaseName -Target $Target
		}
		if ($Expression.kind -eq 'ResolvedCall')
		{
			$FormalArguments = @($Expression.formalArguments)
			$EvaluationSequence = @($Expression.evaluationSequence)
			$ExpectedEvaluationKeys = @{}
			$ObservedEvaluationKeys = @{}
			$FormalIndexes = @{}
			$CallSequenceIsValid = $true

			if ($FormalArguments.Count -eq 0 -and $null -eq $Expression.receiverExpression)
			{
				$CallSequenceIsValid = $EvaluationSequence.Count -eq 0
			}

			foreach ($Binding in $FormalArguments)
			{
				$FormalIndex = 0
				if (-not [int]::TryParse($Binding.formalIndex.ToString(), [ref] $FormalIndex) `
					-or $FormalIndex -lt 0 -or $FormalIndexes.ContainsKey($FormalIndex))
				{
					$CallSequenceIsValid = $false
					continue
				}
				$FormalIndexes[$FormalIndex] = $true
				$Before = $Target.Count
				Test-Reference -Value $Binding.expression -Count $Expressions.Count `
					-Code 'DanglingExpressionId' -Owner "E$Index" `
					-Field "formalArguments[$FormalIndex]" -CaseName $CaseName -Target $Target
				if ($Target.Count -ne $Before)
				{
					$CallSequenceIsValid = $false
					continue
				}
				if (@(
					'SourcePositional', 'SourceNamed', 'Default', 'Hidden',
					'MixinReceiver', 'AbiOnly') -notcontains [string] $Binding.origin)
				{
					$CallSequenceIsValid = $false
				}
				$ExpectedEvaluationKeys["Argument:${FormalIndex}:$($Binding.expression)"] = 1
			}

			$ReceiverProperty = $Expression.PSObject.Properties['receiverExpression']
			if ($null -ne $ReceiverProperty -and $null -ne $ReceiverProperty.Value)
			{
				$Before = $Target.Count
				Test-Reference -Value $ReceiverProperty.Value -Count $Expressions.Count `
					-Code 'DanglingExpressionId' -Owner "E$Index" -Field 'receiverExpression' `
					-CaseName $CaseName -Target $Target
				if ($Target.Count -eq $Before)
				{
					$ExpectedEvaluationKeys["Receiver:none:$($ReceiverProperty.Value)"] = 1
				}
				else
				{
					$CallSequenceIsValid = $false
				}
			}

			foreach ($Step in $EvaluationSequence)
			{
				$Before = $Target.Count
				Test-Reference -Value $Step.expression -Count $Expressions.Count `
					-Code 'DanglingExpressionId' -Owner "E$Index" -Field 'evaluationSequence' `
					-CaseName $CaseName -Target $Target
				if ($Target.Count -ne $Before)
				{
					$CallSequenceIsValid = $false
					continue
				}

				$Role = [string] $Step.role
				if ($Role -eq 'Argument' -or $Role -eq 'Hidden')
				{
					$FormalIndex = 0
					if (-not [int]::TryParse($Step.formalIndex.ToString(), [ref] $FormalIndex))
					{
						$CallSequenceIsValid = $false
						continue
					}
					$Key = "Argument:${FormalIndex}:$($Step.expression)"
				}
				elseif ($Role -eq 'Receiver')
				{
					$Key = "Receiver:none:$($Step.expression)"
				}
				else
				{
					$CallSequenceIsValid = $false
					continue
				}

				if ($ObservedEvaluationKeys.ContainsKey($Key))
				{
					$ObservedEvaluationKeys[$Key]++
				}
				else
				{
					$ObservedEvaluationKeys[$Key] = 1
				}
			}

			if ($ExpectedEvaluationKeys.Count -ne $ObservedEvaluationKeys.Count)
			{
				$CallSequenceIsValid = $false
			}
			foreach ($Key in @($ExpectedEvaluationKeys.Keys))
			{
				if (-not $ObservedEvaluationKeys.ContainsKey($Key) `
					-or $ObservedEvaluationKeys[$Key] -ne 1)
				{
					$CallSequenceIsValid = $false
				}
			}

			if (-not $CallSequenceIsValid)
			{
				Add-ValidationError -Code 'InvalidCallEvaluationSequence' `
					-CaseName $CaseName `
					-Detail "E$Index formal bindings and evaluation sequence are inconsistent." `
					-Target $Target
			}
		}
		$SymbolProperty = $Expression.PSObject.Properties['symbol']
		if ($null -ne $SymbolProperty)
		{
			Test-Reference -Value $SymbolProperty.Value -Count $Symbols.Count `
				-Code 'DanglingSymbolId' -Owner "E$Index" -Field 'symbol' `
				-CaseName $CaseName -Target $Target
		}
	}

	$ParentCounts = @{}
	$ParentStatements = @{}
	for ($Index = 0; $Index -lt $Statements.Count; $Index++)
	{
		$ParentCounts[$Index] = 0
		$ParentStatements[$Index] = $null
	}

	for ($Index = 0; $Index -lt $Statements.Count; $Index++)
	{
		$Statement = $Statements[$Index]
		if ($Statement.id -ne $Index)
		{
			Add-ValidationError -Code 'NonContiguousStatementId' -CaseName $CaseName `
				-Detail "statements[$Index].id must equal $Index." -Target $Target
		}
		Test-Span -Span $Statement.span -SourceLength $SourceText.Length `
			-Owner "T$Index" -CaseName $CaseName -Target $Target

		$SymbolProperty = $Statement.PSObject.Properties['symbol']
		if ($null -ne $SymbolProperty)
		{
			Test-Reference -Value $SymbolProperty.Value -Count $Symbols.Count `
				-Code 'DanglingSymbolId' -Owner "T$Index" -Field 'symbol' `
				-CaseName $CaseName -Target $Target
		}
		foreach ($Field in @(
			'initializerExpression', 'conditionExpression', 'incrementExpression',
			'valueExpression', 'selectorExpression', 'matchExpression', 'expression'))
		{
			$Property = $Statement.PSObject.Properties[$Field]
			if ($null -ne $Property -and $null -ne $Property.Value)
			{
				Test-Reference -Value $Property.Value -Count $Expressions.Count `
					-Code 'DanglingExpressionId' -Owner "T$Index" -Field $Field `
					-CaseName $CaseName -Target $Target
			}
		}

		$OwnedChildren = [System.Collections.Generic.List[object]]::new()
		foreach ($Child in @($Statement.children))
		{
			if ($null -ne $Child) { $OwnedChildren.Add($Child) }
		}
		foreach ($CaseStatement in @($Statement.cases))
		{
			if ($null -ne $CaseStatement) { $OwnedChildren.Add($CaseStatement) }
		}
		foreach ($Field in @(
			'thenStatement', 'elseStatement', 'initializerStatement', 'bodyStatement'))
		{
			$Property = $Statement.PSObject.Properties[$Field]
			if ($null -ne $Property -and $null -ne $Property.Value)
			{
				$OwnedChildren.Add($Property.Value)
			}
		}
		foreach ($Child in $OwnedChildren)
		{
			$Before = $Target.Count
			Test-Reference -Value $Child -Count $Statements.Count `
				-Code 'DanglingStatementId' -Owner "T$Index" -Field 'ownedStatement' `
				-CaseName $CaseName -Target $Target
			if ($Target.Count -eq $Before)
			{
				$ParentCounts[[int] $Child]++
				if ($ParentCounts[[int] $Child] -eq 1)
				{
					$ParentStatements[[int] $Child] = $Index
				}
			}
		}
	}

	for ($Index = 0; $Index -lt $Statements.Count; $Index++)
	{
		$Statement = $Statements[$Index]
		if ($Statement.kind -ne 'Break' -and $Statement.kind -ne 'Continue')
		{
			continue
		}

		$TargetProperty = $Statement.PSObject.Properties['targetStatement']
		$ResolvedTarget = -1
		$TargetIsValidReference = $null -ne $TargetProperty `
			-and $null -ne $TargetProperty.Value `
			-and [int]::TryParse(
				$TargetProperty.Value.ToString(),
				[ref] $ResolvedTarget) `
			-and $ResolvedTarget -ge 0 `
			-and $ResolvedTarget -lt $Statements.Count
		if (-not $TargetIsValidReference)
		{
			Add-ValidationError -Code 'InvalidControlTarget' -CaseName $CaseName `
				-Detail "T$Index $($Statement.kind) has no valid targetStatement." `
				-Target $Target
			continue
		}

		$AllowedKinds = if ($Statement.kind -eq 'Continue')
		{
			@('For', 'While', 'DoWhile')
		}
		else
		{
			@('For', 'While', 'DoWhile', 'Switch')
		}
		$NearestTarget = $null
		$Cursor = $ParentStatements[$Index]
		$VisitedCount = 0
		while ($null -ne $Cursor -and $VisitedCount -lt $Statements.Count)
		{
			if ($AllowedKinds -contains [string] $Statements[[int] $Cursor].kind)
			{
				$NearestTarget = [int] $Cursor
				break
			}
			$Cursor = $ParentStatements[[int] $Cursor]
			$VisitedCount++
		}

		if ($null -eq $NearestTarget -or $ResolvedTarget -ne $NearestTarget)
		{
			$ExpectedTarget = if ($null -eq $NearestTarget)
			{
				'<none>'
			}
			else
			{
				"T$NearestTarget"
			}
			Add-ValidationError -Code 'InvalidControlTarget' -CaseName $CaseName `
				-Detail "T$Index $($Statement.kind) targets T$ResolvedTarget; nearest legal target is $ExpectedTarget." `
				-Target $Target
		}
	}

	$RootBefore = $Target.Count
	Test-Reference -Value $Hir.rootStatement -Count $Statements.Count `
		-Code 'DanglingStatementId' -Owner 'function' -Field 'rootStatement' `
		-CaseName $CaseName -Target $Target
	if ($Target.Count -eq $RootBefore)
	{
		$RootIndex = [int] $Hir.rootStatement
		if ($Statements[$RootIndex].kind -ne 'Block')
		{
			Add-ValidationError -Code 'InvalidRootStatement' -CaseName $CaseName `
				-Detail 'rootStatement must refer to a Block.' -Target $Target
		}
		if ($ParentCounts[$RootIndex] -ne 0)
		{
			Add-ValidationError -Code 'RootStatementHasParent' -CaseName $CaseName `
				-Detail 'rootStatement must not be owned by another statement.' -Target $Target
		}
	}

	foreach ($Key in @($ParentCounts.Keys))
	{
		if ($ParentCounts[$Key] -gt 1)
		{
			Add-ValidationError -Code 'StatementHasMultipleOwners' -CaseName $CaseName `
				-Detail "T$Key has $($ParentCounts[$Key]) owners." -Target $Target
		}
	}
}

$ResolvedFixtureRoot = [System.IO.Path]::GetFullPath($FixtureRoot)
$ManifestPath = Join-Path $ResolvedFixtureRoot 'manifest.json'
if (-not (Test-Path -LiteralPath $ManifestPath -PathType Leaf))
{
	Write-Error "ERROR [MissingManifest] corpus: '$ManifestPath' does not exist."
	exit 1
}

try
{
	$Manifest = Get-Content -LiteralPath $ManifestPath -Raw | ConvertFrom-Json
}
catch
{
	Write-Error "ERROR [InvalidManifestJson] corpus: $($_.Exception.Message)"
	exit 1
}

if ($Manifest.schemaVersion -ne $ExpectedSchemaVersion)
{
	Add-ValidationError -Code 'UnsupportedManifestSchema' -CaseName 'corpus' `
		-Detail "manifest schemaVersion must be $ExpectedSchemaVersion."
}

$Cases = @($Manifest.cases)
$UniqueNames = @{}
foreach ($Case in $Cases)
{
	$CaseName = [string] $Case.name
	$CaseErrors = [System.Collections.Generic.List[object]]::new()
	if ([string]::IsNullOrWhiteSpace($CaseName) -or $UniqueNames.ContainsKey($CaseName))
	{
		Add-ValidationError -Code 'DuplicateOrEmptyCaseName' -CaseName $CaseName `
			-Detail 'Every fixture case name must be non-empty and unique.'
		continue
	}
	$UniqueNames[$CaseName] = $true

	$Artifacts = @{}
	foreach ($ArtifactName in @('source', 'hir', 'dump'))
	{
		$RelativePath = [string] $Case.artifacts.$ArtifactName
		$ArtifactPath = Resolve-FixtureArtifact -Root $ResolvedFixtureRoot `
			-RelativePath $RelativePath -CaseName $CaseName `
			-ArtifactName $ArtifactName -Target $CaseErrors
		if ($null -ne $ArtifactPath)
		{
			$Artifacts[$ArtifactName] = $ArtifactPath
			Test-ArtifactHash -Path $ArtifactPath `
				-ExpectedHash ([string] $Case.sha256.$ArtifactName) `
				-CaseName $CaseName -ArtifactName $ArtifactName -Target $CaseErrors
		}
	}

	$CppRelativePath = [string] $Case.artifacts.cpp
	if ($Case.expectation.eligibility -eq 'Semantic')
	{
		if ([string]::IsNullOrWhiteSpace($CppRelativePath))
		{
			Add-ValidationError -Code 'MissingSemanticCppGolden' -CaseName $CaseName `
				-Detail 'Semantic case must declare expected.cpp.' -Target $CaseErrors
		}
		else
		{
			$CppPath = Resolve-FixtureArtifact -Root $ResolvedFixtureRoot `
				-RelativePath $CppRelativePath -CaseName $CaseName `
				-ArtifactName 'cpp' -Target $CaseErrors
			if ($null -ne $CppPath)
			{
				$Artifacts['cpp'] = $CppPath
				Test-ArtifactHash -Path $CppPath `
					-ExpectedHash ([string] $Case.sha256.cpp) `
					-CaseName $CaseName -ArtifactName 'cpp' -Target $CaseErrors
				$CppText = Get-Content -LiteralPath $CppPath -Raw
				if ($CppText -match '(?i)GetByteCode|FAngelscriptBytecode|FAngelscriptJITProvider|ProviderPrivate|0x[0-9a-f]{8,}')
				{
					Add-ValidationError -Code 'ForbiddenCppToken' -CaseName $CaseName `
						-Detail 'Semantic C++ golden contains bytecode/provider/private-address material.' `
						-Target $CaseErrors
				}
			}
		}
	}
	elseif (-not [string]::IsNullOrWhiteSpace($CppRelativePath))
	{
		Add-ValidationError -Code 'UnexpectedCppGolden' -CaseName $CaseName `
			-Detail 'Fallback or invalid cases must not publish expected.cpp.' `
			-Target $CaseErrors
	}

	if ($Artifacts.ContainsKey('source') -and $Artifacts.ContainsKey('hir'))
	{
		$SourceBytes = [System.IO.File]::ReadAllBytes($Artifacts.source)
		if (@($SourceBytes | Where-Object { $_ -gt 127 }).Count -ne 0)
		{
			Add-ValidationError -Code 'NonAsciiFixtureSource' -CaseName $CaseName `
				-Detail 'Research fixture source must remain ASCII so offsets are unambiguous.' `
				-Target $CaseErrors
		}
		$SourceText = [System.IO.File]::ReadAllText($Artifacts.source)
		try
		{
			$Hir = Get-Content -LiteralPath $Artifacts.hir -Raw | ConvertFrom-Json
			Test-HirStructure -Hir $Hir -SourceText $SourceText `
				-CaseName $CaseName -Target $CaseErrors

			if ($Artifacts.ContainsKey('dump'))
			{
				$ExpectedDump = (
					Get-Content -LiteralPath $Artifacts.dump -Raw
				).Replace("`r`n", "`n")
				$ActualDump = Format-CanonicalHir -Hir $Hir
				if ($ExpectedDump -cne $ActualDump)
				{
					Add-ValidationError -Code 'CanonicalDumpMismatch' -CaseName $CaseName `
						-Detail 'expected.hir.txt does not match the canonical HIR rendering.' `
						-Target $CaseErrors
				}
			}
		}
		catch
		{
			Add-ValidationError -Code 'InvalidHirJson' -CaseName $CaseName `
				-Detail $_.Exception.Message -Target $CaseErrors
		}
	}

	$ExpectedValidation = [string] $Case.expectation.validation
	if ($ExpectedValidation -eq 'Pass')
	{
		if ($CaseErrors.Count -eq 0)
		{
			$PassedCases++
		}
		else
		{
			foreach ($ErrorRecord in $CaseErrors) { $Errors.Add($ErrorRecord) }
		}
	}
	elseif ($ExpectedValidation -eq 'Fail')
	{
		$ExpectedCode = [string] $Case.expectation.validationCode
		$UnexpectedErrors = @($CaseErrors | Where-Object { $_.Code -ne $ExpectedCode })
		$MatchingErrors = @($CaseErrors | Where-Object { $_.Code -eq $ExpectedCode })
		if ($MatchingErrors.Count -eq 1 -and $UnexpectedErrors.Count -eq 0)
		{
			$PassedCases++
		}
		else
		{
			Add-ValidationError -Code 'ExpectedValidationFailureMismatch' `
				-CaseName $CaseName `
				-Detail "Expected exactly one '$ExpectedCode' failure; observed: $((@($CaseErrors.Code) -join ', '))."
			foreach ($ErrorRecord in $CaseErrors) { $Errors.Add($ErrorRecord) }
		}
	}
	else
	{
		Add-ValidationError -Code 'InvalidValidationExpectation' -CaseName $CaseName `
			-Detail "validation must be Pass or Fail, not '$ExpectedValidation'."
	}
}

if ($Cases.Count -ne 10)
{
	Add-ValidationError -Code 'UnexpectedCaseCount' -CaseName 'corpus' `
		-Detail "Expected 10 cases, found $($Cases.Count)."
}

if ($Errors.Count -ne 0)
{
	foreach ($ErrorRecord in $Errors)
	{
		Write-Output "ERROR [$($ErrorRecord.Code)] $($ErrorRecord.CaseName): $($ErrorRecord.Detail)"
	}
	Write-Output "FAIL semantic-aot-v1 fixtures: $PassedCases/$($Cases.Count)"
	exit 1
}

Write-Output "PASS semantic-aot-v1 fixtures: $PassedCases/$($Cases.Count)"
