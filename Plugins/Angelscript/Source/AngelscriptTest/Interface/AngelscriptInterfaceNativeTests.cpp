#include "Core/AngelscriptBinds.h"
#include "Core/AngelscriptEngine.h"
#include "Shared/AngelscriptNativeInterfaceTestTypes.h"
#include "Shared/AngelscriptScenarioTestUtils.h"
#include "Shared/AngelscriptTestMacros.h"
#include "../../AngelscriptRuntime/Binds/BlueprintCallableReflectiveFallback.h"

#include "Components/ActorTestSpawner.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptScenarioTestUtils;

namespace AngelscriptTest_Interface_AngelscriptInterfaceNativeTests_Private
{
}

using namespace AngelscriptTest_Interface_AngelscriptInterfaceNativeTests_Private;

namespace AngelscriptTest_Interface_AngelscriptInterfaceNativeTests_Private
{
	void TestCallInterfaceMethod(asIScriptGeneric* Generic)
	{
		FInterfaceMethodSignature* Signature = static_cast<FInterfaceMethodSignature*>(Generic->GetFunction()->GetUserData());
		UObject* Object = static_cast<UObject*>(Generic->GetObject());
		if (Signature == nullptr || Object == nullptr)
		{
			return;
		}

		UFunction* RealFunc = Object->FindFunction(Signature->FunctionName);
		if (RealFunc == nullptr)
		{
			return;
		}

		InvokeReflectiveUFunctionFromGenericCall(Generic, Object, RealFunc);
	}

	void BindNativeInterfaceMethod(FAngelscriptBinds& Binds, const TCHAR* Declaration, const TCHAR* FunctionName)
	{
		FInterfaceMethodSignature* Signature = FAngelscriptEngine::Get().RegisterInterfaceMethodSignature(FName(FunctionName));
		Binds.GenericMethod(FString(Declaration), TestCallInterfaceMethod, Signature);
	}

	void EnsureNativeInterfaceBoundForTests(UClass* InterfaceClass)
	{
		if (InterfaceClass == nullptr)
		{
			return;
		}

		auto* ScriptEngine = FAngelscriptEngine::Get().Engine;
		const FString TypeName = FAngelscriptType::GetBoundClassName(InterfaceClass);
		if (ScriptEngine->GetTypeInfoByName(TCHAR_TO_ANSI(*TypeName)) != nullptr)
		{
			return;
		}

		FAngelscriptBinds Binds = FAngelscriptBinds::ReferenceClass(TypeName, InterfaceClass);
		auto* TypeInfo = (asCTypeInfo*)Binds.GetTypeInfo();
		if (TypeInfo != nullptr)
		{
			TypeInfo->plainUserData = (SIZE_T)InterfaceClass;
		}

		if (InterfaceClass == UAngelscriptNativeParentInterface::StaticClass())
		{
			BindNativeInterfaceMethod(Binds, TEXT("int GetNativeValue() const"), TEXT("GetNativeValue"));
			BindNativeInterfaceMethod(Binds, TEXT("void SetNativeMarker(FName Marker)"), TEXT("SetNativeMarker"));
			BindNativeInterfaceMethod(Binds, TEXT("void AdjustNativeValue(int Delta, int& Value)"), TEXT("AdjustNativeValue"));
		}
		else if (InterfaceClass == UAngelscriptNativeChildInterface::StaticClass())
		{
			BindNativeInterfaceMethod(Binds, TEXT("int GetChildValue() const"), TEXT("GetChildValue"));
		}
	}

