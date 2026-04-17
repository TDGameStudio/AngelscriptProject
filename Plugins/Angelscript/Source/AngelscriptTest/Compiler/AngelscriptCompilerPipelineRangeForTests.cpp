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

namespace CompilerPipelineRangeForTest
{
	static const FName ModuleName(TEXT("Tests.Compiler.RangeBasedForRewriteSkipsStringAndCommentLiterals"));
	static const FString RelativeScriptPath(TEXT("Tests/Compiler/RangeBasedForRewriteSkipsStringAndCommentLiterals.as"));
	static const FString RawLoopText(TEXT("for (const int Value : Values)"));
	static const FString StringLiteralToken(TEXT("\"for (const int Value : Values)\""));
	static const FString LineCommentToken(TEXT("// for (const int Value : Values)"));
	static const FString BlockCommentToken(TEXT("/* for (const int Value : Values) */"));
	static const int32 ExpectedRawLoopTextOccurrences = 4;
	static const int32 ExpectedEntryResult = 42;

	FString GetFixtureRoot()
	{
		return FPaths::Combine(FPaths::ProjectSavedDir(), TEXT("Automation"), TEXT("CompilerRangeForFixtures"));
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

	FString JoinMessages(const TArray<FString>& Messages)
	{
		return FString::Join(Messages, TEXT(" | "));
	}

	FString JoinDiagnostics(const TArray<FAngelscriptCompileTraceDiagnosticSummary>& Diagnostics)
	{
		TArray<FString> Lines;
		for (const FAngelscriptCompileTraceDiagnosticSummary& Diagnostic : Diagnostics)
		{
			Lines.Add(FString::Printf(
				TEXT("[%s] %s(%d:%d) %s"),
				Diagnostic.bIsError ? TEXT("Error") : (Diagnostic.bIsInfo ? TEXT("Info") : TEXT("Warning")),
				*Diagnostic.Section,
				Diagnostic.Row,
				Diagnostic.Column,
				*Diagnostic.Message));
		}

		return FString::Join(Lines, TEXT(" | "));
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

using namespace CompilerPipelineRangeForTest;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptCompilerRangeBasedForRewriteSkipsStringAndCommentLiteralsTest,
	"Angelscript.TestModule.Compiler.EndToEnd.RangeBasedForRewriteSkipsStringAndCommentLiterals",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptCompilerRangeBasedForRewriteSkipsStringAndCommentLiteralsTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	const FString ScriptSource = TEXT(R"AS(
int Entry()
{
	TArray<int> Values;
	Values.Add(20);
	Values.Add(22);

	FString LoopText = "for (const int Value : Values)";
	// for (const int Value : Values)
	/* for (const int Value : Values) */

	int Sum = 0;
	for (const int Value : Values)
	{
		Sum += Value;
	}

	if (LoopText != "for (const int Value : Values)")
		return 10;

	return Sum;
}
)AS");

	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	const FString AbsoluteScriptPath = CompilerPipelineRangeForTest::WriteFixture(
		CompilerPipelineRangeForTest::RelativeScriptPath,
		ScriptSource);
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*CompilerPipelineRangeForTest::ModuleName.ToString());
		IFileManager::Get().Delete(*AbsoluteScriptPath, false, true);
	};

	Engine.ResetDiagnostics();

	FAngelscriptPreprocessor Preprocessor;
	Preprocessor.AddFile(CompilerPipelineRangeForTest::RelativeScriptPath, AbsoluteScriptPath);

	const bool bPreprocessSucceeded = Preprocessor.Preprocess();
	const TArray<TSharedRef<FAngelscriptModuleDesc>> Modules = Preprocessor.GetModulesToCompile();

	int32 PreprocessErrorCount = 0;
	const TArray<FString> PreprocessMessages = CompilerPipelineRangeForTest::CollectDiagnosticMessages(
		Engine,
		AbsoluteScriptPath,
		PreprocessErrorCount);
	if (PreprocessMessages.Num() > 0)
	{
		AddInfo(FString::Printf(
			TEXT("Range-for preprocess diagnostics: %s"),
			*CompilerPipelineRangeForTest::JoinMessages(PreprocessMessages)));
	}

	const FString ProcessedCode = (Modules.Num() > 0 && Modules[0]->Code.Num() > 0)
		? Modules[0]->Code[0].Code
		: FString();

