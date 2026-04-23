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

namespace InterfaceNativeBridgeTests
{
	static const FName ModuleName(TEXT("TestInterfaceNativeCppImplementerBridge"));
	static const FString ScriptFilename(TEXT("TestInterfaceNativeCppImplementerBridge.as"));
	static const FName GeneratedClassName(TEXT("ATestInterfaceNativeCppImplementerBridge"));
	static const FName TargetPropertyName(TEXT("Target"));
	static const FName CastSucceededPropertyName(TEXT("bCastSucceeded"));
	static const FName ReadValuePropertyName(TEXT("ReadValue"));
	static const FName AdjustedValuePropertyName(TEXT("AdjustedValue"));

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

using namespace InterfaceNativeBridgeTests;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestInterfaceNativeImplementCppImplementerScriptCallTest,
	"Angelscript.TestModule.Interface.NativeImplement.CppImplementerScriptCall",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptTestInterfaceNativeImplementCppImplementerScriptCallTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH
	do
	{

	AngelscriptNativeInterfaceTestHelpers::EnsureNativeInterfaceBound(UAngelscriptNativeParentInterface::StaticClass());

	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*InterfaceNativeBridgeTests::ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		InterfaceNativeBridgeTests::ModuleName,
		InterfaceNativeBridgeTests::ScriptFilename,
		TEXT(R"AS(
UCLASS()
class ATestInterfaceNativeCppImplementerBridge : AActor
{
	UPROPERTY()
	UObject Target;

	UPROPERTY()
	int bCastSucceeded = 0;

	UPROPERTY()
	int ReadValue = 0;

	UPROPERTY()
	int AdjustedValue = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		UAngelscriptNativeParentInterface ParentRef = Cast<UAngelscriptNativeParentInterface>(Target);
		if (ParentRef == nullptr)
			return;

		bCastSucceeded = 1;
		ReadValue = ParentRef.GetNativeValue();

		int Value = 10;
		ParentRef.AdjustNativeValue(5, Value);
		AdjustedValue = Value;

		ParentRef.SetNativeMarker(n"FromScript");
	}
}
)AS"),
		InterfaceNativeBridgeTests::GeneratedClassName);
	if (!TestNotNull(TEXT("ScriptClass should be valid"), ScriptClass))
	{
		break;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();

	ATestNativeParentInterfaceActor* NativeFixtureActor = Spawner.GetWorld().SpawnActor<ATestNativeParentInterfaceActor>();
	AActor* ScriptActor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (!TestNotNull(TEXT("Native interface bridge fixture actor should spawn"), NativeFixtureActor)
		|| !TestNotNull(TEXT("Native interface bridge script actor should spawn"), ScriptActor))
	{
		break;
	}

	if (!InterfaceNativeBridgeTests::SetObjectReferenceProperty(
		*this,
		ScriptActor,
		InterfaceNativeBridgeTests::TargetPropertyName,
		NativeFixtureActor,
		TEXT("Native interface bridge script actor")))
	{
		break;
	}

	BeginPlayActor(Engine, *ScriptActor);

	int32 bCastSucceeded = 0;
	int32 ReadValue = 0;
	int32 AdjustedValue = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, ScriptActor, InterfaceNativeBridgeTests::CastSucceededPropertyName, bCastSucceeded)
		|| !ReadPropertyValue<FIntProperty>(*this, ScriptActor, InterfaceNativeBridgeTests::ReadValuePropertyName, ReadValue)
		|| !ReadPropertyValue<FIntProperty>(*this, ScriptActor, InterfaceNativeBridgeTests::AdjustedValuePropertyName, AdjustedValue))
	{
		break;
	}

	TestEqual(TEXT("Script-side cast to a pure C++ native interface implementer should succeed"), bCastSucceeded, 1);
	TestEqual(TEXT("Script-side interface getter should dispatch to the C++ implementer"), ReadValue, 123);
	TestEqual(TEXT("Script-side ref parameter bridge should write back the adjusted value"), AdjustedValue, 15);
	TestEqual(TEXT("Script-side interface setter should update the C++ implementer marker"), NativeFixtureActor->NativeMarker, FName(TEXT("FromScript")));
	TestEqual(TEXT("C++ fixture should observe the delta passed through the interface bridge"), NativeFixtureActor->LastAdjustmentDelta, 5);
	TestEqual(TEXT("C++ fixture should observe the final ref value written by the interface bridge"), NativeFixtureActor->LastAdjustedValue, 15);

	}
	while (false);
	ASTEST_END_SHARE_FRESH
	return !HasAnyErrors();
}

#endif
