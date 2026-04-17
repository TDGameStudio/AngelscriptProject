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

namespace PreprocessorLiteralTest
{
	static const FName ModuleName(TEXT("Tests.Preprocessor.Literals.NameLiteralRoundTrip"));
	static const FString RelativeScriptPath(TEXT("Tests/Preprocessor/Literals/NameLiteralRoundTrip.as"));

	struct FPrefixedLiteralBoundaryScenario
	{
		const TCHAR* Label;
		const TCHAR* RelativePath;
		const TCHAR* ScriptSource;
		const TCHAR* PreservedToken;
		const TCHAR* UnexpectedRewriteMarker;
		int32 ExpectedErrorRow;
	};

	FString GetFixtureRoot()
	{
		return FPaths::Combine(FPaths::ProjectSavedDir(), TEXT("Automation"), TEXT("PreprocessorLiteralFixtures"));
	}

	FString WriteFixture(const FString& RelativePath, const FString& Contents)
	{
		const FString AbsolutePath = FPaths::Combine(GetFixtureRoot(), RelativePath);
		IFileManager::Get().MakeDirectory(*FPaths::GetPath(AbsolutePath), true);
		FFileHelper::SaveStringToFile(Contents, *AbsolutePath);
		return AbsolutePath;
	}

	const FAngelscriptModuleDesc* FindModuleByName(
		const TArray<TSharedRef<FAngelscriptModuleDesc>>& Modules,
		const FString& ExpectedModuleName)
	{
		for (const TSharedRef<FAngelscriptModuleDesc>& Module : Modules)
		{
			if (Module->ModuleName == ExpectedModuleName)
			{
				return &Module.Get();
			}
		}

		return nullptr;
	}

	FString GetFixtureModuleName(const FString& RelativePath)
	{
		return FPaths::ChangeExtension(RelativePath, TEXT(""))
			.Replace(TEXT("/"), TEXT("."))
			.Replace(TEXT("\\"), TEXT("."));
	}

	int32 CountErrorDiagnostics(const FAngelscriptEngine::FDiagnostics* Diagnostics)
	{
		if (Diagnostics == nullptr)
		{
			return 0;
		}

		int32 ErrorCount = 0;
		for (const FAngelscriptEngine::FDiagnostic& Diagnostic : Diagnostics->Diagnostics)
		{
			if (Diagnostic.bIsError)
			{
				++ErrorCount;
			}
		}

		return ErrorCount;
	}

	const FAngelscriptCompileTraceDiagnosticSummary* FindFirstErrorDiagnostic(const FAngelscriptCompileTraceSummary& Summary)
	{
		for (const FAngelscriptCompileTraceDiagnosticSummary& Diagnostic : Summary.Diagnostics)
		{
			if (Diagnostic.bIsError)
			{
				return &Diagnostic;
			}
		}

		return nullptr;
	}

	TArray<int32> ExtractStaticNameIndices(const FString& ProcessedCode)
	{
		static const FString Marker(TEXT("__STATIC_NAME("));

		TArray<int32> Indices;
		int32 SearchFrom = 0;
		while (true)
		{
			const int32 MarkerIndex = ProcessedCode.Find(Marker, ESearchCase::CaseSensitive, ESearchDir::FromStart, SearchFrom);
			if (MarkerIndex == INDEX_NONE)
			{
				break;
			}

			const int32 NumberStart = MarkerIndex + Marker.Len();
			const int32 NumberEnd = ProcessedCode.Find(TEXT(")"), ESearchCase::CaseSensitive, ESearchDir::FromStart, NumberStart);
			if (NumberEnd == INDEX_NONE)
			{
				break;
			}

			Indices.Add(FCString::Atoi(*ProcessedCode.Mid(NumberStart, NumberEnd - NumberStart)));
			SearchFrom = NumberEnd + 1;
		}

		return Indices;
	}

