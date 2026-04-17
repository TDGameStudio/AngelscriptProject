#include "Shared/AngelscriptScenarioTestUtils.h"
#include "Shared/AngelscriptTestMacros.h"

#include "Components/ActorTestSpawner.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"
#include "UObject/GarbageCollection.h"

// Test Layer: UE Scenario
#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptScenarioTestUtils;

namespace AngelscriptTest_Interface_AngelscriptInterfaceAdvancedTests_Private
{
}

using namespace AngelscriptTest_Interface_AngelscriptInterfaceAdvancedTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioInterfaceInheritedInterfaceTest,
	"Angelscript.TestModule.Interface.InheritedInterface",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioInterfaceMissingMethodTest,
	"Angelscript.TestModule.Interface.MissingMethod",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioInterfaceNoPropertyTest,
	"Angelscript.TestModule.Interface.NoProperty",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioInterfaceGCSafeTest,
	"Angelscript.TestModule.Interface.GCSafe",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

#if 1
IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioInterfaceHotReloadTest,
	"Angelscript.TestModule.Interface.HotReload",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
#endif

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioInterfaceCppInterfaceTest,
	"Angelscript.TestModule.Interface.CppInterface",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioInterfaceInheritedMethodDispatchTest,
	"Angelscript.TestModule.Interface.InheritedMethodDispatch",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioInterfaceInheritedMethodDispatchChildSurfaceIncludesParentMethodsTest,
	"Angelscript.TestModule.Interface.InheritedMethodDispatch.ChildSurfaceIncludesParentMethods",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioInterfaceMultipleInheritanceChainTest,
	"Angelscript.TestModule.Interface.MultipleInheritanceChain",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioInterfaceMultipleInheritanceDispatchTest,
	"Angelscript.TestModule.Interface.MultipleInheritanceDispatch",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptScenarioInterfaceInheritedInterfaceTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH
	static const FName ModuleName(TEXT("ScenarioInterfaceInherited"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioInterfaceInherited.as"),
		TEXT(R"AS(
UINTERFACE()
interface UIDamageableParent
{
	void TakeDamage(float Amount);
}

UINTERFACE()
interface UIKillableChild : UIDamageableParent
{
	void Kill();
}

UCLASS()
class AScenarioInterfaceInherited : AActor, UIKillableChild
{
	UPROPERTY()
	float DamageReceived = 0.0;

	UPROPERTY()
	int Killed = 0;

	UFUNCTION()
	void TakeDamage(float Amount)
	{
		DamageReceived = Amount;
	}

	UFUNCTION()
	void Kill()
	{
		Killed = 1;
	}
}
)AS"),
		TEXT("AScenarioInterfaceInherited"));
	if (ScriptClass == nullptr)
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* Actor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (Actor == nullptr)
	{
		return false;
	}

	UClass* ParentInterface = FindGeneratedClass(&Engine, TEXT("UIDamageableParent"));
	UClass* ChildInterface = FindGeneratedClass(&Engine, TEXT("UIKillableChild"));

	TestNotNull(TEXT("Parent interface class should exist"), ParentInterface);
	TestNotNull(TEXT("Child interface class should exist"), ChildInterface);

	if (ChildInterface != nullptr)
	{
		TestTrue(TEXT("Actor should implement child interface UIKillableChild"), Actor->GetClass()->ImplementsInterface(ChildInterface));
	}
	if (ParentInterface != nullptr)
	{
		TestTrue(TEXT("Actor implementing child interface should also satisfy parent UIDamageableParent"), Actor->GetClass()->ImplementsInterface(ParentInterface));
	}
	ASTEST_END_SHARE_FRESH

	return true;
}

