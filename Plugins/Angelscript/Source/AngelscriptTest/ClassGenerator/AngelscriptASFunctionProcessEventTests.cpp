#include "Shared/AngelscriptFunctionalTestUtils.h"
#include "Shared/AngelscriptTestMacros.h"

#include "CQTest.h"
#include "ClassGenerator/ASClass.h"
#include "Misc/ScopeExit.h"
#include "UObject/StructOnScope.h"
#include "UObject/UObjectGlobals.h"
#include "UObject/UnrealType.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptFunctionalTestUtils;

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
		if (!Test.TestNotNull(TEXT("ProcessEvent thunk test case should expose the Input property"), InputProperty)
			|| !Test.TestNotNull(TEXT("ProcessEvent thunk test case should expose the ReturnValue property"), ReturnProperty))
		{
			return false;
		}

		FStructOnScope Params(Function);
		void* ParamsMemory = Params.GetStructMemory();
		if (!Test.TestNotNull(TEXT("ProcessEvent thunk test case should allocate a reflected parameter buffer"), ParamsMemory))
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
		if (!Test.TestNotNull(TEXT("ProcessEvent thunk test case should expose the Input property on the void function"), InputProperty))
		{
			return false;
		}

		FStructOnScope Params(Function);
		void* ParamsMemory = Params.GetStructMemory();
		if (!Test.TestNotNull(TEXT("ProcessEvent thunk test case should allocate a reflected parameter buffer for the void function"), ParamsMemory))
		{
			return false;
		}

		InputProperty->SetPropertyValue_InContainer(ParamsMemory, InputValue);

		FAngelscriptEngineScope FunctionScope(Engine, Object);
		Object->ProcessEvent(Function, ParamsMemory);
		return true;
	}
}

TEST_CLASS_WITH_FLAGS(FAngelscriptASFunctionProcessEventTests,
	"Angelscript.TestModule.ClassGenerator.ASFunction",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
	TEST_METHOD(ProcessEventDispatchesThroughNativeThunk)
	{
		using namespace ASFunctionProcessEventTests;
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE();
		{ FAngelscriptEngineScope _AutoEngineScope(Engine);

		ON_SCOPE_EXIT
		{
			Engine.DiscardModule(*ASFunctionProcessEventTests::ModuleName.ToString());
			ResetSharedCloneEngine(Engine);
		};

		UASClass* ScriptClass = ASFunctionProcessEventTests::CompileProcessEventCarrier(*TestRunner, Engine);
		if (!TestRunner->TestNotNull(TEXT("ProcessEvent thunk test case should compile to a UASClass"), ScriptClass))
		{
			return;
		}

		UFunction* AddTenFunction = FindGeneratedFunction(ScriptClass, TEXT("AddTen"));
		UFunction* SetStoredValueFunction = FindGeneratedFunction(ScriptClass, TEXT("SetStoredValue"));
		UASFunction* AddTenScriptFunction = Cast<UASFunction>(AddTenFunction);
		UASFunction* SetStoredValueScriptFunction = Cast<UASFunction>(SetStoredValueFunction);
		if (!TestRunner->TestNotNull(TEXT("ProcessEvent thunk test case should generate AddTen"), AddTenFunction)
			|| !TestRunner->TestNotNull(TEXT("ProcessEvent thunk test case should generate SetStoredValue"), SetStoredValueFunction)
			|| !TestRunner->TestNotNull(TEXT("ProcessEvent thunk test case should expose AddTen as a UASFunction"), AddTenScriptFunction)
			|| !TestRunner->TestNotNull(TEXT("ProcessEvent thunk test case should expose SetStoredValue as a UASFunction"), SetStoredValueScriptFunction))
		{
			return;
		}

		TestRunner->TestTrue(TEXT("ProcessEvent thunk test case should route AddTen through UASFunctionNativeThunk"), AddTenFunction->GetNativeFunc() == &UASFunctionNativeThunk);
		TestRunner->TestTrue(TEXT("ProcessEvent thunk test case should route SetStoredValue through UASFunctionNativeThunk"), SetStoredValueFunction->GetNativeFunc() == &UASFunctionNativeThunk);

		UObject* Instance = NewObject<UObject>(GetTransientPackage(), ScriptClass, TEXT("ProcessEventCarrierInstance"));
		if (!TestRunner->TestNotNull(TEXT("ProcessEvent thunk test case should instantiate the generated UObject"), Instance))
		{
			return;
		}

		int32 AddTenResult = INDEX_NONE;
		if (!TestRunner->TestTrue(
				TEXT("ProcessEvent thunk test case should execute AddTen via ProcessEvent"),
				ASFunctionProcessEventTests::InvokeIntFunctionThroughProcessEvent(*TestRunner, Engine, Instance, AddTenFunction, 5, AddTenResult))
			|| !TestRunner->TestEqual(TEXT("ProcessEvent thunk test case should return 15 when AddTen receives 5"), AddTenResult, 15))
		{
			return;
		}

		if (!TestRunner->TestTrue(
				TEXT("ProcessEvent thunk test case should execute SetStoredValue via ProcessEvent"),
				ASFunctionProcessEventTests::InvokeVoidFunctionThroughProcessEvent(*TestRunner, Engine, Instance, SetStoredValueFunction, 17)))
		{
			return;
		}

		int32 StoredValue = INDEX_NONE;
		if (!ReadPropertyValue<FIntProperty>(*TestRunner, Instance, ASFunctionProcessEventTests::StoredValuePropertyName, StoredValue))
		{
			return;
		}

		TestRunner->TestEqual(TEXT("ProcessEvent thunk test case should write StoredValue through RuntimeCallFunction"), StoredValue, 17);

		}
	}
};

#endif
