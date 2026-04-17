#include "Shared/AngelscriptScenarioTestUtils.h"
#include "Shared/AngelscriptTestMacros.h"

#include "Components/ActorTestSpawner.h"
#include "Engine/Blueprint.h"
#include "Kismet2/KismetEditorUtilities.h"
#include "Misc/AutomationTest.h"
#include "Misc/Guid.h"
#include "Misc/PackageName.h"
#include "Misc/ScopeExit.h"
#include "UObject/GarbageCollection.h"
#include "UObject/Package.h"
#include "UObject/UnrealType.h"

// Test Layer: UE Scenario
#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptScenarioTestUtils;

namespace BlueprintSubclassRuntimeTest
{
	constexpr float ScenarioTickDeltaTime = 0.016f;
	constexpr int32 InheritedTickCount = 3;
	constexpr int32 OverrideChainTickCount = 4;

	struct FSingleIntParam
	{
		int32 Value = 0;
	};

	UBlueprint* CreateTransientBlueprintChild(
		FAutomationTestBase& Test,
		UClass* ParentClass,
		FStringView Suffix,
		const TCHAR* CallingContext = TEXT("AngelscriptBlueprintSubclassRuntimeTests"))
	{
		if (!Test.TestNotNull(TEXT("Blueprint child runtime scenario should receive a valid script parent class"), ParentClass))
		{
			return nullptr;
		}

		const FString PackagePath = FString::Printf(
			TEXT("/Temp/AngelscriptBlueprintChildRuntime_%.*s_%s"),
			Suffix.Len(),
			Suffix.GetData(),
			*FGuid::NewGuid().ToString(EGuidFormats::Digits));
		UPackage* BlueprintPackage = CreatePackage(*PackagePath);
		if (!Test.TestNotNull(TEXT("Blueprint child runtime scenario should create a transient package"), BlueprintPackage))
		{
			return nullptr;
		}

		BlueprintPackage->SetFlags(RF_Transient);
		const FName BlueprintName(*FPackageName::GetLongPackageAssetName(PackagePath));

		UBlueprint* Blueprint = FKismetEditorUtilities::CreateBlueprint(
			ParentClass,
			BlueprintPackage,
			BlueprintName,
			BPTYPE_Normal,
			UBlueprint::StaticClass(),
			UBlueprintGeneratedClass::StaticClass(),
			CallingContext);
		if (!Test.TestNotNull(TEXT("Blueprint child runtime scenario should create a transient blueprint asset"), Blueprint))
		{
			return nullptr;
		}

		return Blueprint;
	}

	bool CompileAndValidateBlueprint(FAutomationTestBase& Test, UBlueprint& Blueprint)
	{
		FKismetEditorUtilities::CompileBlueprint(&Blueprint);
		return Test.TestNotNull(TEXT("Blueprint child runtime scenario should compile to a generated class"), Blueprint.GeneratedClass.Get());
	}

	void CleanupBlueprint(UBlueprint*& Blueprint)
	{
		if (Blueprint == nullptr)
		{
			return;
		}

		if (UClass* BlueprintClass = Blueprint->GeneratedClass)
		{
			BlueprintClass->MarkAsGarbage();
		}

		if (UPackage* BlueprintPackage = Blueprint->GetOutermost())
		{
			BlueprintPackage->MarkAsGarbage();
		}

		Blueprint->MarkAsGarbage();
		CollectGarbage(RF_NoFlags, true);
		Blueprint = nullptr;
	}

	struct FScopedTransientBlueprint
	{
		UBlueprint* Blueprint = nullptr;

		~FScopedTransientBlueprint()
		{
			CleanupBlueprint(Blueprint);
		}

		bool CreateAndCompile(
			FAutomationTestBase& Test,
			UClass* ParentClass,
			FStringView Suffix,
			const TCHAR* CallingContext = TEXT("AngelscriptBlueprintSubclassRuntimeTests"))
		{
			Blueprint = CreateTransientBlueprintChild(Test, ParentClass, Suffix, CallingContext);
			return Blueprint != nullptr && CompileAndValidateBlueprint(Test, *Blueprint);
		}

		UClass* GetGeneratedClass() const
		{
			return Blueprint != nullptr ? Blueprint->GeneratedClass.Get() : nullptr;
		}
	};

