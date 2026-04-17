#include "../Shared/AngelscriptTestUtilities.h"
#include "../Shared/AngelscriptTestMacros.h"

#include "Preprocessor/AngelscriptPreprocessor.h"

#include "HAL/FileManager.h"
#include "Misc/AutomationTest.h"
#include "Misc/FileHelper.h"
#include "Misc/Paths.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace AngelscriptTest_Preprocessor_AngelscriptPreprocessorRestrictUsageTests_Private
{
	TUniquePtr<FAngelscriptEngine> CreateRestrictUsageEditorEngine()
	{
		FAngelscriptEngineConfig Config;
		Config.bIsEditor = true;

		FAngelscriptEngineDependencies Dependencies = FAngelscriptEngineDependencies::CreateDefault();
		return FAngelscriptEngine::CreateTestingFullEngine(Config, Dependencies);
	}

	FString GetRestrictUsageFixtureRoot()
	{
		return FPaths::Combine(FPaths::ProjectSavedDir(), TEXT("Automation"), TEXT("PreprocessorRestrictUsageFixtures"));
	}

	FString WriteRestrictUsageFixture(const FString& RelativeScriptPath, const FString& Contents)
	{
		const FString AbsolutePath = FPaths::Combine(GetRestrictUsageFixtureRoot(), RelativeScriptPath);
		IFileManager::Get().MakeDirectory(*FPaths::GetPath(AbsolutePath), true);
		FFileHelper::SaveStringToFile(Contents, *AbsolutePath);
		return AbsolutePath;
	}

	TArray<FString> CollectRestrictUsageDiagnosticMessages(
		const FAngelscriptEngine& Engine,
		const TArray<FString>& AbsoluteFilenames,
		int32& OutErrorCount)
	{
		TArray<FString> Messages;
		OutErrorCount = 0;

		for (const FString& AbsoluteFilename : AbsoluteFilenames)
		{
			const FAngelscriptEngine::FDiagnostics* Diagnostics = Engine.Diagnostics.Find(AbsoluteFilename);
			if (Diagnostics == nullptr)
			{
				continue;
			}

			for (const FAngelscriptEngine::FDiagnostic& Diagnostic : Diagnostics->Diagnostics)
			{
				Messages.Add(Diagnostic.Message);
				if (Diagnostic.bIsError)
				{
					++OutErrorCount;
				}
			}
		}

		return Messages;
	}
}

using namespace AngelscriptTest_Preprocessor_AngelscriptPreprocessorRestrictUsageTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptPreprocessorRestrictUsageInactiveBranchIgnoredTest,
	"Angelscript.TestModule.Preprocessor.RestrictUsage.InactiveBranchIgnored",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptPreprocessorRestrictUsageInactiveBranchIgnoredTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	TUniquePtr<FAngelscriptEngine> OwnedEngine = CreateRestrictUsageEditorEngine();
	if (!TestNotNull(TEXT("RestrictUsage inactive-branch test should create an editor-configured engine"), OwnedEngine.Get()))
	{
		return false;
	}

	FAngelscriptEngine& Engine = *OwnedEngine;
	ASTEST_BEGIN_FULL

	bPassed &= TestTrue(
		TEXT("RestrictUsage inactive-branch test should run with EDITOR enabled"),
		FAngelscriptEngine::ShouldUseEditorScriptsForCurrentContext());

	static const FName ModuleName(TEXT("Game.Preprocessor.RestrictUsage.InactiveBranchIgnored"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
	};

	const FString RelativeScriptPath = TEXT("Game/Preprocessor/RestrictUsage/InactiveBranchIgnored.as");
	const FString ScriptSource = TEXT(
		"#if !EDITOR\n"
		"#restrict usage disallow Runtime.*\n"
		"#endif\n"
		"int Entry()\n"
		"{\n"
		"    return 7;\n"
		"}\n");
	const FString AbsoluteScriptPath = WriteRestrictUsageFixture(RelativeScriptPath, ScriptSource);

	Engine.ResetDiagnostics();

	FAngelscriptPreprocessor Preprocessor;
	Preprocessor.AddFile(RelativeScriptPath, AbsoluteScriptPath);

	const bool bPreprocessSucceeded = Preprocessor.Preprocess();
	const TArray<TSharedRef<FAngelscriptModuleDesc>> Modules = Preprocessor.GetModulesToCompile();

	int32 PreprocessErrorCount = 0;
	const TArray<FString> PreprocessDiagnosticMessages = CollectRestrictUsageDiagnosticMessages(
		Engine,
		{AbsoluteScriptPath},
		PreprocessErrorCount);

	bPassed &= TestTrue(
		TEXT("RestrictUsage in an inactive branch should preprocess successfully"),
		bPreprocessSucceeded);
	bPassed &= TestEqual(
		TEXT("RestrictUsage in an inactive branch should not emit preprocess errors"),
		PreprocessErrorCount,
		0);
	bPassed &= TestEqual(
		TEXT("RestrictUsage in an inactive branch should keep exactly one module descriptor"),
		Modules.Num(),
		1);
	bPassed &= TestEqual(
		TEXT("RestrictUsage in an inactive branch should keep preprocessing diagnostics empty"),
		PreprocessDiagnosticMessages.Num(),
		0);

	const FAngelscriptModuleDesc* Module = Modules.Num() > 0 ? &Modules[0].Get() : nullptr;
	bPassed &= TestNotNull(
		TEXT("RestrictUsage in an inactive branch should still produce a module descriptor"),
		Module);

	if (Module != nullptr && Module->Code.Num() > 0)
	{
		bPassed &= TestFalse(
			TEXT("RestrictUsage in an inactive branch should strip raw #restrict text from processed code"),
			Module->Code[0].Code.Contains(TEXT("#restrict")));
		bPassed &= TestFalse(
			TEXT("RestrictUsage in an inactive branch should not leak the dead-branch pattern into processed code"),
			Module->Code[0].Code.Contains(TEXT("Runtime.*")));
#if WITH_EDITOR
		bPassed &= TestEqual(
			TEXT("RestrictUsage in an inactive branch should not record usage restriction metadata"),
			Module->UsageRestrictions.Num(),
			0);
#endif
	}

	Engine.ResetDiagnostics();

	FAngelscriptCompileTraceSummary Summary;
	const bool bCompiled = CompileModuleWithSummary(
		&Engine,
		ECompileType::SoftReloadOnly,
		ModuleName,
		RelativeScriptPath,
		ScriptSource,
		true,
		Summary,
		true);

	bPassed &= TestTrue(
		TEXT("RestrictUsage inactive branch should still compile through the preprocessor pipeline"),
		bCompiled);
	bPassed &= TestEqual(
		TEXT("RestrictUsage inactive branch should keep compile diagnostics empty"),
		Summary.Diagnostics.Num(),
		0);

	int32 EntryResult = 0;
	const bool bExecuted = bCompiled
		&& ExecuteIntFunction(&Engine, RelativeScriptPath, ModuleName, TEXT("int Entry()"), EntryResult);
	bPassed &= TestTrue(
		TEXT("RestrictUsage inactive branch should execute the compiled Entry function"),
		bExecuted);
	if (bExecuted)
	{
		bPassed &= TestEqual(
			TEXT("RestrictUsage inactive branch should preserve the active branch result"),
			EntryResult,
			7);
	}

	ASTEST_END_FULL
	return bPassed;
}

#endif
