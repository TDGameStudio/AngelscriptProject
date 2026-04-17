#include "../Shared/AngelscriptTestUtilities.h"
#include "../Shared/AngelscriptTestMacros.h"

#include "Preprocessor/AngelscriptPreprocessor.h"

#include "HAL/FileManager.h"
#include "Misc/AutomationTest.h"
#include "Misc/FileHelper.h"
#include "Misc/Paths.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace AngelscriptTest_Preprocessor_AngelscriptPreprocessorDirectiveWhitespaceTests_Private
{
	TUniquePtr<FAngelscriptEngine> CreateDirectiveWhitespaceEngine()
	{
		FAngelscriptEngineConfig Config;
		Config.bIsEditor = true;

		FAngelscriptEngineDependencies Dependencies = FAngelscriptEngineDependencies::CreateDefault();
		return FAngelscriptEngine::CreateTestingFullEngine(Config, Dependencies);
	}

	FString GetDirectiveWhitespaceFixtureRoot()
	{
		return FPaths::Combine(FPaths::ProjectSavedDir(), TEXT("Automation"), TEXT("PreprocessorDirectiveWhitespaceFixtures"));
	}

	FString WriteDirectiveWhitespaceFixture(const FString& RelativeScriptPath, const FString& Contents)
	{
		const FString AbsolutePath = FPaths::Combine(GetDirectiveWhitespaceFixtureRoot(), RelativeScriptPath);
		IFileManager::Get().MakeDirectory(*FPaths::GetPath(AbsolutePath), true);
		FFileHelper::SaveStringToFile(Contents, *AbsolutePath);
		return AbsolutePath;
	}

	TArray<FString> CollectDirectiveWhitespaceDiagnosticMessages(
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

	bool SummaryContainsMessage(
		const FAngelscriptCompileTraceSummary& Summary,
		const FString& Needle)
	{
		return Summary.Diagnostics.ContainsByPredicate(
			[&Needle](const FAngelscriptCompileTraceDiagnosticSummary& Diagnostic)
			{
				return Diagnostic.Message.Contains(Needle);
			});
	}
}

using namespace AngelscriptTest_Preprocessor_AngelscriptPreprocessorDirectiveWhitespaceTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptPreprocessorTabSeparatedDirectiveParsingTest,
	"Angelscript.TestModule.Preprocessor.Directives.TabSeparatedDirectiveParsing",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptPreprocessorTabSeparatedDirectiveParsingTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	TUniquePtr<FAngelscriptEngine> OwnedEngine = CreateDirectiveWhitespaceEngine();
	if (!TestNotNull(TEXT("Tab-separated directive test should create an editor-configured engine"), OwnedEngine.Get()))
	{
		return false;
	}

	FAngelscriptEngine& Engine = *OwnedEngine;
	ASTEST_BEGIN_FULL

	bPassed &= TestTrue(
		TEXT("Tab-separated directive test should run with EDITOR flag enabled in the active engine context"),
		FAngelscriptEngine::ShouldUseEditorScriptsForCurrentContext());

	static const FName ModuleName(TEXT("Game.Preprocessor.Directives.TabSeparatedDirectiveParsing"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
	};

	const FString RelativeScriptPath = TEXT("Game/Preprocessor/Directives/TabSeparatedDirectiveParsing.as");
	const FString ScriptSource = TEXT(
		"#if\tEDITOR\n"
		"#ifdef\tEDITOR\n"
		"int Entry()\n"
		"{\n"
		"    return 74;\n"
		"}\n"
		"#else\n"
		"int Entry()\n"
		"{\n"
		"    return 704;\n"
		"}\n"
		"#endif\n"
		"#else\n"
		"int Entry()\n"
		"{\n"
		"    return 0;\n"
		"}\n"
		"#endif\n"
		"#restrict usage allow\tGame.*\n"
		);
	const FString AbsoluteScriptPath = WriteDirectiveWhitespaceFixture(RelativeScriptPath, ScriptSource);

	Engine.ResetDiagnostics();

	FAngelscriptPreprocessor Preprocessor;
	Preprocessor.AddFile(RelativeScriptPath, AbsoluteScriptPath);

	const bool bPreprocessSucceeded = Preprocessor.Preprocess();
	const TArray<TSharedRef<FAngelscriptModuleDesc>> Modules = Preprocessor.GetModulesToCompile();

	int32 PreprocessErrorCount = 0;
	const TArray<FString> PreprocessDiagnosticMessages = CollectDirectiveWhitespaceDiagnosticMessages(
		Engine,
		{AbsoluteScriptPath},
		PreprocessErrorCount);
	const FString PreprocessDiagnosticSummary = FString::Join(PreprocessDiagnosticMessages, TEXT("\n"));

	bPassed &= TestTrue(
		TEXT("Tab-separated directives should preprocess successfully"),
		bPreprocessSucceeded);
	bPassed &= TestEqual(
		TEXT("Tab-separated directives should keep exactly one module descriptor"),
		Modules.Num(),
		1);
	bPassed &= TestEqual(
		TEXT("Tab-separated directives should not emit preprocessing errors"),
		PreprocessErrorCount,
		0);
	bPassed &= TestTrue(
		TEXT("Tab-separated directives should keep preprocessing diagnostics empty"),
		PreprocessDiagnosticSummary.IsEmpty());

	const FAngelscriptModuleDesc* Module = Modules.Num() > 0 ? &Modules[0].Get() : nullptr;
	bPassed &= TestNotNull(
		TEXT("Tab-separated directives should still produce a preprocessed module descriptor"),
		Module);

	FString ProcessedCode;
	if (Module != nullptr && Module->Code.Num() > 0)
	{
		ProcessedCode = Module->Code[0].Code;
	}

	bPassed &= TestTrue(
		TEXT("Tab-separated nested #if/#ifdef should keep the active branch body"),
		ProcessedCode.Contains(TEXT("return 74;")));
	bPassed &= TestTrue(
		TEXT("Tab-separated nested directives should keep the Entry implementation"),
		ProcessedCode.Contains(TEXT("int Entry()")));
	bPassed &= TestFalse(
		TEXT("Tab-separated nested #ifdef should strip the inactive branch body"),
		ProcessedCode.Contains(TEXT("return 704;")));
	bPassed &= TestFalse(
		TEXT("Tab-separated outer #if should strip the inactive branch body"),
		ProcessedCode.Contains(TEXT("return 0;")));
	bPassed &= TestFalse(
		TEXT("Tab-separated directives should not leak raw #if tokens into processed code"),
		ProcessedCode.Contains(TEXT("#if")));
	bPassed &= TestFalse(
		TEXT("Tab-separated directives should not leak raw #restrict tokens into processed code"),
		ProcessedCode.Contains(TEXT("#restrict")));

#if WITH_EDITOR
	if (Module != nullptr)
	{
		bPassed &= TestEqual(
			TEXT("Tab-separated #restrict usage allow should record exactly one usage restriction"),
			Module->UsageRestrictions.Num(),
			1);
		if (Module->UsageRestrictions.Num() == 1)
		{
			bPassed &= TestTrue(
				TEXT("Tab-separated #restrict usage allow should record an allow restriction"),
				Module->UsageRestrictions[0].bIsAllow);
			bPassed &= TestEqual(
				TEXT("Tab-separated #restrict usage allow should preserve the pattern text"),
				Module->UsageRestrictions[0].Pattern,
				FString(TEXT("Game.*")));
		}
	}
#endif

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
		TEXT("Tab-separated directives should compile through the preprocessor pipeline"),
		bCompiled);
	bPassed &= TestTrue(
		TEXT("Tab-separated directives should report preprocessor usage in compile summary"),
		Summary.bUsedPreprocessor);
	bPassed &= TestEqual(
		TEXT("Tab-separated directives should keep compile diagnostics empty"),
		Summary.Diagnostics.Num(),
		0);
	bPassed &= TestFalse(
		TEXT("Tab-separated directives should not surface raw #if text in compile diagnostics"),
		SummaryContainsMessage(Summary, TEXT("#if")));
	bPassed &= TestFalse(
		TEXT("Tab-separated directives should not surface raw #restrict text in compile diagnostics"),
		SummaryContainsMessage(Summary, TEXT("#restrict")));

	int32 EntryResult = 0;
	const bool bExecuted = bCompiled
		&& ExecuteIntFunction(&Engine, RelativeScriptPath, ModuleName, TEXT("int Entry()"), EntryResult);
	bPassed &= TestTrue(
		TEXT("Tab-separated directives should still execute the compiled Entry function"),
		bExecuted);
	if (bExecuted)
	{
		bPassed &= TestEqual(
			TEXT("Tab-separated directives should keep the active branch result"),
			EntryResult,
			74);
	}

	ASTEST_END_FULL
	return bPassed;
}

#endif
