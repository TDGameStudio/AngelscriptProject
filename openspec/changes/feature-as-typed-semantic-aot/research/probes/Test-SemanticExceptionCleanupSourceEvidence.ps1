[CmdletBinding()]
param(
	[string] $ProjectRoot
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

if ([string]::IsNullOrWhiteSpace($ProjectRoot))
{
	$ProjectRoot = Find-ProjectRoot -StartPath $PSScriptRoot
}
else
{
	$ProjectRoot = [System.IO.Path]::GetFullPath($ProjectRoot)
}

$RuntimeRoot = Join-Path $ProjectRoot 'Plugins/Angelscript/Source/AngelscriptRuntime'
$ThirdPartySource = Join-Path $RuntimeRoot 'ThirdParty/angelscript/source'
$Files = @{
	ContextHeader = Join-Path $ThirdPartySource 'as_context.h'
	Context = Join-Path $ThirdPartySource 'as_context.cpp'
	Bytecode = Join-Path $ThirdPartySource 'as_bytecode.cpp'
	Compiler = Join-Path $ThirdPartySource 'as_compiler.cpp'
	StaticJITHeaderSource = Join-Path $RuntimeRoot 'StaticJIT/StaticJITHeader.cpp'
	LegacyGenerator = Join-Path $RuntimeRoot 'StaticJIT/BytecodeJIT/AngelscriptBytecodeJIT.cpp'
	LegacyBytecodes = Join-Path $RuntimeRoot 'StaticJIT/BytecodeJIT/AngelscriptBytecodes.cpp'
	Engine = Join-Path $RuntimeRoot 'Core/AngelscriptEngine.cpp'
	HandlingRejectionTest = Join-Path $ProjectRoot 'Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Language/Exceptions/AngelscriptNativeExceptionHandlingRejectionTests.cpp'
}

$Texts = @{}
foreach ($Entry in $Files.GetEnumerator())
{
	if (-not (Test-Path -LiteralPath $Entry.Value -PathType Leaf))
	{
		throw "Required evidence file is missing: $($Entry.Value)"
	}

	$Texts[$Entry.Key] = [System.IO.File]::ReadAllText($Entry.Value)
}

$Failures = [System.Collections.Generic.List[string]]::new()
$Passed = 0

function Assert-SourcePattern
{
	param(
		[Parameter(Mandatory = $true)] [string] $Name,
		[Parameter(Mandatory = $true)] [string] $Text,
		[Parameter(Mandatory = $true)] [string] $Pattern,
		[int] $MinimumMatches = 1
	)

	$MatchCount = [System.Text.RegularExpressions.Regex]::Matches(
		$Text,
		$Pattern,
		[System.Text.RegularExpressions.RegexOptions]::Singleline).Count
	if ($MatchCount -lt $MinimumMatches)
	{
		$script:Failures.Add(
			"${Name}: expected at least $MinimumMatches match(es), found $MatchCount.")
		return
	}

	$script:Passed += 1
}

function Assert-SourcePatternAbsent
{
	param(
		[Parameter(Mandatory = $true)] [string] $Name,
		[Parameter(Mandatory = $true)] [string] $Text,
		[Parameter(Mandatory = $true)] [string] $Pattern
	)

	$MatchCount = [System.Text.RegularExpressions.Regex]::Matches(
		$Text,
		$Pattern,
		[System.Text.RegularExpressions.RegexOptions]::Singleline).Count
	if ($MatchCount -ne 0)
	{
		$script:Failures.Add(
			"${Name}: expected no matches, found $MatchCount.")
		return
	}

	$script:Passed += 1
}

Assert-SourcePattern -Name 'VM context retains structured exception payload' `
	-Text $Texts.ContextHeader `
	-Pattern 'asCString\s+m_exceptionString;\s*int\s+m_exceptionFunction;\s*int\s+m_exceptionSectionIdx;\s*int\s+m_exceptionLine;\s*int\s+m_exceptionColumn;\s*bool\s+m_exceptionWillBeCaught;'
Assert-SourcePattern -Name 'JIT execution retains only the exception flag' `
	-Text $Texts.ContextHeader `
	-Pattern 'struct\s+FScriptExecution\s*\{(?<body>.*?)bool\s+bExceptionThrown;'
$ExecutionBody = [System.Text.RegularExpressions.Regex]::Match(
	$Texts.ContextHeader,
	'struct\s+FScriptExecution\s*\{(?<body>.*?)\n\};',
	[System.Text.RegularExpressions.RegexOptions]::Singleline).Groups['body'].Value
Assert-SourcePatternAbsent -Name 'JIT execution has no exception text field' `
	-Text $ExecutionBody `
	-Pattern 'exception(String|Text|Message|Function|Line|Column)'
Assert-SourcePattern -Name 'Runtime Throw prefers active JIT execution' `
	-Text $Texts.Engine `
	-Pattern 'void\s+FAngelscriptEngine::Throw.*activeExecution\s*!=\s*nullptr.*SetExternalException\(\s*\*tld->activeExecution,\s*Exception\);.*else if \(tld->activeContext != nullptr\).*activeContext->SetException\(Exception\);'
Assert-SourcePattern -Name 'JIT exception handler currently only logs' `
	-Text $Texts.Engine `
	-Pattern 'void\s+FAngelscriptEngine::HandleExceptionFromJIT\([^)]*\)\s*\{\s*LogAngelscriptException\(ExceptionString\);\s*\}'
Assert-SourcePattern -Name 'StaticJIT exception helpers record then log through HandleExceptionFromJIT' `
	-Text $Texts.StaticJITHeaderSource `
	-Pattern 'FAngelscriptEngine::HandleExceptionFromJIT' `
	-MinimumMatches 2
Assert-SourcePattern -Name 'top and nested VM entries collapse JIT failure to context status' `
	-Text $Texts.Context `
	-Pattern 'if\s*\(!Execution\.bExceptionThrown\).*m_status\s*=\s*asEXECUTION_FINISHED;.*else\s*\{\s*if\s*\(!Execution\.PublishException\(\*this\)\)\s*m_status\s*=\s*asEXECUTION_EXCEPTION;'
Assert-SourcePattern -Name 'nested JIT entry also maps failure to context status' `
	-Text $Texts.Context `
	-Pattern 'void\s+asCContext::CallScriptFunction.*if\s*\(!Execution\.bExceptionThrown\).*else\s*\{\s*if\s*\(!Execution\.PublishException\(\*this\)\)\s*m_status\s*=\s*asEXECUTION_EXCEPTION;'
Assert-SourcePattern -Name 'direct generated script calls share execution state' `
	-Text $Texts.LegacyBytecodes `
	-Pattern 'FunctionSymbolName,\s*ArgumentString,\s*HeadCode,\s*FootCode\);.*if\s*\(Execution\.bExceptionThrown\)'
Assert-SourcePattern -Name 'dynamic bridge creates a nested context' `
	-Text $Texts.LegacyBytecodes `
	-Pattern 'FAngelscriptContext\s+CallContext\(CallFunction->GetEngine\(\)\);.*CallContext->Prepare\(CallFunction\);.*CallContext->Execute\(\);'
Assert-SourcePattern -Name 'dynamic bridge folds inner status into outer flag' `
	-Text $Texts.LegacyBytecodes `
	-Pattern 'CallContext->m_status\s*!=\s*asEXECUTION_FINISHED.*Execution\.bExceptionThrown\s*=\s*true;'
Assert-SourcePatternAbsent -Name 'dynamic bridge does not adopt exception text' `
	-Text $Texts.LegacyBytecodes `
	-Pattern 'CallContext->GetException(String|Function|LineNumber)'
Assert-SourcePattern -Name 'VM records exact exception metadata and callback' `
	-Text $Texts.Context `
	-Pattern 'void\s+asCContext::SetInternalException.*m_exceptionString\s*=\s*descr;.*m_exceptionFunction\s*=\s*m_currentFunction->id;.*m_exceptionLine.*m_exceptionColumn.*FindExceptionTryCatch\(\).*CallExceptionCallback\(\);'
Assert-SourcePattern -Name 'VM computes live objects from bytecode position' `
	-Text $Texts.Context `
	-Pattern 'void\s+asCContext::DetermineLiveObjects.*objVariableInfo.*programPos\s*>\s*pos.*asOBJ_UNINIT.*asOBJ_INIT'
Assert-SourcePattern -Name 'VM exception cleanup is reverse declaration order' `
	-Text $Texts.Context `
	-Pattern 'Exception unwinding must release live locals in reverse declaration.*objVariablePos\.GetLength\(\)\s*-\s*1;.*n\s*>=\s*0;.*--n'
Assert-SourcePattern -Name 'Legacy computes before or after operation liveness' `
	-Text $Texts.LegacyGenerator `
	-Pattern 'MarkLiveObjectsForExceptionCleanup.*if\s*\(bAfterCurrentOp\).*GetNextBC.*objVariableInfo.*programPos\s*>\s*bcPos'
Assert-SourcePattern -Name 'Legacy emits deduplicated cleanup labels' `
	-Text $Texts.LegacyGenerator `
	-Pattern 'ExistingLabel\.Positions\s*==\s*Cleanup\.Positions.*ExistingLabel\.Types\s*==\s*Cleanup\.Types.*goto\s+\{0\};'
Assert-SourcePattern -Name 'Legacy exception cleanup emits reverse declaration order' `
	-Text $Texts.LegacyGenerator `
	-Pattern 'for\s*\(int\s+i\s*=\s*Cleanup\.Positions\.Num\(\)\s*-\s*1;\s*i\s*>=\s*0;\s*--i\)'
Assert-SourcePattern -Name 'script cleanup destructors isolate from the failed execution' `
	-Text $Texts.LegacyBytecodes `
	-Pattern 'AngelscriptDestroyScriptObjectIsolated\(Execution,\s*SCRIPT_ENGINE'
Assert-SourcePattern -Name 'generated functions assume no incoming exception' `
	-Text $Texts.LegacyGenerator `
	-Pattern 'FunctionHead\s*\+=\s*TEXT\("SCRIPT_ASSUME_NO_EXCEPTION\(\)\\n"\);'
Assert-SourcePattern -Name 'return-on-stack ownership stays with caller storage' `
	-Text $Texts.StaticJITHeaderSource `
	-Pattern 'Return-on-stack uses caller-owned storage.*AngelScript unwinding is.*responsible for cleaning up the return slot'
Assert-SourcePattern -Name 'try marker plumbing exists internally' `
	-Text $Texts.Bytecode `
	-Pattern 'void\s+asCByteCode::TryBlock.*TryBlockOp\s*=\s*250'
Assert-SourcePatternAbsent -Name 'current compiler does not produce try markers' `
	-Text $Texts.Compiler `
	-Pattern '\.TryBlock\('
Assert-SourcePattern -Name 'current language tests reject try catch and rethrow' `
	-Text $Texts.HandlingRejectionTest `
	-Pattern 'FeatureCases.*try_catch.*try_without_catch.*catch_without_try.*rethrow.*current fork should reject the unsupported exception-handling syntax'
if ($Failures.Count -gt 0)
{
	foreach ($Failure in $Failures)
	{
		Write-Error $Failure -ErrorAction Continue
	}

	throw "Semantic exception/cleanup source evidence probe failed: $($Failures.Count) assertion(s)."
}

Write-Output "PASS semantic exception/cleanup source evidence: $Passed assertions"
Write-Output 'Contract: scalar Semantic code may reuse the fast flag, but rich exception adoption and a future explicit reverse-cleanup patch are separate required capabilities.'
