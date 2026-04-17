#include "Shared/AngelscriptScenarioTestUtils.h"
#include "Shared/AngelscriptTestMacros.h"

#include "ClassGenerator/ASClass.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"
#include "UObject/UnrealType.h"

// Test Layer: Runtime Integration
#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptScenarioTestUtils;

namespace AngelscriptTest_ClassGenerator_AngelscriptASFunctionWorldContextTests_Private
{
	static const FName WorldContextModuleName(TEXT("ASFunctionWorldContext"));
	static const FString WorldContextFilename(TEXT("ASFunctionWorldContext.as"));
	static const FName WorldContextStaticsClassName(TEXT("UModule_ASFunctionWorldContextStatics"));

	struct FCheckWorldContextParams
	{
		AActor* WorldContextObject = nullptr;
		int32 Value = 0;
		int32 ReturnValue = 0;
	};
}

using namespace AngelscriptTest_ClassGenerator_AngelscriptASFunctionWorldContextTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptASFunctionStaticWorldContextRuntimeCallUsesValidParmOffsetTest,
	"Angelscript.TestModule.ClassGenerator.ASFunction.StaticWorldContextRuntimeCallUsesValidParmOffset",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptASFunctionStaticWorldContextRuntimeCallUsesValidParmOffsetTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*WorldContextModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor& ContextActor = Spawner.SpawnActor<AActor>();
	AActor& PreviousContextActor = Spawner.SpawnActor<AActor>();
	UObject* PreviousContext = &PreviousContextActor;
	if (!TestNotNull(TEXT("World-context function test should create a scenario actor"), &ContextActor)
		|| !TestNotNull(TEXT("World-context function test should create a previous ambient context"), PreviousContext))
	{
		return false;
	}

	const FString ScriptSource = TEXT(R"AS(
UFUNCTION(BlueprintCallable, meta = (WorldContext = "WorldContextObject"))
int CheckWorldContext(AActor WorldContextObject, int Value)
{
	if (__WorldContext() != WorldContextObject)
		return -10;

	UWorld CurrentWorld = GetCurrentWorld();
	if (CurrentWorld == null)
		return -20;
	if (CurrentWorld != WorldContextObject.GetWorld())
		return -30;

	return Value;
}
)AS");

	const bool bCompiled = CompileAnnotatedModuleFromMemory(
		&Engine,
		WorldContextModuleName,
		WorldContextFilename,
		ScriptSource);
	if (!TestTrue(TEXT("World-context function test should compile the annotated static callable module"), bCompiled))
	{
		return false;
	}

	UClass* ScriptClass = FindGeneratedClass(&Engine, WorldContextStaticsClassName);
	if (!TestNotNull(TEXT("World-context function test should generate the module statics class"), ScriptClass))
	{
		return false;
	}

	UFunction* GeneratedFunction = FindGeneratedFunction(ScriptClass, TEXT("CheckWorldContext"));
	UASFunction* ScriptFunction = Cast<UASFunction>(GeneratedFunction);
	FObjectProperty* WorldContextProperty = FindFProperty<FObjectProperty>(GeneratedFunction, TEXT("WorldContextObject"));
	if (!TestNotNull(TEXT("World-context function test should expose the generated static function"), GeneratedFunction)
		|| !TestNotNull(TEXT("World-context function test should generate a UASFunction"), ScriptFunction)
		|| !TestNotNull(TEXT("World-context function test should expose the WorldContextObject property"), WorldContextProperty))
	{
		return false;
	}

	TestTrue(TEXT("World-context function test should compile the callable as a static UFunction"), GeneratedFunction->HasAnyFunctionFlags(FUNC_Static));
	TestFalse(TEXT("Explicit WorldContext metadata should not generate an extra synthetic parameter"), ScriptFunction->bIsWorldContextGenerated);
	TestEqual(TEXT("WorldContext parameter should stay at argument index 0"), ScriptFunction->WorldContextIndex, 0);
	if (!TestTrue(TEXT("WorldContext parameter should record a valid parameter offset"), ScriptFunction->WorldContextOffsetInParms >= 0))
	{
		return false;
	}
	if (!TestEqual(TEXT("WorldContext parameter offset should match the reflected property layout"), ScriptFunction->WorldContextOffsetInParms, WorldContextProperty->GetOffset_ForUFunction()))
	{
		return false;
	}

	FCheckWorldContextParams Params;
	Params.WorldContextObject = &ContextActor;
	Params.Value = 7;

	UObject* AmbientBeforeScope = FAngelscriptEngine::GetAmbientWorldContext();
	{
		FScopedTestWorldContextScope PreviousContextScope(PreviousContext);
		if (!TestTrue(TEXT("Outer test scope should install the previous ambient context"), FAngelscriptEngine::GetAmbientWorldContext() == PreviousContext))
		{
			return false;
		}

		ScriptFunction->RuntimeCallEvent(ScriptClass->GetDefaultObject(), &Params);

		TestEqual(TEXT("RuntimeCallEvent should route the explicit WorldContextObject through ambient world-context lookup"), Params.ReturnValue, 7);
		TestTrue(TEXT("RuntimeCallEvent should restore the previous ambient context before leaving the outer scope"), FAngelscriptEngine::GetAmbientWorldContext() == PreviousContext);
	}

	TestTrue(TEXT("World-context runtime call should restore the ambient context after the scoped override exits"), FAngelscriptEngine::GetAmbientWorldContext() == AmbientBeforeScope);
	ASTEST_END_SHARE_FRESH

	return true;
}

#endif
