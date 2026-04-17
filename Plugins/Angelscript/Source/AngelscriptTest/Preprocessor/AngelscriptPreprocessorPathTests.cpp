#include "../Shared/AngelscriptTestUtilities.h"
#include "../Shared/AngelscriptTestMacros.h"

#include "Preprocessor/AngelscriptPreprocessor.h"

#include "HAL/FileManager.h"
#include "Misc/AutomationTest.h"
#include "Misc/FileHelper.h"
#include "Misc/Paths.h"

#if WITH_DEV_AUTOMATION_TESTS

namespace AngelscriptTest_Preprocessor_AngelscriptPreprocessorPathTests_Private
{
	FString GetPreprocessorPathFixtureRoot()
	{
		return FPaths::Combine(FPaths::ProjectSavedDir(), TEXT("Automation"), TEXT("PreprocessorPathFixtures"));
	}

	FString WritePreprocessorPathFixture(const FString& RelativeScriptPath, const FString& Contents)
	{
		const FString AbsolutePath = FPaths::Combine(GetPreprocessorPathFixtureRoot(), RelativeScriptPath);
		IFileManager::Get().MakeDirectory(*FPaths::GetPath(AbsolutePath), true);
		FFileHelper::SaveStringToFile(Contents, *AbsolutePath);
		return AbsolutePath;
	}

