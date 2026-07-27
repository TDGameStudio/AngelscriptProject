Set-StrictMode -Version Latest

function Import-CoverageCatalog
{
	[CmdletBinding()]
	param(
		[Parameter(Mandatory)]
		[string]$CatalogPath
	)

	$ResolvedCatalogPath = Resolve-Path -LiteralPath $CatalogPath -ErrorAction Stop
	$Tokens = $null
	$ParseErrors = $null
	$Ast = [System.Management.Automation.Language.Parser]::ParseFile(
		$ResolvedCatalogPath,
		[ref]$Tokens,
		[ref]$ParseErrors)
	if ($ParseErrors.Count -gt 0)
	{
		$FirstError = $ParseErrors[0]
		throw "Coverage catalog parse failure at $($FirstError.Extent.StartLineNumber):$($FirstError.Extent.StartColumnNumber): $($FirstError.Message)"
	}

	$UnsafeNodes = @($Ast.FindAll(
		{
			param($Node)
			switch ($Node.GetType().Name)
			{
				'ArrayExpressionAst' { return $false }
				'ArrayLiteralAst' { return $false }
				'CommandExpressionAst' { return $false }
				'ConstantExpressionAst' { return $false }
				'HashtableAst' { return $false }
				'NamedBlockAst' { return $false }
				'PipelineAst' { return $false }
				'ScriptBlockAst' { return $false }
				'StatementBlockAst' { return $false }
				'StringConstantExpressionAst' { return $false }
				default { return $true }
			}
		},
		$true))
	if ($UnsafeNodes.Count -gt 0)
	{
		$FirstUnsafeNode = $UnsafeNodes[0]
		throw "Coverage catalog must contain data literals only; found $($FirstUnsafeNode.GetType().Name) at $($FirstUnsafeNode.Extent.StartLineNumber):$($FirstUnsafeNode.Extent.StartColumnNumber): $($FirstUnsafeNode.Extent.Text)"
	}

	# The literal-only AST check above permits lifting PowerShell's small default data-file limit
	# without allowing executable expressions from this checked-in catalog. Windows PowerShell 5.1
	# does not expose SkipLimitCheck, so pass it only when the active host supports the parameter.
	$ImportParameters = @{
		LiteralPath = $ResolvedCatalogPath
		ErrorAction = 'Stop'
	}
	if ((Get-Command Import-PowerShellDataFile).Parameters.ContainsKey('SkipLimitCheck'))
	{
		$ImportParameters.SkipLimitCheck = $true
		return Import-PowerShellDataFile @ImportParameters
	}

	# Windows PowerShell 5.1 has no SkipLimitCheck and applies a stricter restricted
	# language evaluator to data files containing nested literal arrays/hashtables. The
	# AST gate above has already rejected every executable node, so evaluate this
	# checked-in literal-only file directly as the compatibility fallback.
	$CatalogScript = [scriptblock]::Create(
		[System.IO.File]::ReadAllText($ResolvedCatalogPath))
	return & $CatalogScript
}
