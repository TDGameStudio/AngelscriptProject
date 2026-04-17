#include "../Shared/AngelscriptTestEngineHelper.h"
#include "../Shared/AngelscriptTestMacros.h"

#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"
#include "UObject/Class.h"
#include "UObject/UObjectGlobals.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace CompilerPipelineInterfaceRoundTripTest
{
	static const FName ModuleName(TEXT("Tests.Compiler.InterfaceAnnotatedRoundTrip"));
	static const FString ScriptFilename(TEXT("Tests/Compiler/InterfaceAnnotatedRoundTrip.as"));
	static const FName InterfaceClassName(TEXT("UICompilerProbe"));
	static const FName GeneratedClassName(TEXT("UCompilerProbeCarrier"));
	static const FName ComputeValueFunctionName(TEXT("ComputeValue"));
}

using namespace CompilerPipelineInterfaceRoundTripTest;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptCompilerInterfaceAnnotatedRoundTripTest,
	"Angelscript.TestModule.Compiler.EndToEnd.InterfaceAnnotatedRoundTrip",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptCompilerInterfaceAnnotatedRoundTripTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	const FString ScriptSource = TEXT(R"AS(
UINTERFACE()
interface UICompilerProbe
{
	int ComputeValue();
}

UCLASS()
class UCompilerProbeCarrier : UObject, UICompilerProbe
{
	UFUNCTION()
	int ComputeValue()
	{
		return 7;
	}
}
)AS");

	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*CompilerPipelineInterfaceRoundTripTest::ModuleName.ToString());
	};

	FAngelscriptCompileTraceSummary Summary;
	const bool bCompiled = CompileModuleWithSummary(
		&Engine,
		ECompileType::FullReload,
		CompilerPipelineInterfaceRoundTripTest::ModuleName,
		CompilerPipelineInterfaceRoundTripTest::ScriptFilename,
		ScriptSource,
		true,
		Summary,
		false);

	bPassed &= TestTrue(
		TEXT("Interface annotated round-trip should compile successfully"),
		bCompiled);
	bPassed &= TestTrue(
		TEXT("Interface annotated round-trip should run through the preprocessor path"),
		Summary.bUsedPreprocessor);
	bPassed &= TestTrue(
		TEXT("Interface annotated round-trip should mark compile succeeded in the summary"),
		Summary.bCompileSucceeded);
	bPassed &= TestEqual(
		TEXT("Interface annotated round-trip should report FullyHandled"),
		Summary.CompileResult,
		ECompileResult::FullyHandled);
	bPassed &= TestEqual(
		TEXT("Interface annotated round-trip should keep diagnostics empty"),
		Summary.Diagnostics.Num(),
		0);
	if (!bCompiled)
	{
		return false;
	}

	UClass* InterfaceClass = FindGeneratedClass(&Engine, CompilerPipelineInterfaceRoundTripTest::InterfaceClassName);
	UClass* CarrierClass = FindGeneratedClass(&Engine, CompilerPipelineInterfaceRoundTripTest::GeneratedClassName);
	if (!TestNotNull(TEXT("Interface annotated round-trip should generate the interface UClass"), InterfaceClass)
		|| !TestNotNull(TEXT("Interface annotated round-trip should generate the implementing carrier class"), CarrierClass))
	{
		return false;
	}

	bPassed &= TestTrue(
		TEXT("Interface annotated round-trip should mark the generated interface with CLASS_Interface"),
		InterfaceClass->HasAnyClassFlags(CLASS_Interface));
	bPassed &= TestTrue(
		TEXT("Interface annotated round-trip should let the carrier class report the generated interface"),
		CarrierClass->ImplementsInterface(InterfaceClass));

	UFunction* InterfaceFunction = FindGeneratedFunction(InterfaceClass, CompilerPipelineInterfaceRoundTripTest::ComputeValueFunctionName);
	UFunction* CarrierFunction = FindGeneratedFunction(CarrierClass, CompilerPipelineInterfaceRoundTripTest::ComputeValueFunctionName);
	if (!TestNotNull(TEXT("Interface annotated round-trip should expose ComputeValue on the generated interface"), InterfaceFunction)
		|| !TestNotNull(TEXT("Interface annotated round-trip should expose ComputeValue on the implementing carrier"), CarrierFunction))
	{
		return false;
	}

	bPassed &= TestTrue(
		TEXT("Interface annotated round-trip should keep the interface declaration owned by the generated interface class"),
		InterfaceFunction->GetOuter() == InterfaceClass);

	UObject* RuntimeObject = CarrierClass->GetDefaultObject();
	if (!TestNotNull(TEXT("Interface annotated round-trip should materialize the carrier default object"), RuntimeObject))
	{
		return false;
	}

	int32 Result = 0;
	const bool bExecuted = ExecuteGeneratedIntEventOnGameThread(&Engine, RuntimeObject, CarrierFunction, Result);
	bPassed &= TestTrue(
		TEXT("Interface annotated round-trip should execute the generated implementation function"),
		bExecuted);
	if (bExecuted)
	{
		bPassed &= TestEqual(
			TEXT("Interface annotated round-trip should preserve the scripted ComputeValue result"),
			Result,
			7);
	}

	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

#endif