	bool RunPrefixedLiteralBoundaryScenario(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		const FPrefixedLiteralBoundaryScenario& Scenario)
	{
		bool bPassed = true;
		const FString RelativePath(Scenario.RelativePath);
		const FString ScriptSource(Scenario.ScriptSource);
		const FString AbsoluteScriptPath = WriteFixture(RelativePath, ScriptSource);
		const FString FixtureModuleName = GetFixtureModuleName(RelativePath);
		ON_SCOPE_EXIT
		{
			Engine.DiscardModule(*FixtureModuleName);
			IFileManager::Get().Delete(*AbsoluteScriptPath, false, true);
		};

		Engine.ResetDiagnostics();
		Engine.LastEmittedDiagnostics.Empty();

		FAngelscriptPreprocessor Preprocessor;
		Preprocessor.AddFile(RelativePath, AbsoluteScriptPath);

		const bool bPreprocessSucceeded = Preprocessor.Preprocess();
		const TArray<TSharedRef<FAngelscriptModuleDesc>> Modules = Preprocessor.GetModulesToCompile();
		const FAngelscriptModuleDesc* Module = FindModuleByName(Modules, FixtureModuleName);
		const FString ProcessedCode = (Module != nullptr && Module->Code.Num() > 0)
			? Module->Code[0].Code
			: FString();
		const FAngelscriptEngine::FDiagnostics* PreprocessDiagnostics = Engine.Diagnostics.Find(AbsoluteScriptPath);

		bPassed &= Test.TestTrue(
			FString::Printf(TEXT("%s should preprocess successfully"), Scenario.Label),
			bPreprocessSucceeded);
		bPassed &= Test.TestEqual(
			FString::Printf(TEXT("%s should emit exactly one module descriptor during preprocessing"), Scenario.Label),
			Modules.Num(),
			1);
		bPassed &= Test.TestNotNull(
			FString::Printf(TEXT("%s should keep the fixture module descriptor available"), Scenario.Label),
			Module);
		bPassed &= Test.TestEqual(
			FString::Printf(TEXT("%s should keep preprocessing diagnostics empty"), Scenario.Label),
			CountErrorDiagnostics(PreprocessDiagnostics),
			0);

		if (Module != nullptr)
		{
			bPassed &= Test.TestEqual(
				FString::Printf(TEXT("%s should keep exactly one generated code section"), Scenario.Label),
				Module->Code.Num(),
				1);
			bPassed &= Test.TestTrue(
				FString::Printf(TEXT("%s should preserve the malformed token in processed code"), Scenario.Label),
				ProcessedCode.Contains(Scenario.PreservedToken));
			bPassed &= Test.TestFalse(
				FString::Printf(TEXT("%s should not rewrite the malformed token into helper code"), Scenario.Label),
				ProcessedCode.Contains(Scenario.UnexpectedRewriteMarker));
		}

		Engine.ResetDiagnostics();
		Engine.LastEmittedDiagnostics.Empty();

		FAngelscriptCompileTraceSummary Summary;
		const bool bCompiled = CompileModuleWithSummary(
			&Engine,
			ECompileType::SoftReloadOnly,
			FName(*FixtureModuleName),
			RelativePath,
			ScriptSource,
			true,
			Summary,
			true);

		bPassed &= Test.TestFalse(
			FString::Printf(TEXT("%s should fail during the real compile pipeline"), Scenario.Label),
			bCompiled);
		bPassed &= Test.TestTrue(
			FString::Printf(TEXT("%s should report that compile used the preprocessor"), Scenario.Label),
			Summary.bUsedPreprocessor);
		bPassed &= Test.TestTrue(
			FString::Printf(TEXT("%s should capture at least one compile diagnostic"), Scenario.Label),
			Summary.Diagnostics.Num() > 0);

		const FAngelscriptCompileTraceDiagnosticSummary* FirstErrorDiagnostic = FindFirstErrorDiagnostic(Summary);
		bPassed &= Test.TestNotNull(
			FString::Printf(TEXT("%s should expose a first error diagnostic"), Scenario.Label),
			FirstErrorDiagnostic);
		if (FirstErrorDiagnostic != nullptr)
		{
			bPassed &= Test.TestEqual(
				FString::Printf(TEXT("%s should keep the first compile error pinned to the malformed token line"), Scenario.Label),
				FirstErrorDiagnostic->Row,
				Scenario.ExpectedErrorRow);
			bPassed &= Test.TestTrue(
				FString::Printf(TEXT("%s should keep the first compile error on a concrete source column"), Scenario.Label),
				FirstErrorDiagnostic->Column > 0);
		}

		return bPassed;
	}
}

