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
	Compiler = Join-Path $ThirdPartySource 'as_compiler.cpp'
	StaticJITHeader = Join-Path $RuntimeRoot 'StaticJIT/StaticJITHeader.h'
	StaticJITHeaderSource = Join-Path $RuntimeRoot 'StaticJIT/StaticJITHeader.cpp'
	LegacyGenerator = Join-Path $RuntimeRoot 'StaticJIT/AngelscriptStaticJIT.cpp'
	LegacyBytecodes = Join-Path $RuntimeRoot 'StaticJIT/AngelscriptBytecodes.cpp'
	Engine = Join-Path $RuntimeRoot 'Core/AngelscriptEngine.cpp'
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
		[Parameter(Mandatory = $true)]
		[string] $Name,

		[Parameter(Mandatory = $true)]
		[string] $Text,

		[Parameter(Mandatory = $true)]
		[string] $Pattern,

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

Assert-SourcePattern -Name 'JIT execution replaces active context' `
	-Text $Texts.ContextHeader `
	-Pattern 'tld->activeExecution\s*=\s*this;\s*tld->activeContext\s*=\s*nullptr;' `
	-MinimumMatches 2
Assert-SourcePattern -Name 'JIT execution preserves debug stack and exception state' `
	-Text $Texts.ContextHeader `
	-Pattern 'void\*\s+debugCallStack\s*=\s*nullptr;.*bool\s+bExceptionThrown;'
Assert-SourcePattern -Name 'top-level recursion guard precedes JIT entry' `
	-Text $Texts.Context `
	-Pattern 'm_callStack\.GetLength\(\)\s*>\s*20000.*AcquireJITBindingForExecution\(\).*VMEntry'
Assert-SourcePattern -Name 'nested JIT path precedes VM recursion guard' `
	-Text $Texts.Context `
	-Pattern 'void\s+asCContext::CallScriptFunction.*AcquireJITBindingForExecution\(\).*VMEntry.*m_callStack\.GetLength\(\)\s*>\s*10000'
Assert-SourcePattern -Name 'top and nested JIT create execution scopes' `
	-Text $Texts.Context `
	-Pattern 'FScriptExecution\s+Execution\(this\);' `
	-MinimumMatches 2
Assert-SourcePattern -Name 'active function query uses independent thread-local field' `
	-Text $Texts.Context `
	-Pattern 'asGetActiveFunction\(\)\s*\{.*return\s+tld->activeFunction;\s*\}'
Assert-SourcePattern -Name 'system call scope sets and restores active function' `
	-Text $Texts.StaticJITHeader `
	-Pattern 'FScopeInformSystemFunction.*PrevActiveFunction\s*=\s*TLD->activeFunction;\s*TLD->activeFunction\s*=\s*ScriptFunc;.*~FScopeInformSystemFunction\(\).*TLD->activeFunction\s*=\s*PrevActiveFunction;'
Assert-SourcePattern -Name 'VM suspend dispatches line callback' `
	-Text $Texts.Context `
	-Pattern 'case\s+asBC_SUSPEND:.*m_lineCallback\(this\);'
Assert-SourcePattern -Name 'VM suspend dispatches periodic loop detection' `
	-Text $Texts.Context `
	-Pattern 'case\s+asBC_SUSPEND:.*\+\+m_loopDetectionCounter\s*>\s*100000.*m_loopDetectionCallback\(this\);'
Assert-SourcePattern -Name 'Legacy StaticJIT suspend is a no-op' `
	-Text $Texts.LegacyBytecodes `
	-Pattern 'IMPL_BYTECODE_BEGIN\(asBC_SUSPEND\).*bool\s+Implement\([^)]*\)\s+const\s+override\s*\{\s*return\s+true;\s*\}'
Assert-SourcePattern -Name 'Legacy JIT debug frame links and restores' `
	-Text $Texts.StaticJITHeader `
	-Pattern 'PrevFrame\s*=\s*\(FScopeJITDebugCallstack\*\)Execution\.debugCallStack;\s*Execution\.debugCallStack\s*=\s*this;.*~FScopeJITDebugCallstack\(\)\s*\{\s*Execution\.debugCallStack\s*=\s*PrevFrame;'
Assert-SourcePattern -Name 'Legacy generator emits debug frame and line metadata' `
	-Text $Texts.LegacyGenerator `
	-Pattern 'SCRIPT_DEBUG_CALLSTACK_LINE.*bEmitDebugMetadataInOutput.*SCRIPT_DEBUG_CALLSTACK_FRAME'
Assert-SourcePattern -Name 'configured VM contexts install line and loop callbacks' `
	-Text $Texts.Engine `
	-Pattern 'SetLineCallback\(AngelscriptLineCallback\).*SetLoopDetectionCallback\(AngelscriptLoopDetectionCallback\)'
