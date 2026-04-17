#include "../Shared/AngelscriptTestEngineHelper.h"
#include "../Shared/AngelscriptTestMacros.h"

#include "Core/AngelscriptEngine.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"
#include "UObject/Class.h"
#include "UObject/UObjectGlobals.h"
#include "UObject/UnrealType.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace CompilerPipelineRecompileTest
{
	static const FName ModuleName(TEXT("CompilerSuccessfulRecompileReplacesStaleOutputs"));
	static const FString ScriptFilename(TEXT("CompilerSuccessfulRecompileReplacesStaleOutputs.as"));
	static const FName GeneratedClassName(TEXT("URecompileCarrier"));
	static const FName GeneratedFunctionName(TEXT("GetValue"));
	static const FName ScorePropertyName(TEXT("Score"));

	FString MakeScriptSource(int32 Value)
	{
		return FString::Printf(TEXT(R"AS(
UCLASS()
class URecompileCarrier : UObject
{
	UPROPERTY()
	int Score = %d;

	UFUNCTION()
	int GetValue()
	{
		return Score;
	}
}

int Entry()
{
	return %d;
}
)AS"),
			Value,
			Value);
	}

	int32 CountActiveModulesByName(const FAngelscriptEngine& Engine, const FString& ModuleNameString)
	{
		int32 Count = 0;
		for (const TSharedRef<FAngelscriptModuleDesc>& Module : Engine.GetActiveModules())
		{
			if (Module->ModuleName == ModuleNameString)
			{
				++Count;
			}
		}

		return Count;
	}

	bool ExecuteEntryAndExpect(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		int32 ExpectedValue)
	{
		int32 EntryResult = 0;
		const bool bExecuted = ExecuteIntFunction(
			&Engine,
			ScriptFilename,
			ModuleName,
			TEXT("int Entry()"),
			EntryResult);
		const bool bExecutePassed = Test.TestTrue(
			*FString::Printf(TEXT("Successful recompile scenario should execute Entry() for value %d"), ExpectedValue),
			bExecuted);
		if (!bExecutePassed)
		{
			return false;
		}

		return Test.TestEqual(
			*FString::Printf(TEXT("Successful recompile scenario should observe Entry() == %d"), ExpectedValue),
			EntryResult,
			ExpectedValue);
	}

	bool ExecuteGeneratedValueAndExpect(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		UClass* GeneratedClass,
		UFunction* GeneratedFunction,
		int32 ExpectedValue)
	{
		if (!Test.TestNotNull(
				*FString::Printf(TEXT("Successful recompile scenario should materialize a generated class for value %d"), ExpectedValue),
				GeneratedClass)
			|| !Test.TestNotNull(
				*FString::Printf(TEXT("Successful recompile scenario should expose GetValue for value %d"), ExpectedValue),
				GeneratedFunction))
		{
			return false;
		}

		FIntProperty* ScoreProperty = FindFProperty<FIntProperty>(GeneratedClass, ScorePropertyName);
		if (!Test.TestNotNull(
				*FString::Printf(TEXT("Successful recompile scenario should expose Score for value %d"), ExpectedValue),
				ScoreProperty))
		{
			return false;
		}

		UObject* RuntimeObject = NewObject<UObject>(GetTransientPackage(), GeneratedClass);
		if (!Test.TestNotNull(
				*FString::Printf(TEXT("Successful recompile scenario should instantiate the generated class for value %d"), ExpectedValue),
				RuntimeObject))
		{
			return false;
		}

		const int32 DefaultScore = ScoreProperty->GetPropertyValue_InContainer(RuntimeObject);
		const bool bDefaultScoreMatches = Test.TestEqual(
			*FString::Printf(TEXT("Successful recompile scenario should materialize Score == %d on new instances"), ExpectedValue),
			DefaultScore,
			ExpectedValue);

		int32 MethodResult = 0;
		const bool bExecuted = ExecuteGeneratedIntEventOnGameThread(&Engine, RuntimeObject, GeneratedFunction, MethodResult);
		const bool bExecutePassed = Test.TestTrue(
			*FString::Printf(TEXT("Successful recompile scenario should execute GetValue() for value %d"), ExpectedValue),
			bExecuted);
		if (!bDefaultScoreMatches || !bExecutePassed)
		{
			return false;
		}

		return Test.TestEqual(
			*FString::Printf(TEXT("Successful recompile scenario should observe GetValue() == %d"), ExpectedValue),
			MethodResult,
			ExpectedValue);
	}
}

