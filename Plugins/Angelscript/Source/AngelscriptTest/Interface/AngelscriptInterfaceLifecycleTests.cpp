#include "Shared/AngelscriptFunctionalTestUtils.h"
#include "Shared/AngelscriptTestMacros.h"

#include "Components/ActorTestSpawner.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"
#include "UObject/Class.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptFunctionalTestUtils;

namespace AngelscriptTest_Interface_AngelscriptInterfaceLifecycleTests_Private
{
	UFunction* RequireGeneratedFunction(
		FAutomationTestBase& Test,
		UClass* OwnerClass,
		FName FunctionName,
		const TCHAR* Context)
	{
		UFunction* Function = FindGeneratedFunction(OwnerClass, FunctionName);
		Test.TestNotNull(
			*FString::Printf(TEXT("%s should find generated function '%s'"), Context, *FunctionName.ToString()),
			Function);
		return Function;
	}

	bool InvokeGeneratedFunction(
		FAngelscriptEngine& Engine,
		FAutomationTestBase& Test,
		UObject* Object,
		UFunction* Function,
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
		Object->ProcessEvent(Function, nullptr);
		return true;
	}

}

using namespace AngelscriptTest_Interface_AngelscriptInterfaceLifecycleTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestInterfaceHierarchyProcessEventDispatchTest,
	"Angelscript.TestModule.Interface.Hierarchy.ProcessEventDispatch",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptTestInterfaceHierarchyProcessEventDispatchTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH
	do
	{
	static const FName ModuleName(TEXT("TestInterfaceHierarchyProcessEvent"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("TestInterfaceHierarchyProcessEvent.as"),
		TEXT(R"AS(
UINTERFACE()
interface UIBaseDispatchProcess
{
	void BasePing();
}

UINTERFACE()
interface UIMidDispatchProcess : UIBaseDispatchProcess
{
	void MidPing();
}

UINTERFACE()
interface UILeafDispatchProcess : UIMidDispatchProcess
{
	void LeafPing();
}

UCLASS()
class ATestInterfaceHierarchyProcessEvent : AActor, UILeafDispatchProcess
{
	UPROPERTY()
	int BaseCalled = 0;

	UPROPERTY()
	int MidCalled = 0;

	UPROPERTY()
	int LeafCalled = 0;

	UFUNCTION()
	void BasePing()
	{
		BaseCalled = 1;
	}

	UFUNCTION()
	void MidPing()
	{
		MidCalled = 1;
	}

	UFUNCTION()
	void LeafPing()
	{
		LeafCalled = 1;
	}
}
)AS"),
		TEXT("ATestInterfaceHierarchyProcessEvent"));
	if (!TestNotNull(TEXT("ScriptClass should be valid"), ScriptClass))
	{
		break;
	}

	UClass* BaseInterface = FindGeneratedClass(&Engine, TEXT("UIBaseDispatchProcess"));
	UClass* MidInterface = FindGeneratedClass(&Engine, TEXT("UIMidDispatchProcess"));
	UClass* LeafInterface = FindGeneratedClass(&Engine, TEXT("UILeafDispatchProcess"));

	TestNotNull(TEXT("Base interface class should exist"), BaseInterface);
	TestNotNull(TEXT("Mid interface class should exist"), MidInterface);
	TestNotNull(TEXT("Leaf interface class should exist"), LeafInterface);

	if (BaseInterface != nullptr)
	{
		TestTrue(TEXT("Generated actor class should implement the base interface"), ScriptClass->ImplementsInterface(BaseInterface));
	}
	if (MidInterface != nullptr)
	{
		TestTrue(TEXT("Generated actor class should implement the mid interface"), ScriptClass->ImplementsInterface(MidInterface));
	}
	if (LeafInterface != nullptr)
	{
		TestTrue(TEXT("Generated actor class should implement the leaf interface"), ScriptClass->ImplementsInterface(LeafInterface));
	}

	UFunction* BasePingFunction = RequireGeneratedFunction(
		*this,
		ScriptClass,
		TEXT("BasePing"),
		TEXT("Interface hierarchy ProcessEvent scenario"));
	UFunction* LeafPingFunction = RequireGeneratedFunction(
		*this,
		ScriptClass,
		TEXT("LeafPing"),
		TEXT("Interface hierarchy ProcessEvent scenario"));
	if (!TestNotNull(TEXT("BasePingFunction should be valid"), BasePingFunction)
		|| !TestNotNull(TEXT("LeafPingFunction should be valid"), LeafPingFunction))
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

	if (!InvokeGeneratedFunction(Engine, *this, Actor, BasePingFunction, TEXT("Base ProcessEvent dispatch")))
	{
		break;
	}

	int32 BaseCalled = 0;
	int32 MidCalled = 0;
	int32 LeafCalled = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("BaseCalled"), BaseCalled)
		|| !ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("MidCalled"), MidCalled)
		|| !ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("LeafCalled"), LeafCalled))
	{
		break;
	}

	TestEqual(TEXT("Base ProcessEvent dispatch should call the inherited parent interface method"), BaseCalled, 1);
	TestEqual(TEXT("Base ProcessEvent dispatch should not accidentally call the mid method"), MidCalled, 0);
	TestEqual(TEXT("Base ProcessEvent dispatch should not accidentally call the leaf method"), LeafCalled, 0);

	if (!InvokeGeneratedFunction(Engine, *this, Actor, LeafPingFunction, TEXT("Leaf ProcessEvent dispatch")))
	{
		break;
	}

	if (!ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("BaseCalled"), BaseCalled)
		|| !ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("MidCalled"), MidCalled)
		|| !ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("LeafCalled"), LeafCalled))
	{
		break;
	}

	TestEqual(TEXT("Leaf ProcessEvent dispatch should preserve the earlier base invocation"), BaseCalled, 1);
	TestEqual(TEXT("Leaf ProcessEvent dispatch should not implicitly route through the mid method"), MidCalled, 0);
	TestEqual(TEXT("Leaf ProcessEvent dispatch should call the leaf interface method"), LeafCalled, 1);

	}
	while (false);
	ASTEST_END_SHARE_FRESH
	return !HasAnyErrors();
}

#endif