using namespace PreprocessorLiteralTest;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptPreprocessorNameLiteralRoundTripTest,
	"Angelscript.TestModule.Preprocessor.Literals.NameLiteralRoundTrip",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptPreprocessorPrefixedLiteralsRequireTokenBoundaryTest,
	"Angelscript.TestModule.Preprocessor.Literals.PrefixedLiteralsRequireTokenBoundary",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptPreprocessorNameLiteralRoundTripTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	const FString ScriptSource = TEXT(R"AS(
int Entry()
{
	FName A = n"Alpha";
	FName B = n"Alpha";
	FName C = n"Beta";
	return A == B && A != C ? 42 : 0;
}
)AS");

	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	const FString AbsoluteScriptPath = PreprocessorLiteralTest::WriteFixture(
		PreprocessorLiteralTest::RelativeScriptPath,
		ScriptSource);
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*PreprocessorLiteralTest::ModuleName.ToString());
		IFileManager::Get().Delete(*AbsoluteScriptPath, false, true);
	};

	Engine.ResetDiagnostics();

	FAngelscriptPreprocessor Preprocessor;
	Preprocessor.AddFile(PreprocessorLiteralTest::RelativeScriptPath, AbsoluteScriptPath);

	const bool bPreprocessSucceeded = Preprocessor.Preprocess();
	const TArray<TSharedRef<FAngelscriptModuleDesc>> Modules = Preprocessor.GetModulesToCompile();
	const FAngelscriptModuleDesc* LiteralModule = PreprocessorLiteralTest::FindModuleByName(
		Modules,
		PreprocessorLiteralTest::ModuleName.ToString());
	const FString ProcessedCode = (LiteralModule != nullptr && LiteralModule->Code.Num() > 0)
		? LiteralModule->Code[0].Code
		: FString();
	const FAngelscriptEngine::FDiagnostics* PreprocessDiagnostics = Engine.Diagnostics.Find(AbsoluteScriptPath);
	const TArray<int32> StaticNameIndices = PreprocessorLiteralTest::ExtractStaticNameIndices(ProcessedCode);

	bPassed &= TestTrue(
		TEXT("Name literal round-trip should preprocess successfully"),
		bPreprocessSucceeded);
	bPassed &= TestEqual(
		TEXT("Name literal round-trip should emit exactly one module descriptor"),
		Modules.Num(),
		1);
	bPassed &= TestNotNull(
		TEXT("Name literal round-trip should emit the expected module descriptor"),
		LiteralModule);
	if (LiteralModule != nullptr)
	{
		bPassed &= TestEqual(
			TEXT("Name literal round-trip should keep exactly one code section"),
			LiteralModule->Code.Num(),
			1);
		bPassed &= TestEqual(
			TEXT("Name literal round-trip should normalize the module name from the relative filename"),
			LiteralModule->ModuleName,
			PreprocessorLiteralTest::ModuleName.ToString());
	}

	bPassed &= TestTrue(
		TEXT("Name literal round-trip should keep preprocessing diagnostics empty"),
		PreprocessDiagnostics == nullptr || PreprocessDiagnostics->Diagnostics.Num() == 0);
	bPassed &= TestFalse(
		TEXT("Name literal round-trip should remove the original Alpha name literal text from processed code"),
		ProcessedCode.Contains(TEXT("n\"Alpha\"")));
	bPassed &= TestFalse(
		TEXT("Name literal round-trip should remove the original Beta name literal text from processed code"),
		ProcessedCode.Contains(TEXT("n\"Beta\"")));
	bPassed &= TestTrue(
		TEXT("Name literal round-trip should rewrite literals into __STATIC_NAME references"),
		ProcessedCode.Contains(TEXT("__STATIC_NAME(")));
	bPassed &= TestEqual(
		TEXT("Name literal round-trip should materialize exactly three static-name references for the three literals"),
		StaticNameIndices.Num(),
		3);
	if (StaticNameIndices.Num() == 3)
	{
		bPassed &= TestEqual(
			TEXT("Name literal round-trip should reuse the same static-name index for duplicate Alpha literals"),
			StaticNameIndices[0],
			StaticNameIndices[1]);
		bPassed &= TestTrue(
			TEXT("Name literal round-trip should assign a different static-name index to Beta"),
			StaticNameIndices[2] != StaticNameIndices[0]);
	}

	Engine.ResetDiagnostics();

	FAngelscriptCompileTraceSummary Summary;
	const bool bCompiled = CompileModuleWithSummary(
		&Engine,
		ECompileType::SoftReloadOnly,
		PreprocessorLiteralTest::ModuleName,
		PreprocessorLiteralTest::RelativeScriptPath,
		ScriptSource,
		true,
		Summary,
		true);

	bPassed &= TestTrue(
		TEXT("Name literal round-trip should compile through the normal preprocessor pipeline"),
		bCompiled);
	bPassed &= TestTrue(
		TEXT("Name literal round-trip should report that compilation used the preprocessor"),
		Summary.bUsedPreprocessor);
	bPassed &= TestTrue(
		TEXT("Name literal round-trip should mark compile succeeded in the summary"),
		Summary.bCompileSucceeded);
	bPassed &= TestEqual(
		TEXT("Name literal round-trip should report FullyHandled compile result"),
		static_cast<int32>(Summary.CompileResult),
		static_cast<int32>(ECompileResult::FullyHandled));
	bPassed &= TestEqual(
		TEXT("Name literal round-trip should keep compile diagnostics empty"),
		Summary.Diagnostics.Num(),
		0);
	bPassed &= TestEqual(
		TEXT("Name literal round-trip should compile exactly one module descriptor"),
		Summary.ModuleDescCount,
		1);
	bPassed &= TestEqual(
		TEXT("Name literal round-trip should compile exactly one module"),
		Summary.CompiledModuleCount,
		1);

	int32 EntryResult = 0;
	const bool bExecuted = bCompiled
		&& ExecuteIntFunction(
			&Engine,
			PreprocessorLiteralTest::RelativeScriptPath,
			PreprocessorLiteralTest::ModuleName,
			TEXT("int Entry()"),
			EntryResult);
	bPassed &= TestTrue(
		TEXT("Name literal round-trip should execute the compiled Entry function"),
		bExecuted);
	if (bExecuted)
	{
		bPassed &= TestEqual(
			TEXT("Name literal round-trip should keep duplicate-name equality and distinct-name inequality executable after rewrite"),
			EntryResult,
			42);
	}

	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

