#include "../Shared/AngelscriptTestEngineHelper.h"
#include "../Shared/AngelscriptTestMacros.h"

#include "Preprocessor/AngelscriptPreprocessor.h"

#include "HAL/FileManager.h"
#include "Misc/AutomationTest.h"
#include "Misc/FileHelper.h"
#include "Misc/Paths.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace CompilerPipelineControlFlowTest
{
	static const FName ModuleName(TEXT("Tests.Compiler.RangeBasedForRewriteSupportsBlockAndSingleLine"));
	static const FString RelativeScriptPath(TEXT("Tests/Compiler/RangeBasedForRewriteSupportsBlockAndSingleLine.as"));

	FString GetFixtureRoot()
	{
		return FPaths::Combine(FPaths::ProjectSavedDir(), TEXT("Automation"), TEXT("CompilerControlFlowFixtures"));
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

	int32 CountOccurrences(const FString& Haystack, const FString& Needle)
	{
		if (Needle.IsEmpty())
		{
			return 0;
		}

		int32 Count = 0;
		int32 SearchFrom = 0;
		while (true)
		{
			const int32 FoundAt = Haystack.Find(Needle, ESearchCase::CaseSensitive, ESearchDir::FromStart, SearchFrom);
			if (FoundAt == INDEX_NONE)
			{
				break;
			}

			++Count;
			SearchFrom = FoundAt + Needle.Len();
		}

		return Count;
	}
}

using namespace CompilerPipelineControlFlowTest;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptCompilerRangeBasedForRewriteSupportsBlockAndSingleLineTest,
	"Angelscript.TestModule.Compiler.EndToEnd.RangeBasedForRewriteSupportsBlockAndSingleLine",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptCompilerRangeBasedForRewriteSupportsBlockAndSingleLineTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	const FString ScriptSource = TEXT(R"AS(
int Entry()
{
	TArray<int> Values;
	Values.Add(20);
	Values.Add(22);

	int BlockSum = 0;
	for (const int Value : Values)
	{
		BlockSum += Value;
	}

	int SingleLineSum = 0;
	for (const int Value : Values) SingleLineSum += Value;

	return BlockSum * 100 + SingleLineSum;
}
)AS");

	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	const FString AbsoluteScriptPath = CompilerPipelineControlFlowTest::WriteFixture(
		CompilerPipelineControlFlowTest::RelativeScriptPath,
		ScriptSource);
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*CompilerPipelineControlFlowTest::ModuleName.ToString());
		IFileManager::Get().Delete(*AbsoluteScriptPath, false, true);
	};

	Engine.ResetDiagnostics();

	FAngelscriptPreprocessor Preprocessor;
	Preprocessor.AddFile(CompilerPipelineControlFlowTest::RelativeScriptPath, AbsoluteScriptPath);

	const bool bPreprocessSucceeded = Preprocessor.Preprocess();
	const TArray<TSharedRef<FAngelscriptModuleDesc>> Modules = Preprocessor.GetModulesToCompile();

	int32 PreprocessErrorCount = 0;
	const TArray<FString> PreprocessMessages = CompilerPipelineControlFlowTest::CollectDiagnosticMessages(
		Engine,
		AbsoluteScriptPath,
		PreprocessErrorCount);
	const FString ProcessedCode = (Modules.Num() > 0 && Modules[0]->Code.Num() > 0)
		? Modules[0]->Code[0].Code
		: FString();

	bPassed &= TestTrue(
		TEXT("Range-based for rewrite scenario should preprocess successfully"),
		bPreprocessSucceeded);
	bPassed &= TestEqual(
		TEXT("Range-based for rewrite scenario should not emit preprocessing errors"),
		PreprocessErrorCount,
		0);
	bPassed &= TestEqual(
		TEXT("Range-based for rewrite scenario should keep preprocessing diagnostics empty"),
		PreprocessMessages.Num(),
		0);
	bPassed &= TestEqual(
		TEXT("Range-based for rewrite scenario should produce exactly one module descriptor"),
		Modules.Num(),
		1);
	if (Modules.Num() > 0)
	{
		bPassed &= TestEqual(
			TEXT("Range-based for rewrite scenario should preserve the expected module name"),
			Modules[0]->ModuleName,
			CompilerPipelineControlFlowTest::ModuleName.ToString());
	}

	bPassed &= TestEqual(
		TEXT("Range-based for rewrite scenario should rewrite both loops into iterator advance conditions"),
		CompilerPipelineControlFlowTest::CountOccurrences(ProcessedCode, TEXT("_Iterator.CanProceed; )")),
		2);
	bPassed &= TestEqual(
		TEXT("Range-based for rewrite scenario should rewrite both loops into iterator proceed calls"),
		CompilerPipelineControlFlowTest::CountOccurrences(ProcessedCode, TEXT("_Iterator.Proceed();")),
		2);
	bPassed &= TestTrue(
		TEXT("Range-based for rewrite scenario should materialize the const-ref storage marker in processed code"),
		ProcessedCode.Contains(TEXT("__auto_constref_type")));

	Engine.ResetDiagnostics();

	FAngelscriptCompileTraceSummary Summary;
	const bool bCompiled = CompileModuleWithSummary(
		&Engine,
		ECompileType::SoftReloadOnly,
		CompilerPipelineControlFlowTest::ModuleName,
		CompilerPipelineControlFlowTest::RelativeScriptPath,
		ScriptSource,
		true,
		Summary,
		true);

	bPassed &= TestTrue(
		TEXT("Range-based for rewrite scenario should compile through the normal preprocessor pipeline"),
		bCompiled);
	bPassed &= TestTrue(
		TEXT("Range-based for rewrite scenario should report that it used the preprocessor"),
		Summary.bUsedPreprocessor);
	bPassed &= TestTrue(
		TEXT("Range-based for rewrite scenario should mark compile succeeded in the summary"),
		Summary.bCompileSucceeded);
	bPassed &= TestEqual(
		TEXT("Range-based for rewrite scenario should keep compile diagnostics empty"),
		Summary.Diagnostics.Num(),
		0);

	int32 EntryResult = 0;
	const bool bExecuted = bCompiled
		&& ExecuteIntFunction(
			&Engine,
			CompilerPipelineControlFlowTest::RelativeScriptPath,
			CompilerPipelineControlFlowTest::ModuleName,
			TEXT("int Entry()"),
			EntryResult);
	bPassed &= TestTrue(
		TEXT("Range-based for rewrite scenario should execute the compiled Entry function"),
		bExecuted);
	if (bExecuted)
	{
		bPassed &= TestEqual(
			TEXT("Range-based for rewrite scenario should keep both block and single-line loop sums executable"),
			EntryResult,
			4242);
	}

	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

#endif
