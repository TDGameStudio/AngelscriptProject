#include "../Shared/AngelscriptTestUtilities.h"
#include "../Shared/AngelscriptTestMacros.h"

#include "Preprocessor/AngelscriptPreprocessor.h"

#include "HAL/FileManager.h"
#include "Misc/AutomationTest.h"
#include "Misc/FileHelper.h"
#include "Misc/Paths.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace AngelscriptTest_Preprocessor_AngelscriptPreprocessorDirectiveTests_Private
{
	TUniquePtr<FAngelscriptEngine> CreateDirectiveEditorEngine()
	{
		FAngelscriptEngineConfig Config;
		Config.bIsEditor = true;

		FAngelscriptEngineDependencies Dependencies = FAngelscriptEngineDependencies::CreateDefault();
		return FAngelscriptEngine::CreateTestingFullEngine(Config, Dependencies);
	}

	FString GetPreprocessorDirectiveFixtureRoot()
	{
		return FPaths::Combine(FPaths::ProjectSavedDir(), TEXT("Automation"), TEXT("PreprocessorDirectiveFixtures"));
	}

	FString WritePreprocessorDirectiveFixture(const FString& RelativeScriptPath, const FString& Contents)
	{
		const FString AbsolutePath = FPaths::Combine(GetPreprocessorDirectiveFixtureRoot(), RelativeScriptPath);
		IFileManager::Get().MakeDirectory(*FPaths::GetPath(AbsolutePath), true);
		FFileHelper::SaveStringToFile(Contents, *AbsolutePath);
		return AbsolutePath;
	}

	TArray<FString> CollectDiagnosticMessages(
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

	bool ContainsCompilableCode(const TArray<TSharedRef<FAngelscriptModuleDesc>>& Modules)
	{
		for (const TSharedRef<FAngelscriptModuleDesc>& Module : Modules)
		{
			for (const FAngelscriptModuleDesc::FCodeSection& Section : Module->Code)
			{
				if (!Section.Code.IsEmpty())
				{
					return true;
				}
			}
		}

		return false;
	}
}

using namespace AngelscriptTest_Preprocessor_AngelscriptPreprocessorDirectiveTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptPreprocessorIfdefRespectsBooleanFlagValueTest,
	"Angelscript.TestModule.Preprocessor.Directives.IfdefRespectsBooleanFlagValue",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptPreprocessorInactiveBranchSkipsUnknownConditionsTest,
	"Angelscript.TestModule.Preprocessor.Directives.InactiveBranchSkipsUnknownConditions",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptPreprocessorElifShortCircuitsAfterTakenBranchTest,
	"Angelscript.TestModule.Preprocessor.Directives.ElifShortCircuitsAfterTakenBranch",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptPreprocessorStringLiteralDirectiveLexerTest,
	"Angelscript.TestModule.Preprocessor.Directives.StringLiteralDoesNotTriggerDirectiveLexer",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptPreprocessorCompoundConditionReportsUnsupportedSyntaxTest,
	"Angelscript.TestModule.Preprocessor.Directives.CompoundConditionReportsUnsupportedSyntax",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptPreprocessorIfdefRespectsBooleanFlagValueTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	static const FName ModuleName(TEXT("Tests.Preprocessor.Directives.IfdefBooleanFlagValue"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
	};

	const FString RelativeScriptPath = TEXT("Tests/Preprocessor/Directives/IfdefBooleanFlagValue.as");
	const FString ScriptSource = TEXT(
		"#ifdef MYFLAG\n"
		"int IfdefValue()\n"
		"{\n"
		"    return 1;\n"
		"}\n"
		"#else\n"
		"int IfdefValue()\n"
		"{\n"
		"    return 2;\n"
		"}\n"
		"#endif\n"
		"#ifndef MYFLAG\n"
		"int IfndefValue()\n"
		"{\n"
		"    return 3;\n"
		"}\n"
		"#else\n"
		"int IfndefValue()\n"
		"{\n"
		"    return 4;\n"
		"}\n"
		"#endif\n"
		"int Entry()\n"
		"{\n"
		"    return IfdefValue() * 10 + IfndefValue();\n"
		"}\n");
	const FString AbsoluteScriptPath = WritePreprocessorDirectiveFixture(RelativeScriptPath, ScriptSource);

	Engine.ResetDiagnostics();

	FAngelscriptPreprocessor Preprocessor;
	Preprocessor.PreprocessorFlags.Add(TEXT("MYFLAG"), false);
	Preprocessor.AddFile(RelativeScriptPath, AbsoluteScriptPath);

	const bool bPreprocessSucceeded = Preprocessor.Preprocess();
	const TArray<TSharedRef<FAngelscriptModuleDesc>> Modules = Preprocessor.GetModulesToCompile();

	int32 PreprocessErrorCount = 0;
	const TArray<FString> PreprocessDiagnosticMessages = CollectDiagnosticMessages(
		Engine,
		{AbsoluteScriptPath},
		PreprocessErrorCount);
	const FString PreprocessDiagnosticSummary = FString::Join(PreprocessDiagnosticMessages, TEXT("\n"));

	bPassed &= TestTrue(
		TEXT("Boolean-valued MYFLAG should still preprocess successfully"),
		bPreprocessSucceeded);
	bPassed &= TestEqual(
		TEXT("Boolean-valued MYFLAG should not emit preprocess diagnostics"),
		PreprocessErrorCount,
		0);
	bPassed &= TestEqual(
		TEXT("Boolean-valued MYFLAG should keep exactly one module descriptor"),
		Modules.Num(),
		1);

	FString ProcessedCode;
	if (Modules.Num() > 0 && Modules[0]->Code.Num() > 0)
	{
		ProcessedCode = Modules[0]->Code[0].Code;
	}

	bPassed &= TestFalse(
		TEXT("Boolean-valued MYFLAG should not emit any preprocess messages"),
		!PreprocessDiagnosticSummary.IsEmpty());
	bPassed &= TestTrue(
		TEXT("False MYFLAG should route #ifdef to the else branch"),
		ProcessedCode.Contains(TEXT("return 2;")));
	bPassed &= TestTrue(
		TEXT("False MYFLAG should keep the #ifndef body"),
		ProcessedCode.Contains(TEXT("return 3;")));
	bPassed &= TestFalse(
		TEXT("False MYFLAG should strip the #ifdef true branch"),
		ProcessedCode.Contains(TEXT("return 1;")));
	bPassed &= TestFalse(
		TEXT("False MYFLAG should strip the #ifndef else branch"),
		ProcessedCode.Contains(TEXT("return 4;")));

	Engine.ResetDiagnostics();

	TArray<TSharedRef<FAngelscriptModuleDesc>> CompiledModules;
	const ECompileResult CompileResult = Engine.CompileModules(
		ECompileType::SoftReloadOnly,
		Modules,
		CompiledModules);
	const bool bCompiled =
		CompileResult == ECompileResult::FullyHandled
		|| CompileResult == ECompileResult::PartiallyHandled;

	int32 CompileErrorCount = 0;
	const TArray<FString> CompileDiagnosticMessages = CollectDiagnosticMessages(
		Engine,
		{AbsoluteScriptPath},
		CompileErrorCount);

	bPassed &= TestTrue(
		TEXT("Boolean-valued MYFLAG should compile after preprocessing"),
		bCompiled);
	bPassed &= TestEqual(
		TEXT("Boolean-valued MYFLAG compile should not emit diagnostics"),
		CompileErrorCount,
		0);
	bPassed &= TestEqual(
		TEXT("Boolean-valued MYFLAG should compile exactly one module"),
		CompiledModules.Num(),
		1);
	bPassed &= TestEqual(
		TEXT("Boolean-valued MYFLAG should preserve the expected preprocessed module name"),
		Modules.Num() > 0 ? Modules[0]->ModuleName : FString(),
		ModuleName.ToString());

	int32 EntryResult = 0;
	const bool bExecuted = bCompiled
		&& ExecuteIntFunction(&Engine, RelativeScriptPath, ModuleName, TEXT("int Entry()"), EntryResult);
	bPassed &= TestTrue(
		TEXT("Boolean-valued MYFLAG should execute the compiled Entry function"),
		bExecuted);
	if (bExecuted)
	{
		bPassed &= TestEqual(
			TEXT("False MYFLAG should select the #ifdef else branch and the #ifndef body"),
			EntryResult,
			23);
	}

	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

bool FAngelscriptPreprocessorInactiveBranchSkipsUnknownConditionsTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	TUniquePtr<FAngelscriptEngine> OwnedEngine = CreateDirectiveEditorEngine();
	if (!TestNotNull(TEXT("Directive preprocessor test should create an editor-configured engine"), OwnedEngine.Get()))
	{
		return false;
	}

	FAngelscriptEngine& Engine = *OwnedEngine;
	ASTEST_BEGIN_FULL

	bPassed &= TestTrue(
		TEXT("Directive preprocessor test should run with EDITOR flag enabled in the active engine context"),
		FAngelscriptEngine::ShouldUseEditorScriptsForCurrentContext());

	static const FName ModuleName(TEXT("Tests.Preprocessor.Directives.InactiveUnknownConditions"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
	};

	const FString RelativeScriptPath = TEXT("Tests/Preprocessor/Directives/InactiveUnknownConditions.as");
	const FString ScriptSource = TEXT(
		"#if EDITOR\n"
		"int Entry()\n"
		"{\n"
		"    return 7;\n"
		"}\n"
		"#else\n"
		"#if UNKNOWN_FLAG\n"
		"int Entry()\n"
		"{\n"
		"    return 1;\n"
		"}\n"
		"#elif UNKNOWN_FLAG\n"
		"int Entry()\n"
		"{\n"
		"    return 2;\n"
		"}\n"
		"#else\n"
		"int Entry()\n"
		"{\n"
		"    return 3;\n"
		"}\n"
		"#endif\n"
		"#endif\n");
	const FString AbsoluteScriptPath = WritePreprocessorDirectiveFixture(RelativeScriptPath, ScriptSource);

	Engine.ResetDiagnostics();

	FAngelscriptPreprocessor Preprocessor;
	Preprocessor.AddFile(RelativeScriptPath, AbsoluteScriptPath);

	const bool bPreprocessSucceeded = Preprocessor.Preprocess();
	const TArray<TSharedRef<FAngelscriptModuleDesc>> Modules = Preprocessor.GetModulesToCompile();

	int32 PreprocessErrorCount = 0;
	const TArray<FString> PreprocessDiagnosticMessages = CollectDiagnosticMessages(
		Engine,
		{AbsoluteScriptPath},
		PreprocessErrorCount);
	const FString PreprocessDiagnosticSummary = FString::Join(PreprocessDiagnosticMessages, TEXT("\n"));

	bPassed &= TestTrue(
		TEXT("Inactive unknown preprocessor conditions should not break direct preprocessing"),
		bPreprocessSucceeded);
	bPassed &= TestEqual(
		TEXT("Inactive unknown preprocessor conditions should keep exactly one module descriptor"),
		Modules.Num(),
		1);
	bPassed &= TestEqual(
		TEXT("Inactive unknown preprocessor conditions should not emit preprocessing errors"),
		PreprocessErrorCount,
		0);
	bPassed &= TestFalse(
		TEXT("Inactive unknown preprocessor conditions should not report invalid-condition diagnostics"),
		PreprocessDiagnosticSummary.Contains(TEXT("Invalid preprocessor condition")));

	FString ProcessedCode;
	if (Modules.Num() > 0 && Modules[0]->Code.Num() > 0)
	{
		ProcessedCode = Modules[0]->Code[0].Code;
	}

	bPassed &= TestTrue(
		TEXT("Inactive unknown preprocessor conditions should preserve the active Entry implementation"),
		ProcessedCode.Contains(TEXT("return 7;")));
	bPassed &= TestFalse(
		TEXT("Inactive unknown preprocessor conditions should strip dead-branch UNKNOWN_FLAG text from processed code"),
		ProcessedCode.Contains(TEXT("UNKNOWN_FLAG")));
	bPassed &= TestFalse(
		TEXT("Inactive unknown preprocessor conditions should strip dead-branch return values from processed code"),
		ProcessedCode.Contains(TEXT("return 3;")));

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
		TEXT("Inactive unknown preprocessor conditions should still compile through the normal compile pipeline"),
		bCompiled);
	bPassed &= TestTrue(
		TEXT("Inactive unknown preprocessor conditions should report preprocessor usage in compile summary"),
		Summary.bUsedPreprocessor);
	bPassed &= TestFalse(
		TEXT("Compile summary should stay free of invalid-condition diagnostics for inactive unknown branches"),
		SummaryContainsMessage(Summary, TEXT("Invalid preprocessor condition")));

	bPassed &= TestEqual(
		TEXT("Compile summary should surface the preprocessed module name"),
		Summary.ModuleNames.Num(),
		1);

	int32 EntryResult = 0;
	const bool bExecuted = bCompiled
		&& ExecuteIntFunction(&Engine, RelativeScriptPath, ModuleName, TEXT("int Entry()"), EntryResult);
	bPassed &= TestTrue(
		TEXT("Inactive unknown preprocessor conditions should still execute the compiled Entry function"),
		bExecuted);
	if (bExecuted)
	{
		bPassed &= TestEqual(
			TEXT("Inactive unknown preprocessor conditions should keep the active branch result"),
			EntryResult,
			7);
	}

	ASTEST_END_FULL
	return bPassed;
}

bool FAngelscriptPreprocessorElifShortCircuitsAfterTakenBranchTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	TUniquePtr<FAngelscriptEngine> OwnedEngine = CreateDirectiveEditorEngine();
	if (!TestNotNull(TEXT("Directive preprocessor elif short-circuit test should create an editor-configured engine"), OwnedEngine.Get()))
	{
		return false;
	}

	FAngelscriptEngine& Engine = *OwnedEngine;
	ASTEST_BEGIN_FULL
	bPassed &= TestTrue(
		TEXT("Directive preprocessor elif short-circuit test should run with EDITOR flag enabled in the active engine context"),
		FAngelscriptEngine::ShouldUseEditorScriptsForCurrentContext());
	static const FName ModuleName(TEXT("Tests.Preprocessor.Directives.ElifShortCircuitsAfterTakenBranch"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
	};
	const FString RelativeScriptPath = TEXT("Tests/Preprocessor/Directives/ElifShortCircuitsAfterTakenBranch.as");
	const FString ScriptSource = TEXT(
		"#if EDITOR\n"
		"int Entry()\n"
		"{\n"
		"    return 7;\n"
		"}\n"
		"#elif UNKNOWN_FLAG\n"
		"int Entry()\n"
		"{\n"
		"    return 9;\n"
		"}\n"
		"#else\n"
		"int Entry()\n"
		"{\n"
		"    return 3;\n"
		"}\n"
		"#endif\n");
	const FString AbsoluteScriptPath = WritePreprocessorDirectiveFixture(RelativeScriptPath, ScriptSource);
	Engine.ResetDiagnostics();
	FAngelscriptPreprocessor Preprocessor;
	Preprocessor.AddFile(RelativeScriptPath, AbsoluteScriptPath);
	const bool bPreprocessSucceeded = Preprocessor.Preprocess();
	const TArray<TSharedRef<FAngelscriptModuleDesc>> Modules = Preprocessor.GetModulesToCompile();
	int32 PreprocessErrorCount = 0;
	const TArray<FString> PreprocessDiagnosticMessages = CollectDiagnosticMessages(
		Engine,
		{AbsoluteScriptPath},
		PreprocessErrorCount);
	const FString PreprocessDiagnosticSummary = FString::Join(PreprocessDiagnosticMessages, TEXT("\n"));
	const FString ProcessedCode = (Modules.Num() > 0 && Modules[0]->Code.Num() > 0)
		? Modules[0]->Code[0].Code
		: FString();
	bPassed &= TestTrue(
		TEXT("Taken #if branch should let direct preprocessing succeed without evaluating later #elif"),
		bPreprocessSucceeded);
	bPassed &= TestEqual(
		TEXT("Taken #if branch should keep exactly one preprocessed module descriptor"),
		Modules.Num(),
		1);
	bPassed &= TestEqual(
		TEXT("Taken #if branch should not emit preprocessing errors"),
		PreprocessErrorCount,
		0);
	bPassed &= TestTrue(
		TEXT("Taken #if branch should keep preprocessing diagnostics empty"),
		PreprocessDiagnosticSummary.IsEmpty());
	bPassed &= TestFalse(
		TEXT("Taken #if branch should not report invalid-condition diagnostics for later #elif"),
		PreprocessDiagnosticSummary.Contains(TEXT("Invalid preprocessor condition: UNKNOWN_FLAG")));
	bPassed &= TestTrue(
		TEXT("Taken #if branch should preserve the active Entry implementation in processed code"),
		ProcessedCode.Contains(TEXT("return 7;")));
	bPassed &= TestFalse(
		TEXT("Taken #if branch should strip UNKNOWN_FLAG text from processed code"),
		ProcessedCode.Contains(TEXT("UNKNOWN_FLAG")));
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
		TEXT("Taken #if branch should still compile through the normal compile pipeline"),
		bCompiled);
	bPassed &= TestTrue(
		TEXT("Taken #if branch should report preprocessor usage in compile summary"),
		Summary.bUsedPreprocessor);
	bPassed &= TestEqual(
		TEXT("Taken #if branch should keep compile summary diagnostics empty"),
		Summary.Diagnostics.Num(),
		0);
	bPassed &= TestFalse(
		TEXT("Compile summary should not report invalid-condition diagnostics for later #elif"),
		SummaryContainsMessage(Summary, TEXT("Invalid preprocessor condition: UNKNOWN_FLAG")));
	int32 EntryResult = 0;
	const bool bExecuted = bCompiled
		&& ExecuteIntFunction(&Engine, RelativeScriptPath, ModuleName, TEXT("int Entry()"), EntryResult);
	bPassed &= TestTrue(
		TEXT("Taken #if branch should execute the compiled Entry function"),
		bExecuted);
	if (bExecuted)
	{
		bPassed &= TestEqual(
			TEXT("Taken #if branch should keep the active branch result"),
			EntryResult,
			7);
	}
	ASTEST_END_FULL
	return bPassed;
}

