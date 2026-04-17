#include "../Shared/AngelscriptTestEngineHelper.h"
#include "../Shared/AngelscriptTestMacros.h"

#include "Core/AngelscriptSettings.h"
#include "Preprocessor/AngelscriptPreprocessor.h"

#include "HAL/FileManager.h"
#include "Misc/AutomationTest.h"
#include "Misc/FileHelper.h"
#include "Misc/Paths.h"
#include "Misc/ScopeExit.h"
#include "UObject/Class.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace CompilerPipelineFunctionFlagTest
{
	struct FExpectedFunctionFlags
	{
		const TCHAR* FunctionName = nullptr;
		bool bBlueprintCallable = false;
		bool bBlueprintPure = false;
	};

	struct FScenario
	{
		FName ModuleName;
		FString RelativeScriptPath;
		FString ClassName;
		bool bDefaultFunctionBlueprintCallable = false;
		FString ScriptSource;
		TArray<FExpectedFunctionFlags> ExpectedFunctions;
	};

	TArray<FScenario> BuildScenarios()
	{
		return {
			{
				TEXT("Tests.Compiler.FunctionBlueprintCallableDefaultsFalse"),
				TEXT("Tests/Compiler/FunctionBlueprintCallableDefaultsFalse.as"),
				TEXT("UCompilerBlueprintCallableDefaultFalseCarrier"),
				false,
				TEXT(R"AS(
UCLASS()
class UCompilerBlueprintCallableDefaultFalseCarrier : UObject
{
	UFUNCTION()
	int ImplicitDefault()
	{
		return 1;
	}

	UFUNCTION(BlueprintCallable)
	int ExplicitCallable()
	{
		return 2;
	}

	UFUNCTION(BlueprintPure)
	int PureValue()
	{
		return 3;
	}
}
)AS"),
				{
					{ TEXT("ImplicitDefault"), false, false },
					{ TEXT("ExplicitCallable"), true, false },
					{ TEXT("PureValue"), true, true },
				}
			},
			{
				TEXT("Tests.Compiler.FunctionBlueprintCallableDefaultsTrue"),
				TEXT("Tests/Compiler/FunctionBlueprintCallableDefaultsTrue.as"),
				TEXT("UCompilerBlueprintCallableDefaultTrueCarrier"),
				true,
				TEXT(R"AS(
UCLASS()
class UCompilerBlueprintCallableDefaultTrueCarrier : UObject
{
	UFUNCTION()
	int ImplicitCallable()
	{
		return 4;
	}

	UFUNCTION(NotBlueprintCallable)
	int HiddenValue()
	{
		return 5;
	}
}
)AS"),
				{
					{ TEXT("ImplicitCallable"), true, false },
					{ TEXT("HiddenValue"), false, false },
				}
			}
		};
	}

	FString GetFixtureRoot()
	{
		return FPaths::Combine(FPaths::ProjectSavedDir(), TEXT("Automation"), TEXT("CompilerFunctionFlagFixtures"));
	}

	FString WriteFixture(const FString& RelativePath, const FString& Contents)
	{
		const FString AbsolutePath = FPaths::Combine(GetFixtureRoot(), RelativePath);
		IFileManager::Get().MakeDirectory(*FPaths::GetPath(AbsolutePath), true);
		FFileHelper::SaveStringToFile(Contents, *AbsolutePath);
		return AbsolutePath;
	}

	TArray<FString> CollectDiagnosticMessages(
		const FAngelscriptEngine& Engine,
		const FString& AbsoluteFilename,
		int32& OutErrorCount)
	{
		OutErrorCount = 0;

		const FAngelscriptEngine::FDiagnostics* Diagnostics = Engine.Diagnostics.Find(AbsoluteFilename);
		if (Diagnostics == nullptr)
		{
			return {};
		}

		TArray<FString> Messages;
		for (const FAngelscriptEngine::FDiagnostic& Diagnostic : Diagnostics->Diagnostics)
		{
			Messages.Add(Diagnostic.Message);
			if (Diagnostic.bIsError)
			{
				++OutErrorCount;
			}
		}

		return Messages;
	}

	bool ExpectDescriptorFlags(
		FAutomationTestBase& Test,
		const FString& ScenarioLabel,
		const TSharedPtr<FAngelscriptFunctionDesc>& FunctionDesc,
		const FExpectedFunctionFlags& Expected)
	{
		if (!Test.TestTrue(
				*FString::Printf(TEXT("%s should parse function descriptor %s"), *ScenarioLabel, Expected.FunctionName),
				FunctionDesc.IsValid()))
		{
			return false;
		}

		bool bPassed = true;
		bPassed &= Test.TestEqual(
			*FString::Printf(TEXT("%s should set bBlueprintCallable for %s during preprocessing"), *ScenarioLabel, Expected.FunctionName),
			FunctionDesc->bBlueprintCallable,
			Expected.bBlueprintCallable);
		bPassed &= Test.TestEqual(
			*FString::Printf(TEXT("%s should set bBlueprintPure for %s during preprocessing"), *ScenarioLabel, Expected.FunctionName),
			FunctionDesc->bBlueprintPure,
			Expected.bBlueprintPure);
		return bPassed;
	}

	bool ExpectGeneratedFlags(
		FAutomationTestBase& Test,
		const FString& ScenarioLabel,
		UClass* GeneratedClass,
		const FExpectedFunctionFlags& Expected)
	{
		UFunction* GeneratedFunction = FindGeneratedFunction(GeneratedClass, Expected.FunctionName);
		if (!Test.TestNotNull(
				*FString::Printf(TEXT("%s should materialize generated function %s"), *ScenarioLabel, Expected.FunctionName),
				GeneratedFunction))
		{
			return false;
		}

		bool bPassed = true;
		bPassed &= Test.TestEqual(
			*FString::Printf(TEXT("%s should set FUNC_BlueprintCallable for %s"), *ScenarioLabel, Expected.FunctionName),
			GeneratedFunction->HasAnyFunctionFlags(FUNC_BlueprintCallable),
			Expected.bBlueprintCallable);
		bPassed &= Test.TestEqual(
			*FString::Printf(TEXT("%s should set FUNC_BlueprintPure for %s"), *ScenarioLabel, Expected.FunctionName),
			GeneratedFunction->HasAnyFunctionFlags(FUNC_BlueprintPure),
			Expected.bBlueprintPure);
		return bPassed;
	}
}