bool FAngelscriptScenarioInterfaceMissingMethodTest::RunTest(const FString& Parameters)
{
	bool bPassed = false;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH
	static const FName ModuleName(TEXT("ScenarioInterfaceMissingMethod"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	AddExpectedError(TEXT("missing required method"), EAutomationExpectedErrorFlags::Contains, 1);
	const bool bCompiled = CompileAnnotatedModuleFromMemory(
		&Engine,
		ModuleName,
		TEXT("ScenarioInterfaceMissingMethod.as"),
		TEXT(R"AS(
UINTERFACE()
interface UIDamageableMissing
{
	void TakeDamage(float Amount);
	float GetHealth();
}

UCLASS()
class AScenarioInterfaceMissingMethod : AActor, UIDamageableMissing
{
	UFUNCTION()
	void TakeDamage(float Amount) {}
}

)AS"));

	UClass* InterfaceClass = FindGeneratedClass(&Engine, TEXT("UIDamageableMissing"));
	TestNotNull(TEXT("Interface class UIDamageableMissing should exist"), InterfaceClass);

	if (InterfaceClass != nullptr)
	{
		UFunction* TakeDamageFunc = InterfaceClass->FindFunctionByName(TEXT("TakeDamage"));
		UFunction* GetHealthFunc = InterfaceClass->FindFunctionByName(TEXT("GetHealth"));

		TestNotNull(TEXT("Interface should have TakeDamage UFunction"), TakeDamageFunc);
		TestNotNull(TEXT("Interface should have GetHealth UFunction"), GetHealthFunc);

		int32 FuncCount = 0;
		for (TFieldIterator<UFunction> FuncIt(InterfaceClass, EFieldIteratorFlags::ExcludeSuper); FuncIt; ++FuncIt)
		{
			UFunction* Func = *FuncIt;
			if (Func->GetOuter() != UInterface::StaticClass())
				FuncCount++;
		}
		TestEqual(TEXT("Interface should declare exactly 2 methods"), FuncCount, 2);
	}

	bPassed = bCompiled;
	ASTEST_END_SHARE_FRESH

	return bPassed;
}

bool FAngelscriptScenarioInterfaceNoPropertyTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH
	static const FName ModuleName(TEXT("ScenarioInterfaceNoProperty"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* InterfaceClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioInterfaceNoProperty.as"),
		TEXT(R"AS(
UINTERFACE()
interface UINoProperty
{
	void DoSomething();
}
)AS"),
		TEXT("UINoProperty"));

	if (InterfaceClass == nullptr)
	{
		return false;
	}

	int32 PropertyCount = 0;
	for (TFieldIterator<FProperty> PropIt(InterfaceClass, EFieldIteratorFlags::ExcludeSuper); PropIt; ++PropIt)
	{
		PropertyCount++;
	}

	TestEqual(TEXT("Interface should have no UPROPERTY members"), PropertyCount, 0);
	ASTEST_END_SHARE_FRESH

	return true;
}

bool FAngelscriptScenarioInterfaceGCSafeTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH
	static const FName ModuleName(TEXT("ScenarioInterfaceGCSafe"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioInterfaceGCSafe.as"),
		TEXT(R"AS(
UINTERFACE()
interface UIDamageableGC
{
	void TakeDamage(float Amount);
}

UCLASS()
class AScenarioInterfaceGCSafe : AActor, UIDamageableGC
{
	UFUNCTION()
	void TakeDamage(float Amount) {}
}
)AS"),
		TEXT("AScenarioInterfaceGCSafe"));
	if (ScriptClass == nullptr)
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* Actor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (Actor == nullptr)
	{
		return false;
	}
	BeginPlayActor(*Actor);

	UClass* InterfaceClass = FindGeneratedClass(&Engine, TEXT("UIDamageableGC"));
	if (InterfaceClass != nullptr)
	{
		TestTrue(TEXT("Actor should implement interface before destroy"), Actor->GetClass()->ImplementsInterface(InterfaceClass));
	}

	TWeakObjectPtr<AActor> WeakActor = Actor;
	Actor->Destroy();
	TickWorld(Spawner.GetWorld(), 0.0f, 1);
	CollectGarbage(RF_NoFlags, true);

	TestTrue(TEXT("Interface actor should be collected after destroy + GC"), !WeakActor.IsValid());
	ASTEST_END_SHARE_FRESH

	return true;
}

#if 1
bool FAngelscriptScenarioInterfaceHotReloadTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH
	static const FName ModuleName(TEXT("ScenarioInterfaceHotReload"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	const FString ScriptV1 = TEXT(R"AS(
UINTERFACE()
interface UIDamageableHR
{
	void TakeDamage(float Amount);
}

UCLASS()
class AScenarioInterfaceHotReload : AActor, UIDamageableHR
{
	UPROPERTY()
	float DamageReceived = 0.0;

	UFUNCTION()
	void TakeDamage(float Amount)
	{
		DamageReceived = Amount;
	}
}
)AS");

	const FString ScriptV2 = TEXT(R"AS(
UINTERFACE()
interface UIDamageableHR
{
	void TakeDamage(float Amount);
}

UCLASS()
class AScenarioInterfaceHotReload : AActor, UIDamageableHR
{
	UPROPERTY()
	float DamageReceived = 0.0;

	UFUNCTION()
	void TakeDamage(float Amount)
	{
		DamageReceived = Amount * 2.0;
	}
}
)AS");

	UClass* ClassV1 = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioInterfaceHotReload.as"),
		ScriptV1,
		TEXT("AScenarioInterfaceHotReload"));
	if (ClassV1 == nullptr)
	{
		return false;
	}

	UClass* InterfaceV1 = FindGeneratedClass(&Engine, TEXT("UIDamageableHR"));
	TestNotNull(TEXT("Interface should exist after V1 compile"), InterfaceV1);
	if (InterfaceV1 != nullptr)
	{
		TestTrue(TEXT("V1 class should implement interface"), ClassV1->ImplementsInterface(InterfaceV1));
	}

	ECompileResult ReloadResult = ECompileResult::Error;
	if (!TestTrue(TEXT("Interface hot reload should succeed on the full reload path"),
		CompileModuleWithResult(&Engine, ECompileType::FullReload, ModuleName, TEXT("ScenarioInterfaceHotReload.as"), ScriptV2, ReloadResult)))
	{
		return false;
	}
	if (!TestTrue(TEXT("Interface hot reload should route through the full reload path"), ReloadResult == ECompileResult::FullyHandled || ReloadResult == ECompileResult::PartiallyHandled))
	{
		return false;
	}

	UClass* ClassV2 = FindGeneratedClass(&Engine, TEXT("AScenarioInterfaceHotReload"));
	if (ClassV2 == nullptr)
	{
		return false;
	}

	UClass* InterfaceV2 = FindGeneratedClass(&Engine, TEXT("UIDamageableHR"));
	TestNotNull(TEXT("Interface should exist after V2 hot reload"), InterfaceV2);
	if (InterfaceV2 != nullptr)
	{
		TestTrue(TEXT("V2 class should still implement interface after hot reload"), ClassV2->ImplementsInterface(InterfaceV2));
	}

	ASTEST_END_SHARE_FRESH

	return true;
}
#endif

bool FAngelscriptScenarioInterfaceCppInterfaceTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH
	static const FName ModuleName(TEXT("ScenarioInterfaceCppInterface"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioInterfaceCppInterface.as"),
		TEXT(R"AS(
UINTERFACE()
interface UICppTestInterface
{
	void DoWork();
}

UCLASS()
class AScenarioInterfaceCppBase : AActor, UICppTestInterface
{
	UPROPERTY()
	int WorkDone = 0;

	UFUNCTION()
	void DoWork()
	{
		WorkDone = 1;
	}
}
)AS"),
		TEXT("AScenarioInterfaceCppBase"));
	if (ScriptClass == nullptr)
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* Actor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (Actor == nullptr)
	{
		return false;
	}

	UClass* InterfaceClass = FindGeneratedClass(&Engine, TEXT("UICppTestInterface"));
	TestNotNull(TEXT("Interface class should exist"), InterfaceClass);
	if (InterfaceClass != nullptr)
	{
		TestTrue(TEXT("Class should implement its declared interface"), Actor->GetClass()->ImplementsInterface(InterfaceClass));
	}

	ASTEST_END_SHARE_FRESH

	return true;
}

bool FAngelscriptScenarioInterfaceInheritedMethodDispatchTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH
	static const FName ModuleName(TEXT("ScenarioInterfaceInheritedDispatch"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioInterfaceInheritedDispatch.as"),
		TEXT(R"AS(
UINTERFACE()
interface UIDamageableDispatch
{
	int GetDamageLevel();
}

UINTERFACE()
interface UIKillableDispatch : UIDamageableDispatch
{
	int GetKillCount();
}

UCLASS()
class AScenarioInterfaceInheritedDispatch : AActor, UIKillableDispatch
{
	UPROPERTY()
	int ParentCastWorked = 0;

	UPROPERTY()
	int ChildCastWorked = 0;

	UPROPERTY()
	int ParentResult = 0;

	UPROPERTY()
	int ChildResult = 0;

	UFUNCTION()
	int GetDamageLevel()
	{
		return 3;
	}

	UFUNCTION()
	int GetKillCount()
	{
		return 5;
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		UObject Self = this;
		UIDamageableDispatch ParentRef = Cast<UIDamageableDispatch>(Self);
		if (ParentRef != nullptr)
		{
			ParentCastWorked = 1;
			ParentResult = ParentRef.GetDamageLevel();
		}

		UIKillableDispatch ChildRef = Cast<UIKillableDispatch>(Self);
		if (ChildRef != nullptr)
		{
			ChildCastWorked = 1;
			ChildResult = ChildRef.GetKillCount();
		}
	}
}
)AS"),
		TEXT("AScenarioInterfaceInheritedDispatch"));
	if (ScriptClass == nullptr)
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* Actor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (Actor == nullptr)
	{
		return false;
	}

	BeginPlayActor(*Actor);

	int32 ParentCastWorked = 0;
	int32 ChildCastWorked = 0;
	int32 ParentResult = 0;
	int32 ChildResult = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("ParentCastWorked"), ParentCastWorked)
		|| !ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("ChildCastWorked"), ChildCastWorked)
		|| !ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("ParentResult"), ParentResult)
		|| !ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("ChildResult"), ChildResult))
	{
		return false;
	}

	TestEqual(TEXT("Parent interface cast should succeed for inherited script interface"), ParentCastWorked, 1);
	TestEqual(TEXT("Child interface cast should succeed for inherited script interface"), ChildCastWorked, 1);
	TestEqual(TEXT("Parent interface method should dispatch through inherited interface reference"), ParentResult, 3);
	TestEqual(TEXT("Child interface method should dispatch through child interface reference"), ChildResult, 5);
	ASTEST_END_SHARE_FRESH

	return true;
}

