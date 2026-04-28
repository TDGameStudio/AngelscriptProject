#include "Core/AngelscriptEngine.h"
#include "Shared/AngelscriptNativeInterfaceTestTypes.h"
#include "Shared/AngelscriptNativeInterfaceTestHelpers.h"
#include "Shared/AngelscriptFunctionalTestUtils.h"
#include "Shared/AngelscriptTestMacros.h"

#include "Components/ActorTestSpawner.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

// Phase 2 regression tests for FScriptInterface pointer offset handling on
// C++ native implementing classes.
//
// When a C++ class implements more than one UInterface (or its chosen interface
// is not the first UObject-derived base), UE lays the interface vtable down at
// a non-zero `PointerOffset`. Correct behavior requires going through
// `UObject::GetInterfaceAddress(InterfaceClass)` to reach the interface pointer
// rather than assuming it coincides with the UObject pointer.
//
// These tests exercise the test case via `ATestNativeMultiInterfaceActor`
// (implements both Parent + Secondary native interfaces) and validate that:
//   1. Script-side `Cast<U...>(NativeActor)` succeeds for both interfaces.
//   2. Method dispatch through either interface reference lands in the
//      correct C++ `_Implementation` on the multi-interface actor.
//   3. State mutations made through each interface end up on the distinct
//      backing fields (Parent's NativeMarker vs Secondary's SecondaryLabel),
//      which would silently corrupt if the pointer offset were wrong.
//
// See `Plan_InterfaceParityWithCpp.md` Phase 2 / 3 for the broader context.
#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptFunctionalTestUtils;

namespace AngelscriptTest_InterfaceNativePointerOffset_Private
{
	static const FName ModuleName(TEXT("TestInterfaceNativePointerOffset"));
	static const FString ScriptFilename(TEXT("TestInterfaceNativePointerOffset.as"));
	static const FName GeneratedClassName(TEXT("ATestInterfaceNativePointerOffset"));
	static const FName TargetPropertyName(TEXT("Target"));
	static const FName ParentCastPropertyName(TEXT("bParentCastSucceeded"));
	static const FName SecondaryCastPropertyName(TEXT("bSecondaryCastSucceeded"));
	static const FName ParentReadValuePropertyName(TEXT("ParentReadValue"));
	static const FName SecondaryReadValuePropertyName(TEXT("SecondaryReadValue"));

	bool SetObjectReferenceProperty(
		FAutomationTestBase& Test,
		UObject* Object,
		FName PropertyName,
		UObject* ReferencedObject,
		const TCHAR* Context)
	{
		if (!Test.TestNotNull(*FString::Printf(TEXT("%s should have a valid object"), Context), Object))
		{
			return false;
		}

		FObjectPropertyBase* Property = FindFProperty<FObjectPropertyBase>(Object->GetClass(), PropertyName);
		if (!Test.TestNotNull(
			*FString::Printf(TEXT("%s should expose object property '%s'"), Context, *PropertyName.ToString()),
			Property))
		{
			return false;
		}

		Property->SetObjectPropertyValue_InContainer(Object, ReferencedObject);
		return true;
	}
}

using namespace AngelscriptTest_InterfaceNativePointerOffset_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestInterfaceNativePointerOffsetMultiInterfaceCastTest,
	"Angelscript.TestModule.Interface.NativePointerOffset.MultiInterfaceCast",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestInterfaceNativePointerOffsetScriptClassStillZeroOffsetTest,
	"Angelscript.TestModule.Interface.NativePointerOffset.ScriptClassStillZeroOffset",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptTestInterfaceNativePointerOffsetMultiInterfaceCastTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	do
	{

	AngelscriptNativeInterfaceTestHelpers::EnsureNativeInterfaceBound(UAngelscriptNativeParentInterface::StaticClass());
	AngelscriptNativeInterfaceTestHelpers::EnsureNativeInterfaceBound(UAngelscriptNativeSecondaryInterface::StaticClass());

	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		ScriptFilename,
		TEXT(R"AS(
UCLASS()
class ATestInterfaceNativePointerOffset : AActor
{
	UPROPERTY()
	UObject Target;

	UPROPERTY()
	int bParentCastSucceeded = 0;

	UPROPERTY()
	int bSecondaryCastSucceeded = 0;

	UPROPERTY()
	int ParentReadValue = 0;

	UPROPERTY()
	int SecondaryReadValue = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		UAngelscriptNativeParentInterface ParentRef = Cast<UAngelscriptNativeParentInterface>(Target);
		if (ParentRef != nullptr)
		{
			bParentCastSucceeded = 1;
			ParentReadValue = ParentRef.GetNativeValue();
			ParentRef.SetNativeMarker(n"FromParent");
		}

		UAngelscriptNativeSecondaryInterface SecondaryRef = Cast<UAngelscriptNativeSecondaryInterface>(Target);
		if (SecondaryRef != nullptr)
		{
			bSecondaryCastSucceeded = 1;
			SecondaryReadValue = SecondaryRef.GetSecondaryValue();
			SecondaryRef.SetSecondaryLabel("FromSecondary");
		}
	}
}
)AS"),
		GeneratedClassName);
	if (!TestNotNull(TEXT("ScriptClass should be valid"), ScriptClass))
	{
		break;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();

	ATestNativeMultiInterfaceActor* NativeFixtureActor = Spawner.GetWorld().SpawnActor<ATestNativeMultiInterfaceActor>();
	AActor* ScriptActor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (!TestNotNull(TEXT("Multi-interface native fixture actor should spawn"), NativeFixtureActor)
		|| !TestNotNull(TEXT("Script actor should spawn"), ScriptActor))
	{
		break;
	}

	if (!SetObjectReferenceProperty(
		*this,
		ScriptActor,
		TargetPropertyName,
		NativeFixtureActor,
		TEXT("Multi-interface native pointer offset script actor")))
	{
		break;
	}

	BeginPlayActor(Engine, *ScriptActor);

	int32 bParentCastSucceeded = 0;
	int32 bSecondaryCastSucceeded = 0;
	int32 ParentReadValue = 0;
	int32 SecondaryReadValue = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, ScriptActor, ParentCastPropertyName, bParentCastSucceeded)
		|| !ReadPropertyValue<FIntProperty>(*this, ScriptActor, SecondaryCastPropertyName, bSecondaryCastSucceeded)
		|| !ReadPropertyValue<FIntProperty>(*this, ScriptActor, ParentReadValuePropertyName, ParentReadValue)
		|| !ReadPropertyValue<FIntProperty>(*this, ScriptActor, SecondaryReadValuePropertyName, SecondaryReadValue))
	{
		break;
	}

	TestEqual(TEXT("Script-side Cast<UAngelscriptNativeParentInterface> should succeed on multi-interface native actor"), bParentCastSucceeded, 1);
	TestEqual(TEXT("Script-side Cast<UAngelscriptNativeSecondaryInterface> should succeed on multi-interface native actor"), bSecondaryCastSucceeded, 1);
	TestEqual(TEXT("Parent interface method dispatch returns the correct C++ field"), ParentReadValue, 777);
	TestEqual(TEXT("Secondary interface method dispatch returns the correct C++ field"), SecondaryReadValue, 4242);

	TestEqual(TEXT("Parent interface setter writes the correct C++ backing field"), NativeFixtureActor->NativeMarker, FName(TEXT("FromParent")));
	TestEqual(TEXT("Secondary interface setter writes the distinct C++ backing field"), NativeFixtureActor->SecondaryLabel, FString(TEXT("FromSecondary")));

	}
	while (false);
	ASTEST_END_SHARE_CLEAN
	return !HasAnyErrors();
}