using namespace CompilerPipelineFunctionFlagTest;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptCompilerFunctionBlueprintCallableDefaultsAndOverridesTest,
	"Angelscript.TestModule.Compiler.EndToEnd.FunctionBlueprintCallableDefaultsAndOverrides",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptCompilerFunctionBlueprintCallableDefaultsAndOverridesTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	UAngelscriptSettings* Settings = GetMutableDefault<UAngelscriptSettings>();
	if (!TestNotNull(TEXT("Function blueprint callable defaults test should access mutable angelscript settings"), Settings))
	{
		return false;
	}

	const bool PreviousDefaultCallable = Settings->bDefaultFunctionBlueprintCallable;
	ON_SCOPE_EXIT
	{
		Settings->bDefaultFunctionBlueprintCallable = PreviousDefaultCallable;
	};

	for (const CompilerPipelineFunctionFlagTest::FScenario& Scenario : CompilerPipelineFunctionFlagTest::BuildScenarios())
	{
		{
			const FString AbsoluteScriptPath = CompilerPipelineFunctionFlagTest::WriteFixture(
				Scenario.RelativeScriptPath,
				Scenario.ScriptSource);
			const FString ModuleNameString = Scenario.ModuleName.ToString();
			ON_SCOPE_EXIT
			{
				Engine.DiscardModule(*ModuleNameString);
				IFileManager::Get().Delete(*AbsoluteScriptPath, false, true);
			};

			Settings->bDefaultFunctionBlueprintCallable = Scenario.bDefaultFunctionBlueprintCallable;
			Engine.ResetDiagnostics();

			FAngelscriptPreprocessor Preprocessor;
			Preprocessor.AddFile(Scenario.RelativeScriptPath, AbsoluteScriptPath);

			const bool bPreprocessSucceeded = Preprocessor.Preprocess();
			const TArray<TSharedRef<FAngelscriptModuleDesc>> Modules = Preprocessor.GetModulesToCompile();

			int32 PreprocessErrorCount = 0;
			const TArray<FString> PreprocessMessages = CompilerPipelineFunctionFlagTest::CollectDiagnosticMessages(
				Engine,
				AbsoluteScriptPath,
				PreprocessErrorCount);

			const FString ScenarioLabel = FString::Printf(
				TEXT("Function blueprint callable defaults scenario (%s, default=%s)"),
				*Scenario.ClassName,
				Scenario.bDefaultFunctionBlueprintCallable ? TEXT("true") : TEXT("false"));

			bPassed &= TestTrue(
				*FString::Printf(TEXT("%s should preprocess successfully"), *ScenarioLabel),
				bPreprocessSucceeded);
			bPassed &= TestEqual(
				*FString::Printf(TEXT("%s should keep preprocessing error count at zero"), *ScenarioLabel),
				PreprocessErrorCount,
				0);
			bPassed &= TestEqual(
				*FString::Printf(TEXT("%s should keep preprocessing diagnostics empty"), *ScenarioLabel),
				PreprocessMessages.Num(),
				0);
			bPassed &= TestEqual(
				*FString::Printf(TEXT("%s should emit exactly one module descriptor"), *ScenarioLabel),
				Modules.Num(),
				1);
			if (!bPassed || !bPreprocessSucceeded || Modules.Num() != 1)
			{
				return false;
			}

			const TSharedRef<FAngelscriptModuleDesc> ModuleDesc = Modules[0];
			const TSharedPtr<FAngelscriptClassDesc> ClassDesc = ModuleDesc->GetClass(Scenario.ClassName);
			if (!TestTrue(
					*FString::Printf(TEXT("%s should parse the annotated class descriptor"), *ScenarioLabel),
					ClassDesc.IsValid()))
			{
				return false;
			}

			for (const CompilerPipelineFunctionFlagTest::FExpectedFunctionFlags& ExpectedFunction : Scenario.ExpectedFunctions)
			{
				const TSharedPtr<FAngelscriptFunctionDesc> FunctionDesc = ClassDesc->GetMethod(ExpectedFunction.FunctionName);
				bPassed &= CompilerPipelineFunctionFlagTest::ExpectDescriptorFlags(
					*this,
					ScenarioLabel,
					FunctionDesc,
					ExpectedFunction);
			}

			Engine.ResetDiagnostics();

			FAngelscriptCompileTraceSummary Summary;
			const bool bCompiled = CompileModuleWithSummary(
				&Engine,
				ECompileType::FullReload,
				Scenario.ModuleName,
				Scenario.RelativeScriptPath,
				Scenario.ScriptSource,
				true,
				Summary,
				true);

			bPassed &= TestTrue(
				*FString::Printf(TEXT("%s should compile through the full preprocessor pipeline"), *ScenarioLabel),
				bCompiled);
			bPassed &= TestTrue(
				*FString::Printf(TEXT("%s should record preprocessor usage in the compile summary"), *ScenarioLabel),
				Summary.bUsedPreprocessor);
			bPassed &= TestTrue(
				*FString::Printf(TEXT("%s should mark compile succeeded in the summary"), *ScenarioLabel),
				Summary.bCompileSucceeded);
			bPassed &= TestEqual(
				*FString::Printf(TEXT("%s should report FullyHandled compile result"), *ScenarioLabel),
				Summary.CompileResult,
				ECompileResult::FullyHandled);
			bPassed &= TestEqual(
				*FString::Printf(TEXT("%s should keep compile diagnostics empty"), *ScenarioLabel),
				Summary.Diagnostics.Num(),
				0);
			if (!bCompiled)
			{
				return false;
			}

			UClass* GeneratedClass = FindGeneratedClass(&Engine, *Scenario.ClassName);
			if (!TestNotNull(
					*FString::Printf(TEXT("%s should materialize the generated class"), *ScenarioLabel),
					GeneratedClass))
			{
				return false;
			}

			for (const CompilerPipelineFunctionFlagTest::FExpectedFunctionFlags& ExpectedFunction : Scenario.ExpectedFunctions)
			{
				bPassed &= CompilerPipelineFunctionFlagTest::ExpectGeneratedFlags(
					*this,
					ScenarioLabel,
					GeneratedClass,
					ExpectedFunction);
			}
		}
	}

	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

#endif
