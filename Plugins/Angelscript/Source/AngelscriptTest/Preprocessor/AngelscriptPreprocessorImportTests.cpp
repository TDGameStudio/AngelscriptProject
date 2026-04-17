#include "../Shared/AngelscriptTestUtilities.h"
#include "../Shared/AngelscriptTestMacros.h"

#include "Preprocessor/AngelscriptPreprocessor.h"

#include "HAL/FileManager.h"
#include "Misc/AutomationTest.h"
#include "Misc/FileHelper.h"
#include "Misc/Paths.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace AngelscriptTest_Preprocessor_AngelscriptPreprocessorImportTests_Private
{
	FString GetPreprocessorImportFixtureRoot()
	{
		return FPaths::Combine(FPaths::ProjectSavedDir(), TEXT("Automation"), TEXT("PreprocessorImportFixtures"));
	}

	FString WritePreprocessorImportFixture(const FString& RelativeScriptPath, const FString& Contents)
	{
		const FString AbsolutePath = FPaths::Combine(GetPreprocessorImportFixtureRoot(), RelativeScriptPath);
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
}

using namespace AngelscriptTest_Preprocessor_AngelscriptPreprocessorImportTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptPreprocessorCircularImportChainTest,
	"Angelscript.TestModule.Preprocessor.Import.CircularDependencyReportsChain",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptPreprocessorAutomaticImportCompatibilityTest,
	"Angelscript.TestModule.Preprocessor.Import.AutomaticModeManualImportCompatibility",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptPreprocessorMissingSemicolonReportsSyntaxTest,
	"Angelscript.TestModule.Preprocessor.Import.MissingSemicolonReportsSyntax",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptPreprocessorTrailingBlockCommentImportTest,
	"Angelscript.TestModule.Preprocessor.Import.TrailingBlockCommentDoesNotPolluteModuleName",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptPreprocessorCircularImportChainTest::RunTest(const FString& Parameters)
{
	bool bPassed = false;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	Engine.ResetDiagnostics();

	const FString ModuleARelativePath = TEXT("Tests/Preprocessor/ImportCycles/CircularA.as");
	const FString ModuleAAbsolutePath = WritePreprocessorImportFixture(
		ModuleARelativePath,
		TEXT("import Tests.Preprocessor.ImportCycles.CircularB;\n")
		TEXT("int FromA()\n")
		TEXT("{\n")
		TEXT("    return FromB();\n")
		TEXT("}\n"));

	const FString ModuleBRelativePath = TEXT("Tests/Preprocessor/ImportCycles/CircularB.as");
	const FString ModuleBAbsolutePath = WritePreprocessorImportFixture(
		ModuleBRelativePath,
		TEXT("import Tests.Preprocessor.ImportCycles.CircularA;\n")
		TEXT("int FromB()\n")
		TEXT("{\n")
		TEXT("    return FromA();\n")
		TEXT("}\n"));

	AddExpectedError(
		TEXT("Detected circular import of module Tests.Preprocessor.ImportCycles.CircularA. Import chain:"),
		EAutomationExpectedErrorFlags::Contains,
		1);
	AddExpectedError(
		TEXT("=> Tests.Preprocessor.ImportCycles.CircularB"),
		EAutomationExpectedErrorFlags::Contains,
		1);
	AddExpectedError(
		TEXT("=> Tests.Preprocessor.ImportCycles.CircularA"),
		EAutomationExpectedErrorFlags::Contains,
		1);

	TGuardValue<bool> AutomaticImportGuard(Engine.bUseAutomaticImportMethod, false);
	FAngelscriptPreprocessor Preprocessor;
	Preprocessor.AddFile(ModuleARelativePath, ModuleAAbsolutePath);
	Preprocessor.AddFile(ModuleBRelativePath, ModuleBAbsolutePath);

	const bool bPreprocessSucceeded = Preprocessor.Preprocess();
	const int32 ActiveModulesBeforeCompile = Engine.GetActiveModules().Num();

	int32 ErrorCount = 0;
	const TArray<FString> DiagnosticMessages = CollectDiagnosticMessages(
		Engine,
		{ModuleAAbsolutePath, ModuleBAbsolutePath},
		ErrorCount);
	const FString DiagnosticSummary = FString::Join(DiagnosticMessages, TEXT("\n"));

	const bool bFailedAsExpected = TestFalse(
		TEXT("Circular imports should fail during preprocessing"),
		bPreprocessSucceeded);
	const bool bHasCircularError = TestTrue(
		TEXT("Circular import failure should report a dedicated diagnostic"),
		DiagnosticSummary.Contains(TEXT("Detected circular import")));
	const bool bHasModuleAInChain = TestTrue(
		TEXT("Circular import diagnostic should mention module A"),
		DiagnosticSummary.Contains(TEXT("Tests.Preprocessor.ImportCycles.CircularA")));
	const bool bHasModuleBInChain = TestTrue(
		TEXT("Circular import diagnostic should mention module B"),
		DiagnosticSummary.Contains(TEXT("Tests.Preprocessor.ImportCycles.CircularB")));
	const bool bEmittedChainEntries = TestTrue(
		TEXT("Circular import failure should emit at least the headline plus two chain entries"),
		ErrorCount >= 3);
	const bool bAvoidedCompilationSideEffects = TestEqual(
		TEXT("Circular import failure should not register new active modules on the engine"),
		ActiveModulesBeforeCompile,
		0);

	bPassed =
		bFailedAsExpected &&
		bHasCircularError &&
		bHasModuleAInChain &&
		bHasModuleBInChain &&
		bEmittedChainEntries &&
		bAvoidedCompilationSideEffects;

	ASTEST_END_SHARE_CLEAN

	return bPassed;
}

bool FAngelscriptPreprocessorAutomaticImportCompatibilityTest::RunTest(const FString& Parameters)
{
	bool bPassed = false;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	Engine.ResetDiagnostics();

	if (!TestTrue(
		TEXT("Automatic-import compatibility test should run with automatic imports enabled on the current engine"),
		Engine.ShouldUseAutomaticImportMethod()))
	{
		return false;
	}

	if (!TestTrue(
		TEXT("Automatic-import compatibility test should observe automatic imports through the active engine context"),
		FAngelscriptEngine::ShouldUseAutomaticImportMethodForCurrentContext()))
	{
		return false;
	}

	const FString SharedRelativePath = TEXT("Tests/Preprocessor/AutomaticImportCompat/Shared.as");
	const FString SharedAbsolutePath = WritePreprocessorImportFixture(
		SharedRelativePath,
		TEXT("int SharedValue()\n")
		TEXT("{\n")
		TEXT("    return 11;\n")
		TEXT("}\n"));

	const FString ImportingRelativePath = TEXT("Tests/Preprocessor/AutomaticImportCompat/UsesManualImport.as");
	const FString ImportingAbsolutePath = WritePreprocessorImportFixture(
		ImportingRelativePath,
		TEXT("import Tests.Preprocessor.AutomaticImportCompat.Shared;\n")
		TEXT("int UseShared()\n")
		TEXT("{\n")
		TEXT("    return SharedValue();\n")
		TEXT("}\n"));

	FAngelscriptPreprocessor Preprocessor;
	Preprocessor.AddFile(SharedRelativePath, SharedAbsolutePath);
	Preprocessor.AddFile(ImportingRelativePath, ImportingAbsolutePath);

	const bool bPreprocessSucceeded = Preprocessor.Preprocess();
	if (!TestTrue(
		TEXT("Automatic import mode should still preprocess a module that contains a manual import statement"),
		bPreprocessSucceeded))
	{
		return false;
	}

	const TArray<TSharedRef<FAngelscriptModuleDesc>> Modules = Preprocessor.GetModulesToCompile();
	if (!TestEqual(
		TEXT("Automatic import compatibility path should keep both provider and consumer modules available"),
		Modules.Num(),
		2))
	{
		return false;
	}

	const FAngelscriptModuleDesc* SharedModule = FindModuleByName(
		Modules,
		TEXT("Tests.Preprocessor.AutomaticImportCompat.Shared"));
	if (!TestNotNull(
		TEXT("Automatic import compatibility path should emit the shared provider module"),
		SharedModule))
	{
		return false;
	}

	const FAngelscriptModuleDesc* ImportingModule = FindModuleByName(
		Modules,
		TEXT("Tests.Preprocessor.AutomaticImportCompat.UsesManualImport"));
	if (!TestNotNull(
		TEXT("Automatic import compatibility path should emit the importing consumer module"),
		ImportingModule))
	{
		return false;
	}

	if (!TestTrue(
		TEXT("Automatic import compatibility path should emit at least one code section for the consumer module"),
		ImportingModule->Code.Num() > 0))
	{
		return false;
	}

	const bool bTracksImportedModule = TestEqual(
		TEXT("Automatic import compatibility path should preserve exactly one imported module entry"),
		ImportingModule->ImportedModules.Num(),
		1);
	const bool bPointsToProvider = TestTrue(
		TEXT("Automatic import compatibility path should record the provider module in ImportedModules"),
		ImportingModule->ImportedModules.Contains(TEXT("Tests.Preprocessor.AutomaticImportCompat.Shared")));
	const bool bProviderRemainsClean = TestEqual(
		TEXT("Provider module should not gain synthetic imports when only the consumer declares a manual import"),
		SharedModule->ImportedModules.Num(),
		0);
	const bool bStripsImportText = TestFalse(
		TEXT("Automatic import compatibility path should remove the raw manual import statement from processed code"),
		ImportingModule->Code[0].Code.Contains(TEXT("import Tests.Preprocessor.AutomaticImportCompat.Shared;")));

	int32 ErrorCount = 0;
	const TArray<FString> DiagnosticMessages = CollectDiagnosticMessages(
		Engine,
		{SharedAbsolutePath, ImportingAbsolutePath},
		ErrorCount);
	const int32 WarningCount = DiagnosticMessages.Num() - ErrorCount;
	const FString DiagnosticSummary = FString::Join(DiagnosticMessages, TEXT("\n"));
	const bool bWarningsEnabledByDefault = GetDefault<UAngelscriptSettings>()->bWarnOnManualImportStatements;

	const bool bHasNoErrors = TestEqual(
		TEXT("Automatic import compatibility path should not emit preprocessing errors for a valid manual import"),
		ErrorCount,
		0);
	const bool bMatchesWarningPolicy = bWarningsEnabledByDefault
		? TestEqual(
			TEXT("Automatic import compatibility path should emit one compatibility warning when warning policy is enabled"),
			WarningCount,
			1)
		: TestEqual(
			TEXT("Automatic import compatibility path should stay silent when warning policy is disabled"),
			WarningCount,
			0);
	const bool bMentionsCompatibilityWarning = !bWarningsEnabledByDefault
		|| TestTrue(
			TEXT("Automatic import compatibility warning should explain that manual imports are ignored"),
			DiagnosticSummary.Contains(TEXT("Automatic imports are active, import statements will be ignored.")));

	bPassed =
		bTracksImportedModule &&
		bPointsToProvider &&
		bProviderRemainsClean &&
		bStripsImportText &&
		bHasNoErrors &&
		bMatchesWarningPolicy &&
		bMentionsCompatibilityWarning;

	ASTEST_END_SHARE_CLEAN

	return bPassed;
}

bool FAngelscriptPreprocessorMissingSemicolonReportsSyntaxTest::RunTest(const FString& Parameters)
{
	bool bPassed = false;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	Engine.ResetDiagnostics();

	const FString SharedRelativePath = TEXT("Tests/Preprocessor/MissingSemicolon/Shared.as");
	const FString SharedAbsolutePath = WritePreprocessorImportFixture(
		SharedRelativePath,
		TEXT("int SharedValue()\n")
		TEXT("{\n")
		TEXT("    return 11;\n")
		TEXT("}\n"));

	const FString BrokenRelativePath = TEXT("Tests/Preprocessor/MissingSemicolon/BrokenImport.as");
	const FString BrokenAbsolutePath = WritePreprocessorImportFixture(
		BrokenRelativePath,
		TEXT("import Tests.Preprocessor.MissingSemicolon.Shared\n")
		TEXT("int UseShared()\n")
		TEXT("{\n")
		TEXT("    return SharedValue();\n")
		TEXT("}\n"));

	AddExpectedError(
		TEXT("Import statement is missing terminating ';'."),
		EAutomationExpectedErrorFlags::Contains,
		1);

	TGuardValue<bool> AutomaticImportGuard(Engine.bUseAutomaticImportMethod, false);
	FAngelscriptPreprocessor Preprocessor;
	Preprocessor.AddFile(SharedRelativePath, SharedAbsolutePath);
	Preprocessor.AddFile(BrokenRelativePath, BrokenAbsolutePath);

	const bool bPreprocessSucceeded = Preprocessor.Preprocess();
	const TArray<TSharedRef<FAngelscriptModuleDesc>> Modules = Preprocessor.GetModulesToCompile();

	const FAngelscriptModuleDesc* BrokenModule = FindModuleByName(
		Modules,
		TEXT("Tests.Preprocessor.MissingSemicolon.BrokenImport"));
	if (!TestNotNull(
		TEXT("Missing-semicolon preprocessing should still keep the broken module descriptor available for diagnostics"),
		BrokenModule))
	{
		return false;
	}

	const FAngelscriptEngine::FDiagnostics* BrokenDiagnostics = Engine.Diagnostics.Find(BrokenAbsolutePath);
	if (!TestNotNull(
		TEXT("Missing-semicolon preprocessing should emit diagnostics for the broken import file"),
		BrokenDiagnostics))
	{
		return false;
	}

	int32 ErrorCount = 0;
	const TArray<FString> DiagnosticMessages = CollectDiagnosticMessages(
		Engine,
		{BrokenAbsolutePath, SharedAbsolutePath},
		ErrorCount);
	const FString DiagnosticSummary = FString::Join(DiagnosticMessages, TEXT("\n"));

	const bool bFailedAsExpected = TestFalse(
		TEXT("Missing-semicolon import should fail during preprocessing"),
		bPreprocessSucceeded);
	const bool bHasSingleError = TestEqual(
		TEXT("Missing-semicolon import should emit exactly one preprocessing error"),
		ErrorCount,
		1);
	const bool bMentionsSemicolon = TestTrue(
		TEXT("Missing-semicolon import should report a dedicated syntax diagnostic"),
		DiagnosticSummary.Contains(TEXT("Import statement is missing terminating ';'.")));
	const bool bHasDiagnosticEntry = TestTrue(
		TEXT("Missing-semicolon import should record at least one diagnostic entry"),
		BrokenDiagnostics->Diagnostics.Num() > 0);
	const bool bPointsAtImportLine = bHasDiagnosticEntry
		&& TestEqual(
			TEXT("Missing-semicolon import diagnostic should point at the import line"),
			BrokenDiagnostics->Diagnostics[0].Row,
			1);
	const bool bDoesNotPolluteImports = TestEqual(
		TEXT("Missing-semicolon import should not record any malformed imported module names"),
		BrokenModule->ImportedModules.Num(),
		0);
	const bool bLeavesNoMaterializedCodeOrCleanOutput = TestTrue(
		TEXT("Missing-semicolon import should either abort before materializing code sections or keep the emitted code free of the broken import text"),
		BrokenModule->Code.Num() == 0
			|| !BrokenModule->Code[0].Code.Contains(TEXT("import Tests.Preprocessor.MissingSemicolon.Shared")));
	const bool bPreservesFollowingCodeWhenMaterialized = TestTrue(
		TEXT("Missing-semicolon import should preserve the subsequent function definition whenever code sections are materialized"),
		BrokenModule->Code.Num() == 0
			|| BrokenModule->Code[0].Code.Contains(TEXT("int UseShared()")));

	bPassed =
		bFailedAsExpected &&
		bHasSingleError &&
		bMentionsSemicolon &&
		bHasDiagnosticEntry &&
		bPointsAtImportLine &&
		bDoesNotPolluteImports &&
		bLeavesNoMaterializedCodeOrCleanOutput &&
		bPreservesFollowingCodeWhenMaterialized;

	ASTEST_END_SHARE_CLEAN

	return bPassed;
}

bool FAngelscriptPreprocessorTrailingBlockCommentImportTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	Engine.ResetDiagnostics();

	const FString SharedRelativePath = TEXT("Tests/Preprocessor/ImportTrailingBlockComment/Shared.as");
	const FString SharedAbsolutePath = WritePreprocessorImportFixture(
		SharedRelativePath,
		TEXT("int SharedValue()\n")
		TEXT("{\n")
		TEXT("    return 11;\n")
		TEXT("}\n"));

	const FString ImportingRelativePath = TEXT("Tests/Preprocessor/ImportTrailingBlockComment/UsesShared.as");
	const FString ImportingAbsolutePath = WritePreprocessorImportFixture(
		ImportingRelativePath,
		TEXT("import Tests.Preprocessor.ImportTrailingBlockComment.Shared /* shared helpers */;\n")
		TEXT("int Entry()\n")
		TEXT("{\n")
		TEXT("    return SharedValue();\n")
		TEXT("}\n"));

	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(TEXT("Tests.Preprocessor.ImportTrailingBlockComment.UsesShared"));
		Engine.DiscardModule(TEXT("Tests.Preprocessor.ImportTrailingBlockComment.Shared"));
		IFileManager::Get().Delete(*ImportingAbsolutePath, false, true);
		IFileManager::Get().Delete(*SharedAbsolutePath, false, true);
	};

	TGuardValue<bool> AutomaticImportGuard(Engine.bUseAutomaticImportMethod, false);
	FScopedAutomaticImportsOverride AutomaticImportsOverride(Engine.GetScriptEngine());

	FAngelscriptPreprocessor Preprocessor;
	Preprocessor.AddFile(SharedRelativePath, SharedAbsolutePath);
	Preprocessor.AddFile(ImportingRelativePath, ImportingAbsolutePath);

	const bool bPreprocessSucceeded = Preprocessor.Preprocess();
	const TArray<TSharedRef<FAngelscriptModuleDesc>> Modules = Preprocessor.GetModulesToCompile();

	int32 PreprocessErrorCount = 0;
	const TArray<FString> PreprocessMessages = CollectDiagnosticMessages(
		Engine,
		{SharedAbsolutePath, ImportingAbsolutePath},
		PreprocessErrorCount);
	const FString PreprocessDiagnostics = FString::Join(PreprocessMessages, TEXT("\n"));

	bPassed &= TestTrue(
		TEXT("Trailing block-comment import should preprocess successfully"),
		bPreprocessSucceeded);
	bPassed &= TestEqual(
		TEXT("Trailing block-comment import should keep preprocessing diagnostics empty"),
		PreprocessErrorCount,
		0);
	bPassed &= TestTrue(
		TEXT("Trailing block-comment import should not accumulate preprocessing messages"),
		PreprocessDiagnostics.IsEmpty());
	bPassed &= TestEqual(
		TEXT("Trailing block-comment import should emit exactly two module descriptors"),
		Modules.Num(),
		2);
	if (!bPreprocessSucceeded || Modules.Num() != 2)
	{
		return false;
	}

	const FAngelscriptModuleDesc* SharedModule = FindModuleByName(
		Modules,
		TEXT("Tests.Preprocessor.ImportTrailingBlockComment.Shared"));
	const FAngelscriptModuleDesc* ImportingModule = FindModuleByName(
		Modules,
		TEXT("Tests.Preprocessor.ImportTrailingBlockComment.UsesShared"));
	if (!TestNotNull(
			TEXT("Trailing block-comment import should emit the shared provider module descriptor"),
			SharedModule)
		|| !TestNotNull(
			TEXT("Trailing block-comment import should emit the importing consumer module descriptor"),
			ImportingModule))
	{
		return false;
	}

	bPassed &= TestEqual(
		TEXT("Trailing block-comment import should record exactly one imported module"),
		ImportingModule->ImportedModules.Num(),
		1);
	bPassed &= TestTrue(
		TEXT("Trailing block-comment import should normalize the imported module name before storing it"),
		ImportingModule->ImportedModules.Contains(TEXT("Tests.Preprocessor.ImportTrailingBlockComment.Shared")));
	bPassed &= TestFalse(
		TEXT("Trailing block-comment import should not preserve the trailing block comment in ImportedModules"),
		ImportingModule->ImportedModules.Contains(TEXT("Tests.Preprocessor.ImportTrailingBlockComment.Shared /* shared helpers */")));
	bPassed &= TestTrue(
		TEXT("Trailing block-comment import should materialize at least one code section for the importing module"),
		ImportingModule->Code.Num() > 0);
	if (ImportingModule->Code.Num() == 0)
	{
		return false;
	}
	bPassed &= TestFalse(
		TEXT("Trailing block-comment import should remove the raw import statement from the processed code"),
		ImportingModule->Code[0].Code.Contains(TEXT("import Tests.Preprocessor.ImportTrailingBlockComment.Shared /* shared helpers */;")));

	Engine.ResetDiagnostics();

	TArray<TSharedRef<FAngelscriptModuleDesc>> CompiledModules;
	const ECompileResult CompileResult = Engine.CompileModules(
		ECompileType::SoftReloadOnly,
		Modules,
		CompiledModules);

	int32 CompileErrorCount = 0;
	const TArray<FString> CompileMessages = CollectDiagnosticMessages(
		Engine,
		{SharedAbsolutePath, ImportingAbsolutePath},
		CompileErrorCount);
	const FString CompileDiagnostics = FString::Join(CompileMessages, TEXT("\n"));

	bPassed &= TestEqual(
		TEXT("Trailing block-comment import should compile as FullyHandled"),
		CompileResult,
		ECompileResult::FullyHandled);
	bPassed &= TestEqual(
		TEXT("Trailing block-comment import should keep compile diagnostics empty"),
		CompileErrorCount,
		0);
	bPassed &= TestTrue(
		TEXT("Trailing block-comment import should not accumulate compile messages"),
		CompileDiagnostics.IsEmpty());
	bPassed &= TestEqual(
		TEXT("Trailing block-comment import should materialize exactly two compiled modules"),
		CompiledModules.Num(),
		2);
	if (CompileResult != ECompileResult::FullyHandled || CompiledModules.Num() != 2)
	{
		return false;
	}

	TSharedPtr<FAngelscriptModuleDesc> CompiledImportingModule = Engine.GetModule(TEXT("Tests.Preprocessor.ImportTrailingBlockComment.UsesShared"));
	if (!TestTrue(
		TEXT("Trailing block-comment import should register the consumer module on the engine after compile"),
		CompiledImportingModule.IsValid()))
	{
		return false;
	}

	if (!TestNotNull(
		TEXT("Trailing block-comment import should expose a backing script module for the consumer"),
		CompiledImportingModule->ScriptModule))
	{
		return false;
	}

	asIScriptFunction* EntryFunction = GetFunctionByDecl(*this, *CompiledImportingModule->ScriptModule, TEXT("int Entry()"));
	if (EntryFunction == nullptr)
	{
		return false;
	}

	int32 Result = 0;
	if (!ExecuteIntFunction(*this, Engine, *EntryFunction, Result))
	{
		return false;
	}

	bPassed &= TestEqual(
		TEXT("Trailing block-comment import should still execute the imported provider function after compile"),
		Result,
		11);

	ASTEST_END_SHARE_CLEAN

	return bPassed;
}

#endif
