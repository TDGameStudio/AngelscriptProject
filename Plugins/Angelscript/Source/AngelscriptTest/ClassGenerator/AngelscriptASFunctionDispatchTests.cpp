#include "Shared/AngelscriptScenarioTestUtils.h"
#include "Shared/AngelscriptTestMacros.h"

#include "ClassGenerator/ASClass.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"
#include "UObject/UObjectGlobals.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptScenarioTestUtils;

namespace ASFunctionDispatchTests
{
	struct FDispatchCase
	{
		FName ModuleName;
		FString Filename;
		FName GeneratedClassName;
		const TCHAR* CaseLabel = TEXT("");
		const TCHAR* ScriptSource = TEXT("");
		UClass* ExpectedFunctionClass = nullptr;
		UClass* ExpectedJitFunctionClass = nullptr;
	};

	bool MatchesExpectedFunctionClass(const UFunction& Function, const FDispatchCase& TestCase)
	{
		const UClass* ActualFunctionClass = Function.GetClass();
		return ActualFunctionClass == TestCase.ExpectedFunctionClass || ActualFunctionClass == TestCase.ExpectedJitFunctionClass;
	}

	FString DescribeExpectedFunctionClasses(const FDispatchCase& TestCase)
	{
		return FString::Printf(
			TEXT("%s or %s"),
			*GetNameSafe(TestCase.ExpectedFunctionClass),
			*GetNameSafe(TestCase.ExpectedJitFunctionClass));
	}

	FString DescribeActualFunctionClass(const UFunction* Function)
	{
		return Function != nullptr ? GetNameSafe(Function->GetClass()) : TEXT("<null>");
	}
}

using namespace ASFunctionDispatchTests;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptASFunctionAllocateFunctionForSelectsCorrectThreadSafeDispatchSubclassTest,
	"Angelscript.TestModule.ClassGenerator.ASFunction.AllocateFunctionForSelectsCorrectThreadSafeDispatchSubclass",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptASFunctionAllocateFunctionForSelectsCorrectThreadSafeDispatchSubclassTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH

	const TArray<ASFunctionDispatchTests::FDispatchCase> Cases =
	{
		{
			TEXT("ASFunctionDispatchDefault"),
			TEXT("ASFunctionDispatchDefault.as"),
			TEXT("UASFunctionDispatchDefault"),
			TEXT("default non-thread-safe"),
			TEXT(R"AS(
UCLASS()
class UASFunctionDispatchDefault : UObject
{
	UFUNCTION()
	int GetValue()
	{
		return 1;
	}
}
)AS"),
			UASFunction_DWordReturn::StaticClass(),
			UASFunction_DWordReturn_JIT::StaticClass()
		},
		{
			TEXT("ASFunctionDispatchBlueprintThreadSafeFunction"),
			TEXT("ASFunctionDispatchBlueprintThreadSafeFunction.as"),
			TEXT("UASFunctionDispatchBlueprintThreadSafeFunction"),
			TEXT("function-level BlueprintThreadSafe"),
			TEXT(R"AS(
UCLASS()
class UASFunctionDispatchBlueprintThreadSafeFunction : UObject
{
	UFUNCTION(meta = (BlueprintThreadSafe))
	int GetValue()
	{
		return 1;
	}
}
)AS"),
			UASFunction::StaticClass(),
			UASFunction_JIT::StaticClass()
		},
		{
			TEXT("ASFunctionDispatchClassThreadSafeWithOverride"),
			TEXT("ASFunctionDispatchClassThreadSafeWithOverride.as"),
			TEXT("UASFunctionDispatchClassThreadSafeWithOverride"),
			TEXT("class-level BlueprintThreadSafe with function-level NotBlueprintThreadSafe"),
			TEXT(R"AS(
UCLASS(meta = (BlueprintThreadSafe))
class UASFunctionDispatchClassThreadSafeWithOverride : UObject
{
	UFUNCTION(meta = (NotBlueprintThreadSafe))
	int GetValue()
	{
		return 1;
	}
}
)AS"),
			UASFunction_DWordReturn::StaticClass(),
			UASFunction_DWordReturn_JIT::StaticClass()
		}
	};

	ON_SCOPE_EXIT
	{
		for (const ASFunctionDispatchTests::FDispatchCase& TestCase : Cases)
		{
			Engine.DiscardModule(*TestCase.ModuleName.ToString());
		}
		ResetSharedCloneEngine(Engine);
	};

	for (const ASFunctionDispatchTests::FDispatchCase& TestCase : Cases)
	{
		UClass* ScriptClass = CompileScriptModule(
			*this,
			Engine,
			TestCase.ModuleName,
			TestCase.Filename,
			TestCase.ScriptSource,
			TestCase.GeneratedClassName);
		if (ScriptClass == nullptr)
		{
			return false;
		}

		UASFunction* GeneratedFunction = Cast<UASFunction>(FindGeneratedFunction(ScriptClass, TEXT("GetValue")));
		if (!TestNotNull(
				*FString::Printf(TEXT("AllocateFunctionFor %s case should generate GetValue"), TestCase.CaseLabel),
				GeneratedFunction))
		{
			return false;
		}

		TestTrue(
			*FString::Printf(
				TEXT("AllocateFunctionFor %s case should select %s (actual: %s)"),
				TestCase.CaseLabel,
				*ASFunctionDispatchTests::DescribeExpectedFunctionClasses(TestCase),
				*ASFunctionDispatchTests::DescribeActualFunctionClass(GeneratedFunction)),
			ASFunctionDispatchTests::MatchesExpectedFunctionClass(*GeneratedFunction, TestCase));

		UObject* Instance = NewObject<UObject>(GetTransientPackage(), ScriptClass);
		if (!TestNotNull(
				*FString::Printf(TEXT("AllocateFunctionFor %s case should instantiate the generated class"), TestCase.CaseLabel),
				Instance))
		{
			return false;
		}

		int32 Result = 0;
		if (!TestTrue(
				*FString::Printf(TEXT("AllocateFunctionFor %s case should execute the generated function"), TestCase.CaseLabel),
				ExecuteGeneratedIntEventOnGameThread(&Engine, Instance, GeneratedFunction, Result)))
		{
			return false;
		}

		TestEqual(
			*FString::Printf(TEXT("AllocateFunctionFor %s case should keep GetValue returning 1"), TestCase.CaseLabel),
			Result,
			1);
	}

	ASTEST_END_SHARE_FRESH
	return true;
}

#endif