bool FAngelscriptScenarioInterfaceInheritedMethodDispatchChildSurfaceIncludesParentMethodsTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH
	static const FName ChildModuleName(TEXT("ScenarioInterfaceInheritedDispatchChildSurface"));
	static const FName LeafModuleName(TEXT("ScenarioInterfaceMultiDispatchChildSurface"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*LeafModuleName.ToString());
		Engine.DiscardModule(*ChildModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ChildScriptClass = CompileScriptModule(
		*this,
		Engine,
		ChildModuleName,
		TEXT("ScenarioInterfaceInheritedDispatchChildSurface.as"),
		TEXT(R"AS(
UINTERFACE()
interface UIDamageableDispatchChildSurface
{
	int GetDamageLevel();
}

UINTERFACE()
interface UIKillableDispatchChildSurface : UIDamageableDispatchChildSurface
{
	int GetKillCount();
}

UCLASS()
class AScenarioInterfaceInheritedDispatchChildSurface : AActor, UIKillableDispatchChildSurface
{
	UPROPERTY()
	int ChildCastWorked = 0;

	UPROPERTY()
	int ChildParentResult = 0;

	UPROPERTY()
	int ChildResult = 0;

	UFUNCTION()
	int GetDamageLevel()
	{
		return 3;
	}

	UFUNCTION()
	int GetKillCount()
	{
		return 5;
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		UObject Self = this;
		UIKillableDispatchChildSurface ChildRef = Cast<UIKillableDispatchChildSurface>(Self);
		if (ChildRef != nullptr)
		{
			ChildCastWorked = 1;
			ChildParentResult = ChildRef.GetDamageLevel();
			ChildResult = ChildRef.GetKillCount();
		}
	}
}
)AS"),
		TEXT("AScenarioInterfaceInheritedDispatchChildSurface"));
	if (ChildScriptClass == nullptr)
	{
		return false;
	}

	UClass* LeafScriptClass = CompileScriptModule(
		*this,
		Engine,
		LeafModuleName,
		TEXT("ScenarioInterfaceMultiDispatchChildSurface.as"),
		TEXT(R"AS(
UINTERFACE()
interface UIBaseDispatchChainChildSurface
{
	int BaseValue();
}

UINTERFACE()
interface UIMidDispatchChainChildSurface : UIBaseDispatchChainChildSurface
{
	int MidValue();
}

UINTERFACE()
interface UILeafDispatchChainChildSurface : UIMidDispatchChainChildSurface
{
	int LeafValue();
}

UCLASS()
class AScenarioInterfaceMultiDispatchChildSurface : AActor, UILeafDispatchChainChildSurface
{
	UPROPERTY()
	int LeafCastWorked = 0;

	UPROPERTY()
	int LeafBaseResult = 0;

	UPROPERTY()
	int LeafMidResult = 0;

	UPROPERTY()
	int LeafResult = 0;

	UFUNCTION()
	int BaseValue()
	{
		return 2;
	}

	UFUNCTION()
	int MidValue()
	{
		return 4;
	}

	UFUNCTION()
	int LeafValue()
	{
		return 8;
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		UObject Self = this;
		UILeafDispatchChainChildSurface LeafRef = Cast<UILeafDispatchChainChildSurface>(Self);
		if (LeafRef != nullptr)
		{
			LeafCastWorked = 1;
			LeafBaseResult = LeafRef.BaseValue();
			LeafMidResult = LeafRef.MidValue();
			LeafResult = LeafRef.LeafValue();
		}
	}
}
)AS"),
		TEXT("AScenarioInterfaceMultiDispatchChildSurface"));
	if (LeafScriptClass == nullptr)
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();

	AActor* ChildActor = SpawnScriptActor(*this, Spawner, ChildScriptClass);
	AActor* LeafActor = SpawnScriptActor(*this, Spawner, LeafScriptClass);
	if (ChildActor == nullptr || LeafActor == nullptr)
	{
		return false;
	}

	BeginPlayActor(*ChildActor);
	BeginPlayActor(*LeafActor);

	int32 ChildCastWorked = 0;
	int32 ChildParentResult = 0;
	int32 ChildResult = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, ChildActor, TEXT("ChildCastWorked"), ChildCastWorked)
		|| !ReadPropertyValue<FIntProperty>(*this, ChildActor, TEXT("ChildParentResult"), ChildParentResult)
		|| !ReadPropertyValue<FIntProperty>(*this, ChildActor, TEXT("ChildResult"), ChildResult))
	{
		return false;
	}

	int32 LeafCastWorked = 0;
	int32 LeafBaseResult = 0;
	int32 LeafMidResult = 0;
	int32 LeafResult = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, LeafActor, TEXT("LeafCastWorked"), LeafCastWorked)
		|| !ReadPropertyValue<FIntProperty>(*this, LeafActor, TEXT("LeafBaseResult"), LeafBaseResult)
		|| !ReadPropertyValue<FIntProperty>(*this, LeafActor, TEXT("LeafMidResult"), LeafMidResult)
		|| !ReadPropertyValue<FIntProperty>(*this, LeafActor, TEXT("LeafResult"), LeafResult))
	{
		return false;
	}

	TestEqual(TEXT("Most-derived child interface cast should succeed"), ChildCastWorked, 1);
	TestEqual(TEXT("Child interface ref should inherit parent methods"), ChildParentResult, 3);
	TestEqual(TEXT("Child interface ref should retain child methods"), ChildResult, 5);
	TestEqual(TEXT("Most-derived leaf interface cast should succeed"), LeafCastWorked, 1);
	TestEqual(TEXT("Leaf interface ref should inherit base methods"), LeafBaseResult, 2);
	TestEqual(TEXT("Leaf interface ref should inherit mid methods"), LeafMidResult, 4);
	TestEqual(TEXT("Leaf interface ref should retain leaf methods"), LeafResult, 8);
	ASTEST_END_SHARE_FRESH

	return true;
}

