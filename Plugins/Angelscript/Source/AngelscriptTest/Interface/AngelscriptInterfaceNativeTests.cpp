#include "Core/AngelscriptEngine.h"
#include "Shared/AngelscriptNativeInterfaceTestTypes.h"
#include "Shared/AngelscriptNativeInterfaceTestHelpers.h"
#include "Shared/AngelscriptFunctionalTestUtils.h"
#include "Shared/AngelscriptTestMacros.h"

#include "Components/ActorTestSpawner.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptFunctionalTestUtils;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestInterfaceNativeImplementTest,
	"Angelscript.TestModule.Interface.NativeImplement",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestInterfaceNativeInheritedImplementTest,
	"Angelscript.TestModule.Interface.NativeInheritedImplement",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestInterfaceNativeReferenceRoundTripTest,
	"Angelscript.TestModule.Interface.NativeReferenceRoundTrip",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestInterfaceNativeReferenceRoundTripCppBridgeMutatesActorStateTest,
	"Angelscript.TestModule.Interface.NativeReferenceRoundTrip.CppBridgeMutatesActorState",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestInterfaceNativeInheritedParentBridgeSetterAndRefTest,
	"Angelscript.TestModule.Interface.NativeInheritedImplement.ParentBridgeSetterAndRef",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptTestInterfaceNativeImplementTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH
	do
	{
	AngelscriptNativeInterfaceTestHelpers::EnsureNativeInterfaceBound(UAngelscriptNativeParentInterface::StaticClass());
	AngelscriptNativeInterfaceTestHelpers::EnsureNativeInterfaceBound(UAngelscriptNativeChildInterface::StaticClass());
	static const FName ModuleName(TEXT("TestInterfaceNativeImplement"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("TestInterfaceNativeImplement.as"),
		TEXT(R"AS(
UCLASS()
class ATestInterfaceNativeImplement : AActor, UAngelscriptNativeParentInterface
{
	UPROPERTY()
	int NativeValue = 123;

	UPROPERTY()
	FName NativeMarker = NAME_None;

	UPROPERTY()
	int ParentCastWorked = 0;

	UFUNCTION()
	int GetNativeValue() const
	{
		return NativeValue;
	}

	UFUNCTION()
	void SetNativeMarker(FName Marker)
	{
		NativeMarker = Marker;
	}

	UFUNCTION()
	void AdjustNativeValue(int Delta, int& Value)
	{
		Value += Delta;
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		UObject Self = this;
		UAngelscriptNativeParentInterface ParentRef = Cast<UAngelscriptNativeParentInterface>(Self);
		if (ParentRef != nullptr)
		{
			ParentCastWorked = 1;
			NativeValue = ParentRef.GetNativeValue();
			ParentRef.SetNativeMarker(n"FromScript");
		}
	}
}
)AS"),
		TEXT("ATestInterfaceNativeImplement"));
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

	BeginPlayActor(Engine, *Actor);

	TestTrue(TEXT("Script actor should implement native parent interface"), ScriptClass->ImplementsInterface(UAngelscriptNativeParentInterface::StaticClass()));

	int32 ParentCastWorked = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("ParentCastWorked"), ParentCastWorked))
	{
		break;
	}
	TestEqual(TEXT("Cast to native parent interface should succeed in script"), ParentCastWorked, 1);

	int32 NativeValue = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("NativeValue"), NativeValue))
	{
		break;
	}
	TestEqual(TEXT("Script-side native interface call should preserve the returned value"), NativeValue, 123);

	FName NativeMarker = NAME_None;
	if (!ReadPropertyValue<FNameProperty>(*this, Actor, TEXT("NativeMarker"), NativeMarker))
	{
		break;
	}
	TestEqual(TEXT("Script-side native interface setter should run through the interface reference"), NativeMarker, FName(TEXT("FromScript")));

	TestEqual(TEXT("C++ Execute_ bridge should call the script implementation of GetNativeValue"),
		IAngelscriptNativeParentInterface::Execute_GetNativeValue(Actor), 123);
	IAngelscriptNativeParentInterface::Execute_SetNativeMarker(Actor, TEXT("FromCpp"));

	if (!ReadPropertyValue<FNameProperty>(*this, Actor, TEXT("NativeMarker"), NativeMarker))
	{
		break;
	}
	TestEqual(TEXT("C++ Execute_ bridge should call the script implementation of SetNativeMarker"), NativeMarker, FName(TEXT("FromCpp")));

	}
	while (false);
	ASTEST_END_SHARE_FRESH

	return !HasAnyErrors();
}