bool FAngelscriptPreprocessorStringLiteralDirectiveLexerTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	TUniquePtr<FAngelscriptEngine> OwnedEngine = CreateDirectiveEditorEngine();
	if (!TestNotNull(TEXT("Directive string-literal test should create an editor-configured engine"), OwnedEngine.Get()))
		return false;
	FAngelscriptEngine& Engine = *OwnedEngine;
	ASTEST_BEGIN_FULL
	static const FName ModuleName(TEXT("Tests.Preprocessor.Directives.StringLiteralDoesNotTriggerDirectiveLexer"));
	ON_SCOPE_EXIT { Engine.DiscardModule(*ModuleName.ToString()); };
	const FString RelativeScriptPath = TEXT("Tests/Preprocessor/Directives/StringLiteralDoesNotTriggerDirectiveLexer.as");
	const FString ScriptSource = TEXT(R"AS(
FString BuildMarker()
{
	return "debug #if RELEASE #else keep";
}
int Entry()
{
	return BuildMarker() == "debug #if RELEASE #else keep" ? 42 : 0;
}
)AS");
	const FString AbsoluteScriptPath = WritePreprocessorDirectiveFixture(RelativeScriptPath, ScriptSource);
	Engine.ResetDiagnostics();
	FAngelscriptPreprocessor Preprocessor;
	Preprocessor.AddFile(RelativeScriptPath, AbsoluteScriptPath);
	const bool bPreprocessSucceeded = Preprocessor.Preprocess();
	const TArray<TSharedRef<FAngelscriptModuleDesc>> Modules = Preprocessor.GetModulesToCompile();
	int32 PreprocessErrorCount = 0;
	const TArray<FString> PreprocessDiagnosticMessages = CollectDiagnosticMessages(Engine, {AbsoluteScriptPath}, PreprocessErrorCount);
	const FString ProcessedCode = (Modules.Num() > 0 && Modules[0]->Code.Num() > 0) ? Modules[0]->Code[0].Code : FString();
	bPassed &= TestTrue(TEXT("String-literal #if/#else text should let preprocessing succeed"), bPreprocessSucceeded);
	bPassed &= TestEqual(TEXT("String-literal #if/#else text should keep preprocessing diagnostics empty"), PreprocessDiagnosticMessages.Num(), 0);
	bPassed &= TestEqual(TEXT("String-literal #if/#else text should not emit preprocessing errors"), PreprocessErrorCount, 0);
	bPassed &= TestTrue(TEXT("String-literal #if/#else text should survive preprocessing unchanged"), ProcessedCode.Contains(TEXT("\"debug #if RELEASE #else keep\"")));
	Engine.ResetDiagnostics();
	FAngelscriptCompileTraceSummary Summary;
	const bool bCompiled = CompileModuleWithSummary(&Engine, ECompileType::SoftReloadOnly, ModuleName, RelativeScriptPath, ScriptSource, true, Summary, true);
	bPassed &= TestTrue(TEXT("String-literal #if/#else text should compile through the preprocessor pipeline"), bCompiled);
	bPassed &= TestEqual(TEXT("String-literal #if/#else text should keep compile diagnostics empty"), Summary.Diagnostics.Num(), 0);
	int32 EntryResult = 0;
	const bool bExecuted = bCompiled && ExecuteIntFunction(&Engine, RelativeScriptPath, ModuleName, TEXT("int Entry()"), EntryResult);
	bPassed &= TestTrue(TEXT("String-literal #if/#else text should execute the compiled Entry function"), bExecuted);
	if (bExecuted)
		bPassed &= TestEqual(TEXT("String-literal #if/#else text should keep Entry() returning the string-match sentinel"), EntryResult, 42);
	ASTEST_END_FULL
	return bPassed;
}

