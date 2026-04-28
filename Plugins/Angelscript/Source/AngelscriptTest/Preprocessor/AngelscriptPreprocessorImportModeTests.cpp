#include "../Shared/AngelscriptTestMacros.h"
#include "../Shared/AngelscriptTestUtilities.h"

#include "AngelscriptSettings.h"
#include "Preprocessor/AngelscriptPreprocessor.h"

#include "HAL/FileManager.h"
#include "Misc/AutomationTest.h"
#include "Misc/FileHelper.h"
#include "Misc/Paths.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace AngelscriptTest_Preprocessor_AngelscriptPreprocessorImportModeTests_Private
{
	const TCHAR* const AutomaticImportWarningMessage =
		TEXT("Automatic imports are active, import statements will be ignored.");
	const TCHAR* const ProviderModuleName = TEXT("Tests.Preprocessor.ImportMode.Shared");
	const TCHAR* const ConsumerModuleName = TEXT("Tests.Preprocessor.ImportMode.Consumer");
	const TCHAR* const ConsumerImportStatement = TEXT("import Tests.Preprocessor.ImportMode.Shared;");

	struct FCollectedDiagnostics
	{
		TArray<FAngelscriptEngine::FDiagnostic> Diagnostics;
		int32 ErrorCount = 0;
	};

	struct FImportWarningTestCase
	{
		const TCHAR* Label = TEXT("");
		bool bWarnOnManualImportStatements = false;
		int32 ExpectedWarningCount = 0;
	};

	FString GetPreprocessorImportModeFixtureRoot()
	{
		return FPaths::Combine(FPaths::ProjectSavedDir(), TEXT("Automation"), TEXT("PreprocessorImportModeFixtures"));
	}

	FString WritePreprocessorImportModeFixture(const FString& RelativeScriptPath, const FString& Contents)
	{
		const FString AbsolutePath = FPaths::Combine(GetPreprocessorImportModeFixtureRoot(), RelativeScriptPath);
		IFileManager::Get().MakeDirectory(*FPaths::GetPath(AbsolutePath), true);
		FFileHelper::SaveStringToFile(Contents, *AbsolutePath);
		return AbsolutePath;
	}

	const FAngelscriptModuleDesc* FindModuleByName(
		const TArray<TSharedRef<FAngelscriptModuleDesc>>& Modules,
		const FString& ModuleName)
	{
		for (const TSharedRef<FAngelscriptModuleDesc>& Module : Modules)
		{
			if (Module->ModuleName == ModuleName)
			{
				return &Module.Get();
			}
		}

		return nullptr;
	}

	bool ModuleContainsText(const FAngelscriptModuleDesc& Module, const FString& Text)
	{
		for (const FAngelscriptModuleDesc::FCodeSection& Section : Module.Code)
		{
			if (Section.Code.Contains(Text))
			{
				return true;
			}
		}

		return false;
	}

	FCollectedDiagnostics CollectDiagnostics(
		const FAngelscriptEngine& Engine,
		const TArray<FString>& AbsoluteFilenames)
	{
		FCollectedDiagnostics Result;

		for (const FString& AbsoluteFilename : AbsoluteFilenames)
		{
			const FAngelscriptEngine::FDiagnostics* Diagnostics = Engine.Diagnostics.Find(AbsoluteFilename);
			if (Diagnostics == nullptr)
			{
				continue;
			}

			for (const FAngelscriptEngine::FDiagnostic& Diagnostic : Diagnostics->Diagnostics)
			{
				Result.Diagnostics.Add(Diagnostic);
				if (Diagnostic.bIsError)
				{
					++Result.ErrorCount;
				}
			}
		}

		return Result;
	}
}

