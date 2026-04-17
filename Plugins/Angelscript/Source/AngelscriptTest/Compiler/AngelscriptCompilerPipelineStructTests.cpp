#include "../Shared/AngelscriptTestEngineHelper.h"
#include "../Shared/AngelscriptTestMacros.h"

#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"
#include "UObject/UObjectGlobals.h"
#include "UObject/UnrealType.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace CompilerPipelineStructTest
{
	static const FName ModuleName(TEXT("CompilerAnnotatedStructRoundTrip"));
	static const FString ScriptFilename(TEXT("CompilerAnnotatedStructRoundTrip.as"));
	static const FName GeneratedStructName(TEXT("AnnotatedCarrier"));
	static const FName ValuePropertyName(TEXT("Value"));
}

using namespace CompilerPipelineStructTest;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptCompilerAnnotatedStructRoundTripTest,
	"Angelscript.TestModule.Compiler.EndToEnd.AnnotatedStructRoundTrip",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptCompilerAnnotatedStructRoundTripTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	const FString ScriptSource = TEXT(R"AS(
USTRUCT()
struct FAnnotatedCarrier
{
	UPROPERTY()
	int Value = 7;
}

int Entry()
{
	FAnnotatedCarrier Carrier;
	return Carrier.Value;
}
)AS");

	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*CompilerPipelineStructTest::ModuleName.ToString());
	};

	FAngelscriptCompileTraceSummary Summary;
	const bool bCompiled = CompileModuleWithSummary(
		&Engine,
		ECompileType::FullReload,
		CompilerPipelineStructTest::ModuleName,
		CompilerPipelineStructTest::ScriptFilename,
		ScriptSource,
		true,
		Summary);

	bPassed &= TestTrue(
		TEXT("Annotated struct round-trip test should compile through the preprocessor-enabled full-reload pipeline"),
		bCompiled);
	bPassed &= TestTrue(
		TEXT("Annotated struct round-trip test should report preprocessor usage in the compile summary"),
		Summary.bUsedPreprocessor);
	bPassed &= TestEqual(
		TEXT("Annotated struct round-trip test should finish with a fully handled compile result"),
		Summary.CompileResult,
		ECompileResult::FullyHandled);
	bPassed &= TestEqual(
		TEXT("Annotated struct round-trip test should compile without diagnostics"),
		Summary.Diagnostics.Num(),
		0);
	if (!bCompiled)
	{
		return false;
	}

	int32 EntryResult = 0;
	const bool bExecuted = ExecuteIntFunction(
		&Engine,
		CompilerPipelineStructTest::ScriptFilename,
		CompilerPipelineStructTest::ModuleName,
		TEXT("int Entry()"),
		EntryResult);
	bPassed &= TestTrue(
		TEXT("Annotated struct round-trip test should execute the compiled Entry function"),
		bExecuted);
	if (bExecuted)
	{
		bPassed &= TestEqual(
			TEXT("Annotated struct round-trip test should read the annotated struct field through runtime execution"),
			EntryResult,
			7);
	}

	UScriptStruct* GeneratedStruct = FindObject<UScriptStruct>(FAngelscriptEngine::GetPackage(), *CompilerPipelineStructTest::GeneratedStructName.ToString());
	if (!TestNotNull(TEXT("Annotated struct round-trip test should materialize a backing UScriptStruct"), GeneratedStruct))
	{
		return false;
	}

	FIntProperty* ValueProperty = FindFProperty<FIntProperty>(GeneratedStruct, CompilerPipelineStructTest::ValuePropertyName);
	bPassed &= TestNotNull(
		TEXT("Annotated struct round-trip test should preserve the reflected Value property on the generated UScriptStruct"),
		ValueProperty);

	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

#endif
