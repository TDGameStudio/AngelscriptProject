param(
	[switch]$FailOnRequired
)

$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..\..")
$TestRoot = Join-Path $RepoRoot "Plugins\Angelscript\Source\AngelscriptTest"

function Get-RepoFileText {
	param([string]$RelativePath)
	return Get-Content -Raw -LiteralPath (Join-Path $RepoRoot $RelativePath)
}

function Test-Include {
	param(
		[string]$Text,
		[string]$Header
	)

	$EscapedHeader = [regex]::Escape($Header)
	return $Text -match "#\s*include\s+`"[^`"]*$EscapedHeader`""
}

function Test-Contains {
	param(
		[string]$Text,
		[string]$Pattern
	)

	return $Text -match $Pattern
}

function New-Issue {
	param(
		[string]$Severity,
		[string]$Path,
		[string]$Symbol,
		[string]$Expected
	)

	[pscustomobject]@{
		Severity = $Severity
		Path = $Path
		Symbol = $Symbol
		Expected = $Expected
	}
}

$RequiredChecks = @(
	@{
		Path = "Plugins\Angelscript\Source\AngelscriptTest\AngelScriptSDK\AngelscriptGlobalVarTests.cpp"
		Symbol = "ExecuteScriptFunction"
		Pattern = "\bExecuteScriptFunction\b"
		Header = "AngelscriptSDKTestExecutionHelpers.h"
	},
	@{
		Path = "Plugins\Angelscript\Source\AngelscriptTest\AngelScriptSDK\AngelscriptParserTests.cpp"
		Symbol = "AngelscriptNativeTestSupport::FParserAccessor"
		Pattern = "AngelscriptNativeTestSupport::FParserAccessor"
		Header = "AngelscriptNativeTestSupport.h"
	},
	@{
		Path = "Plugins\Angelscript\Source\AngelscriptTest\StaticJIT\AngelscriptStaticJITDiagnosticsTests.cpp"
		Symbol = "ASTEST_CREATE_ENGINE"
		Pattern = "\bASTEST_CREATE_ENGINE\b"
		Header = "AngelscriptTestMacros.h"
	},
	@{
		Path = "Plugins\Angelscript\Source\AngelscriptTest\StaticJIT\AOT\AngelscriptStaticJITAotGeneration.cpp"
		Symbol = "CreateIsolatedFullEngine"
		Pattern = "\bCreateIsolatedFullEngine\b"
		Header = "AngelscriptTestEngineAcquisition.h"
	},
	@{
		Path = "Plugins\Angelscript\Source\AngelscriptTest\StaticJIT\AOT\AngelscriptStaticJITAotGeneration.cpp"
		Symbol = "asCModule public interface conversion"
		Pattern = "\basCModule\b"
		Header = "source/as_module.h"
	},
	@{
		Path = "Plugins\Angelscript\Source\AngelscriptTest\GC\AngelscriptEngineMemoryLifecycleTests.cpp"
		Symbol = "CreateIsolatedFullEngine"
		Pattern = "\bCreateIsolatedFullEngine\b"
		Header = "AngelscriptTestEngineAcquisition.h"
	},
	@{
		Path = "Plugins\Angelscript\Source\AngelscriptTest\GC\AngelscriptEngineMemoryLifecycleTests.cpp"
		Symbol = "UPackage dereference"
		Pattern = "TObjectIterator<UPackage>"
		Header = "UObject/Package.h"
	},
	@{
		Path = "Plugins\Angelscript\Source\AngelscriptRuntime\Core\AngelscriptEngine.h"
		Symbol = "FCoreDelegates::EOnScreenMessageSeverity"
		Pattern = "FCoreDelegates::EOnScreenMessageSeverity"
		Header = "Misc/CoreDelegates.h"
	}
)

$RequiredFailures = @()
foreach ($Check in $RequiredChecks) {
	$Text = Get-RepoFileText $Check.Path
	if ((Test-Contains $Text $Check.Pattern) -and -not (Test-Include $Text $Check.Header)) {
		$RequiredFailures += New-Issue "required" $Check.Path $Check.Symbol "include $($Check.Header)"
	}
}

$HotReloadPath = "Plugins\Angelscript\Source\AngelscriptTest\HotReload\AngelscriptHotReloadVersionChainTests.cpp"
$HotReloadText = Get-RepoFileText $HotReloadPath
$UsesFunctionalHelpers = Test-Contains $HotReloadText "\b(CompileScriptModule|SpawnScriptActor|BeginPlayActor|ReadPropertyValue)\b"
$HasFunctionalHelperAccess = (Test-Contains $HotReloadText "AngelscriptFunctionalTestUtils::") -or (Test-Contains $HotReloadText "using\s+namespace\s+AngelscriptFunctionalTestUtils\s*;")
if ($UsesFunctionalHelpers -and -not $HasFunctionalHelperAccess) {
	$RequiredFailures += New-Issue "required" $HotReloadPath "AngelscriptFunctionalTestUtils helpers" "qualify calls or add function-scope using namespace"
}

$Advisories = @()
$CppFiles = Get-ChildItem -Recurse -File -LiteralPath $TestRoot -Filter "*.cpp"
foreach ($File in $CppFiles) {
	$RelativePath = Resolve-Path -LiteralPath $File.FullName -Relative
	$RelativePath = $RelativePath.TrimStart(".\")
	$Text = Get-Content -Raw -LiteralPath $File.FullName

	if ((Test-Contains $Text "\b(ExecuteScriptFunction|FSdkFunctionInvoker)\b") -and -not (Test-Include $Text "AngelscriptSDKTestExecutionHelpers.h")) {
		$Advisories += New-Issue "advisory" $RelativePath "SDK execution helpers" "include AngelscriptSDKTestExecutionHelpers.h"
	}

	if ((Test-Contains $Text "AngelscriptNativeTestSupport::") -and -not (Test-Include $Text "AngelscriptNativeTestSupport.h")) {
		$Advisories += New-Issue "advisory" $RelativePath "AngelscriptNativeTestSupport" "include AngelscriptNativeTestSupport.h"
	}

	if ((Test-Contains $Text "\bASTEST_[A-Z0-9_]+\b") -and -not (Test-Include $Text "AngelscriptTestMacros.h")) {
		$Advisories += New-Issue "advisory" $RelativePath "ASTEST_* macro" "include AngelscriptTestMacros.h"
	}

	if ((Test-Contains $Text "\bCreateIsolatedFullEngine\b") -and -not (Test-Include $Text "AngelscriptTestEngineAcquisition.h")) {
		$Advisories += New-Issue "advisory" $RelativePath "CreateIsolatedFullEngine" "include AngelscriptTestEngineAcquisition.h"
	}

	if ((Test-Contains $Text "\b(AcquireTransientFullTestEngine|AcquireTransientFullTestEngineWithProbe|GetTransientFullTestEngineStorage)\b") -and -not (Test-Include $Text "AngelscriptTestMemoryProbe.h")) {
		$Advisories += New-Issue "advisory" $RelativePath "memory-probe acquisition helpers" "include AngelscriptTestMemoryProbe.h"
	}

	if (Test-Contains $Text "(?m)^using namespace AngelscriptFunctionalTestUtils;\s*$") {
		$Advisories += New-Issue "advisory" $RelativePath "file-level AngelscriptFunctionalTestUtils import" "use explicit qualification or function-body import"
	}
}

Write-Host "AngelscriptTest self-containment audit"
Write-Host "Required failures: $($RequiredFailures.Count)"
Write-Host "Advisories: $($Advisories.Count)"

if ($RequiredFailures.Count -gt 0) {
	Write-Host ""
	Write-Host "Required failures:"
	$RequiredFailures | Format-Table -AutoSize | Out-String | Write-Host
}

if ($Advisories.Count -gt 0) {
	Write-Host ""
	Write-Host "Advisories:"
	$Advisories | Select-Object -First 80 | Format-Table -AutoSize | Out-String | Write-Host
	if ($Advisories.Count -gt 80) {
		Write-Host "Displayed first 80 advisories out of $($Advisories.Count)."
	}
}

if ($FailOnRequired -and $RequiredFailures.Count -gt 0) {
	exit 1
}

exit 0