	bool InvokeNoParamScriptFunction(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		UObject* Object,
		FName FunctionName,
		const TCHAR* Context)
	{
		if (!Test.TestNotNull(*FString::Printf(TEXT("%s should have a valid object instance"), Context), Object))
		{
			return false;
		}

		UFunction* Function = Object->FindFunction(FunctionName);
		if (!Test.TestNotNull(
			*FString::Printf(TEXT("%s should expose function '%s'"), Context, *FunctionName.ToString()),
			Function))
		{
			return false;
		}

		FAngelscriptEngineScope FunctionScope(Engine, Object);
		Object->ProcessEvent(Function, nullptr);
		return true;
	}

	bool InvokeIntScriptFunction(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		UObject* Object,
		FName FunctionName,
		int32 Value,
		const TCHAR* Context)
	{
		if (!Test.TestNotNull(*FString::Printf(TEXT("%s should have a valid object instance"), Context), Object))
		{
			return false;
		}

		UFunction* Function = Object->FindFunction(FunctionName);
		if (!Test.TestNotNull(
			*FString::Printf(TEXT("%s should expose function '%s'"), Context, *FunctionName.ToString()),
			Function))
		{
			return false;
		}

		FSingleIntParam Params;
		Params.Value = Value;

		FAngelscriptEngineScope FunctionScope(Engine, Object);
		Object->ProcessEvent(Function, &Params);
		return true;
	}
}

using namespace BlueprintSubclassRuntimeTest;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioBlueprintChildInheritsScriptBeginPlayTest,
	"Angelscript.TestModule.BlueprintChild.InheritsScriptBeginPlay",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioBlueprintChildInheritsScriptTickTest,
	"Angelscript.TestModule.BlueprintChild.InheritsScriptTick",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioBlueprintChildScriptUFunctionStillCallableTest,
	"Angelscript.TestModule.BlueprintChild.ScriptUFunctionStillCallable",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioBlueprintChildRecreateDoesNotLeakPreviousStateTest,
	"Angelscript.TestModule.BlueprintChild.RecreateDoesNotLeakPreviousState",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioBlueprintChildNoOverrideUsesScriptParentDefaultTest,
	"Angelscript.TestModule.BlueprintChild.NoOverrideUsesScriptParentDefault",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioBlueprintChildOverrideChainHasDeterministicCountsTest,
	"Angelscript.TestModule.BlueprintChild.OverrideChainHasDeterministicCounts",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptScenarioBlueprintChildInheritsScriptBeginPlayTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	static const FName ModuleName(TEXT("ScenarioBlueprintChildInheritsScriptBeginPlay"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptParentClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioBlueprintChildInheritsScriptBeginPlay.as"),
		TEXT(R"AS(
UCLASS()
class AScenarioBlueprintChildInheritsScriptBeginPlayParent : AActor
{
	UPROPERTY()
	int BeginPlayCount = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BeginPlayCount += 1;
	}
}
)AS"),
		TEXT("AScenarioBlueprintChildInheritsScriptBeginPlayParent"));
	if (ScriptParentClass == nullptr)
	{
		return false;
	}

	BlueprintSubclassRuntimeTest::FScopedTransientBlueprint Blueprint;
	if (!Blueprint.CreateAndCompile(*this, ScriptParentClass, TEXT("InheritsScriptBeginPlay")))
	{
		return false;
	}

	UClass* BlueprintClass = Blueprint.GetGeneratedClass();
	if (!TestNotNull(TEXT("Blueprint child BeginPlay scenario should expose a generated class"), BlueprintClass))
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* Actor = SpawnScriptActor(*this, Spawner, BlueprintClass);
	if (!TestNotNull(TEXT("Blueprint child BeginPlay scenario should spawn the blueprint subclass"), Actor))
	{
		return false;
	}

	BeginPlayActor(Engine, *Actor);

	int32 BeginPlayCount = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("BeginPlayCount"), BeginPlayCount))
	{
		return false;
	}

	TestEqual(TEXT("Blueprint child should inherit and execute the script BeginPlay override"), BeginPlayCount, 1);
	ASTEST_END_SHARE_CLEAN

	return true;
}