using namespace AngelscriptTest_Preprocessor_AngelscriptPreprocessorImportModeTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptPreprocessorAutomaticWarningRespectsConfigTest,
	"Angelscript.TestModule.Preprocessor.Import.AutomaticWarningRespectsConfig",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptPreprocessorAutomaticWarningRespectsConfigTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_MODULE_CLEAN();
	ASTEST_BEGIN_MODULE_CLEAN

	Engine.ResetDiagnostics();

	if (!TestTrue(
		TEXT("Automatic warning config test should run with automatic imports enabled on the current engine"),
		Engine.ShouldUseAutomaticImportMethod()))
	{
		return false;
	}

	if (!TestTrue(
		TEXT("Automatic warning config test should observe automatic imports through the active engine context"),
		FAngelscriptEngine::ShouldUseAutomaticImportMethodForCurrentContext()))
	{
		return false;
	}

	UAngelscriptSettings* Settings = GetMutableDefault<UAngelscriptSettings>();
	if (!TestNotNull(
		TEXT("Automatic warning config test should access mutable angelscript settings"),
		Settings))
	{
		return false;
	}

	const bool PreviousWarnOnManualImportStatements = Settings->bWarnOnManualImportStatements;
	ON_SCOPE_EXIT
	{
		Settings->bWarnOnManualImportStatements = PreviousWarnOnManualImportStatements;
	};

	const FString ProviderRelativePath = TEXT("Tests/Preprocessor/ImportMode/Shared.as");
	const FString ProviderAbsolutePath = WritePreprocessorImportModeFixture(
		ProviderRelativePath,
		TEXT("int SharedValue()\n")
		TEXT("{\n")
		TEXT("    return 11;\n")
		TEXT("}\n"));

	const FString ConsumerRelativePath = TEXT("Tests/Preprocessor/ImportMode/Consumer.as");
	const FString ConsumerAbsolutePath = WritePreprocessorImportModeFixture(
		ConsumerRelativePath,
		TEXT("import Tests.Preprocessor.ImportMode.Shared;\n")
		TEXT("int Entry()\n")
		TEXT("{\n")
		TEXT("    return SharedValue();\n")
		TEXT("}\n"));

	ON_SCOPE_EXIT
	{
		IFileManager::Get().Delete(*ConsumerAbsolutePath, false, true);
		IFileManager::Get().Delete(*ProviderAbsolutePath, false, true);
	};

	const TArray<FImportWarningTestCase> TestCases = {
		{TEXT("WarningsEnabled"), true, 1},
		{TEXT("WarningsDisabled"), false, 0},
	};

	for (const FImportWarningTestCase& TestCase : TestCases)
	{
		const FString TestCaseLabel = TestCase.Label;
		Settings->bWarnOnManualImportStatements = TestCase.bWarnOnManualImportStatements;
		Engine.ResetDiagnostics();

		FAngelscriptPreprocessor Preprocessor;
		Preprocessor.AddFile(ProviderRelativePath, ProviderAbsolutePath);
		Preprocessor.AddFile(ConsumerRelativePath, ConsumerAbsolutePath);

		const bool bPreprocessSucceeded = Preprocessor.Preprocess();
		const TArray<TSharedRef<FAngelscriptModuleDesc>> Modules = Preprocessor.GetModulesToCompile();
		const FCollectedDiagnostics CollectedDiagnostics = CollectDiagnostics(
			Engine,
			{ProviderAbsolutePath, ConsumerAbsolutePath});

		bPassed &= TestTrue(
			*FString::Printf(TEXT("%s should preprocess successfully"), *TestCaseLabel),
			bPreprocessSucceeded);
		bPassed &= TestEqual(
			*FString::Printf(TEXT("%s should emit exactly two module descriptors"), *TestCaseLabel),
			Modules.Num(),
			2);
		bPassed &= TestEqual(
			*FString::Printf(TEXT("%s should keep preprocessing error count at zero"), *TestCaseLabel),
			CollectedDiagnostics.ErrorCount,
			0);
		bPassed &= TestEqual(
			*FString::Printf(TEXT("%s should emit the expected warning count"), *TestCaseLabel),
			CollectedDiagnostics.Diagnostics.Num(),
			TestCase.ExpectedWarningCount);

		const FAngelscriptModuleDesc* ProviderModule = FindModuleByName(Modules, ProviderModuleName);
		const FAngelscriptModuleDesc* ConsumerModule = FindModuleByName(Modules, ConsumerModuleName);
		if (!TestNotNull(
				*FString::Printf(TEXT("%s should emit the provider module descriptor"), *TestCaseLabel),
				ProviderModule)
			|| !TestNotNull(
				*FString::Printf(TEXT("%s should emit the consumer module descriptor"), *TestCaseLabel),
				ConsumerModule))
		{
			bPassed = false;
			continue;
		}

		bPassed &= TestEqual(
			*FString::Printf(TEXT("%s should keep the provider module free of imported modules"), *TestCaseLabel),
			ProviderModule->ImportedModules.Num(),
			0);
		bPassed &= TestEqual(
			*FString::Printf(TEXT("%s should record exactly one imported module on the consumer"), *TestCaseLabel),
			ConsumerModule->ImportedModules.Num(),
			1);
		bPassed &= TestTrue(
			*FString::Printf(TEXT("%s should record the provider module name in ImportedModules"), *TestCaseLabel),
			ConsumerModule->ImportedModules.Contains(ProviderModuleName));
		bPassed &= TestTrue(
			*FString::Printf(TEXT("%s should materialize at least one processed code section for the consumer"), *TestCaseLabel),
			ConsumerModule->Code.Num() > 0);
		bPassed &= TestFalse(
			*FString::Printf(TEXT("%s should strip the raw manual import statement from processed code"), *TestCaseLabel),
			ModuleContainsText(*ConsumerModule, ConsumerImportStatement));

		if (TestCase.bWarnOnManualImportStatements)
		{
			if (!TestEqual(
				*FString::Printf(TEXT("%s should emit exactly one compatibility warning"), *TestCaseLabel),
				CollectedDiagnostics.Diagnostics.Num(),
				1))
			{
				bPassed = false;
				continue;
			}

			const FAngelscriptEngine::FDiagnostic& Diagnostic = CollectedDiagnostics.Diagnostics[0];
			bPassed &= TestFalse(
				*FString::Printf(TEXT("%s should emit a warning instead of an error"), *TestCaseLabel),
				Diagnostic.bIsError);
			bPassed &= TestEqual(
				*FString::Printf(TEXT("%s should point the warning at the import line"), *TestCaseLabel),
				Diagnostic.Row,
				1);
			bPassed &= TestTrue(
				*FString::Printf(TEXT("%s should mention automatic import compatibility in the warning message"), *TestCaseLabel),
				Diagnostic.Message.Contains(AutomaticImportWarningMessage));
		}
		else
		{
			bPassed &= TestTrue(
				*FString::Printf(TEXT("%s should keep diagnostics empty when warning policy is disabled"), *TestCaseLabel),
				CollectedDiagnostics.Diagnostics.IsEmpty());
		}
	}

	ASTEST_END_MODULE_CLEAN
	return bPassed;
}

#endif