	void EnsureNativeInterfaceFixturesBound()
	{
		EnsureNativeInterfaceBoundForTests(UAngelscriptNativeParentInterface::StaticClass());
		EnsureNativeInterfaceBoundForTests(UAngelscriptNativeChildInterface::StaticClass());
	}
}

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioInterfaceNativeImplementTest,
	"Angelscript.TestModule.Interface.NativeImplement",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioInterfaceNativeInheritedImplementTest,
	"Angelscript.TestModule.Interface.NativeInheritedImplement",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioInterfaceNativeReferenceRoundTripTest,
	"Angelscript.TestModule.Interface.NativeReferenceRoundTrip",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioInterfaceNativeReferenceRoundTripCppBridgeMutatesActorStateTest,
	"Angelscript.TestModule.Interface.NativeReferenceRoundTrip.CppBridgeMutatesActorState",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioInterfaceNativeInheritedParentBridgeSetterAndRefTest,
	"Angelscript.TestModule.Interface.NativeInheritedImplement.ParentBridgeSetterAndRef",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptScenarioInterfaceNativeImplementTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH
	static const FName ModuleName(TEXT("ScenarioInterfaceNativeImplement"));
	EnsureNativeInterfaceFixturesBound();
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioInterfaceNativeImplement.as"),
		TEXT(R"AS(
UCLASS()
class AScenarioInterfaceNativeImplement : AActor, UAngelscriptNativeParentInterface
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
		TEXT("AScenarioInterfaceNativeImplement"));
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

	BeginPlayActor(Engine, *Actor);

	TestTrue(TEXT("Script actor should implement native parent interface"), ScriptClass->ImplementsInterface(UAngelscriptNativeParentInterface::StaticClass()));

	int32 ParentCastWorked = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("ParentCastWorked"), ParentCastWorked))
	{
		return false;
	}
	TestEqual(TEXT("Cast to native parent interface should succeed in script"), ParentCastWorked, 1);

	int32 NativeValue = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("NativeValue"), NativeValue))
	{
		return false;
	}
	TestEqual(TEXT("Script-side native interface call should preserve the returned value"), NativeValue, 123);

	FName NativeMarker = NAME_None;
	if (!ReadPropertyValue<FNameProperty>(*this, Actor, TEXT("NativeMarker"), NativeMarker))
	{
		return false;
	}
	TestEqual(TEXT("Script-side native interface setter should run through the interface reference"), NativeMarker, FName(TEXT("FromScript")));

	TestEqual(TEXT("C++ Execute_ bridge should call the script implementation of GetNativeValue"),
		IAngelscriptNativeParentInterface::Execute_GetNativeValue(Actor), 123);
	IAngelscriptNativeParentInterface::Execute_SetNativeMarker(Actor, TEXT("FromCpp"));

	if (!ReadPropertyValue<FNameProperty>(*this, Actor, TEXT("NativeMarker"), NativeMarker))
	{
		return false;
	}
	TestEqual(TEXT("C++ Execute_ bridge should call the script implementation of SetNativeMarker"), NativeMarker, FName(TEXT("FromCpp")));

	ASTEST_END_SHARE_FRESH

	return true;
}

bool FAngelscriptScenarioInterfaceNativeInheritedImplementTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH
	static const FName ModuleName(TEXT("ScenarioInterfaceNativeInheritedImplement"));
	EnsureNativeInterfaceFixturesBound();
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioInterfaceNativeInheritedImplement.as"),
		TEXT(R"AS(
UCLASS()
class AScenarioInterfaceNativeInheritedImplement : AActor, UAngelscriptNativeChildInterface
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
		TEXT("AScenarioInterfaceNativeInheritedImplement"));
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
		return false;
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

	ASTEST_END_SHARE_FRESH

	return true;
}

bool FAngelscriptScenarioInterfaceNativeReferenceRoundTripTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH
	static const FName ModuleName(TEXT("ScenarioInterfaceNativeReferenceRoundTrip"));
	EnsureNativeInterfaceFixturesBound();
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioInterfaceNativeReferenceRoundTrip.as"),
		TEXT(R"AS(
UCLASS()
class AScenarioInterfaceNativeReferenceRoundTrip : AActor, UAngelscriptNativeParentInterface
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
		TEXT("AScenarioInterfaceNativeReferenceRoundTrip"));
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

	BeginPlayActor(Engine, *Actor);

	int32 ScriptAdjustedValue = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("ScriptAdjustedValue"), ScriptAdjustedValue))
	{
		return false;
	}
	TestEqual(TEXT("Script-side native interface call should round-trip ref parameters"), ScriptAdjustedValue, 15);

	int32 CppAdjustedValue = 20;
	IAngelscriptNativeParentInterface::Execute_AdjustNativeValue(Actor, 7, CppAdjustedValue);
	TestEqual(TEXT("C++ Execute_ bridge should round-trip ref parameters through the script implementation"), CppAdjustedValue, 27);

	ASTEST_END_SHARE_FRESH

	return true;
}