bool FAngelscriptTestInterfaceNativeInheritedImplementTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH
	do
	{
	AngelscriptNativeInterfaceTestHelpers::EnsureNativeInterfaceBound(UAngelscriptNativeParentInterface::StaticClass());
	AngelscriptNativeInterfaceTestHelpers::EnsureNativeInterfaceBound(UAngelscriptNativeChildInterface::StaticClass());
	static const FName ModuleName(TEXT("TestInterfaceNativeInheritedImplement"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("TestInterfaceNativeInheritedImplement.as"),
		TEXT(R"AS(
UCLASS()
class ATestInterfaceNativeInheritedImplement : AActor, UAngelscriptNativeChildInterface
{
	UPROPERTY()
	int ParentCastWorked = 0;

	UPROPERTY()
	int ChildCastWorked = 0;

	UPROPERTY()
	int ParentResult = 0;

	UPROPERTY()
	int ChildResult = 0;

	UPROPERTY()
	FName NativeMarker = NAME_None;

	UFUNCTION()
	int GetNativeValue() const
	{
		return 7;
	}

	UFUNCTION()
	void SetNativeMarker(FName Marker)
	{
		NativeMarker = Marker;
	}

	UFUNCTION()
	void AdjustNativeValue(int Delta, int& Value)
	{
		Value += Delta;
	}

	UFUNCTION()
	int GetChildValue() const
	{
		return 11;
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		UObject Self = this;
		UAngelscriptNativeParentInterface ParentRef = Cast<UAngelscriptNativeParentInterface>(Self);
		if (ParentRef != nullptr)
		{
			ParentCastWorked = 1;
			ParentResult = ParentRef.GetNativeValue();
			ParentRef.SetNativeMarker(n"ParentRoute");
		}

		UAngelscriptNativeChildInterface ChildRef = Cast<UAngelscriptNativeChildInterface>(Self);
		if (ChildRef != nullptr)
		{
			ChildCastWorked = 1;
			ChildResult = ChildRef.GetChildValue();
		}
	}
}
)AS"),
		TEXT("ATestInterfaceNativeInheritedImplement"));
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

	BeginPlayActor(Engine, *Actor);

	TestTrue(TEXT("Script actor should implement native child interface"), ScriptClass->ImplementsInterface(UAngelscriptNativeChildInterface::StaticClass()));
	TestTrue(TEXT("Script actor implementing child interface should also satisfy native parent interface"), ScriptClass->ImplementsInterface(UAngelscriptNativeParentInterface::StaticClass()));

	int32 ParentCastWorked = 0;
	int32 ChildCastWorked = 0;
	int32 ParentResult = 0;
	int32 ChildResult = 0;
	FName NativeMarker = NAME_None;

	if (!ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("ParentCastWorked"), ParentCastWorked)
		|| !ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("ChildCastWorked"), ChildCastWorked)
		|| !ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("ParentResult"), ParentResult)
		|| !ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("ChildResult"), ChildResult)
		|| !ReadPropertyValue<FNameProperty>(*this, Actor, TEXT("NativeMarker"), NativeMarker))
	{
		break;
	}

	TestEqual(TEXT("Script-side cast to native parent interface should succeed through child implementation"), ParentCastWorked, 1);
	TestEqual(TEXT("Script-side cast to native child interface should succeed"), ChildCastWorked, 1);
	TestEqual(TEXT("Parent native interface method should return the script implementation value"), ParentResult, 7);
	TestEqual(TEXT("Child native interface method should return the script implementation value"), ChildResult, 11);
	TestEqual(TEXT("Parent native interface setter should execute through the parent reference"), NativeMarker, FName(TEXT("ParentRoute")));

	TestEqual(TEXT("C++ Execute_ should dispatch parent interface method on child implementation"),
		IAngelscriptNativeParentInterface::Execute_GetNativeValue(Actor), 7);
	TestEqual(TEXT("C++ Execute_ should dispatch child interface method on child implementation"),
		IAngelscriptNativeChildInterface::Execute_GetChildValue(Actor), 11);

	}
	while (false);
	ASTEST_END_SHARE_FRESH

	return !HasAnyErrors();
}