bool FAngelscriptScenarioBlueprintChildInheritsScriptTickTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	static const FName ModuleName(TEXT("ScenarioBlueprintChildInheritsScriptTick"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptParentClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioBlueprintChildInheritsScriptTick.as"),
		TEXT(R"AS(
UCLASS()
class AScenarioBlueprintChildInheritsScriptTickParent : AActor
{
	UPROPERTY()
	int LogicalTickCount = 0;

	UPROPERTY()
	float LastTickWorldTime = -1.0f;

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaTime)
	{
		float CurrentTime = -1.0f;
		if (GetWorld() != null)
		{
			CurrentTime = GetWorld().TimeSeconds;
		}

		if (CurrentTime > LastTickWorldTime)
		{
			LogicalTickCount += 1;
			LastTickWorldTime = CurrentTime;
		}
	}
}
)AS"),
		TEXT("AScenarioBlueprintChildInheritsScriptTickParent"));
	if (ScriptParentClass == nullptr)
	{
		return false;
	}

	BlueprintSubclassRuntimeTest::FScopedTransientBlueprint Blueprint;
	if (!Blueprint.CreateAndCompile(*this, ScriptParentClass, TEXT("InheritsScriptTick")))
	{
		return false;
	}

	UClass* BlueprintClass = Blueprint.GetGeneratedClass();
	if (!TestNotNull(TEXT("Blueprint child Tick scenario should expose a generated class"), BlueprintClass))
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* Actor = SpawnScriptActor(*this, Spawner, BlueprintClass);
	if (!TestNotNull(TEXT("Blueprint child Tick scenario should spawn the blueprint subclass"), Actor))
	{
		return false;
	}

	BeginPlayActor(Engine, *Actor);

	int32 InitialLogicalTickCount = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("LogicalTickCount"), InitialLogicalTickCount))
	{
		return false;
	}

	TickWorld(Engine, Spawner.GetWorld(), BlueprintSubclassRuntimeTest::ScenarioTickDeltaTime, BlueprintSubclassRuntimeTest::InheritedTickCount);

	int32 LogicalTickCount = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("LogicalTickCount"), LogicalTickCount))
	{
		return false;
	}

	TestEqual(
		TEXT("Blueprint child should inherit and execute the script Tick override for each manual world tick"),
		LogicalTickCount - InitialLogicalTickCount,
		BlueprintSubclassRuntimeTest::InheritedTickCount);
	ASTEST_END_SHARE_CLEAN

	return true;
}

bool FAngelscriptScenarioBlueprintChildScriptUFunctionStillCallableTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	static const FName ModuleName(TEXT("ScenarioBlueprintChildScriptUFunctionStillCallable"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptParentClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioBlueprintChildScriptUFunctionStillCallable.as"),
		TEXT(R"AS(
UCLASS()
class AScenarioBlueprintChildScriptUFunctionStillCallableParent : AActor
{
	UPROPERTY()
	int ScriptCallCount = 0;

	UPROPERTY()
	int LastCallValue = 0;

	UFUNCTION()
	void RecordExternalCall(int Value)
	{
		ScriptCallCount += 1;
		LastCallValue = Value;
	}
}
)AS"),
		TEXT("AScenarioBlueprintChildScriptUFunctionStillCallableParent"));
	if (ScriptParentClass == nullptr)
	{
		return false;
	}

	BlueprintSubclassRuntimeTest::FScopedTransientBlueprint Blueprint;
	if (!Blueprint.CreateAndCompile(*this, ScriptParentClass, TEXT("ScriptUFunctionStillCallable")))
	{
		return false;
	}

	UClass* BlueprintClass = Blueprint.GetGeneratedClass();
	if (!TestNotNull(TEXT("Blueprint child script-UFUNCTION scenario should expose a generated class"), BlueprintClass))
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* Actor = SpawnScriptActor(*this, Spawner, BlueprintClass);
	if (!TestNotNull(TEXT("Blueprint child script-UFUNCTION scenario should spawn the blueprint subclass"), Actor))
	{
		return false;
	}

	if (!BlueprintSubclassRuntimeTest::InvokeIntScriptFunction(
			*this,
			Engine,
			Actor,
			TEXT("RecordExternalCall"),
			77,
			TEXT("Blueprint child script-UFUNCTION invocation")))
	{
		return false;
	}

	int32 ScriptCallCount = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("ScriptCallCount"), ScriptCallCount))
	{
		return false;
	}

	int32 LastCallValue = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("LastCallValue"), LastCallValue))
	{
		return false;
	}

	TestEqual(TEXT("Blueprint child should preserve script UFUNCTION dispatch through ProcessEvent"), ScriptCallCount, 1);
	TestEqual(TEXT("Blueprint child should preserve reflected integer parameters when invoking script UFUNCTIONs"), LastCallValue, 77);
	ASTEST_END_SHARE_CLEAN

	return true;
}

