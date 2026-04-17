#include "Core/AngelscriptBinds.h"
#include "Core/AngelscriptEngine.h"
#include "Shared/AngelscriptNativeInterfaceTestTypes.h"
#include "Shared/AngelscriptScenarioTestUtils.h"
#include "Shared/AngelscriptTestMacros.h"

#include "ClassGenerator/AngelscriptClassGenerator.h"

#include "Components/ActorTestSpawner.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptScenarioTestUtils;

namespace InterfaceDispatchBridgeTests
{
	static const FName ModuleName(TEXT("ASInterfaceDispatchBridge"));
	static const FString ScriptFilename(TEXT("ASInterfaceDispatchBridge.as"));
	static const FName GeneratedClassName(TEXT("AInterfaceDispatchBridgeCarrier"));

	void BindProductionInterfaceMethod(FAngelscriptBinds& Binds, const TCHAR* Declaration, const TCHAR* FunctionName)
	{
		FInterfaceMethodSignature* Signature = FAngelscriptEngine::Get().RegisterInterfaceMethodSignature(FName(FunctionName));
		Binds.GenericMethod(FString(Declaration), CallInterfaceMethod, Signature);
	}

	void EnsureProductionNativeInterfaceBound(UClass* InterfaceClass)
	{
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

		BindProductionInterfaceMethod(Binds, TEXT("int GetNativeValue() const"), TEXT("GetNativeValue"));
		BindProductionInterfaceMethod(Binds, TEXT("void SetNativeMarker(FName Marker)"), TEXT("SetNativeMarker"));
		BindProductionInterfaceMethod(Binds, TEXT("void AdjustNativeValue(int Delta, int& Value)"), TEXT("AdjustNativeValue"));
	}

	void EnsureFixturesBound()
	{
		EnsureProductionNativeInterfaceBound(UAngelscriptNativeParentInterface::StaticClass());
	}
}

using namespace InterfaceDispatchBridgeTests;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptCallInterfaceMethodDispatchesToImplementingUFunctionTest,
	"Angelscript.TestModule.ClassGenerator.Interface.CallInterfaceMethodDispatchesToImplementingUFunction",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptCallInterfaceMethodDispatchesToImplementingUFunctionTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH

	InterfaceDispatchBridgeTests::EnsureFixturesBound();

	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*InterfaceDispatchBridgeTests::ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		InterfaceDispatchBridgeTests::ModuleName,
		InterfaceDispatchBridgeTests::ScriptFilename,
		TEXT(R"AS(
UCLASS()
class AInterfaceDispatchBridgeCarrier : AActor, UAngelscriptNativeParentInterface
{
	UPROPERTY()
	int ScriptObservedValue = 0;

	UPROPERTY()
	int ScriptAdjustedValue = 0;

	UPROPERTY()
	FName ScriptObservedMarker = NAME_None;

	UFUNCTION()
	int GetNativeValue() const
	{
		return 55;
	}

	UFUNCTION()
	void SetNativeMarker(FName Marker)
	{
		ScriptObservedMarker = Marker;
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

		ScriptObservedValue = ParentRef.GetNativeValue();

		int Value = 10;
		ParentRef.AdjustNativeValue(5, Value);
		ScriptAdjustedValue = Value;

		ParentRef.SetNativeMarker(n"BridgeHit");
	}
}
)AS"),
		InterfaceDispatchBridgeTests::GeneratedClassName);
	if (ScriptClass == nullptr)
	{
		return false;
	}

	TestTrue(
		TEXT("Production bridge scenario should generate a class that implements the native parent interface"),
		ScriptClass->ImplementsInterface(UAngelscriptNativeParentInterface::StaticClass()));

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();

	AActor* Actor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (Actor == nullptr)
	{
		return false;
	}

	BeginPlayActor(Engine, *Actor);

	int32 ScriptObservedValue = INDEX_NONE;
	int32 ScriptAdjustedValue = INDEX_NONE;
	FName ScriptObservedMarker = NAME_None;
	if (!ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("ScriptObservedValue"), ScriptObservedValue)
		|| !ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("ScriptAdjustedValue"), ScriptAdjustedValue)
		|| !ReadPropertyValue<FNameProperty>(*this, Actor, TEXT("ScriptObservedMarker"), ScriptObservedMarker))
	{
		return false;
	}

	TestEqual(
		TEXT("Production bridge should dispatch GetNativeValue through the implementing UFunction"),
		ScriptObservedValue,
		55);
	TestEqual(
		TEXT("Production bridge should round-trip ref parameters through the implementing UFunction"),
		ScriptAdjustedValue,
		15);
	TestEqual(
		TEXT("Production bridge should route void calls with payload arguments through the implementing UFunction"),
		ScriptObservedMarker,
		FName(TEXT("BridgeHit")));

	ASTEST_END_SHARE_FRESH
	return true;
}

#endif