bool FAngelscriptScenarioInterfaceMultipleInheritanceChainTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH
	static const FName ModuleName(TEXT("ScenarioInterfaceMultiChain"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioInterfaceMultiChain.as"),
		TEXT(R"AS(
UINTERFACE()
interface UIBaseChain
{
	void BaseMethod();
}

UINTERFACE()
interface UIMidChain : UIBaseChain
{
	void MidMethod();
}

UINTERFACE()
interface UILeafChain : UIMidChain
{
	void LeafMethod();
}

UCLASS()
class AScenarioInterfaceMultiChain : AActor, UILeafChain
{
	UFUNCTION()
	void BaseMethod() {}

	UFUNCTION()
	void MidMethod() {}

	UFUNCTION()
	void LeafMethod() {}
}
)AS"),
		TEXT("AScenarioInterfaceMultiChain"));
	if (ScriptClass == nullptr)
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* Actor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (Actor == nullptr)
	{
		return false;
	}

	UClass* BaseInterface = FindGeneratedClass(&Engine, TEXT("UIBaseChain"));
	UClass* MidInterface = FindGeneratedClass(&Engine, TEXT("UIMidChain"));
	UClass* LeafInterface = FindGeneratedClass(&Engine, TEXT("UILeafChain"));

	TestNotNull(TEXT("Base interface should exist"), BaseInterface);
	TestNotNull(TEXT("Mid interface should exist"), MidInterface);
	TestNotNull(TEXT("Leaf interface should exist"), LeafInterface);

	if (BaseInterface != nullptr)
	{
		TestTrue(TEXT("Actor implementing leaf should satisfy base interface"), Actor->GetClass()->ImplementsInterface(BaseInterface));
	}
	if (MidInterface != nullptr)
	{
		TestTrue(TEXT("Actor implementing leaf should satisfy mid interface"), Actor->GetClass()->ImplementsInterface(MidInterface));
	}
	if (LeafInterface != nullptr)
	{
		TestTrue(TEXT("Actor implementing leaf should satisfy leaf interface"), Actor->GetClass()->ImplementsInterface(LeafInterface));
	}

	ASTEST_END_SHARE_FRESH

	return true;
}