bool FAngelscriptScenarioBlueprintChildRecreateDoesNotLeakPreviousStateTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	static const FName ModuleName(TEXT("ScenarioBlueprintChildRecreateDoesNotLeakPreviousState"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptParentClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioBlueprintChildRecreateDoesNotLeakPreviousState.as"),
		TEXT(R"AS(
UCLASS()
class AScenarioBlueprintChildRecreateStateParent : AActor
{
	UPROPERTY()
	int StatefulValue = 10;

	UPROPERTY()
	int BeginPlayCount = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BeginPlayCount += 1;
		StatefulValue += 1;
	}

	UFUNCTION()
	void BumpState()
	{
		StatefulValue += 37;
	}
}
)AS"),
		TEXT("AScenarioBlueprintChildRecreateStateParent"));
	if (ScriptParentClass == nullptr)
	{
		return false;
	}

	BlueprintSubclassRuntimeTest::FScopedTransientBlueprint Blueprint;
	if (!Blueprint.CreateAndCompile(*this, ScriptParentClass, TEXT("RecreateDoesNotLeakPreviousState")))
	{
		return false;
	}

	UClass* BlueprintClass = Blueprint.GetGeneratedClass();
	if (!TestNotNull(TEXT("Blueprint child recreate scenario should expose a generated class"), BlueprintClass))
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* FirstActor = SpawnScriptActor(*this, Spawner, BlueprintClass);
	if (!TestNotNull(TEXT("Blueprint child recreate scenario should spawn the first actor"), FirstActor))
	{
		return false;
	}

	BeginPlayActor(Engine, *FirstActor);
	if (!BlueprintSubclassRuntimeTest::InvokeNoParamScriptFunction(
			*this,
			Engine,
			FirstActor,
			TEXT("BumpState"),
			TEXT("Blueprint child recreate scenario first actor mutation")))
	{
		return false;
	}

	int32 FirstStatefulValue = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, FirstActor, TEXT("StatefulValue"), FirstStatefulValue))
	{
		return false;
	}

	FirstActor->Destroy();
	TickWorld(Engine, Spawner.GetWorld(), 0.0f, 1);

	AActor* SecondActor = SpawnScriptActor(*this, Spawner, BlueprintClass);
	if (!TestNotNull(TEXT("Blueprint child recreate scenario should spawn the second actor"), SecondActor))
	{
		return false;
	}

	BeginPlayActor(Engine, *SecondActor);

	int32 SecondStatefulValue = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, SecondActor, TEXT("StatefulValue"), SecondStatefulValue))
	{
		return false;
	}

	int32 SecondBeginPlayCount = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, SecondActor, TEXT("BeginPlayCount"), SecondBeginPlayCount))
	{
		return false;
	}

	TestEqual(TEXT("Blueprint child recreate scenario should observe the first actor mutating its local script state"), FirstStatefulValue, 48);
	TestEqual(TEXT("Blueprint child recreate scenario should reset script state when respawning a new blueprint child"), SecondStatefulValue, 11);
	TestEqual(TEXT("Blueprint child recreate scenario should execute BeginPlay independently for each spawned instance"), SecondBeginPlayCount, 1);
	ASTEST_END_SHARE_CLEAN

	return true;
}