bool FAngelscriptTestInterfaceNativeReferenceRoundTripTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH
	do
	{
	AngelscriptNativeInterfaceTestHelpers::EnsureNativeInterfaceBound(UAngelscriptNativeParentInterface::StaticClass());
	AngelscriptNativeInterfaceTestHelpers::EnsureNativeInterfaceBound(UAngelscriptNativeChildInterface::StaticClass());
	static const FName ModuleName(TEXT("TestInterfaceNativeReferenceRoundTrip"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("TestInterfaceNativeReferenceRoundTrip.as"),
		TEXT(R"AS(
UCLASS()
class ATestInterfaceNativeReferenceRoundTrip : AActor, UAngelscriptNativeParentInterface
{
	UPROPERTY()
	int ScriptAdjustedValue = 0;

	UFUNCTION()
	int GetNativeValue() const
	{
		return 0;
	}

	UFUNCTION()
	void SetNativeMarker(FName Marker)
	{
	}

	UFUNCTION()
	void AdjustNativeValue(int Delta, int& Value)
	{
		Value += Delta;
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		UObject Self = this;
		UAngelscriptNativeParentInterface ParentRef = Cast<UAngelscriptNativeParentInterface>(Self);
		if (ParentRef == nullptr)
			return;

		int Value = 10;
		ParentRef.AdjustNativeValue(5, Value);
		ScriptAdjustedValue = Value;
	}
}
)AS"),
		TEXT("ATestInterfaceNativeReferenceRoundTrip"));
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

	BeginPlayActor(Engine, *Actor);

	int32 ScriptAdjustedValue = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("ScriptAdjustedValue"), ScriptAdjustedValue))
	{
		break;
	}
	TestEqual(TEXT("Script-side native interface call should round-trip ref parameters"), ScriptAdjustedValue, 15);

	int32 CppAdjustedValue = 20;
	IAngelscriptNativeParentInterface::Execute_AdjustNativeValue(Actor, 7, CppAdjustedValue);
	TestEqual(TEXT("C++ Execute_ bridge should round-trip ref parameters through the script implementation"), CppAdjustedValue, 27);

	}
	while (false);
	ASTEST_END_SHARE_FRESH

	return !HasAnyErrors();
}

bool FAngelscriptTestInterfaceNativeReferenceRoundTripCppBridgeMutatesActorStateTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH
	do
	{
	AngelscriptNativeInterfaceTestHelpers::EnsureNativeInterfaceBound(UAngelscriptNativeParentInterface::StaticClass());
	AngelscriptNativeInterfaceTestHelpers::EnsureNativeInterfaceBound(UAngelscriptNativeChildInterface::StaticClass());
	static const FName ModuleName(TEXT("TestInterfaceNativeReferenceRoundTripCppBridgeState"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("TestInterfaceNativeReferenceRoundTripCppBridgeState.as"),
		TEXT(R"AS(
UCLASS()
class ATestInterfaceNativeReferenceRoundTripCppBridgeState : AActor, UAngelscriptNativeParentInterface
{
	UPROPERTY()
	int ScriptAdjustedValue = 0;

	UPROPERTY()
	int AdjustCallCount = 0;

	UPROPERTY()
	int LastAdjustedValue = 0;

	UFUNCTION()
	int GetNativeValue() const
	{
		return 0;
	}

	UFUNCTION()
	void SetNativeMarker(FName Marker)
	{
	}

	UFUNCTION()
	void AdjustNativeValue(int Delta, int& Value)
	{
		Value += Delta;
		AdjustCallCount += 1;
		LastAdjustedValue = Value;
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		UObject Self = this;
		UAngelscriptNativeParentInterface ParentRef = Cast<UAngelscriptNativeParentInterface>(Self);
		if (ParentRef == nullptr)
			return;

		int Value = 10;
		ParentRef.AdjustNativeValue(5, Value);
		ScriptAdjustedValue = Value;
	}
}
)AS"),
		TEXT("ATestInterfaceNativeReferenceRoundTripCppBridgeState"));
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

	BeginPlayActor(Engine, *Actor);

	int32 ScriptAdjustedValue = 0;
	int32 AdjustCallCount = 0;
	int32 LastAdjustedValue = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("ScriptAdjustedValue"), ScriptAdjustedValue)
		|| !ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("AdjustCallCount"), AdjustCallCount)
		|| !ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("LastAdjustedValue"), LastAdjustedValue))
	{
		break;
	}

	if (!TestEqual(TEXT("Script-side native interface call should still round-trip ref parameters"), ScriptAdjustedValue, 15))
	{
		break;
	}
	if (!TestEqual(TEXT("Script-side BeginPlay route should increment the adjust call count once"), AdjustCallCount, 1))
	{
		break;
	}
	if (!TestEqual(TEXT("Script-side BeginPlay route should persist the last adjusted value on the actor state"), LastAdjustedValue, 15))
	{
		break;
	}

	int32 CppAdjustedValue = 20;
	IAngelscriptNativeParentInterface::Execute_AdjustNativeValue(Actor, 7, CppAdjustedValue);
	if (!TestEqual(TEXT("C++ Execute_ bridge should still round-trip ref parameters through the script implementation"), CppAdjustedValue, 27))
	{
		break;
	}

	if (!ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("AdjustCallCount"), AdjustCallCount)
		|| !ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("LastAdjustedValue"), LastAdjustedValue))
	{
		break;
	}

	if (!TestEqual(TEXT("C++ Execute_ bridge should re-enter the script implementation and increment actor state"), AdjustCallCount, 2))
	{
		break;
	}
	if (!TestEqual(TEXT("C++ Execute_ bridge should update the actor's last adjusted value after mutating the caller buffer"), LastAdjustedValue, 27))
	{
		break;
	}

	}
	while (false);
	ASTEST_END_SHARE_FRESH

	return !HasAnyErrors();
}

