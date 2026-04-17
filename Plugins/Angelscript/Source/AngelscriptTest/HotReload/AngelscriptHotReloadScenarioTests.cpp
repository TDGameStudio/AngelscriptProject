#include "Shared/AngelscriptScenarioTestUtils.h"
#include "Shared/AngelscriptTestMacros.h"

#include "Components/ActorTestSpawner.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

// Test Layer: UE Scenario
#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace AngelscriptTest_HotReload_AngelscriptHotReloadScenarioTests_Private
{
	using namespace AngelscriptScenarioTestUtils;
void InitializeHotReloadScenarioSpawner(FActorTestSpawner& Spawner)
	{
		Spawner.InitializeGameSubsystems();
	}
}

using namespace AngelscriptTest_HotReload_AngelscriptHotReloadScenarioTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioHotReloadPropertyPreservedTest,
	"Angelscript.TestModule.HotReload.PropertyPreserved",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioHotReloadAddPropertyTest,
	"Angelscript.TestModule.HotReload.AddProperty",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioHotReloadFunctionChangeTest,
	"Angelscript.TestModule.HotReload.FunctionChange",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioHotReloadPIEStructuralChangeNeedsFullReloadTest,
	"Angelscript.TestModule.HotReload.PIEStructuralChangeNeedsFullReload",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptScenarioHotReloadPropertyPreservedTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH
	static const FName ModuleName(TEXT("ScenarioHotReloadPropertyPreserved"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	const FString ScriptV1 = TEXT(R"AS(
UCLASS()
class AScenarioHotReloadPropertyPreserved : AActor
{
	UPROPERTY()
	int Counter = 0;

	UFUNCTION()
	int GetValue()
	{
		return Counter;
	}
}
)AS");
	const FString ScriptV2 = TEXT(R"AS(
UCLASS()
class AScenarioHotReloadPropertyPreserved : AActor
{
	UPROPERTY()
	int Counter = 0;

	UFUNCTION()
	int GetValue()
	{
		return Counter + 100;
	}
}
)AS");

	UClass* ClassV1 = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioHotReloadPropertyPreserved.as"),
		ScriptV1,
		TEXT("AScenarioHotReloadPropertyPreserved"));
	if (ClassV1 == nullptr)
	{
		return false;
	}

	FActorTestSpawner Spawner;
	InitializeHotReloadScenarioSpawner(Spawner);
	AActor* Actor = SpawnScriptActor(*this, Spawner, ClassV1);
	if (Actor == nullptr)
	{
		return false;
	}
	BeginPlayActor(*Actor);

	FIntProperty* CounterProperty = FindFProperty<FIntProperty>(ClassV1, TEXT("Counter"));
	if (!TestNotNull(TEXT("Scenario hot-reload property should exist before reload"), CounterProperty))
	{
		return false;
	}
	CounterProperty->SetPropertyValue_InContainer(Actor, 42);

	ECompileResult ReloadResult = ECompileResult::Error;
	if (!TestTrue(TEXT("Scenario hot-reload property-preserved compile should succeed on the soft reload path"),
		CompileModuleWithResult(&Engine, ECompileType::SoftReloadOnly, ModuleName, TEXT("ScenarioHotReloadPropertyPreserved.as"), ScriptV2, ReloadResult)))
	{
		return false;
	}
	if (!TestTrue(TEXT("Scenario hot-reload property-preserved should stay on the soft reload path"), ReloadResult == ECompileResult::FullyHandled || ReloadResult == ECompileResult::PartiallyHandled))
	{
		return false;
	}

	UClass* ClassAfterReload = FindGeneratedClass(&Engine, TEXT("AScenarioHotReloadPropertyPreserved"));
	if (!TestNotNull(TEXT("Scenario hot-reload property-preserved class should exist after reload"), ClassAfterReload))
	{
		return false;
	}
	TestEqual(TEXT("Scenario hot-reload property-preserved should keep the generated actor class instance"), ClassAfterReload, ClassV1);

	int32 CounterValue = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("Counter"), CounterValue))
	{
		return false;
	}
	TestEqual(TEXT("Scenario hot-reload property-preserved should keep the actor property value after soft reload"), CounterValue, 42);

	UFunction* GetValueFunction = FindGeneratedFunction(ClassAfterReload, TEXT("GetValue"));
	if (!TestNotNull(TEXT("Scenario hot-reload property-preserved function should still exist after reload"), GetValueFunction))
	{
		return false;
	}

	int32 Result = 0;
	if (!TestTrue(TEXT("Scenario hot-reload property-preserved function should execute after reload"), ExecuteGeneratedIntEventOnGameThread(Actor, GetValueFunction, Result)))
	{
		return false;
	}
	TestEqual(TEXT("Scenario hot-reload property-preserved function should observe the preserved property value after reload"), Result, 142);
	ASTEST_END_SHARE_FRESH

	return true;
}