bool FAngelscriptScenarioInterfaceNativeReferenceRoundTripCppBridgeMutatesActorStateTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH
	static const FName ModuleName(TEXT("ScenarioInterfaceNativeReferenceRoundTripCppBridgeState"));
	EnsureNativeInterfaceFixturesBound();
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioInterfaceNativeReferenceRoundTripCppBridgeState.as"),
		TEXT(R"AS(
UCLASS()
class AScenarioInterfaceNativeReferenceRoundTripCppBridgeState : AActor, UAngelscriptNativeParentInterface
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
		TEXT("AScenarioInterfaceNativeReferenceRoundTripCppBridgeState"));
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

	BeginPlayActor(Engine, *Actor);

	int32 ScriptAdjustedValue = 0;
	int32 AdjustCallCount = 0;
	int32 LastAdjustedValue = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("ScriptAdjustedValue"), ScriptAdjustedValue)
		|| !ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("AdjustCallCount"), AdjustCallCount)
		|| !ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("LastAdjustedValue"), LastAdjustedValue))
	{
		return false;
	}

	if (!TestEqual(TEXT("Script-side native interface call should still round-trip ref parameters"), ScriptAdjustedValue, 15))
	{
		return false;
	}
	if (!TestEqual(TEXT("Script-side BeginPlay route should increment the adjust call count once"), AdjustCallCount, 1))
	{
		return false;
	}
	if (!TestEqual(TEXT("Script-side BeginPlay route should persist the last adjusted value on the actor state"), LastAdjustedValue, 15))
	{
		return false;
	}

	int32 CppAdjustedValue = 20;
	IAngelscriptNativeParentInterface::Execute_AdjustNativeValue(Actor, 7, CppAdjustedValue);
	if (!TestEqual(TEXT("C++ Execute_ bridge should still round-trip ref parameters through the script implementation"), CppAdjustedValue, 27))
	{
		return false;
	}

	if (!ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("AdjustCallCount"), AdjustCallCount)
		|| !ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("LastAdjustedValue"), LastAdjustedValue))
	{
		return false;
	}

	if (!TestEqual(TEXT("C++ Execute_ bridge should re-enter the script implementation and increment actor state"), AdjustCallCount, 2))
	{
		return false;
	}
	if (!TestEqual(TEXT("C++ Execute_ bridge should update the actor's last adjusted value after mutating the caller buffer"), LastAdjustedValue, 27))
	{
		return false;
	}

	ASTEST_END_SHARE_FRESH

	return true;
}

bool FAngelscriptScenarioInterfaceNativeInheritedParentBridgeSetterAndRefTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH
	static const FName ModuleName(TEXT("ScenarioInterfaceNativeInheritedParentBridge"));
	EnsureNativeInterfaceFixturesBound();
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioInterfaceNativeInheritedParentBridge.as"),
		TEXT(R"AS(
UCLASS()
class AScenarioInterfaceNativeInheritedParentBridge : AActor, UAngelscriptNativeChildInterface
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
		TEXT("AScenarioInterfaceNativeInheritedParentBridge"));
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

	IAngelscriptNativeParentInterface::Execute_SetNativeMarker(Actor, TEXT("FromParentExecute"));

	int32 AdjustedValue = 20;
	IAngelscriptNativeParentInterface::Execute_AdjustNativeValue(Actor, 9, AdjustedValue);

	FName NativeMarker = NAME_None;
	int32 ParentAdjustedValue = 0;
	if (!ReadPropertyValue<FNameProperty>(*this, Actor, TEXT("NativeMarker"), NativeMarker)
		|| !ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("ParentAdjustedValue"), ParentAdjustedValue))
	{
		return false;
	}

	TestEqual(TEXT("Parent Execute_ setter should dispatch through the child implementation"), NativeMarker, FName(TEXT("FromParentExecute")));
	TestEqual(TEXT("Parent Execute_ ref parameter should round-trip through the child implementation"), AdjustedValue, 29);
	TestEqual(TEXT("Child implementation should persist the adjusted parent-interface value"), ParentAdjustedValue, 29);

	ASTEST_END_SHARE_FRESH

	return true;
}

#endif