bool FAngelscriptTestInterfaceNativePointerOffsetScriptClassStillZeroOffsetTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	do
	{

	AngelscriptNativeInterfaceTestHelpers::EnsureNativeInterfaceBound(UAngelscriptNativeParentInterface::StaticClass());

	static const FName ScriptOnlyModuleName(TEXT("TestInterfaceNativePointerOffsetScriptZero"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ScriptOnlyModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ScriptOnlyModuleName,
		TEXT("TestInterfaceNativePointerOffsetScriptZero.as"),
		TEXT(R"AS(
UCLASS()
class ATestInterfaceNativePointerOffsetScriptZero : AActor, UAngelscriptNativeParentInterface
{
	UPROPERTY()
	int NativeValue = 321;

	UPROPERTY()
	FName NativeMarker = NAME_None;

	UPROPERTY()
	int bSelfCastSucceeded = 0;

	UPROPERTY()
	int DispatchedValue = 0;

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
			bSelfCastSucceeded = 1;
			DispatchedValue = ParentRef.GetNativeValue();
			ParentRef.SetNativeMarker(n"FromSelf");
		}
	}
}
)AS"),
		TEXT("ATestInterfaceNativePointerOffsetScriptZero"));
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

	// Script-implemented interfaces have `PointerOffset == 0`; this test guards
	// the fast-path: Cast + dispatch must behave identically to the pre-Phase-2
	// behavior on script classes. Any regression here would indicate the new
	// `GetInterfacePointerForCast` helper accidentally perturbed the script path.
	UClass* ImplementedInterface = FindGeneratedClass(&Engine, TEXT("UAngelscriptNativeParentInterface"));
	if (ImplementedInterface == nullptr)
	{
		ImplementedInterface = UAngelscriptNativeParentInterface::StaticClass();
	}
	const FImplementedInterface* ImplementedEntry = Actor->GetClass()->Interfaces.FindByPredicate(
		[ImplementedInterface](const FImplementedInterface& Entry) { return Entry.Class == ImplementedInterface; });
	if (TestNotNull(TEXT("Implemented interface entry should exist on the script class"), ImplementedEntry))
	{
		TestEqual(TEXT("Script-implemented interface must keep PointerOffset == 0"), ImplementedEntry->PointerOffset, 0);
	}

	int32 bSelfCastSucceeded = 0;
	int32 DispatchedValue = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("bSelfCastSucceeded"), bSelfCastSucceeded)
		|| !ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("DispatchedValue"), DispatchedValue))
	{
		break;
	}

	TestEqual(TEXT("Script-implemented interface cast should still succeed after Phase 2"), bSelfCastSucceeded, 1);
	TestEqual(TEXT("Script-implemented interface dispatch should still return the script field"), DispatchedValue, 321);

	FName NativeMarker = NAME_None;
	if (!ReadPropertyValue<FNameProperty>(*this, Actor, TEXT("NativeMarker"), NativeMarker))
	{
		break;
	}
	TestEqual(TEXT("Script-implemented interface setter should still route through the script implementation"), NativeMarker, FName(TEXT("FromSelf")));

	}
	while (false);
	ASTEST_END_SHARE_CLEAN
	return !HasAnyErrors();
}

#endif
