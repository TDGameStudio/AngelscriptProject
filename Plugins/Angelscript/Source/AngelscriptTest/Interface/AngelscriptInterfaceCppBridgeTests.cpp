#include "Shared/AngelscriptScenarioTestUtils.h"
#include "Shared/AngelscriptTestMacros.h"

#include "ClassGenerator/ASClass.h"
#include "Components/ActorTestSpawner.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"
#include "UObject/Class.h"
#include "UObject/UnrealType.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptScenarioTestUtils;

namespace AngelscriptTest_Interface_AngelscriptInterfaceCppBridgeTests_Private
{
	static const FName ModuleName(TEXT("ScenarioInterfaceCppBridgeReferenceArg"));
	static const FString ScriptFilename(TEXT("ScenarioInterfaceCppBridgeReferenceArg.as"));
	static const FName GeneratedClassName(TEXT("AScenarioInterfaceRefBridgeActor"));
	static const FName GeneratedInterfaceName(TEXT("UICppRefBridge"));
	static const FName FunctionName(TEXT("AdjustValue"));
	static const FName ValuePropertyName(TEXT("Value"));
	static const FName LastAdjustedPropertyName(TEXT("LastAdjusted"));

	struct FAdjustValueParms
	{
		int32 Value = 0;
	};

	static_assert(sizeof(FAdjustValueParms) == sizeof(int32), "ProcessEvent parameter carrier should match the single int32 argument layout.");

	UFunction* RequireGeneratedFunction(
		FAutomationTestBase& Test,
		UClass* OwnerClass,
		FName InFunctionName,
		const TCHAR* Context)
	{
		UFunction* Function = FindGeneratedFunction(OwnerClass, InFunctionName);
		Test.TestNotNull(
			*FString::Printf(TEXT("%s should find generated function '%s'"), Context, *InFunctionName.ToString()),
			Function);
		return Function;
	}

	bool InvokeGeneratedFunction(
		FAngelscriptEngine& Engine,
		FAutomationTestBase& Test,
		UObject* Object,
		UFunction* Function,
		void* Parms,
		const TCHAR* Context)
	{
		if (!Test.TestNotNull(*FString::Printf(TEXT("%s should have a valid object"), Context), Object))
		{
			return false;
		}

		if (!Test.TestNotNull(*FString::Printf(TEXT("%s should have a valid function"), Context), Function))
		{
			return false;
		}

		FAngelscriptEngineScope FunctionScope(Engine, Object);
		Object->ProcessEvent(Function, Parms);
		return true;
	}

	bool ValidateReferenceParameterShape(
		FAutomationTestBase& Test,
		UFunction* Function)
	{
		FIntProperty* ValueProperty = FindFProperty<FIntProperty>(Function, ValuePropertyName);
		if (!Test.TestNotNull(TEXT("Cpp interface ProcessEvent reference-arg bridge should expose the reflected int parameter"), ValueProperty))
		{
			return false;
		}

		const bool bUsesReferenceBridge = Function->IsA<UASFunction_ReferenceArg>() || Function->IsA<UASFunction_ReferenceArg_JIT>();
		Test.TestTrue(TEXT("Cpp interface ProcessEvent reference-arg bridge should use UASFunction_ReferenceArg or its JIT variant"), bUsesReferenceBridge);
		Test.TestEqual(TEXT("Cpp interface ProcessEvent reference-arg bridge should use a one-int parameter struct"), static_cast<int32>(Function->ParmsSize), static_cast<int32>(sizeof(FAdjustValueParms)));
		Test.TestTrue(TEXT("Cpp interface ProcessEvent reference-arg bridge should mark the parameter as CPF_Parm"), ValueProperty->HasAnyPropertyFlags(CPF_Parm));
		Test.TestTrue(TEXT("Cpp interface ProcessEvent reference-arg bridge should mark the parameter as CPF_OutParm"), ValueProperty->HasAnyPropertyFlags(CPF_OutParm));
		Test.TestTrue(TEXT("Cpp interface ProcessEvent reference-arg bridge should mark the parameter as CPF_ReferenceParm"), ValueProperty->HasAnyPropertyFlags(CPF_ReferenceParm));
		return bUsesReferenceBridge;
	}
}

using namespace AngelscriptTest_Interface_AngelscriptInterfaceCppBridgeTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioInterfaceCppInterfaceProcessEventReferenceArgRoundTripTest,
	"Angelscript.TestModule.Interface.CppInterface.ProcessEventReferenceArgRoundTrip",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptScenarioInterfaceCppInterfaceProcessEventReferenceArgRoundTripTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH
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
UINTERFACE()
interface UICppRefBridge
{
	void AdjustValue(int& Value);
}

UCLASS()
class AScenarioInterfaceRefBridgeActor : AActor, UICppRefBridge
{
	UPROPERTY()
	int LastAdjusted = -1;

	UFUNCTION()
	void AdjustValue(int& Value)
	{
		Value += 7;
		LastAdjusted = Value;
	}
}
)AS"),
		GeneratedClassName);
	if (ScriptClass == nullptr)
	{
		return false;
	}

	UClass* InterfaceClass = FindGeneratedClass(&Engine, GeneratedInterfaceName);
	TestNotNull(TEXT("Cpp interface ProcessEvent reference-arg bridge should generate the interface class"), InterfaceClass);
	if (InterfaceClass != nullptr)
	{
		TestTrue(TEXT("Cpp interface ProcessEvent reference-arg bridge should have the actor implement the generated interface"), ScriptClass->ImplementsInterface(InterfaceClass));
	}

	UFunction* AdjustValueFunction = RequireGeneratedFunction(
		*this,
		ScriptClass,
		FunctionName,
		TEXT("Cpp interface ProcessEvent reference-arg bridge"));
	if (AdjustValueFunction == nullptr)
	{
		return false;
	}

	if (!ValidateReferenceParameterShape(*this, AdjustValueFunction))
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

	FAdjustValueParms AdjustValueParms;
	AdjustValueParms.Value = 5;
	if (!InvokeGeneratedFunction(
			Engine,
			*this,
			Actor,
			AdjustValueFunction,
			&AdjustValueParms,
			TEXT("Cpp interface ProcessEvent reference-arg bridge")))
	{
		return false;
	}

	int32 LastAdjusted = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, Actor, LastAdjustedPropertyName, LastAdjusted))
	{
		return false;
	}

	TestEqual(TEXT("Cpp interface ProcessEvent reference-arg bridge should write back the caller buffer"), AdjustValueParms.Value, 12);
	TestEqual(TEXT("Cpp interface ProcessEvent reference-arg bridge should persist the adjusted value on the script actor"), LastAdjusted, 12);

	ASTEST_END_SHARE_FRESH
	return true;
}

#endif