bool FAngelscriptTestInterfaceNativeInheritedParentBridgeSetterAndRefTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH
	do
	{
	AngelscriptNativeInterfaceTestHelpers::EnsureNativeInterfaceBound(UAngelscriptNativeParentInterface::StaticClass());
	AngelscriptNativeInterfaceTestHelpers::EnsureNativeInterfaceBound(UAngelscriptNativeChildInterface::StaticClass());
	static const FName ModuleName(TEXT("TestInterfaceNativeInheritedParentBridge"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("TestInterfaceNativeInheritedParentBridge.as"),
		TEXT(R"AS(
UCLASS()
class ATestInterfaceNativeInheritedParentBridge : AActor, UAngelscriptNativeChildInterface
{
	UPROPERTY()
	FName NativeMarker = NAME_None;

	UPROPERTY()
	int ParentAdjustedValue = 0;

	UFUNCTION()
	int GetNativeValue() const
	{
		return 0;
	}

	UFUNCTION()
	void SetNativeMarker(FName Marker)
	{
		NativeMarker = Marker;
	}

	UFUNCTION()
	void AdjustNativeValue(int Delta, int& Value)
	{
		Value += Delta;
		ParentAdjustedValue = Value;
	}

	UFUNCTION()
	int GetChildValue() const
	{
		return 11;
	}
}
)AS"),
		TEXT("ATestInterfaceNativeInheritedParentBridge"));
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

	IAngelscriptNativeParentInterface::Execute_SetNativeMarker(Actor, TEXT("FromParentExecute"));

	int32 AdjustedValue = 20;
	IAngelscriptNativeParentInterface::Execute_AdjustNativeValue(Actor, 9, AdjustedValue);

	FName NativeMarker = NAME_None;
	int32 ParentAdjustedValue = 0;
	if (!ReadPropertyValue<FNameProperty>(*this, Actor, TEXT("NativeMarker"), NativeMarker)
		|| !ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("ParentAdjustedValue"), ParentAdjustedValue))
	{
		break;
	}

	TestEqual(TEXT("Parent Execute_ setter should dispatch through the child implementation"), NativeMarker, FName(TEXT("FromParentExecute")));
	TestEqual(TEXT("Parent Execute_ ref parameter should round-trip through the child implementation"), AdjustedValue, 29);
	TestEqual(TEXT("Child implementation should persist the adjusted parent-interface value"), ParentAdjustedValue, 29);

	}
	while (false);
	ASTEST_END_SHARE_FRESH

	return !HasAnyErrors();
}

#endif