bool FAngelscriptScenarioHotReloadAddPropertyTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH
	static const FName ModuleName(TEXT("ScenarioHotReloadAddProperty"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	const FString ScriptV1 = TEXT(R"AS(
UCLASS()
class AScenarioHotReloadAddProperty : AActor
{
	UPROPERTY()
	int ExistingValue = 1;
}
)AS");
	const FString ScriptV2 = TEXT(R"AS(
UCLASS()
class AScenarioHotReloadAddProperty : AActor
{
	UPROPERTY()
	int ExistingValue = 1;

	UPROPERTY()
	int NewValue = 99;
}
)AS");

	UClass* ClassV1 = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioHotReloadAddProperty.as"),
		ScriptV1,
		TEXT("AScenarioHotReloadAddProperty"));
	if (ClassV1 == nullptr)
	{
		return false;
	}

	ECompileResult ReloadResult = ECompileResult::Error;
	if (!TestTrue(TEXT("Scenario hot-reload add-property compile should succeed on the full reload path"),
		CompileModuleWithResult(&Engine, ECompileType::FullReload, ModuleName, TEXT("ScenarioHotReloadAddProperty.as"), ScriptV2, ReloadResult)))
	{
		return false;
	}
	if (!TestTrue(TEXT("Scenario hot-reload add-property should be handled by a full reload"), ReloadResult == ECompileResult::FullyHandled || ReloadResult == ECompileResult::PartiallyHandled))
	{
		return false;
	}

	UClass* ClassV2 = FindGeneratedClass(&Engine, TEXT("AScenarioHotReloadAddProperty"));
	if (!TestNotNull(TEXT("Scenario hot-reload add-property class should exist after reload"), ClassV2))
	{
		return false;
	}

	FActorTestSpawner Spawner;
	InitializeHotReloadScenarioSpawner(Spawner);
	AActor* Actor = SpawnScriptActor(*this, Spawner, ClassV2);
	if (Actor == nullptr)
	{
		return false;
	}
	BeginPlayActor(*Actor);

	int32 ExistingValue = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("ExistingValue"), ExistingValue))
	{
		return false;
	}
	int32 NewValue = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("NewValue"), NewValue))
	{
		return false;
	}

	TestEqual(TEXT("Scenario hot-reload add-property should preserve the original property default"), ExistingValue, 1);
	TestEqual(TEXT("Scenario hot-reload add-property should expose the newly added property with its default value"), NewValue, 99);
	ASTEST_END_SHARE_FRESH

	return true;
}