bool FAngelscriptPreprocessorCompoundConditionReportsUnsupportedSyntaxTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	AddExpectedError(TEXT("Invalid preprocessor condition:"), EAutomationExpectedErrorFlags::Contains, 1);

	TUniquePtr<FAngelscriptEngine> OwnedEngine = CreateDirectiveEditorEngine();
	if (!TestNotNull(TEXT("Compound-condition directive test should create an editor-configured engine"), OwnedEngine.Get()))
	{
		return false;
	}

	FAngelscriptEngine& Engine = *OwnedEngine;
	ASTEST_BEGIN_FULL

	bPassed &= TestTrue(
		TEXT("Compound-condition directive test should run with EDITOR flag enabled in the active engine context"),
		FAngelscriptEngine::ShouldUseEditorScriptsForCurrentContext());

	const FString RelativeScriptPath = TEXT("Tests/Preprocessor/Directives/CompoundConditionReportsUnsupportedSyntax.as");
	const FString ScriptSource = TEXT(
		"#if EDITOR && TEST\n"
		"int Entry()\n"
		"{\n"
		"    return 7;\n"
		"}\n"
		"#endif\n");
	const FString AbsoluteScriptPath = WritePreprocessorDirectiveFixture(RelativeScriptPath, ScriptSource);

	Engine.ResetDiagnostics();
	Engine.LastEmittedDiagnostics.Empty();

	FAngelscriptPreprocessor Preprocessor;
	Preprocessor.AddFile(RelativeScriptPath, AbsoluteScriptPath);

	const bool bPreprocessSucceeded = Preprocessor.Preprocess();
	const TArray<TSharedRef<FAngelscriptModuleDesc>> Modules = Preprocessor.GetModulesToCompile();
	const FAngelscriptEngine::FDiagnostics* Diagnostics = Engine.Diagnostics.Find(AbsoluteScriptPath);

	bPassed &= TestFalse(
		TEXT("Compound #if conditions should fail direct preprocessing"),
		bPreprocessSucceeded);
	bPassed &= TestNotNull(
		TEXT("Compound #if conditions should record diagnostics for the failing file"),
		Diagnostics);
	bPassed &= TestEqual(
		TEXT("Compound #if conditions should emit exactly one preprocessing error"),
		CountErrorDiagnostics(Diagnostics),
		1);
	bPassed &= TestFalse(
		TEXT("Compound #if conditions should not leave compilable code sections behind after preprocessing fails"),
		ContainsCompilableCode(Modules));

	const bool bHasFirstDiagnostic = Diagnostics != nullptr && Diagnostics->Diagnostics.Num() > 0;
	bPassed &= TestTrue(
		TEXT("Compound #if conditions should emit a first diagnostic entry"),
		bHasFirstDiagnostic);
	if (bHasFirstDiagnostic)
	{
		const FAngelscriptEngine::FDiagnostic& FirstDiagnostic = Diagnostics->Diagnostics[0];
		bPassed &= TestEqual(
			TEXT("Compound #if conditions should report the expected invalid-condition text"),
			FirstDiagnostic.Message,
			FString(TEXT("Invalid preprocessor condition: EDITOR && TEST")));
		bPassed &= TestEqual(
			TEXT("Compound #if conditions should pin the diagnostic row to the #if line"),
			FirstDiagnostic.Row,
			1);
		bPassed &= TestEqual(
			TEXT("Compound #if conditions should keep the diagnostic column at the directive start"),
			FirstDiagnostic.Column,
			1);
	}

	ASTEST_END_FULL
	return bPassed;
}

#endif
