#include "../Shared/AngelscriptTestEngineHelper.h"
#include "../Shared/AngelscriptTestMacros.h"

#include "Core/AngelscriptEngine.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"
#include "UObject/Class.h"
#include "UObject/Package.h"
#include "UObject/UObjectGlobals.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace CompilerPipelineNamingTest
{
	static const FName ModuleName(TEXT("CompilerGeneratedClassExactNameLookup"));
	static const FString ScriptFilename(TEXT("Tests/Compiler/CompilerGeneratedClassExactNameLookup.as"));
	static const FName GeneratedClassName(TEXT("UExactNameCarrier"));
	static const FName GeneratedFunctionName(TEXT("GetValue"));

	const FString ScriptSource = TEXT(R"AS(
UCLASS()
class UExactNameCarrier : UObject
{
	UFUNCTION()
	int GetValue()
	{
		return 42;
	}
}
)AS");
}

using namespace CompilerPipelineNamingTest;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptCompilerGeneratedClassExactNameLookupTest,
	"Angelscript.TestModule.Compiler.EndToEnd.GeneratedClassExactNameLookup",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptCompilerGeneratedClassExactNameLookupTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*CompilerPipelineNamingTest::ModuleName.ToString());
	};

	Engine.ResetDiagnostics();

	FAngelscriptCompileTraceSummary Summary;
	const bool bCompiled = CompileModuleWithSummary(
		&Engine,
		ECompileType::FullReload,
		CompilerPipelineNamingTest::ModuleName,
		CompilerPipelineNamingTest::ScriptFilename,
		CompilerPipelineNamingTest::ScriptSource,
		true,
		Summary,
		false);

	bPassed &= TestTrue(
		TEXT("Generated-class exact-name lookup scenario should compile successfully"),
		bCompiled);
	bPassed &= TestTrue(
		TEXT("Generated-class exact-name lookup scenario should use the preprocessor path"),
		Summary.bUsedPreprocessor);
	bPassed &= TestTrue(
		TEXT("Generated-class exact-name lookup scenario should mark compile succeeded in the summary"),
		Summary.bCompileSucceeded);
	bPassed &= TestEqual(
		TEXT("Generated-class exact-name lookup scenario should report FullyHandled"),
		Summary.CompileResult,
		ECompileResult::FullyHandled);
	bPassed &= TestEqual(
		TEXT("Generated-class exact-name lookup scenario should not emit diagnostics"),
		Summary.Diagnostics.Num(),
		0);
	if (!bCompiled)
	{
		return false;
	}

	UPackage* Package = Engine.GetPackageInstance();
	if (!TestNotNull(TEXT("Generated-class exact-name lookup scenario should expose the engine package"), Package))
	{
		return false;
	}

	UClass* ExactLookupClass = FindObject<UClass>(Package, *CompilerPipelineNamingTest::GeneratedClassName.ToString());
	if (!TestNotNull(TEXT("Generated-class exact-name lookup scenario should find the generated class by its exact script name"), ExactLookupClass))
	{
		return false;
	}

	bPassed &= TestEqual(
		TEXT("Generated-class exact-name lookup scenario should keep the exact UObject name"),
		ExactLookupClass->GetName(),
		CompilerPipelineNamingTest::GeneratedClassName.ToString());

	UClass* StrippedLookupClass = FindObject<UClass>(Package, TEXT("ExactNameCarrier"));
	bPassed &= TestNull(
		TEXT("Generated-class exact-name lookup scenario should not leave behind a stripped-name alias"),
		StrippedLookupClass);

	UClass* HelperLookupClass = FindGeneratedClass(&Engine, CompilerPipelineNamingTest::GeneratedClassName);
	if (!TestNotNull(TEXT("Generated-class exact-name lookup scenario should still resolve through FindGeneratedClass"), HelperLookupClass))
	{
		return false;
	}

	bPassed &= TestTrue(
		TEXT("Generated-class exact-name lookup scenario should have helper lookup resolve to the same exact-name object"),
		HelperLookupClass == ExactLookupClass);

	UFunction* GetValueFunction = FindGeneratedFunction(ExactLookupClass, CompilerPipelineNamingTest::GeneratedFunctionName);
	if (!TestNotNull(TEXT("Generated-class exact-name lookup scenario should expose GetValue on the exact-name class"), GetValueFunction))
	{
		return false;
	}

	UObject* RuntimeObject = NewObject<UObject>(GetTransientPackage(), ExactLookupClass, TEXT("CompilerExactNameCarrier"));
	if (!TestNotNull(TEXT("Generated-class exact-name lookup scenario should instantiate the exact-name class"), RuntimeObject))
	{
		return false;
	}

	int32 Result = 0;
	const bool bExecuted = ExecuteGeneratedIntEventOnGameThread(&Engine, RuntimeObject, GetValueFunction, Result);
	bPassed &= TestTrue(
		TEXT("Generated-class exact-name lookup scenario should execute GetValue on the exact-name class"),
		bExecuted);
	if (bExecuted)
	{
		bPassed &= TestEqual(
			TEXT("Generated-class exact-name lookup scenario should return the expected value"),
			Result,
			42);
	}

	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

#endif