bool FAngelscriptScenarioInterfaceMultipleInheritanceDispatchTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH
	static const FName ModuleName(TEXT("ScenarioInterfaceMultiDispatch"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioInterfaceMultiDispatch.as"),
		TEXT(R"AS(
UINTERFACE()
interface UIBaseDispatchChain
{
	int BaseValue();
}

UINTERFACE()
interface UIMidDispatchChain : UIBaseDispatchChain
{
	int MidValue();
}

UINTERFACE()
interface UILeafDispatchChain : UIMidDispatchChain
{
	int LeafValue();
}

UCLASS()
class AScenarioInterfaceMultiDispatch : AActor, UILeafDispatchChain
{
	UPROPERTY()
	int BaseResult = 0;

	UPROPERTY()
	int MidResult = 0;

	UPROPERTY()
	int LeafResult = 0;

	UFUNCTION()
	int BaseValue()
	{
		return 2;
	}

	UFUNCTION()
	int MidValue()
	{
		return 4;
	}

	UFUNCTION()
	int LeafValue()
	{
		return 8;
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		UObject Self = this;
		UIBaseDispatchChain BaseRef = Cast<UIBaseDispatchChain>(Self);
		UIMidDispatchChain MidRef = Cast<UIMidDispatchChain>(Self);
		UILeafDispatchChain LeafRef = Cast<UILeafDispatchChain>(Self);

		if (BaseRef != nullptr)
		{
			BaseResult = BaseRef.BaseValue();
		}
		if (MidRef != nullptr)
		{
			MidResult = MidRef.MidValue();
		}
		if (LeafRef != nullptr)
		{
			LeafResult = LeafRef.LeafValue();
		}
	}
}
)AS"),
		TEXT("AScenarioInterfaceMultiDispatch"));
	if (ScriptClass == nullptr)
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* Actor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (Actor == nullptr)
	{
		return false;
	}

	BeginPlayActor(*Actor);

	int32 BaseResult = 0;
	int32 MidResult = 0;
	int32 LeafResult = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("BaseResult"), BaseResult)
		|| !ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("MidResult"), MidResult)
		|| !ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("LeafResult"), LeafResult))
	{
		return false;
	}

	TestEqual(TEXT("Base interface method should dispatch through a leaf implementation"), BaseResult, 2);
	TestEqual(TEXT("Mid interface method should dispatch through a leaf implementation"), MidResult, 4);
	TestEqual(TEXT("Leaf interface method should dispatch through a leaf implementation"), LeafResult, 8);
	ASTEST_END_SHARE_FRESH

	return true;
}

#endif
