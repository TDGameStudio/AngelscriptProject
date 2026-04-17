#include "Shared/AngelscriptScenarioTestUtils.h"
#include "Shared/AngelscriptTestMacros.h"

#include "ClassGenerator/ASClass.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"
#include "UObject/UnrealType.h"
#include "UObject/UObjectGlobals.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptScenarioTestUtils;

namespace ScriptClassStructureTests
{
	int32 CountDeclaredProperties(const UClass& ScriptClass)
	{
		int32 PropertyCount = 0;
		for (TFieldIterator<FProperty> It(&ScriptClass, EFieldIteratorFlags::ExcludeSuper); It; ++It)
		{
			++PropertyCount;
		}

		return PropertyCount;
	}
}

using namespace ScriptClassStructureTests;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptFunctionOnlyScriptClassCompilesAndExecutesTest,
	"Angelscript.TestModule.ScriptClass.FunctionOnlyClassCompilesAndExecutes",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptFunctionOnlyScriptClassCompilesAndExecutesTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH

	static const FName ModuleName(TEXT("ASFunctionOnlyScriptClassStructure"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	static const FString ScriptSource = TEXT(R"AS(
UCLASS()
class UFunctionOnlyScriptClass : UObject
{
	UFUNCTION()
	int GetValue()
	{
		return 17;
	}
}
)AS");

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("FunctionOnlyScriptClass.as"),
		ScriptSource,
		TEXT("UFunctionOnlyScriptClass"));
	if (ScriptClass == nullptr)
	{
		return false;
	}

	UASClass* ASClass = Cast<UASClass>(ScriptClass);
	if (!TestNotNull(TEXT("Function-only script class scenario should generate a UASClass"), ASClass))
	{
		return false;
	}

	TestTrue(TEXT("Function-only script class scenario should remain UObject-derived"), ScriptClass->IsChildOf(UObject::StaticClass()));
	TestEqual(TEXT("Function-only script class scenario should not synthesize any declared user properties"), ScriptClassStructureTests::CountDeclaredProperties(*ScriptClass), 0);
	TestNull(TEXT("Function-only script class scenario should not expose undeclared properties"), FindFProperty<FProperty>(ScriptClass, TEXT("UnexpectedProperty")));

	UFunction* GetValueFunction = FindGeneratedFunction(ScriptClass, TEXT("GetValue"));
	if (!TestNotNull(TEXT("Function-only script class scenario should generate GetValue"), GetValueFunction))
	{
		return false;
	}

	UObject* Instance = NewObject<UObject>(GetTransientPackage(), ScriptClass);
	if (!TestNotNull(TEXT("Function-only script class scenario should instantiate the generated class"), Instance))
	{
		return false;
	}

	int32 Result = 0;
	if (!TestTrue(TEXT("Function-only script class scenario should execute GetValue on the game thread"), ExecuteGeneratedIntEventOnGameThread(&Engine, Instance, GetValueFunction, Result)))
	{
		return false;
	}

	TestEqual(TEXT("Function-only script class scenario should keep GetValue returning 17"), Result, 17);

	ASTEST_END_SHARE_FRESH
	return true;
}

#endif
