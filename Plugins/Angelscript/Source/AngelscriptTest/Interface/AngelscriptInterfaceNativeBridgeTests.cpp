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

namespace InterfaceNativeBridgeTests
{
	static const FName ModuleName(TEXT("ScenarioInterfaceNativeCppImplementerBridge"));
	static const FString ScriptFilename(TEXT("ScenarioInterfaceNativeCppImplementerBridge.as"));
	static const FName GeneratedClassName(TEXT("AScenarioInterfaceNativeCppImplementerBridge"));
	static const FName TargetPropertyName(TEXT("Target"));
	static const FName CastSucceededPropertyName(TEXT("bCastSucceeded"));
	static const FName ReadValuePropertyName(TEXT("ReadValue"));
	static const FName AdjustedValuePropertyName(TEXT("AdjustedValue"));

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

	void EnsureNativeInterfaceFixturesBound()
	{
		UClass* InterfaceClass = UAngelscriptNativeParentInterface::StaticClass();
		if (InterfaceClass == nullptr)
		{
			return;
		}

		asIScriptEngine* ScriptEngine = FAngelscriptEngine::Get().Engine;
		if (ScriptEngine == nullptr)
		{
			return;
		}

		const FString TypeName = FAngelscriptType::GetBoundClassName(InterfaceClass);
		if (ScriptEngine->GetTypeInfoByName(TCHAR_TO_ANSI(*TypeName)) != nullptr)
		{
			return;
		}

		FAngelscriptBinds Binds = FAngelscriptBinds::ReferenceClass(TypeName, InterfaceClass);
		asCTypeInfo* TypeInfo = static_cast<asCTypeInfo*>(Binds.GetTypeInfo());
		if (TypeInfo != nullptr)
		{
			TypeInfo->plainUserData = reinterpret_cast<SIZE_T>(InterfaceClass);
		}

		BindNativeInterfaceMethod(Binds, TEXT("int GetNativeValue() const"), TEXT("GetNativeValue"));
		BindNativeInterfaceMethod(Binds, TEXT("void SetNativeMarker(FName Marker)"), TEXT("SetNativeMarker"));
		BindNativeInterfaceMethod(Binds, TEXT("void AdjustNativeValue(int Delta, int& Value)"), TEXT("AdjustNativeValue"));
	}

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
	FAngelscriptScenarioInterfaceNativeImplementCppImplementerScriptCallTest,
	"Angelscript.TestModule.Interface.NativeImplement.CppImplementerScriptCall",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptScenarioInterfaceNativeImplementCppImplementerScriptCallTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH

	InterfaceNativeBridgeTests::EnsureNativeInterfaceFixturesBound();

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
class AScenarioInterfaceNativeCppImplementerBridge : AActor
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
	if (ScriptClass == nullptr)
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();

	ATestNativeParentInterfaceActor* NativeFixtureActor = Spawner.GetWorld().SpawnActor<ATestNativeParentInterfaceActor>();
	AActor* ScriptActor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (!TestNotNull(TEXT("Native interface bridge fixture actor should spawn"), NativeFixtureActor)
		|| !TestNotNull(TEXT("Native interface bridge script actor should spawn"), ScriptActor))
	{
		return false;
	}

	if (!InterfaceNativeBridgeTests::SetObjectReferenceProperty(
		*this,
		ScriptActor,
		InterfaceNativeBridgeTests::TargetPropertyName,
		NativeFixtureActor,
		TEXT("Native interface bridge script actor")))
	{
		return false;
	}

	BeginPlayActor(Engine, *ScriptActor);

	int32 bCastSucceeded = 0;
	int32 ReadValue = 0;
	int32 AdjustedValue = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, ScriptActor, InterfaceNativeBridgeTests::CastSucceededPropertyName, bCastSucceeded)
		|| !ReadPropertyValue<FIntProperty>(*this, ScriptActor, InterfaceNativeBridgeTests::ReadValuePropertyName, ReadValue)
		|| !ReadPropertyValue<FIntProperty>(*this, ScriptActor, InterfaceNativeBridgeTests::AdjustedValuePropertyName, AdjustedValue))
	{
		return false;
	}

	TestEqual(TEXT("Script-side cast to a pure C++ native interface implementer should succeed"), bCastSucceeded, 1);
	TestEqual(TEXT("Script-side interface getter should dispatch to the C++ implementer"), ReadValue, 123);
	TestEqual(TEXT("Script-side ref parameter bridge should write back the adjusted value"), AdjustedValue, 15);
	TestEqual(TEXT("Script-side interface setter should update the C++ implementer marker"), NativeFixtureActor->NativeMarker, FName(TEXT("FromScript")));
	TestEqual(TEXT("C++ fixture should observe the delta passed through the interface bridge"), NativeFixtureActor->LastAdjustmentDelta, 5);
	TestEqual(TEXT("C++ fixture should observe the final ref value written by the interface bridge"), NativeFixtureActor->LastAdjustedValue, 15);

	ASTEST_END_SHARE_FRESH
	return true;
}

#endif
