#include "../Shared/AngelscriptTestUtilities.h"
#include "../Shared/AngelscriptTestMacros.h"

#include "Preprocessor/AngelscriptPreprocessor.h"

#include "HAL/FileManager.h"
#include "Misc/AutomationTest.h"
#include "Misc/FileHelper.h"
#include "Misc/Paths.h"

#if WITH_DEV_AUTOMATION_TESTS

namespace AngelscriptTest_Preprocessor_AngelscriptPreprocessorDeletedFileTests_Private
{
	FString GetPreprocessorDeletedFileFixtureRoot()
	{
		return FPaths::Combine(FPaths::ProjectSavedDir(), TEXT("Automation"), TEXT("PreprocessorDeletedFileFixtures"));
	}

	FString WritePreprocessorDeletedFileFixture(const FString& RelativeScriptPath, const FString& Contents)
	{
		const FString AbsolutePath = FPaths::Combine(GetPreprocessorDeletedFileFixtureRoot(), RelativeScriptPath);
		IFileManager::Get().MakeDirectory(*FPaths::GetPath(AbsolutePath), true);
		FFileHelper::SaveStringToFile(Contents, *AbsolutePath);
		return AbsolutePath;
	}

	TArray<FString> CollectDeletedFileDiagnosticMessages(
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

	const FAngelscriptModuleDesc* FindDeletedFileModuleByName(
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

using namespace AngelscriptTest_Preprocessor_AngelscriptPreprocessorDeletedFileTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptPreprocessorTreatAsDeletedProducesEmptyModuleTest,
	"Angelscript.TestModule.Preprocessor.DeletedFile.TreatAsDeletedProducesEmptyModule",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptPreprocessorTreatAsDeletedProducesEmptyModuleTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	Engine.ResetDiagnostics();

	const FString RelativeScriptPath = TEXT("Tests/Preprocessor/DeletedFile/TreatAsDeletedProducesEmptyModule.as");
	const FString AbsoluteScriptPath = WritePreprocessorDeletedFileFixture(
		RelativeScriptPath,
		TEXT("import Tests.Preprocessor.DeletedFile.MissingProvider;\n")
		TEXT("UCLASS()\n")
		TEXT("class UDeletedFileProbe : UObject\n")
		TEXT("{\n")
		TEXT("    UFUNCTION()\n")
		TEXT("    int Entry()\n")
		TEXT("    {\n")
		TEXT("        return 7;\n")
		TEXT("    }\n")
		TEXT("}\n"));

	FAngelscriptPreprocessor Preprocessor;
	Preprocessor.AddFile(RelativeScriptPath, AbsoluteScriptPath, false, true);

	const bool bPreprocessSucceeded = Preprocessor.Preprocess();
	const TArray<TSharedRef<FAngelscriptModuleDesc>> Modules = Preprocessor.GetModulesToCompile();

	int32 ErrorCount = 0;
	const TArray<FString> DiagnosticMessages = CollectDeletedFileDiagnosticMessages(
		Engine,
		{AbsoluteScriptPath},
		ErrorCount);
	const FString DiagnosticSummary = FString::Join(DiagnosticMessages, TEXT("\n"));

	bPassed &= TestTrue(
		TEXT("Treat-as-deleted preprocessing should succeed even when a real file exists on disk"),
		bPreprocessSucceeded);
	bPassed &= TestEqual(
		TEXT("Treat-as-deleted preprocessing should materialize exactly one module descriptor"),
		Modules.Num(),
		1);
	bPassed &= TestEqual(
		TEXT("Treat-as-deleted preprocessing should not emit diagnostics"),
		ErrorCount,
		0);
	bPassed &= TestTrue(
		TEXT("Treat-as-deleted preprocessing should keep the diagnostic summary empty"),
		DiagnosticSummary.IsEmpty());

	const FAngelscriptModuleDesc* Module = FindDeletedFileModuleByName(
		Modules,
		TEXT("Tests.Preprocessor.DeletedFile.TreatAsDeletedProducesEmptyModule"));
	if (!TestNotNull(
		TEXT("Treat-as-deleted preprocessing should normalize the deleted file path into a module name"),
		Module))
	{
		return false;
	}

	bPassed &= TestEqual(
		TEXT("Treat-as-deleted preprocessing should keep exactly one empty code section"),
		Module->Code.Num(),
		1);
	if (Module->Code.Num() > 0)
	{
		bPassed &= TestEqual(
			TEXT("Treat-as-deleted preprocessing should preserve the relative filename on the emitted code section"),
			Module->Code[0].RelativeFilename,
			RelativeScriptPath);
		bPassed &= TestEqual(
			TEXT("Treat-as-deleted preprocessing should preserve the absolute filename on the emitted code section"),
			Module->Code[0].AbsoluteFilename,
			AbsoluteScriptPath);
		bPassed &= TestTrue(
			TEXT("Treat-as-deleted preprocessing should emit an empty processed code section"),
			Module->Code[0].Code.IsEmpty());
		bPassed &= TestEqual(
			TEXT("Treat-as-deleted preprocessing should zero the empty code section hash"),
			Module->Code[0].CodeHash,
			static_cast<int64>(0));
	}

	bPassed &= TestEqual(
		TEXT("Treat-as-deleted preprocessing should keep the module code hash at zero"),
		Module->CodeHash,
		static_cast<int64>(0));
	bPassed &= TestEqual(
		TEXT("Treat-as-deleted preprocessing should not record imported modules from deleted source"),
		Module->ImportedModules.Num(),
		0);
	bPassed &= TestEqual(
		TEXT("Treat-as-deleted preprocessing should not record post-init functions from deleted source"),
		Module->PostInitFunctions.Num(),
		0);
	bPassed &= TestEqual(
		TEXT("Treat-as-deleted preprocessing should not materialize classes from deleted source"),
		Module->Classes.Num(),
		0);
	bPassed &= TestEqual(
		TEXT("Treat-as-deleted preprocessing should not materialize enums from deleted source"),
		Module->Enums.Num(),
		0);
	bPassed &= TestEqual(
		TEXT("Treat-as-deleted preprocessing should not materialize delegates from deleted source"),
		Module->Delegates.Num(),
		0);
#if WITH_EDITOR
	bPassed &= TestEqual(
		TEXT("Treat-as-deleted preprocessing should not materialize usage restrictions from deleted source"),
		Module->UsageRestrictions.Num(),
		0);
	bPassed &= TestEqual(
		TEXT("Treat-as-deleted preprocessing should not record editor-only block lines from deleted source"),
		Module->EditorOnlyBlockLines.Num(),
		0);
#endif

	ASTEST_END_SHARE_CLEAN

	return bPassed;
}

#endif