using namespace CompilerPipelineRecompileTest;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptCompilerSuccessfulRecompileReplacesStaleOutputsTest,
	"Angelscript.TestModule.Compiler.EndToEnd.SuccessfulRecompileReplacesStaleOutputs",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptCompilerSuccessfulRecompileReplacesStaleOutputsTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*CompilerPipelineRecompileTest::ModuleName.ToString());
	};

	Engine.ResetDiagnostics();

	FAngelscriptCompileTraceSummary InitialSummary;
	const bool bInitialCompiled = CompileModuleWithSummary(
		&Engine,
		ECompileType::FullReload,
		CompilerPipelineRecompileTest::ModuleName,
		CompilerPipelineRecompileTest::ScriptFilename,
		CompilerPipelineRecompileTest::MakeScriptSource(7),
		true,
		InitialSummary);
	bPassed &= TestTrue(
		TEXT("Successful recompile scenario should compile the initial annotated module"),
		bInitialCompiled);
	bPassed &= TestEqual(
		TEXT("Successful recompile scenario should report FullyHandled for the initial compile"),
		InitialSummary.CompileResult,
		ECompileResult::FullyHandled);
	bPassed &= TestEqual(
		TEXT("Successful recompile scenario should emit no diagnostics for the initial compile"),
		InitialSummary.Diagnostics.Num(),
		0);
	if (!bInitialCompiled)
	{
		return false;
	}

	TSharedPtr<FAngelscriptModuleDesc> InitialModuleDesc = Engine.GetModuleByFilenameOrModuleName(
		CompilerPipelineRecompileTest::ScriptFilename,
		CompilerPipelineRecompileTest::ModuleName.ToString());
	if (!TestNotNull(TEXT("Successful recompile scenario should publish the initial module descriptor"), InitialModuleDesc.Get()))
	{
		return false;
	}

	UClass* InitialClass = FindGeneratedClass(&Engine, CompilerPipelineRecompileTest::GeneratedClassName);
	UFunction* InitialFunction = InitialClass != nullptr
		? FindGeneratedFunction(InitialClass, CompilerPipelineRecompileTest::GeneratedFunctionName)
		: nullptr;
	if (!CompilerPipelineRecompileTest::ExecuteEntryAndExpect(*this, Engine, 7)
		|| !CompilerPipelineRecompileTest::ExecuteGeneratedValueAndExpect(*this, Engine, InitialClass, InitialFunction, 7))
	{
		return false;
	}

	bPassed &= TestEqual(
		TEXT("Successful recompile scenario should keep exactly one active module after the initial compile"),
		CompilerPipelineRecompileTest::CountActiveModulesByName(Engine, CompilerPipelineRecompileTest::ModuleName.ToString()),
		1);

	Engine.ResetDiagnostics();

	FAngelscriptCompileTraceSummary RecompiledSummary;
	const bool bRecompiled = CompileModuleWithSummary(
		&Engine,
		ECompileType::FullReload,
		CompilerPipelineRecompileTest::ModuleName,
		CompilerPipelineRecompileTest::ScriptFilename,
		CompilerPipelineRecompileTest::MakeScriptSource(42),
		true,
		RecompiledSummary);
	bPassed &= TestTrue(
		TEXT("Successful recompile scenario should compile the updated annotated module"),
		bRecompiled);
	bPassed &= TestEqual(
		TEXT("Successful recompile scenario should report FullyHandled for the updated compile"),
		RecompiledSummary.CompileResult,
		ECompileResult::FullyHandled);
	bPassed &= TestEqual(
		TEXT("Successful recompile scenario should emit no diagnostics for the updated compile"),
		RecompiledSummary.Diagnostics.Num(),
		0);
	if (!bRecompiled)
	{
		return false;
	}

	TSharedPtr<FAngelscriptModuleDesc> RecompiledModuleDesc = Engine.GetModuleByFilenameOrModuleName(
		CompilerPipelineRecompileTest::ScriptFilename,
		CompilerPipelineRecompileTest::ModuleName.ToString());
	if (!TestNotNull(TEXT("Successful recompile scenario should publish the recompiled module descriptor"), RecompiledModuleDesc.Get()))
	{
		return false;
	}

	UClass* RecompiledClass = FindGeneratedClass(&Engine, CompilerPipelineRecompileTest::GeneratedClassName);
	UFunction* RecompiledFunction = RecompiledClass != nullptr
		? FindGeneratedFunction(RecompiledClass, CompilerPipelineRecompileTest::GeneratedFunctionName)
		: nullptr;
	if (!CompilerPipelineRecompileTest::ExecuteEntryAndExpect(*this, Engine, 42)
		|| !CompilerPipelineRecompileTest::ExecuteGeneratedValueAndExpect(*this, Engine, RecompiledClass, RecompiledFunction, 42))
	{
		return false;
	}

	bPassed &= TestEqual(
		TEXT("Successful recompile scenario should keep exactly one active module after the updated compile"),
		CompilerPipelineRecompileTest::CountActiveModulesByName(Engine, CompilerPipelineRecompileTest::ModuleName.ToString()),
		1);
	bPassed &= TestNotEqual(
		TEXT("Successful recompile scenario should replace the active module descriptor after the updated compile"),
		RecompiledModuleDesc.Get(),
		InitialModuleDesc.Get());
	bPassed &= TestTrue(
		TEXT("Successful recompile scenario should replace the underlying script module after the updated compile"),
		RecompiledModuleDesc->ScriptModule != InitialModuleDesc->ScriptModule);

	if (RecompiledClass == InitialClass && RecompiledFunction == InitialFunction)
	{
		bPassed &= CompilerPipelineRecompileTest::ExecuteGeneratedValueAndExpect(
			*this,
			Engine,
			InitialClass,
			InitialFunction,
			42);
	}

	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

#endif
