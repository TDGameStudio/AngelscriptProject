#include "Shared/AngelscriptScenarioTestUtils.h"
#include "Shared/AngelscriptTestMacros.h"

#include "ClassGenerator/ASClass.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"
#include "UObject/UObjectGlobals.h"
#include "UObject/UnrealType.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptScenarioTestUtils;

namespace ASFunctionOptimizedCallTests
{
	static const FName ModuleName(TEXT("ASFunctionOptimizedCall"));
	static const FString ScriptFilename(TEXT("ASFunctionOptimizedCall.as"));
	static const FName GeneratedClassName(TEXT("UOptimizedCallTarget"));
	static const FName PingCountPropertyName(TEXT("PingCount"));
	static const FName StoredFloatHundredthsPropertyName(TEXT("StoredFloatHundredths"));
	static const FName StoredDoubleHundredthsPropertyName(TEXT("StoredDoubleHundredths"));
	static const FName ObservedRefValuePropertyName(TEXT("ObservedRefValue"));

	UASClass* CompileOptimizedCallTarget(FAutomationTestBase& Test, FAngelscriptEngine& Engine)
	{
		const FString ScriptSource = TEXT(R"AS(
UCLASS()
class UOptimizedCallTarget : UObject
{
	UPROPERTY()
	int PingCount = 0;

	UPROPERTY()
	int StoredFloatHundredths = 0;

	UPROPERTY()
	int StoredDoubleHundredths = 0;

	UPROPERTY()
	int ObservedRefValue = 0;

	UFUNCTION()
	void Ping()
	{
		PingCount += 1;
	}

	UFUNCTION()
	uint8 GetByteCode()
	{
		return 42;
	}

	UFUNCTION()
	void StoreFloat(float32 InValue)
	{
		StoredFloatHundredths = int(InValue * 100.0f);
	}

	UFUNCTION()
	void StoreDouble(float64 InValue)
	{
		StoredDoubleHundredths = int(InValue * 100.0);
	}

	UFUNCTION()
	void BumpRef(int& Value)
	{
		Value += 3;
		ObservedRefValue = Value;
	}

	UFUNCTION()
	uint8 BumpRefAndReturn(int& Value)
	{
		Value += 4;
		ObservedRefValue = Value;
		return 77;
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

	UASFunction* RequireGeneratedScriptFunction(
		FAutomationTestBase& Test,
		UClass* ScriptClass,
		const TCHAR* FunctionName)
	{
		UASFunction* ScriptFunction = Cast<UASFunction>(FindGeneratedFunction(ScriptClass, FunctionName));
		Test.TestNotNull(
			*FString::Printf(TEXT("Optimized-call scenario should generate '%s' as a UASFunction"), FunctionName),
			ScriptFunction);
		return ScriptFunction;
	}
}

using namespace ASFunctionOptimizedCallTests;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptASFunctionOptimizedCallWrappersPreserveArgumentsAndReturnValuesTest,
	"Angelscript.TestModule.ClassGenerator.ASFunction.OptimizedCallWrappersPreserveArgumentsAndReturnValues",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptASFunctionOptimizedCallWrappersPreserveArgumentsAndReturnValuesTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH

	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ASFunctionOptimizedCallTests::ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UASClass* ScriptClass = ASFunctionOptimizedCallTests::CompileOptimizedCallTarget(*this, Engine);
	if (!TestNotNull(TEXT("Optimized-call scenario should compile to a UASClass"), ScriptClass))
	{
		return false;
	}

	UASFunction* PingFunction = ASFunctionOptimizedCallTests::RequireGeneratedScriptFunction(*this, ScriptClass, TEXT("Ping"));
	UASFunction* GetByteCodeFunction = ASFunctionOptimizedCallTests::RequireGeneratedScriptFunction(*this, ScriptClass, TEXT("GetByteCode"));
	UASFunction* StoreFloatFunction = ASFunctionOptimizedCallTests::RequireGeneratedScriptFunction(*this, ScriptClass, TEXT("StoreFloat"));
	UASFunction* StoreDoubleFunction = ASFunctionOptimizedCallTests::RequireGeneratedScriptFunction(*this, ScriptClass, TEXT("StoreDouble"));
	UASFunction* BumpRefFunction = ASFunctionOptimizedCallTests::RequireGeneratedScriptFunction(*this, ScriptClass, TEXT("BumpRef"));
	UASFunction* BumpRefAndReturnFunction = ASFunctionOptimizedCallTests::RequireGeneratedScriptFunction(*this, ScriptClass, TEXT("BumpRefAndReturn"));
	if (PingFunction == nullptr
		|| GetByteCodeFunction == nullptr
		|| StoreFloatFunction == nullptr
		|| StoreDoubleFunction == nullptr
		|| BumpRefFunction == nullptr
		|| BumpRefAndReturnFunction == nullptr)
	{
		return false;
	}

	if (!TestTrue(
			TEXT("Optimized-call scenario should route Ping through the dedicated no-params dispatch class"),
			PingFunction->GetClass() == UASFunction_NoParams::StaticClass()
				|| PingFunction->GetClass() == UASFunction_NoParams_JIT::StaticClass())
		|| !TestTrue(
			TEXT("Optimized-call scenario should route GetByteCode through the dedicated byte-return dispatch class"),
			GetByteCodeFunction->GetClass() == UASFunction_ByteReturn::StaticClass()
				|| GetByteCodeFunction->GetClass() == UASFunction_ByteReturn_JIT::StaticClass())
		|| !TestTrue(
			TEXT("Optimized-call scenario should route StoreFloat through the dedicated float-argument dispatch class"),
			StoreFloatFunction->GetClass() == UASFunction_FloatArg::StaticClass()
				|| StoreFloatFunction->GetClass() == UASFunction_FloatArg_JIT::StaticClass())
		|| !TestTrue(
			TEXT("Optimized-call scenario should route StoreDouble through the dedicated double-argument dispatch class"),
			StoreDoubleFunction->GetClass() == UASFunction_DoubleArg::StaticClass()
				|| StoreDoubleFunction->GetClass() == UASFunction_DoubleArg_JIT::StaticClass())
		|| !TestTrue(
			TEXT("Optimized-call scenario should route BumpRef through the dedicated reference-argument dispatch class"),
			BumpRefFunction->GetClass() == UASFunction_ReferenceArg::StaticClass()
				|| BumpRefFunction->GetClass() == UASFunction_ReferenceArg_JIT::StaticClass()))
	{
		return false;
	}

	UObject* Instance = NewObject<UObject>(GetTransientPackage(), ScriptClass, TEXT("OptimizedCallTargetInstance"));
	if (!TestNotNull(TEXT("Optimized-call scenario should instantiate the generated UObject"), Instance))
	{
		return false;
	}

	PingFunction->OptimizedCall(Instance);

	int32 PingCount = INDEX_NONE;
	if (!ReadPropertyValue<FIntProperty>(*this, Instance, ASFunctionOptimizedCallTests::PingCountPropertyName, PingCount)
		|| !TestEqual(TEXT("OptimizedCall should execute a no-parameter void function exactly once"), PingCount, 1))
	{
		return false;
	}

	const uint8 ByteResult = GetByteCodeFunction->OptimizedCall_ByteReturn(Instance);
	if (!TestEqual(TEXT("OptimizedCall_ByteReturn should preserve the script byte return value"), static_cast<int32>(ByteResult), 42))
	{
		return false;
	}

	StoreFloatFunction->OptimizedCall_FloatArg(Instance, 12.5f);

	int32 StoredFloatHundredths = INDEX_NONE;
	if (!ReadPropertyValue<FIntProperty>(*this, Instance, ASFunctionOptimizedCallTests::StoredFloatHundredthsPropertyName, StoredFloatHundredths)
		|| !TestEqual(TEXT("OptimizedCall_FloatArg should pass the float argument without mangling its value"), StoredFloatHundredths, 1250))
	{
		return false;
	}

	StoreDoubleFunction->OptimizedCall_DoubleArg(Instance, 42.25);

	int32 StoredDoubleHundredths = INDEX_NONE;
	if (!ReadPropertyValue<FIntProperty>(*this, Instance, ASFunctionOptimizedCallTests::StoredDoubleHundredthsPropertyName, StoredDoubleHundredths)
		|| !TestEqual(TEXT("OptimizedCall_DoubleArg should pass the double argument without mangling its value"), StoredDoubleHundredths, 4225))
	{
		return false;
	}

	int32 RefArgument = 5;
	BumpRefFunction->OptimizedCall_RefArg(Instance, &RefArgument);

	int32 ObservedRefValue = INDEX_NONE;
	if (!TestEqual(TEXT("OptimizedCall_RefArg should write through the referenced argument"), RefArgument, 8)
		|| !ReadPropertyValue<FIntProperty>(*this, Instance, ASFunctionOptimizedCallTests::ObservedRefValuePropertyName, ObservedRefValue)
		|| !TestEqual(TEXT("OptimizedCall_RefArg should expose the mutated reference value inside script state"), ObservedRefValue, 8))
	{
		return false;
	}

	int32 RefArgumentWithReturn = 9;
	const uint8 RefReturnValue = BumpRefAndReturnFunction->OptimizedCall_RefArg_ByteReturn(Instance, &RefArgumentWithReturn);
	if (!TestEqual(TEXT("OptimizedCall_RefArg_ByteReturn should write through the referenced argument"), RefArgumentWithReturn, 13)
		|| !ReadPropertyValue<FIntProperty>(*this, Instance, ASFunctionOptimizedCallTests::ObservedRefValuePropertyName, ObservedRefValue)
		|| !TestEqual(TEXT("OptimizedCall_RefArg_ByteReturn should expose the mutated reference value inside script state"), ObservedRefValue, 13)
		|| !TestEqual(TEXT("OptimizedCall_RefArg_ByteReturn should preserve the script byte return value"), static_cast<int32>(RefReturnValue), 77))
	{
		return false;
	}

	ASTEST_END_SHARE_FRESH
	return true;
}

#endif