bool FAngelscriptPreprocessorPrefixedLiteralsRequireTokenBoundaryTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	const TArray<PreprocessorLiteralTest::FPrefixedLiteralBoundaryScenario> Scenarios = {
		{
			TEXT("Name literal token boundary"),
			TEXT("Tests/Preprocessor/Literals/PrefixedNameLiteralRequiresTokenBoundary.as"),
			TEXT(
				"void Probe()\n"
				"{\n"
				"    Actionn\"Tag\";\n"
				"}\n"),
			TEXT("Actionn\"Tag\""),
			TEXT("__STATIC_NAME("),
			3
		},
		{
			TEXT("Format string token boundary"),
			TEXT("Tests/Preprocessor/Literals/PrefixedFormatLiteralRequiresTokenBoundary.as"),
			TEXT(
				"void Probe()\n"
				"{\n"
				"    Valuef\"{123}\";\n"
				"}\n"),
			TEXT("Valuef\"{123}\""),
			TEXT("(FString()"),
			3
		}
	};

	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	for (const PreprocessorLiteralTest::FPrefixedLiteralBoundaryScenario& Scenario : Scenarios)
	{
		bPassed &= PreprocessorLiteralTest::RunPrefixedLiteralBoundaryScenario(*this, Engine, Scenario);
	}

	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

#endif
