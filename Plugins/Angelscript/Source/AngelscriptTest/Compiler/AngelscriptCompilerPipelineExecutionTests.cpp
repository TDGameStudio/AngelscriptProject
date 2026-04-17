#include "../Shared/AngelscriptTestEngineHelper.h"
#include "../Shared/AngelscriptTestMacros.h"

#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"
#include "UObject/Class.h"
#include "UObject/UObjectGlobals.h"
#include "UObject/UnrealType.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace CompilerPipelineExecutionTest
{
	static const FName ModuleName(TEXT("CompilerAnnotatedMethodExecutes"));
	static const FString ScriptFilename(TEXT("CompilerAnnotatedMethodExecutes.as"));
	static const FName GeneratedClassName(TEXT("UCompilerExecutionCarrier"));
	static const FName FunctionName(TEXT("IncrementAndGetScore"));
	static const FName ScorePropertyName(TEXT("Score"));
}

using namespace CompilerPipelineExecutionTest;

namespace CompilerPipelinePlainSourceRoundTripTest
{
	static const FName ModuleName(TEXT("Tests.Compiler.PlainSourceRoundTrip"));
	static const FString RelativeScriptPath(TEXT("Tests/Compiler/PlainSourceRoundTrip.as"));
}

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptCompilerAnnotatedMethodExecutesTest,
	"Angelscript.TestModule.Compiler.EndToEnd.AnnotatedMethodExecutes",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptCompilerPlainSourcePreprocessorRoundTripTest,
	"Angelscript.TestModule.Compiler.EndToEnd.PlainSourcePreprocessorRoundTrip",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptCompilerAnnotatedMethodExecutesTest::RunTest(const FString& Parameters)
{
	bool bPassed = false;
	const FString ScriptSource = TEXT(R"AS(
UCLASS()
class UCompilerExecutionCarrier : UObject
{
	UPROPERTY()
	int Score = 41;

	UFUNCTION()
	int IncrementAndGetScore()
	{
		Score += 1;
		return Score;
	}
}
)AS");

	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*CompilerPipelineExecutionTest::ModuleName.ToString());
	};

	const bool bCompiled = CompileAnnotatedModuleFromMemory(
		&Engine,
		CompilerPipelineExecutionTest::ModuleName,
		CompilerPipelineExecutionTest::ScriptFilename,
		ScriptSource);
	if (!TestTrue(TEXT("Annotated execution test should compile the generated class module"), bCompiled))
	{
		return false;
	}

	UClass* GeneratedClass = FindGeneratedClass(&Engine, CompilerPipelineExecutionTest::GeneratedClassName);
	if (!TestNotNull(TEXT("Annotated execution test should find the generated class"), GeneratedClass))
	{
		return false;
	}

	UFunction* GeneratedFunction = FindGeneratedFunction(GeneratedClass, CompilerPipelineExecutionTest::FunctionName);
	if (!TestNotNull(TEXT("Annotated execution test should find the generated execution function"), GeneratedFunction))
	{
		return false;
	}

	FIntProperty* ScoreProperty = FindFProperty<FIntProperty>(GeneratedClass, CompilerPipelineExecutionTest::ScorePropertyName);
	if (!TestNotNull(TEXT("Annotated execution test should expose the generated Score property"), ScoreProperty))
	{
		return false;
	}

	UObject* RuntimeObject = NewObject<UObject>(GetTransientPackage(), GeneratedClass, TEXT("CompilerExecutionCarrier"));
	if (!TestNotNull(TEXT("Annotated execution test should instantiate the generated class"), RuntimeObject))
	{
		return false;
	}

	const int32 InitialScore = ScoreProperty->GetPropertyValue_InContainer(RuntimeObject);
	if (!TestEqual(TEXT("Annotated execution test should materialize the scripted default before invocation"), InitialScore, 41))
	{
		return false;
	}

	int32 Result = 0;
	if (!TestTrue(
		TEXT("Annotated execution test should execute the generated method on the game thread"),
		ExecuteGeneratedIntEventOnGameThread(&Engine, RuntimeObject, GeneratedFunction, Result)))
	{
		return false;
	}

	const int32 ScoreAfterCall = ScoreProperty->GetPropertyValue_InContainer(RuntimeObject);
	TestEqual(TEXT("Annotated execution test should return the updated scripted value"), Result, 42);
	TestEqual(TEXT("Annotated execution test should persist the scripted state mutation on the UObject instance"), ScoreAfterCall, 42);
	bPassed = Result == 42 && ScoreAfterCall == 42;

	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

bool FAngelscriptCompilerPlainSourcePreprocessorRoundTripTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	const FString ScriptSource = TEXT(R"AS(
int Entry()
{
	return 42;
}
)AS");

	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*CompilerPipelinePlainSourceRoundTripTest::ModuleName.ToString());
	};

	FAngelscriptCompileTraceSummary Summary;
	const bool bCompiled = CompileModuleWithSummary(
		&Engine,
		ECompileType::SoftReloadOnly,
		CompilerPipelinePlainSourceRoundTripTest::ModuleName,
		CompilerPipelinePlainSourceRoundTripTest::RelativeScriptPath,
		ScriptSource,
		true,
		Summary,
		true);

	bPassed &= TestTrue(
		TEXT("Plain source preprocessor round-trip should compile successfully"),
		bCompiled);
	bPassed &= TestTrue(
		TEXT("Plain source preprocessor round-trip should report preprocessor usage"),
		Summary.bUsedPreprocessor);
	bPassed &= TestTrue(
		TEXT("Plain source preprocessor round-trip should mark compile succeeded in the summary"),
		Summary.bCompileSucceeded);
	bPassed &= TestEqual(
		TEXT("Plain source preprocessor round-trip should report FullyHandled"),
		Summary.CompileResult,
		ECompileResult::FullyHandled);
	bPassed &= TestEqual(
		TEXT("Plain source preprocessor round-trip should produce exactly one module descriptor"),
		Summary.ModuleDescCount,
		1);
	bPassed &= TestEqual(
		TEXT("Plain source preprocessor round-trip should keep diagnostics empty"),
		Summary.Diagnostics.Num(),
		0);
	bPassed &= TestEqual(
		TEXT("Plain source preprocessor round-trip should record exactly one module name"),
		Summary.ModuleNames.Num(),
		1);
	if (Summary.ModuleNames.Num() > 0)
	{
		bPassed &= TestEqual(
			TEXT("Plain source preprocessor round-trip should normalize the module name from the relative script path"),
			Summary.ModuleNames[0],
			TEXT("Tests.Compiler.PlainSourceRoundTrip"));
	}

	int32 EntryResult = 0;
	const bool bExecuted = bCompiled
		&& ExecuteIntFunction(
			&Engine,
			CompilerPipelinePlainSourceRoundTripTest::RelativeScriptPath,
			CompilerPipelinePlainSourceRoundTripTest::ModuleName,
			TEXT("int Entry()"),
			EntryResult);
	bPassed &= TestTrue(
		TEXT("Plain source preprocessor round-trip should execute the compiled Entry function"),
		bExecuted);
	if (bExecuted)
	{
		bPassed &= TestEqual(
			TEXT("Plain source preprocessor round-trip should preserve the plain-source return value"),
			EntryResult,
			42);
	}

	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

#endif