bool FAngelscriptScenarioBlueprintChildNoOverrideUsesScriptParentDefaultTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	static const FName ModuleName(TEXT("ScenarioBlueprintChildNoOverrideUsesScriptParentDefault"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptParentClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioBlueprintChildNoOverrideUsesScriptParentDefault.as"),
		TEXT(R"AS(
UCLASS()
class AScenarioBlueprintChildNoOverrideUsesScriptParentDefaultParent : AActor
{
	UPROPERTY()
	int DefaultCounter = 23;

	UPROPERTY()
	bool bDefaultToggle = true;

	UPROPERTY()
	FString DefaultLabel = "ScriptParentDefault";
}
)AS"),
		TEXT("AScenarioBlueprintChildNoOverrideUsesScriptParentDefaultParent"));
	if (ScriptParentClass == nullptr)
	{
		return false;
	}

	BlueprintSubclassRuntimeTest::FScopedTransientBlueprint Blueprint;
	if (!Blueprint.CreateAndCompile(*this, ScriptParentClass, TEXT("NoOverrideUsesScriptParentDefault")))
	{
		return false;
	}

	UClass* BlueprintClass = Blueprint.GetGeneratedClass();
	if (!TestNotNull(TEXT("Blueprint child default-preservation scenario should expose a generated class"), BlueprintClass))
	{
		return false;
	}

	UObject* BlueprintCDO = BlueprintClass->GetDefaultObject();
	if (!TestNotNull(TEXT("Blueprint child default-preservation scenario should expose a class default object"), BlueprintCDO))
	{
		return false;
	}

	int32 DefaultCounterOnCDO = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, BlueprintCDO, TEXT("DefaultCounter"), DefaultCounterOnCDO))
	{
		return false;
	}

	bool bDefaultToggleOnCDO = false;
	if (!ReadPropertyValue<FBoolProperty>(*this, BlueprintCDO, TEXT("bDefaultToggle"), bDefaultToggleOnCDO))
	{
		return false;
	}

	FString DefaultLabelOnCDO;
	if (!ReadPropertyValue<FStrProperty>(*this, BlueprintCDO, TEXT("DefaultLabel"), DefaultLabelOnCDO))
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* Actor = SpawnScriptActor(*this, Spawner, BlueprintClass);
	if (!TestNotNull(TEXT("Blueprint child default-preservation scenario should spawn the blueprint subclass"), Actor))
	{
		return false;
	}

	int32 DefaultCounterOnInstance = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("DefaultCounter"), DefaultCounterOnInstance))
	{
		return false;
	}

	bool bDefaultToggleOnInstance = false;
	if (!ReadPropertyValue<FBoolProperty>(*this, Actor, TEXT("bDefaultToggle"), bDefaultToggleOnInstance))
	{
		return false;
	}

	FString DefaultLabelOnInstance;
	if (!ReadPropertyValue<FStrProperty>(*this, Actor, TEXT("DefaultLabel"), DefaultLabelOnInstance))
	{
		return false;
	}

	TestEqual(TEXT("Blueprint child with no overrides should preserve parent integer defaults on the generated class CDO"), DefaultCounterOnCDO, 23);
	TestTrue(TEXT("Blueprint child with no overrides should preserve parent boolean defaults on the generated class CDO"), bDefaultToggleOnCDO);
	TestEqual(TEXT("Blueprint child with no overrides should preserve parent string defaults on the generated class CDO"), DefaultLabelOnCDO, FString(TEXT("ScriptParentDefault")));
	TestEqual(TEXT("Blueprint child with no overrides should preserve parent integer defaults on spawned instances"), DefaultCounterOnInstance, 23);
	TestTrue(TEXT("Blueprint child with no overrides should preserve parent boolean defaults on spawned instances"), bDefaultToggleOnInstance);
	TestEqual(TEXT("Blueprint child with no overrides should preserve parent string defaults on spawned instances"), DefaultLabelOnInstance, FString(TEXT("ScriptParentDefault")));
	ASTEST_END_SHARE_CLEAN

	return true;
}