bool FAngelscriptScenarioHotReloadFunctionChangeTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH
	static const FName ModuleName(TEXT("ScenarioHotReloadFunctionChange"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	const FString ScriptV1 = TEXT(R"AS(
UCLASS()
class AScenarioHotReloadFunctionChange : AActor
{
	UFUNCTION()
	int GetValue()
	{
		return 1;
	}
}
)AS");
	const FString ScriptV2 = TEXT(R"AS(
UCLASS()
class AScenarioHotReloadFunctionChange : AActor
{
	UFUNCTION()
	int GetValue()
	{
		return 2;
	}
}
)AS");

	UClass* ClassV1 = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioHotReloadFunctionChange.as"),
		ScriptV1,
		TEXT("AScenarioHotReloadFunctionChange"));
	if (ClassV1 == nullptr)
	{
		return false;
	}

	FActorTestSpawner Spawner;
	InitializeHotReloadScenarioSpawner(Spawner);
	AActor* Actor = SpawnScriptActor(*this, Spawner, ClassV1);
	if (Actor == nullptr)
	{
		return false;
	}
	BeginPlayActor(*Actor);

	UFunction* GetValueBeforeReload = FindGeneratedFunction(ClassV1, TEXT("GetValue"));
	if (!TestNotNull(TEXT("Scenario hot-reload function-change function should exist before reload"), GetValueBeforeReload))
	{
		return false;
	}

	int32 BeforeReloadResult = 0;
	if (!TestTrue(TEXT("Scenario hot-reload function-change function should execute before reload"), ExecuteGeneratedIntEventOnGameThread(Actor, GetValueBeforeReload, BeforeReloadResult)))
	{
		return false;
	}
	TestEqual(TEXT("Scenario hot-reload function-change should return the original value before reload"), BeforeReloadResult, 1);

	ECompileResult ReloadResult = ECompileResult::Error;
	if (!TestTrue(TEXT("Scenario hot-reload function-change compile should succeed on the soft reload path"),
		CompileModuleWithResult(&Engine, ECompileType::SoftReloadOnly, ModuleName, TEXT("ScenarioHotReloadFunctionChange.as"), ScriptV2, ReloadResult)))
	{
		return false;
	}
	if (!TestTrue(TEXT("Scenario hot-reload function-change should stay on the soft reload path"), ReloadResult == ECompileResult::FullyHandled || ReloadResult == ECompileResult::PartiallyHandled))
	{
		return false;
	}

	UClass* ClassAfterReload = FindGeneratedClass(&Engine, TEXT("AScenarioHotReloadFunctionChange"));
	if (!TestNotNull(TEXT("Scenario hot-reload function-change class should exist after reload"), ClassAfterReload))
	{
		return false;
	}

	UFunction* GetValueAfterReload = FindGeneratedFunction(ClassAfterReload, TEXT("GetValue"));
	if (!TestNotNull(TEXT("Scenario hot-reload function-change function should exist after reload"), GetValueAfterReload))
	{
		return false;
	}

	int32 AfterReloadResult = 0;
	if (!TestTrue(TEXT("Scenario hot-reload function-change function should execute after reload"), ExecuteGeneratedIntEventOnGameThread(Actor, GetValueAfterReload, AfterReloadResult)))
	{
		return false;
	}
	TestEqual(TEXT("Scenario hot-reload function-change should expose the updated function body on the same actor instance"), AfterReloadResult, 2);
	ASTEST_END_SHARE_FRESH

	return true;
}

bool FAngelscriptScenarioHotReloadPIEStructuralChangeNeedsFullReloadTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH
	static const FName ModuleName(TEXT("ScenarioHotReloadPIEStructuralChange"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	const FString ScriptV1 = TEXT(R"AS(
UCLASS()
class AScenarioHotReloadPIEStructuralChange : AActor
{
	UPROPERTY()
	int Value = 1;
}
)AS");
	const FString ScriptV2 = TEXT(R"AS(
UCLASS()
class AScenarioHotReloadPIEStructuralChange : AActor
{
	UPROPERTY()
	int Value = 1;

	UPROPERTY()
	int AddedValue = 2;
}
)AS");

	UClass* BaselineClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioHotReloadPIEStructuralChange.as"),
		ScriptV1,
		TEXT("AScenarioHotReloadPIEStructuralChange"));
	if (BaselineClass == nullptr)
	{
		return false;
	}

	FAngelscriptClassGenerator::EReloadRequirement ReloadRequirement = FAngelscriptClassGenerator::Error;
	bool bWantsFullReload = false;
	bool bNeedsFullReload = false;
	const bool bAnalyzed = AnalyzeReloadFromMemory(
		&Engine,
		ModuleName,
		TEXT("ScenarioHotReloadPIEStructuralChange.as"),
		ScriptV2,
		ReloadRequirement,
		bWantsFullReload,
		bNeedsFullReload);
	if (!TestTrue(TEXT("PIE structural hot-reload analysis should complete"), bAnalyzed))
	{
		return false;
	}

	TestTrue(TEXT("Structural actor change should request a full reload path"), bWantsFullReload || bNeedsFullReload);
	return TestTrue(
		TEXT("Structural actor change should not stay on the soft reload path"),
		ReloadRequirement == FAngelscriptClassGenerator::FullReloadRequired
		|| ReloadRequirement == FAngelscriptClassGenerator::FullReloadSuggested);

	ASTEST_END_SHARE_FRESH
}

#endif