Assert-SourcePattern -Name 'line callback is game-thread constrained' `
	-Text $Texts.Engine `
	-Pattern 'void\s+AngelscriptLineCallback\(asCContext\*\s*Context\).*if\s*\(!IsInGameThread\(\)\)\s*return;'
Assert-SourcePattern -Name 'line callback drives debugger and coverage' `
	-Text $Texts.Engine `
	-Pattern 'void\s+AngelscriptLineCallback.*ProcessScriptLine\(Context\).*CodeCoverage->HitLine'
Assert-SourcePattern -Name 'loop timeout becomes script exception' `
	-Text $Texts.Engine `
	-Pattern 'void\s+AngelscriptLoopDetectionCallback.*EditorMaximumScriptExecutionTime.*Context->SetException\("Script function took too long to execute\.'
Assert-SourcePattern -Name 'for continue executes increment before condition' `
	-Text $Texts.Compiler `
	-Pattern 'void\s+asCCompiler::CompileForStatement.*Label\(\(short\)continueLabel\);\s*bc->AddCode\(&nextBC\);\s*bc->Label\(\(short\)conditionLabel\);'
Assert-SourcePattern -Name 'while continue targets the condition label' `
	-Text $Texts.Compiler `
	-Pattern 'void\s+asCCompiler::CompileWhileStatement.*continueLabels\.PushLast\(beforeLabel\);.*Label\(\(short\)beforeLabel\);.*CompileCondition'
Assert-SourcePattern -Name 'do-while continue targets trailing test and safe point' `
	-Text $Texts.Compiler `
	-Pattern 'void\s+asCCompiler::CompileDoWhileStatement.*continueLabels\.PushLast\(beforeTest\);.*Label\(\(short\)beforeTest\);.*Instr\(asBC_SUSPEND\);.*CompileCondition'
Assert-SourcePattern -Name 'break and continue emit exited-scope destructors' `
	-Text $Texts.Compiler `
	-Pattern 'void\s+asCCompiler::CompileBreakStatement.*CallDestructor.*breakLabels\[breakLabels\.GetLength\(\)-1\].*void\s+asCCompiler::CompileContinueStatement.*CallDestructor.*continueLabels\[continueLabels\.GetLength\(\)-1\]'
Assert-SourcePattern -Name 'switch selector is currently normalized to 32 bit' `
	-Text $Texts.Compiler `
	-Pattern 'void\s+asCCompiler::CompileSwitchStatement.*TODO:\s*Need to support 64bit integers.*SetTokenType\(ttInt\).*SetTokenType\(ttUInt\)'
Assert-SourcePattern -Name 'switch default-last and exhaustive exception are explicit' `
	-Text $Texts.Compiler `
	-Pattern 'TXT_DEFAULT_MUST_BE_LAST.*bSwitchIsExhaustive.*InstrWORD\(asBC_ThrowException,\s*0\)'
Assert-SourcePattern -Name 'switch invalid enum value has the maintained JIT exception' `
	-Text $Texts.StaticJITHeaderSource `
	-Pattern 'SetSwitchValueInvalidException.*bExceptionThrown\s*=\s*true;.*Invalid enum value passed to switch'
Assert-SourcePattern -Name 'assignment compiles RHS before LHS' `
	-Text $Texts.Compiler `
	-Pattern 'int\s+rr\s*=\s*CompileAssignment\(lexpr->next->next,\s*&rctx\);\s*int\s+lr\s*=\s*CompileCondition\(lexpr,\s*&lctx\);'
Assert-SourcePattern -Name 'compound math merges RHS before LHS' `
	-Text $Texts.Compiler `
	-Pattern 'different order so that they are evaluated correctly\s*MergeExprBytecode\(ctx,\s*rctx\);\s*MergeExprBytecode\(ctx,\s*lctx\);'
Assert-SourcePattern -Name 'postfix returns copied old value before mutation' `
	-Text $Texts.Compiler `
	-Pattern 'Copy the value to a temp before changing it\s*ConvertToTempVariable\(ctx\);.*Increment the value pointed to by the reference still in the register'
Assert-SourcePattern -Name 'integer power remains compiler rejected' `
	-Text $Texts.Compiler `
	-Pattern 'Cannot pow on integer values' `
	-MinimumMatches 2
Assert-SourcePattern -Name 'double integer-exponent power uses normalized int opcode' `
	-Text $Texts.Compiler `
	-Pattern 'ImplicitConversion\(rctx,\s*to,\s*node,\s*asIC_IMPLICIT_CONV,\s*true\).*instruction\s*=\s*asBC_POWdi;'

if ($Failures.Count -gt 0)
{
	foreach ($Failure in $Failures)
	{
		Write-Error $Failure -ErrorAction Continue
	}

	throw "Semantic execution source evidence probe failed: $($Failures.Count) assertion(s)."
}

Write-Output "PASS semantic execution source evidence: $Passed assertions"
Write-Output 'Contract: generated Semantic code must preserve execution capabilities and exact structured transfer/mutation semantics or route to VM.'