bool FAngelscriptScenarioBlueprintChildOverrideChainHasDeterministicCountsTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	static const FName ModuleName(TEXT("ScenarioBlueprintChildOverrideChainHasDeterministicCounts"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptChildClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioBlueprintChildOverrideChainHasDeterministicCounts.as"),
		TEXT(R"AS(
UCLASS()
class AScenarioBlueprintChildOverrideChainParent : AActor
{
	UPROPERTY()
	int ParentBeginPlayCount = 0;

	UPROPERTY()
	int ParentTickCount = 0;

	UPROPERTY()
	float LastParentTickWorldTime = -1.0f;

	UFUNCTION()
	void ParentBeginPlayStep()
	{
		ParentBeginPlayCount += 1;
	}

	UFUNCTION()
	void ParentTickStep()
	{
		float CurrentTime = -1.0f;
		if (GetWorld() != null)
		{
			CurrentTime = GetWorld().TimeSeconds;
		}

		if (CurrentTime > LastParentTickWorldTime)
		{
			ParentTickCount += 1;
			LastParentTickWorldTime = CurrentTime;
		}
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		ParentBeginPlayStep();
	}

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaTime)
	{
		ParentTickStep();
	}
}

UCLASS()
class AScenarioBlueprintChildOverrideChainScriptChild : AScenarioBlueprintChildOverrideChainParent
{
	UPROPERTY()
	int ChildBeginPlayCount = 0;

	UPROPERTY()
	int ChildTickCount = 0;

	UPROPERTY()
	float LastChildTickWorldTime = -1.0f;

	UFUNCTION()
	void ChildBeginPlayStep()
	{
		ChildBeginPlayCount += 1;
	}

	UFUNCTION()
	void ChildTickStep()
	{
		float CurrentTime = -1.0f;
		if (GetWorld() != null)
		{
			CurrentTime = GetWorld().TimeSeconds;
		}

		if (CurrentTime > LastChildTickWorldTime)
		{
			ChildTickCount += 1;
			LastChildTickWorldTime = CurrentTime;
		}
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		ParentBeginPlayStep();
		ChildBeginPlayStep();
	}

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaTime)
	{
		ParentTickStep();
		ChildTickStep();
	}
}
)AS"),
		TEXT("AScenarioBlueprintChildOverrideChainScriptChild"));
	if (ScriptChildClass == nullptr)
	{
		return false;
	}

	BlueprintSubclassRuntimeTest::FScopedTransientBlueprint Blueprint;
	if (!Blueprint.CreateAndCompile(*this, ScriptChildClass, TEXT("OverrideChainHasDeterministicCounts")))
	{
		return false;
	}

	UClass* BlueprintClass = Blueprint.GetGeneratedClass();
	if (!TestNotNull(TEXT("Blueprint child override-chain scenario should expose a generated class"), BlueprintClass))
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* Actor = SpawnScriptActor(*this, Spawner, BlueprintClass);
	if (!TestNotNull(TEXT("Blueprint child override-chain scenario should spawn the blueprint subclass"), Actor))
	{
		return false;
	}

	BeginPlayActor(Engine, *Actor);

	TickWorld(Engine, Spawner.GetWorld(), BlueprintSubclassRuntimeTest::ScenarioTickDeltaTime, BlueprintSubclassRuntimeTest::OverrideChainTickCount);

	int32 ParentBeginPlayCount = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("ParentBeginPlayCount"), ParentBeginPlayCount))
	{
		return false;
	}

	int32 ChildBeginPlayCount = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("ChildBeginPlayCount"), ChildBeginPlayCount))
	{
		return false;
	}

	int32 ParentTickCount = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("ParentTickCount"), ParentTickCount))
	{
		return false;
	}

	int32 ChildTickCount = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("ChildTickCount"), ChildTickCount))
	{
		return false;
	}

	TestEqual(TEXT("Blueprint child override-chain scenario should execute the inherited parent BeginPlay step exactly once"), ParentBeginPlayCount, 1);
	TestEqual(TEXT("Blueprint child override-chain scenario should execute the child BeginPlay step exactly once"), ChildBeginPlayCount, 1);
	TestEqual(
		TEXT("Blueprint child override-chain scenario should execute deterministic parent Tick steps"),
		ParentTickCount,
		BlueprintSubclassRuntimeTest::OverrideChainTickCount);
	TestEqual(
		TEXT("Blueprint child override-chain scenario should execute deterministic child Tick steps"),
		ChildTickCount,
		BlueprintSubclassRuntimeTest::OverrideChainTickCount);
	ASTEST_END_SHARE_CLEAN

	return true;
}

#endif
