#include "Shared/AngelscriptFunctionalTestUtils.h"
#include "Shared/AngelscriptTestMacros.h"

#include "Components/ActorTestSpawner.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

// Test Layer: UE Scenario
#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptFunctionalTestUtils;

namespace AngelscriptTest_Interface_AngelscriptInterfaceImplementTests_Private
{
}

using namespace AngelscriptTest_Interface_AngelscriptInterfaceImplementTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestInterfaceImplementBasicTest,
	"Angelscript.TestModule.Interface.ImplementBasic",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestInterfaceImplementMultipleTest,
	"Angelscript.TestModule.Interface.ImplementMultiple",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestInterfaceImplementsInterfaceMethodTest,
	"Angelscript.TestModule.Interface.ImplementsInterfaceMethod",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptTestInterfaceImplementBasicTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH
	do
	{
	static const FName ModuleName(TEXT("TestInterfaceImplementBasic"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("TestInterfaceImplementBasic.as"),
		TEXT(R"AS(
UINTERFACE()
interface UIDamageableImpl
{
	void TakeDamage(float Amount);
}

UCLASS()
class ATestInterfaceImplBasic : AActor, UIDamageableImpl
{
	UPROPERTY()
	float DamageReceived = 0.0;

	UFUNCTION()
	void TakeDamage(float Amount)
	{
		DamageReceived = Amount;
	}
}
)AS"),
		TEXT("ATestInterfaceImplBasic"));
	if (!TestNotNull(TEXT("ScriptClass should be valid"), ScriptClass))
	{
		break;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* Actor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (!TestNotNull(TEXT("Actor should be valid"), Actor))
	{
		break;
	}

	UClass* InterfaceClass = FindGeneratedClass(&Engine, TEXT("UIDamageableImpl"));
	TestNotNull(TEXT("Interface class should exist"), InterfaceClass);
	if (InterfaceClass != nullptr)
	{
		TestTrue(TEXT("Actor should implement the interface"), Actor->GetClass()->ImplementsInterface(InterfaceClass));
	}
	}
	while (false);
	ASTEST_END_SHARE_FRESH

	return !HasAnyErrors();
}

bool FAngelscriptTestInterfaceImplementMultipleTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH
	do
	{
	static const FName ModuleName(TEXT("TestInterfaceImplementMultiple"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("TestInterfaceImplementMultiple.as"),
		TEXT(R"AS(
UINTERFACE()
interface UIDamageableMulti
{
	void TakeDamage(float Amount);
}

UINTERFACE()
interface UIHealableMulti
{
	void Heal(float Amount);
}

UCLASS()
class ATestInterfaceImplMultiple : AActor, UIDamageableMulti, UIHealableMulti
{
	UPROPERTY()
	float Health = 100.0;

	UFUNCTION()
	void TakeDamage(float Amount)
	{
		Health -= Amount;
	}

	UFUNCTION()
	void Heal(float Amount)
	{
		Health += Amount;
	}
}
)AS"),
		TEXT("ATestInterfaceImplMultiple"));
	if (!TestNotNull(TEXT("ScriptClass should be valid"), ScriptClass))
	{
		break;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* Actor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (!TestNotNull(TEXT("Actor should be valid"), Actor))
	{
		break;
	}

	UClass* DamageableClass = FindGeneratedClass(&Engine, TEXT("UIDamageableMulti"));
	UClass* HealableClass = FindGeneratedClass(&Engine, TEXT("UIHealableMulti"));

	TestNotNull(TEXT("Damageable interface class should exist"), DamageableClass);
	TestNotNull(TEXT("Healable interface class should exist"), HealableClass);

	if (DamageableClass != nullptr)
	{
		TestTrue(TEXT("Actor should implement UIDamageableMulti"), Actor->GetClass()->ImplementsInterface(DamageableClass));
	}
	if (HealableClass != nullptr)
	{
		TestTrue(TEXT("Actor should implement UIHealableMulti"), Actor->GetClass()->ImplementsInterface(HealableClass));
	}
	}
	while (false);
	ASTEST_END_SHARE_FRESH

	return !HasAnyErrors();
}

bool FAngelscriptTestInterfaceImplementsInterfaceMethodTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH
	do
	{
	static const FName ModuleName(TEXT("TestInterfaceImplMethod"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("TestInterfaceImplMethod.as"),
		TEXT(R"AS(
UINTERFACE()
interface UIDamageableImplCheck
{
	void TakeDamage(float Amount);
}

UCLASS()
class ATestInterfaceImplMethod : AActor, UIDamageableImplCheck
{
	UPROPERTY()
	int ImplementsResult = 0;

	UFUNCTION()
	void TakeDamage(float Amount) {}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		if (this.ImplementsInterface(UIDamageableImplCheck::StaticClass()))
		{
			ImplementsResult = 1;
		}
	}
}
)AS"),
		TEXT("ATestInterfaceImplMethod"));
	if (!TestNotNull(TEXT("ScriptClass should be valid"), ScriptClass))
	{
		break;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* Actor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (!TestNotNull(TEXT("Actor should be valid"), Actor))
	{
		break;
	}

	BeginPlayActor(*Actor);

	UClass* InterfaceClass = FindGeneratedClass(&Engine, TEXT("UIDamageableImplCheck"));
	TestNotNull(TEXT("Interface class should exist"), InterfaceClass);
	if (InterfaceClass != nullptr)
	{
		TestTrue(TEXT("ImplementsInterface() should return true for the implementing class"), ScriptClass->ImplementsInterface(InterfaceClass));
	}

	int32 ImplementsResult = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("ImplementsResult"), ImplementsResult))
	{
		break;
	}

	TestEqual(TEXT("ImplementsInterface via StaticClass() should succeed in AS script"), ImplementsResult, 1);
	}
	while (false);
	ASTEST_END_SHARE_FRESH

	return !HasAnyErrors();
}

#endif
