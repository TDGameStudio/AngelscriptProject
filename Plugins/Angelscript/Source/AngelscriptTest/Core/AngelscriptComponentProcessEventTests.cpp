#include "Shared/AngelscriptScenarioTestUtils.h"
#include "Shared/AngelscriptTestMacros.h"

#include "ClassGenerator/ASClass.h"
#include "Core/AngelscriptComponent.h"
#include "Components/ActorTestSpawner.h"
#include "GameFramework/Actor.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"
#include "UObject/CoreNet.h"
#include "UObject/StructOnScope.h"
#include "UObject/UnrealType.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptScenarioTestUtils;

namespace AngelscriptTest_Core_AngelscriptComponentProcessEventTests_Private
{
	static const FName ProcessEventModuleName(TEXT("ComponentProcessEventValidate"));
	static const FString ProcessEventFilename(TEXT("ComponentProcessEventValidate.as"));
	static const FName ProcessEventClassName(TEXT("UComponentProcessEventValidate"));
	static const FName ServerFunctionName(TEXT("Server_RecordValue"));
	static const FName ValidateFunctionName(TEXT("Server_RecordValue_Validate"));
	static const FName ValidateCallsPropertyName(TEXT("ValidateCalls"));
	static const FName BodyCallsPropertyName(TEXT("BodyCalls"));
	static const FName LastAcceptedValuePropertyName(TEXT("LastAcceptedValue"));
	static constexpr int32 AcceptedValue = 7;
	static constexpr int32 RejectedValue = -3;

	UAngelscriptComponent* CreateProcessEventScenarioComponent(
		FAutomationTestBase& Test,
		AActor& OwnerActor,
		UClass* ComponentClass)
	{
		if (!Test.TestNotNull(TEXT("Component ProcessEvent scenario should compile to a valid component class"), ComponentClass))
		{
			return nullptr;
		}

		UActorComponent* Component = NewObject<UActorComponent>(&OwnerActor, ComponentClass);
		if (!Test.TestNotNull(TEXT("Component ProcessEvent scenario should instantiate a runtime component"), Component))
		{
			return nullptr;
		}

		OwnerActor.AddInstanceComponent(Component);
		Component->OnComponentCreated();
		Component->RegisterComponent();
		Component->Activate(true);

		UAngelscriptComponent* TypedComponent = Cast<UAngelscriptComponent>(Component);
		if (!Test.TestNotNull(TEXT("Component ProcessEvent scenario should instantiate a UAngelscriptComponent"), TypedComponent))
		{
			return nullptr;
		}

		return TypedComponent;
	}

	bool InvokeServerRecordValue(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		UAngelscriptComponent& Component,
		UFunction& Function,
		int32 InValue)
	{
		FStructOnScope FunctionParameters(&Function);
		uint8* ParametersMemory = FunctionParameters.GetStructMemory();
		if (!Test.TestNotNull(TEXT("Component ProcessEvent scenario should allocate parameter storage"), ParametersMemory))
		{
			return false;
		}

		FIntProperty* ValueProperty = FindFProperty<FIntProperty>(&Function, TEXT("Value"));
		if (!Test.TestNotNull(TEXT("Component ProcessEvent scenario should expose the RPC value parameter"), ValueProperty))
		{
			return false;
		}

		ValueProperty->SetPropertyValue_InContainer(ParametersMemory, InValue);

		FAngelscriptEngineScope ExecutionScope(Engine, &Component);
		Component.ProcessEvent(&Function, ParametersMemory);
		return true;
	}

	bool ExpectIntPropertyValue(
		FAutomationTestBase& Test,
		UObject& Object,
		FName PropertyName,
		int32 ExpectedValue,
		const TCHAR* Context)
	{
		int32 ActualValue = 0;
		if (!ReadPropertyValue<FIntProperty>(Test, &Object, PropertyName, ActualValue))
		{
			return false;
		}

		return Test.TestEqual(Context, ActualValue, ExpectedValue);
	}
}

