#include "../Shared/AngelscriptTestEngineHelper.h"
#include "../Shared/AngelscriptTestMacros.h"

#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"
#include "UObject/Class.h"
#include "UObject/UObjectGlobals.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace CompilerPipelineClassLikeExecutionTest
{
	static const FName ModuleName(TEXT("Tests.Compiler.ClassLikeMethodExecutionRoundTrip"));
	static const FString ScriptFilename(TEXT("Tests/Compiler/ClassLikeMethodExecutionRoundTrip.as"));
	static const FName GeneratedClassName(TEXT("UCompilerClassLikeExecutionCarrier"));
	static const FName VerifyFunctionName(TEXT("VerifyRoundTrip"));
}

using namespace CompilerPipelineClassLikeExecutionTest;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptCompilerClassLikeMethodExecutionRoundTripTest,
	"Angelscript.TestModule.Compiler.EndToEnd.ClassLikeMethodExecutionRoundTrip",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptCompilerClassLikeMethodExecutionRoundTripTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	const FString ScriptSource = TEXT(R"AS(
UCLASS()
class UCompilerClassLikeExecutionCarrier : UObject
{
	UFUNCTION()
	UClass EchoPlainClass(UClass Value)
	{
		return Value;
	}

	UFUNCTION()
	TSubclassOf<AActor> EchoActorClass(TSubclassOf<AActor> Value)
	{
		return Value;
	}

	UFUNCTION()
	TSoftClassPtr<AActor> EchoSoftActorClass(TSoftClassPtr<AActor> Value)
	{
		return Value;
	}

	UFUNCTION()
	int VerifyRoundTrip()
	{
		if (!(EchoPlainClass(AActor::StaticClass()) == AActor::StaticClass()))
			return 10;

		if (!(EchoActorClass(ACameraActor::StaticClass()) == ACameraActor::StaticClass()))
			return 20;

		TSoftClassPtr<AActor> SoftActorClass = TSoftClassPtr<AActor>(AActor::StaticClass());
		if (!(EchoSoftActorClass(SoftActorClass).Get() == AActor::StaticClass()))
			return 30;

		return 1;
	}
}
)AS");

	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*CompilerPipelineClassLikeExecutionTest::ModuleName.ToString());
	};

	FAngelscriptCompileTraceSummary Summary;
	const bool bCompiled = CompileModuleWithSummary(
		&Engine,
		ECompileType::FullReload,
		CompilerPipelineClassLikeExecutionTest::ModuleName,
		CompilerPipelineClassLikeExecutionTest::ScriptFilename,
		ScriptSource,
		true,
		Summary);

	bPassed &= TestTrue(
		TEXT("Class-like method execution round-trip should compile successfully"),
		bCompiled);
	bPassed &= TestTrue(
		TEXT("Class-like method execution round-trip should run through the preprocessor path"),
		Summary.bUsedPreprocessor);
	bPassed &= TestTrue(
		TEXT("Class-like method execution round-trip should mark compile succeeded in the summary"),
		Summary.bCompileSucceeded);
	bPassed &= TestEqual(
		TEXT("Class-like method execution round-trip should not emit diagnostics"),
		Summary.Diagnostics.Num(),
		0);
	if (!bCompiled)
	{
		return false;
	}

	UClass* GeneratedClass = FindGeneratedClass(&Engine, CompilerPipelineClassLikeExecutionTest::GeneratedClassName);
	if (!TestNotNull(TEXT("Class-like method execution round-trip should generate the annotated carrier class"), GeneratedClass))
	{
		return false;
	}

	UFunction* EchoPlainClass = FindGeneratedFunction(GeneratedClass, TEXT("EchoPlainClass"));
	UFunction* EchoActorClass = FindGeneratedFunction(GeneratedClass, TEXT("EchoActorClass"));
	UFunction* EchoSoftActorClass = FindGeneratedFunction(GeneratedClass, TEXT("EchoSoftActorClass"));
	UFunction* VerifyRoundTrip = FindGeneratedFunction(GeneratedClass, CompilerPipelineClassLikeExecutionTest::VerifyFunctionName);
	if (!TestNotNull(TEXT("Class-like method execution round-trip should expose EchoPlainClass"), EchoPlainClass)
		|| !TestNotNull(TEXT("Class-like method execution round-trip should expose EchoActorClass"), EchoActorClass)
		|| !TestNotNull(TEXT("Class-like method execution round-trip should expose EchoSoftActorClass"), EchoSoftActorClass)
		|| !TestNotNull(TEXT("Class-like method execution round-trip should expose VerifyRoundTrip"), VerifyRoundTrip))
	{
		return false;
	}

	UObject* RuntimeObject = NewObject<UObject>(GetTransientPackage(), GeneratedClass, TEXT("CompilerClassLikeExecutionCarrier"));
	if (!TestNotNull(TEXT("Class-like method execution round-trip should instantiate the generated class"), RuntimeObject))
	{
		return false;
	}

	int32 Result = 0;
	const bool bExecuted = ExecuteGeneratedIntEventOnGameThread(&Engine, RuntimeObject, VerifyRoundTrip, Result);
	bPassed &= TestTrue(
		TEXT("Class-like method execution round-trip should execute the generated verification method"),
		bExecuted);
	if (bExecuted)
	{
		bPassed &= TestEqual(
			TEXT("Class-like method execution round-trip should preserve plain class, subclass and soft-class marshalling"),
			Result,
			1);
	}

	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

#endif
