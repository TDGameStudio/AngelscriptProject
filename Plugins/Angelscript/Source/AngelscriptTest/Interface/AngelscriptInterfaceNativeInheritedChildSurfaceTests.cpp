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

namespace InterfaceNativeInheritedChildSurfaceTests
{
	static const FName ModuleName(TEXT("ScenarioInterfaceNativeInheritedChildSurface"));
	static const FString ScriptFilename(TEXT("ScenarioInterfaceNativeInheritedChildSurface.as"));
	static const FName GeneratedClassName(TEXT("AScenarioInterfaceNativeInheritedChildSurface"));

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

		if (InterfaceClass == UAngelscriptNativeParentInterface::StaticClass())
		{
			BindNativeInterfaceMethod(Binds, TEXT("int GetNativeValue() const"), TEXT("GetNativeValue"));
			BindNativeInterfaceMethod(Binds, TEXT("void SetNativeMarker(FName Marker)"), TEXT("SetNativeMarker"));
			BindNativeInterfaceMethod(Binds, TEXT("void AdjustNativeValue(int Delta, int& Value)"), TEXT("AdjustNativeValue"));
		}
		else if (InterfaceClass == UAngelscriptNativeChildInterface::StaticClass())
		{
			BindNativeInterfaceMethod(Binds, TEXT("int GetNativeValue() const"), TEXT("GetNativeValue"));
			BindNativeInterfaceMethod(Binds, TEXT("void SetNativeMarker(FName Marker)"), TEXT("SetNativeMarker"));
			BindNativeInterfaceMethod(Binds, TEXT("void AdjustNativeValue(int Delta, int& Value)"), TEXT("AdjustNativeValue"));
			BindNativeInterfaceMethod(Binds, TEXT("int GetChildValue() const"), TEXT("GetChildValue"));
		}
	}

	void EnsureNativeInterfaceFixturesBound()
	{
		EnsureNativeInterfaceBoundForTests(UAngelscriptNativeParentInterface::StaticClass());
		EnsureNativeInterfaceBoundForTests(UAngelscriptNativeChildInterface::StaticClass());
	}
}

using namespace InterfaceNativeInheritedChildSurfaceTests;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioInterfaceNativeInheritedChildSurfaceIncludesParentMethodsTest,
	"Angelscript.TestModule.Interface.NativeInheritedImplement.ChildSurfaceIncludesParentMethods",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptScenarioInterfaceNativeInheritedChildSurfaceIncludesParentMethodsTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH

	InterfaceNativeInheritedChildSurfaceTests::EnsureNativeInterfaceFixturesBound();

	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*InterfaceNativeInheritedChildSurfaceTests::ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		InterfaceNativeInheritedChildSurfaceTests::ModuleName,
		InterfaceNativeInheritedChildSurfaceTests::ScriptFilename,
		TEXT(R"AS(
UCLASS()
class AScenarioInterfaceNativeInheritedChildSurface : AActor, UAngelscriptNativeChildInterface
{
	UPROPERTY()
	int ChildCastWorked = 0;

	UPROPERTY()
	int ChildParentResult = 0;

	UPROPERTY()
	int ChildAdjustedValue = 0;

	UPROPERTY()
	int ChildOwnResult = 0;

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
		UAngelscriptNativeChildInterface ChildRef = Cast<UAngelscriptNativeChildInterface>(Self);
		if (ChildRef == nullptr)
			return;

		ChildCastWorked = 1;
		ChildParentResult = ChildRef.GetNativeValue();
		int Value = 20;
		ChildRef.AdjustNativeValue(9, Value);
		ChildAdjustedValue = Value;
		ChildOwnResult = ChildRef.GetChildValue();
		ChildRef.SetNativeMarker(n"ChildRoute");
	}
}
)AS"),
		InterfaceNativeInheritedChildSurfaceTests::GeneratedClassName);
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

	int32 ChildCastWorked = 0;
	int32 ChildParentResult = 0;
	int32 ChildAdjustedValue = 0;
	int32 ChildOwnResult = 0;
	FName NativeMarker = NAME_None;
	if (!ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("ChildCastWorked"), ChildCastWorked)
		|| !ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("ChildParentResult"), ChildParentResult)
		|| !ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("ChildAdjustedValue"), ChildAdjustedValue)
		|| !ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("ChildOwnResult"), ChildOwnResult)
		|| !ReadPropertyValue<FNameProperty>(*this, Actor, TEXT("NativeMarker"), NativeMarker))
	{
		return false;
	}

	TestTrue(TEXT("Script actor should implement native child interface"), ScriptClass->ImplementsInterface(UAngelscriptNativeChildInterface::StaticClass()));
	TestTrue(TEXT("Script actor implementing child interface should also satisfy native parent interface"), ScriptClass->ImplementsInterface(UAngelscriptNativeParentInterface::StaticClass()));
	TestEqual(TEXT("Script-side cast to native child interface should succeed"), ChildCastWorked, 1);
	TestEqual(TEXT("Child native interface ref should expose inherited parent getter"), ChildParentResult, 7);
	TestEqual(TEXT("Child native interface ref should expose inherited parent ref-parameter method"), ChildAdjustedValue, 29);
	TestEqual(TEXT("Child native interface ref should still expose child-owned methods"), ChildOwnResult, 11);
	TestEqual(TEXT("Child native interface ref should expose inherited parent setter"), NativeMarker, FName(TEXT("ChildRoute")));

	ASTEST_END_SHARE_FRESH
	return true;
}

#endif