using namespace AngelscriptTest_Core_AngelscriptComponentProcessEventTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptComponentProcessEventWithValidationTest,
	"Angelscript.TestModule.Engine.Component.ProcessEvent.WithValidationRoutesValidateBeforeRpcBody",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptComponentProcessEventWithValidationTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ProcessEventModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ProcessEventModuleName,
		ProcessEventFilename,
		TEXT(R"AS(
UCLASS()
class UComponentProcessEventValidate : UAngelscriptComponent
{
	UPROPERTY()
	int ValidateCalls = 0;

	UPROPERTY()
	int BodyCalls = 0;

	UPROPERTY()
	int LastAcceptedValue = -1;

	UFUNCTION(Server, WithValidation)
	void Server_RecordValue(int Value)
	{
		BodyCalls += 1;
		LastAcceptedValue = Value;
	}

	UFUNCTION()
	bool Server_RecordValue_Validate(int Value)
	{
		ValidateCalls += 1;
		return Value >= 0;
	}
}
)AS"),
		ProcessEventClassName);
	if (ScriptClass == nullptr)
	{
		return false;
	}

	UFunction* ServerFunction = FindGeneratedFunction(ScriptClass, ServerFunctionName);
	UASFunction* GeneratedServerFunction = Cast<UASFunction>(ServerFunction);
	if (!TestNotNull(TEXT("Component ProcessEvent scenario should generate the server RPC"), ServerFunction)
		|| !TestNotNull(TEXT("Component ProcessEvent scenario should expose the server RPC as UASFunction"), GeneratedServerFunction))
	{
		return false;
	}

	UFunction* ValidateFunction = GeneratedServerFunction->GetRuntimeValidateFunction();
	if (!TestNotNull(TEXT("Component ProcessEvent scenario should cache the _Validate companion function"), ValidateFunction))
	{
		return false;
	}

	TestTrue(TEXT("Component ProcessEvent scenario should mark the generated RPC as requiring validation"), ServerFunction->HasAnyFunctionFlags(FUNC_NetValidate));
	TestTrue(TEXT("Component ProcessEvent scenario should resolve the expected _Validate function"), ValidateFunction->GetFName() == ValidateFunctionName);

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor& HostActor = Spawner.SpawnActor<AActor>();
	UAngelscriptComponent* Component = CreateProcessEventScenarioComponent(*this, HostActor, ScriptClass);
	if (Component == nullptr)
	{
		return false;
	}

	BeginPlayActor(Engine, HostActor);

	RPC_ResetLastFailedReason();
	if (!InvokeServerRecordValue(*this, Engine, *Component, *ServerFunction, AcceptedValue))
	{
		return false;
	}

	if (!ExpectIntPropertyValue(
			*this,
			*Component,
			ValidateCallsPropertyName,
			1,
			TEXT("Component ProcessEvent should call the _Validate companion before accepting the RPC"))
		|| !ExpectIntPropertyValue(
			*this,
			*Component,
			BodyCallsPropertyName,
			1,
			TEXT("Component ProcessEvent should execute the RPC body when validation passes"))
		|| !ExpectIntPropertyValue(
			*this,
			*Component,
			LastAcceptedValuePropertyName,
			AcceptedValue,
			TEXT("Component ProcessEvent should persist the accepted RPC payload")))
	{
		return false;
	}

	TestTrue(TEXT("Component ProcessEvent should not record a validation failure for accepted input"), RPC_GetLastFailedReason() == nullptr);

	RPC_ResetLastFailedReason();
	if (!InvokeServerRecordValue(*this, Engine, *Component, *ServerFunction, RejectedValue))
	{
		return false;
	}

	if (!ExpectIntPropertyValue(
			*this,
			*Component,
			ValidateCallsPropertyName,
			2,
			TEXT("Component ProcessEvent should call the _Validate companion again for rejected input"))
		|| !ExpectIntPropertyValue(
			*this,
			*Component,
			BodyCallsPropertyName,
			1,
			TEXT("Component ProcessEvent should not execute the RPC body when validation fails"))
		|| !ExpectIntPropertyValue(
			*this,
			*Component,
			LastAcceptedValuePropertyName,
			AcceptedValue,
			TEXT("Component ProcessEvent should preserve the last accepted payload after validation failure")))
	{
		return false;
	}

	const TCHAR* FailedReason = RPC_GetLastFailedReason();
	if (!TestNotNull(TEXT("Component ProcessEvent should record the failed validation function name"), FailedReason))
	{
		return false;
	}

	TestEqual(TEXT("Component ProcessEvent should report the _Validate function name on validation failure"), FString(FailedReason), ValidateFunctionName.ToString());

	ASTEST_END_SHARE_CLEAN
	return true;
}

#endif
