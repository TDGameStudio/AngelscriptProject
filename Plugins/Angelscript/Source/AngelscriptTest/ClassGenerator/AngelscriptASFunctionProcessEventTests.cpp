#include "Shared/AngelscriptScenarioTestUtils.h"
#include "Shared/AngelscriptTestMacros.h"

#include "ClassGenerator/ASClass.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"
#include "UObject/StructOnScope.h"
#include "UObject/UObjectGlobals.h"
#include "UObject/UnrealType.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptScenarioTestUtils;

namespace ASFunctionProcessEventTests
{
	static const FName ModuleName(TEXT("ASFunctionProcessEvent"));
	static const FString ScriptFilename(TEXT("ASFunctionProcessEvent.as"));
	static const FName GeneratedClassName(TEXT("UProcessEventCarrier"));
	static const FName StoredValuePropertyName(TEXT("StoredValue"));

	UASClass* CompileProcessEventCarrier(FAutomationTestBase& Test, FAngelscriptEngine& Engine)
	{
		const FString ScriptSource = TEXT(R"AS(
UCLASS()
class UProcessEventCarrier : UObject
{
	UPROPERTY()
	int StoredValue = 0;

	UFUNCTION()
	int AddTen(int Input)
	{
		return Input + 10;
	}

	UFUNCTION()
	void SetStoredValue(int Input)
	{
		StoredValue = Input;
	}
}
)AS");

		UClass* GeneratedClass = CompileScriptModule(
			Test,
			Engine,
			ModuleName,
			ScriptFilename,
			ScriptSource,
			GeneratedClassName);
		if (GeneratedClass == nullptr)
		{
			return nullptr;
		}

		return Cast<UASClass>(GeneratedClass);
	}

	bool InvokeIntFunctionThroughProcessEvent(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		UObject* Object,
		UFunction* Function,
		int32 InputValue,
		int32& OutReturnValue)
	{
		FIntProperty* InputProperty = FindFProperty<FIntProperty>(Function, TEXT("Input"));
		FIntProperty* ReturnProperty = FindFProperty<FIntProperty>(Function, TEXT("ReturnValue"));
		if (!Test.TestNotNull(TEXT("ProcessEvent thunk scenario should expose the Input property"), InputProperty)
			|| !Test.TestNotNull(TEXT("ProcessEvent thunk scenario should expose the ReturnValue property"), ReturnProperty))
		{
			return false;
		}

		FStructOnScope Params(Function);
		void* ParamsMemory = Params.GetStructMemory();
		if (!Test.TestNotNull(TEXT("ProcessEvent thunk scenario should allocate a reflected parameter buffer"), ParamsMemory))
		{
			return false;
		}

		InputProperty->SetPropertyValue_InContainer(ParamsMemory, InputValue);

		FAngelscriptEngineScope FunctionScope(Engine, Object);
		Object->ProcessEvent(Function, ParamsMemory);

		OutReturnValue = ReturnProperty->GetPropertyValue_InContainer(ParamsMemory);
		return true;
	}

	bool InvokeVoidFunctionThroughProcessEvent(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		UObject* Object,
		UFunction* Function,
		int32 InputValue)
	{
		FIntProperty* InputProperty = FindFProperty<FIntProperty>(Function, TEXT("Input"));
		if (!Test.TestNotNull(TEXT("ProcessEvent thunk scenario should expose the Input property on the void function"), InputProperty))
		{
			return false;
		}

		FStructOnScope Params(Function);
		void* ParamsMemory = Params.GetStructMemory();
		if (!Test.TestNotNull(TEXT("ProcessEvent thunk scenario should allocate a reflected parameter buffer for the void function"), ParamsMemory))
		{
			return false;
		}

		InputProperty->SetPropertyValue_InContainer(ParamsMemory, InputValue);

		FAngelscriptEngineScope FunctionScope(Engine, Object);
		Object->ProcessEvent(Function, ParamsMemory);
		return true;
	}
}

using namespace ASFunctionProcessEventTests;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptASFunctionProcessEventDispatchesThroughNativeThunkTest,
	"Angelscript.TestModule.ClassGenerator.ASFunction.ProcessEventDispatchesThroughNativeThunk",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptASFunctionProcessEventDispatchesThroughNativeThunkTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH

	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ASFunctionProcessEventTests::ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UASClass* ScriptClass = ASFunctionProcessEventTests::CompileProcessEventCarrier(*this, Engine);
	if (!TestNotNull(TEXT("ProcessEvent thunk scenario should compile to a UASClass"), ScriptClass))
	{
		return false;
	}

	UFunction* AddTenFunction = FindGeneratedFunction(ScriptClass, TEXT("AddTen"));
	UFunction* SetStoredValueFunction = FindGeneratedFunction(ScriptClass, TEXT("SetStoredValue"));
	UASFunction* AddTenScriptFunction = Cast<UASFunction>(AddTenFunction);
	UASFunction* SetStoredValueScriptFunction = Cast<UASFunction>(SetStoredValueFunction);
	if (!TestNotNull(TEXT("ProcessEvent thunk scenario should generate AddTen"), AddTenFunction)
		|| !TestNotNull(TEXT("ProcessEvent thunk scenario should generate SetStoredValue"), SetStoredValueFunction)
		|| !TestNotNull(TEXT("ProcessEvent thunk scenario should expose AddTen as a UASFunction"), AddTenScriptFunction)
		|| !TestNotNull(TEXT("ProcessEvent thunk scenario should expose SetStoredValue as a UASFunction"), SetStoredValueScriptFunction))
	{
		return false;
	}

	TestTrue(TEXT("ProcessEvent thunk scenario should route AddTen through UASFunctionNativeThunk"), AddTenFunction->GetNativeFunc() == &UASFunctionNativeThunk);
	TestTrue(TEXT("ProcessEvent thunk scenario should route SetStoredValue through UASFunctionNativeThunk"), SetStoredValueFunction->GetNativeFunc() == &UASFunctionNativeThunk);

	UObject* Instance = NewObject<UObject>(GetTransientPackage(), ScriptClass, TEXT("ProcessEventCarrierInstance"));
	if (!TestNotNull(TEXT("ProcessEvent thunk scenario should instantiate the generated UObject"), Instance))
	{
		return false;
	}

	int32 AddTenResult = INDEX_NONE;
	if (!TestTrue(
			TEXT("ProcessEvent thunk scenario should execute AddTen via ProcessEvent"),
			ASFunctionProcessEventTests::InvokeIntFunctionThroughProcessEvent(*this, Engine, Instance, AddTenFunction, 5, AddTenResult))
		|| !TestEqual(TEXT("ProcessEvent thunk scenario should return 15 when AddTen receives 5"), AddTenResult, 15))
	{
		return false;
	}

	if (!TestTrue(
			TEXT("ProcessEvent thunk scenario should execute SetStoredValue via ProcessEvent"),
			ASFunctionProcessEventTests::InvokeVoidFunctionThroughProcessEvent(*this, Engine, Instance, SetStoredValueFunction, 17)))
	{
		return false;
	}

	int32 StoredValue = INDEX_NONE;
	if (!ReadPropertyValue<FIntProperty>(*this, Instance, ASFunctionProcessEventTests::StoredValuePropertyName, StoredValue))
	{
		return false;
	}

	TestEqual(TEXT("ProcessEvent thunk scenario should write StoredValue through RuntimeCallFunction"), StoredValue, 17);

	ASTEST_END_SHARE_FRESH
	return true;
}

#endif