	bPassed &= TestTrue(
		TEXT("Range-based for literal/comment guard scenario should preprocess successfully"),
		bPreprocessSucceeded);
	bPassed &= TestEqual(
		TEXT("Range-based for literal/comment guard scenario should not emit preprocessing errors"),
		PreprocessErrorCount,
		0);
	bPassed &= TestEqual(
		TEXT("Range-based for literal/comment guard scenario should keep preprocessing diagnostics empty"),
		PreprocessMessages.Num(),
		0);
	bPassed &= TestEqual(
		TEXT("Range-based for literal/comment guard scenario should produce exactly one module descriptor"),
		Modules.Num(),
		1);
	if (Modules.Num() > 0)
	{
		bPassed &= TestEqual(
			TEXT("Range-based for literal/comment guard scenario should preserve the expected module name"),
			Modules[0]->ModuleName,
			CompilerPipelineRangeForTest::ModuleName.ToString());
	}

	bPassed &= TestEqual(
		TEXT("Range-based for literal/comment guard scenario should rewrite exactly one real loop into iterator advance form"),
		CompilerPipelineRangeForTest::CountOccurrences(ProcessedCode, TEXT("_Iterator.CanProceed; )")),
		1);
	bPassed &= TestEqual(
		TEXT("Range-based for literal/comment guard scenario should rewrite exactly one real loop into iterator proceed form"),
		CompilerPipelineRangeForTest::CountOccurrences(ProcessedCode, TEXT("_Iterator.Proceed();")),
		1);
	bPassed &= TestEqual(
		TEXT("Range-based for literal/comment guard scenario should preserve the raw loop text only inside the two strings and two comments"),
		CompilerPipelineRangeForTest::CountOccurrences(ProcessedCode, CompilerPipelineRangeForTest::RawLoopText),
		CompilerPipelineRangeForTest::ExpectedRawLoopTextOccurrences);
	bPassed &= TestTrue(
		TEXT("Range-based for literal/comment guard scenario should preserve the exact string literal payload"),
		ProcessedCode.Contains(CompilerPipelineRangeForTest::StringLiteralToken));
	bPassed &= TestTrue(
		TEXT("Range-based for literal/comment guard scenario should preserve the single-line comment payload"),
		ProcessedCode.Contains(CompilerPipelineRangeForTest::LineCommentToken));
	bPassed &= TestTrue(
		TEXT("Range-based for literal/comment guard scenario should preserve the block comment payload"),
		ProcessedCode.Contains(CompilerPipelineRangeForTest::BlockCommentToken));

	Engine.ResetDiagnostics();

	FAngelscriptCompileTraceSummary Summary;
	const bool bCompiled = CompileModuleWithSummary(
		&Engine,
		ECompileType::SoftReloadOnly,
		CompilerPipelineRangeForTest::ModuleName,
		CompilerPipelineRangeForTest::RelativeScriptPath,
		ScriptSource,
		true,
		Summary,
		true);
	if (Summary.Diagnostics.Num() > 0)
	{
		AddInfo(FString::Printf(
			TEXT("Range-for compile diagnostics: %s"),
			*CompilerPipelineRangeForTest::JoinDiagnostics(Summary.Diagnostics)));
	}

	bPassed &= TestTrue(
		TEXT("Range-based for literal/comment guard scenario should compile through the normal preprocessor pipeline"),
		bCompiled);
	bPassed &= TestTrue(
		TEXT("Range-based for literal/comment guard scenario should report that it used the preprocessor"),
		Summary.bUsedPreprocessor);
	bPassed &= TestTrue(
		TEXT("Range-based for literal/comment guard scenario should mark compile succeeded in the summary"),
		Summary.bCompileSucceeded);
	bPassed &= TestEqual(
		TEXT("Range-based for literal/comment guard scenario should keep compile diagnostics empty"),
		Summary.Diagnostics.Num(),
		0);

	int32 EntryResult = 0;
	const bool bExecuted = bCompiled
		&& ExecuteIntFunction(
			&Engine,
			CompilerPipelineRangeForTest::RelativeScriptPath,
			CompilerPipelineRangeForTest::ModuleName,
			TEXT("int Entry()"),
			EntryResult);
	bPassed &= TestTrue(
		TEXT("Range-based for literal/comment guard scenario should execute the compiled Entry function"),
		bExecuted);
	if (bExecuted)
	{
		bPassed &= TestEqual(
			TEXT("Range-based for literal/comment guard scenario should preserve the string literal while keeping the real loop executable"),
			EntryResult,
			CompilerPipelineRangeForTest::ExpectedEntryResult);
	}

	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

#endif