	TArray<FString> CollectPathDiagnosticMessages(
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

	const FAngelscriptModuleDesc* FindPathModuleByName(
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

using namespace AngelscriptTest_Preprocessor_AngelscriptPreprocessorPathTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptPreprocessorBackslashRelativePathNormalizesModuleNameTest,
	"Angelscript.TestModule.Preprocessor.Paths.BackslashRelativePathNormalizesModuleName",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptPreprocessorFilenameToModuleNameOnlyStripsTerminalExtensionTest,
	"Angelscript.TestModule.Preprocessor.Paths.FilenameToModuleNameOnlyStripsTerminalExtension",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptPreprocessorBackslashRelativePathNormalizesModuleNameTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	Engine.ResetDiagnostics();

	const FString SharedRelativePath = TEXT("Tests\\Preprocessor\\PathNormalization\\WinShared.as");
	const FString SharedAbsolutePath = WritePreprocessorPathFixture(
		SharedRelativePath,
		TEXT("int SharedValue()\n")
		TEXT("{\n")
		TEXT("    return 11;\n")
		TEXT("}\n"));

	const FString ImportingRelativePath = TEXT("Tests\\Preprocessor\\PathNormalization\\WinUse.as");
	const FString ImportingAbsolutePath = WritePreprocessorPathFixture(
		ImportingRelativePath,
		TEXT("import Tests.Preprocessor.PathNormalization.WinShared;\n")
		TEXT("int UseShared()\n")
		TEXT("{\n")
		TEXT("    return SharedValue();\n")
		TEXT("}\n"));

	TGuardValue<bool> AutomaticImportGuard(Engine.bUseAutomaticImportMethod, false);
	FAngelscriptPreprocessor Preprocessor;
	Preprocessor.AddFile(SharedRelativePath, SharedAbsolutePath);
	Preprocessor.AddFile(ImportingRelativePath, ImportingAbsolutePath);

	const bool bPreprocessSucceeded = Preprocessor.Preprocess();
	const TArray<TSharedRef<FAngelscriptModuleDesc>> Modules = Preprocessor.GetModulesToCompile();
	const FString ModuleNames = FString::JoinBy(
		Modules,
		TEXT(" | "),
		[](const TSharedRef<FAngelscriptModuleDesc>& Module)
		{
			return Module->ModuleName;
		});

	int32 ErrorCount = 0;
	const TArray<FString> DiagnosticMessages = CollectPathDiagnosticMessages(
		Engine,
		{SharedAbsolutePath, ImportingAbsolutePath},
		ErrorCount);
	const FString DiagnosticSummary = FString::Join(DiagnosticMessages, TEXT("\n"));

	const FAngelscriptModuleDesc* SharedModule = FindPathModuleByName(
		Modules,
		TEXT("Tests.Preprocessor.PathNormalization.WinShared"));
	const FAngelscriptModuleDesc* ImportingModule = FindPathModuleByName(
		Modules,
		TEXT("Tests.Preprocessor.PathNormalization.WinUse"));

	bPassed &= TestTrue(
		TEXT("Backslash relative paths should preprocess successfully in manual import mode"),
		bPreprocessSucceeded);
	bPassed &= TestEqual(
		TEXT("Backslash relative paths should produce exactly two module descriptors"),
		Modules.Num(),
		2);
	bPassed &= TestEqual(
		TEXT("Backslash relative paths should not emit preprocessing errors"),
		ErrorCount,
		0);
	bPassed &= TestTrue(
		TEXT("Backslash relative paths should keep diagnostics empty"),
		DiagnosticSummary.IsEmpty());
	bPassed &= TestNotNull(
		TEXT("Backslash relative provider path should normalize to a dotted module name"),
		SharedModule);
	bPassed &= TestNotNull(
		TEXT("Backslash relative importer path should normalize to a dotted module name"),
		ImportingModule);
	bPassed &= TestFalse(
		TEXT("Normalized module names should not preserve raw backslashes"),
		ModuleNames.Contains(TEXT("\\")));

	if (SharedModule != nullptr)
	{
		bPassed &= TestEqual(
			TEXT("Normalized provider module should not record any imports"),
			SharedModule->ImportedModules.Num(),
			0);
	}

	if (ImportingModule != nullptr)
	{
		bPassed &= TestEqual(
			TEXT("Normalized importer module should record exactly one imported module"),
			ImportingModule->ImportedModules.Num(),
			1);
		bPassed &= TestTrue(
			TEXT("Normalized importer module should reference the dotted provider module name"),
			ImportingModule->ImportedModules.Contains(TEXT("Tests.Preprocessor.PathNormalization.WinShared")));
		bPassed &= TestFalse(
			TEXT("Normalized importer module should not record backslash-based import names"),
			ImportingModule->ImportedModules.Contains(TEXT("Tests\\Preprocessor\\PathNormalization\\WinShared")));
	}

	ASTEST_END_SHARE_CLEAN

	return bPassed;
}

bool FAngelscriptPreprocessorFilenameToModuleNameOnlyStripsTerminalExtensionTest::RunTest(const FString& Parameters)
{
	FAngelscriptPreprocessor Preprocessor;

	const FString FolderAsModuleName = Preprocessor.FilenameToModuleName(TEXT("Tests/Foo.as/Bar.as"));
	const FString RegularModuleName = Preprocessor.FilenameToModuleName(TEXT("Tests/Foo/Bar.as"));
	const FString AssetSuffixModuleName = Preprocessor.FilenameToModuleName(TEXT("Tests/Foo.as/Baz.asset.as"));

	bool bPassed = true;
	bPassed &= TestEqual(
		TEXT("FilenameToModuleName should preserve '.as' when it appears in an intermediate path segment"),
		FolderAsModuleName,
		TEXT("Tests.Foo.as.Bar"));
	bPassed &= TestEqual(
		TEXT("FilenameToModuleName should continue normalizing a standard script filename"),
		RegularModuleName,
		TEXT("Tests.Foo.Bar"));
	bPassed &= TestTrue(
		TEXT("FilenameToModuleName should keep intermediate '.as' segments distinct from plain folders"),
		FolderAsModuleName != RegularModuleName);
	bPassed &= TestEqual(
		TEXT("FilenameToModuleName should strip only the terminal extension from asset-like script filenames"),
		AssetSuffixModuleName,
		TEXT("Tests.Foo.as.Baz.asset"));

	return bPassed;
}

#endif
