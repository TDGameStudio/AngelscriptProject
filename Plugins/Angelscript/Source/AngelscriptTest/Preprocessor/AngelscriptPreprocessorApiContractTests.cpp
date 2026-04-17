#include "../Shared/AngelscriptTestUtilities.h"

#include "Preprocessor/AngelscriptPreprocessor.h"

#include "HAL/FileManager.h"
#include "Misc/AutomationTest.h"
#include "Misc/FileHelper.h"
#include "Misc/Paths.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace AngelscriptTest_Preprocessor_AngelscriptPreprocessorApiContractTests_Private
{
	FString GetPreprocessorApiContractFixtureRoot()
	{
		return FPaths::Combine(FPaths::ProjectSavedDir(), TEXT("Automation"), TEXT("PreprocessorApiContractFixtures"));
	}

	FString WritePreprocessorApiContractFixture(const FString& RelativeScriptPath, const FString& Contents)
	{
		const FString AbsolutePath = FPaths::Combine(GetPreprocessorApiContractFixtureRoot(), RelativeScriptPath);
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

	struct FCodeSectionSnapshot
	{
		FString RelativeFilename;
		FString AbsoluteFilename;
		FString Code;
		int64 CodeHash = 0;
	};

	struct FModuleSnapshot
	{
		FString ModuleName;
		TArray<FString> ImportedModules;
		TArray<FCodeSectionSnapshot> CodeSections;
		int64 CodeHash = 0;
	};

	FModuleSnapshot CaptureModuleSnapshot(const FAngelscriptModuleDesc& Module)
	{
		FModuleSnapshot Snapshot;
		Snapshot.ModuleName = Module.ModuleName;
		Snapshot.ImportedModules = Module.ImportedModules;
		Snapshot.CodeHash = Module.CodeHash;
		Snapshot.CodeSections.Reserve(Module.Code.Num());

		for (const FAngelscriptModuleDesc::FCodeSection& Section : Module.Code)
		{
			FCodeSectionSnapshot& SectionSnapshot = Snapshot.CodeSections.AddDefaulted_GetRef();
			SectionSnapshot.RelativeFilename = Section.RelativeFilename;
			SectionSnapshot.AbsoluteFilename = Section.AbsoluteFilename;
			SectionSnapshot.Code = Section.Code;
			SectionSnapshot.CodeHash = Section.CodeHash;
		}

		return Snapshot;
	}

	bool TestModuleSnapshotMatches(
		FAutomationTestBase& Test,
		const TCHAR* ContextLabel,
		const FModuleSnapshot& ExpectedModule,
		const FAngelscriptModuleDesc& ActualModule)
	{
		bool bMatched = true;

		bMatched &= Test.TestEqual(
			*FString::Printf(TEXT("%s should preserve the first module name"), ContextLabel),
			ActualModule.ModuleName,
			ExpectedModule.ModuleName);
		bMatched &= Test.TestEqual(
			*FString::Printf(TEXT("%s should preserve the first module import count"), ContextLabel),
			ActualModule.ImportedModules.Num(),
			ExpectedModule.ImportedModules.Num());
		bMatched &= Test.TestEqual(
			*FString::Printf(TEXT("%s should preserve the first module code section count"), ContextLabel),
			ActualModule.Code.Num(),
			ExpectedModule.CodeSections.Num());
		bMatched &= Test.TestEqual(
			*FString::Printf(TEXT("%s should preserve the first module aggregate code hash"), ContextLabel),
			ActualModule.CodeHash,
			ExpectedModule.CodeHash);

		const int32 ComparedImportCount = FMath::Min(ActualModule.ImportedModules.Num(), ExpectedModule.ImportedModules.Num());
		for (int32 ImportIndex = 0; ImportIndex < ComparedImportCount; ++ImportIndex)
		{
			bMatched &= Test.TestEqual(
				*FString::Printf(TEXT("%s should preserve import[%d]"), ContextLabel, ImportIndex),
				ActualModule.ImportedModules[ImportIndex],
				ExpectedModule.ImportedModules[ImportIndex]);
		}

		const int32 ComparedCodeSectionCount = FMath::Min(ActualModule.Code.Num(), ExpectedModule.CodeSections.Num());
		for (int32 SectionIndex = 0; SectionIndex < ComparedCodeSectionCount; ++SectionIndex)
		{
			const FAngelscriptModuleDesc::FCodeSection& ActualSection = ActualModule.Code[SectionIndex];
			const FCodeSectionSnapshot& ExpectedSection = ExpectedModule.CodeSections[SectionIndex];

			bMatched &= Test.TestEqual(
				*FString::Printf(TEXT("%s should preserve section[%d] relative filename"), ContextLabel, SectionIndex),
				ActualSection.RelativeFilename,
				ExpectedSection.RelativeFilename);
			bMatched &= Test.TestEqual(
				*FString::Printf(TEXT("%s should preserve section[%d] absolute filename"), ContextLabel, SectionIndex),
				ActualSection.AbsoluteFilename,
				ExpectedSection.AbsoluteFilename);
			bMatched &= Test.TestEqual(
				*FString::Printf(TEXT("%s should preserve section[%d] code hash"), ContextLabel, SectionIndex),
				ActualSection.CodeHash,
				ExpectedSection.CodeHash);
			bMatched &= Test.TestEqual(
				*FString::Printf(TEXT("%s should preserve section[%d] processed code"), ContextLabel, SectionIndex),
				ActualSection.Code,
				ExpectedSection.Code);
		}

		return bMatched;
	}
}

using namespace AngelscriptTest_Preprocessor_AngelscriptPreprocessorApiContractTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptPreprocessorPreprocessIsSingleUseTest,
	"Angelscript.TestModule.Preprocessor.Api.PreprocessIsSingleUse",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptPreprocessorPreprocessIsSingleUseTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;

	AddExpectedErrorPlain(
		TEXT("Ensure condition failed: !bIsPreprocessed"),
		EAutomationExpectedErrorFlags::Contains,
		2);
	AddExpectedErrorPlain(
		TEXT("LogOutputDevice:"),
		EAutomationExpectedErrorFlags::Contains,
		0);

	FAngelscriptTestFixture Fixture(*this);
	if (!TestTrue(TEXT("Preprocessor single-use test should acquire a clean engine fixture"), Fixture.IsValid()))
	{
		return false;
	}

	FAngelscriptEngine& Engine = Fixture.GetEngine();
	Engine.ResetDiagnostics();

	const FString FirstRelativeScriptPath = TEXT("Tests/Preprocessor/ApiContract/First.as");
	const FString FirstAbsoluteScriptPath = WritePreprocessorApiContractFixture(
		FirstRelativeScriptPath,
		TEXT("int Entry()\n")
		TEXT("{\n")
		TEXT("    return 7;\n")
		TEXT("}\n"));

	const FString SecondRelativeScriptPath = TEXT("Tests/Preprocessor/ApiContract/Second.as");
	const FString SecondAbsoluteScriptPath = WritePreprocessorApiContractFixture(
		SecondRelativeScriptPath,
		TEXT("int Entry()\n")
		TEXT("{\n")
		TEXT("    return 11;\n")
		TEXT("}\n"));

	ON_SCOPE_EXIT
	{
		IFileManager::Get().Delete(*FirstAbsoluteScriptPath, false, true);
		IFileManager::Get().Delete(*SecondAbsoluteScriptPath, false, true);
	};

	FAngelscriptPreprocessor Preprocessor;
	Preprocessor.AddFile(FirstRelativeScriptPath, FirstAbsoluteScriptPath);

	const bool bFirstPreprocessSucceeded = Preprocessor.Preprocess();
	const TArray<TSharedRef<FAngelscriptModuleDesc>> FirstModules = Preprocessor.GetModulesToCompile();
	const FString FirstModuleName = TEXT("Tests.Preprocessor.ApiContract.First");
	const FString SecondModuleName = TEXT("Tests.Preprocessor.ApiContract.Second");

	bPassed &= TestTrue(
		TEXT("The first Preprocess() call should succeed for a minimal script"),
		bFirstPreprocessSucceeded);
	bPassed &= TestEqual(
		TEXT("The first Preprocess() call should emit exactly one module"),
		FirstModules.Num(),
		1);

	const FAngelscriptModuleDesc* FirstModule = FindModuleByName(FirstModules, FirstModuleName);
	if (!TestNotNull(TEXT("The first Preprocess() call should emit the first module"), FirstModule))
	{
		return false;
	}

	const FModuleSnapshot FirstSnapshot = CaptureModuleSnapshot(*FirstModule);

	Preprocessor.AddFile(SecondRelativeScriptPath, SecondAbsoluteScriptPath);

	const TArray<TSharedRef<FAngelscriptModuleDesc>> ModulesAfterLateAdd = Preprocessor.GetModulesToCompile();
	bPassed &= TestEqual(
		TEXT("Late AddFile() should not change the number of modules already queued for compile"),
		ModulesAfterLateAdd.Num(),
		1);
	bPassed &= TestNull(
		TEXT("Late AddFile() should not materialize the second module"),
		FindModuleByName(ModulesAfterLateAdd, SecondModuleName));

	const FAngelscriptModuleDesc* ModuleAfterLateAdd = FindModuleByName(ModulesAfterLateAdd, FirstModuleName);
	if (!TestNotNull(TEXT("Late AddFile() should keep the original module available"), ModuleAfterLateAdd))
	{
		return false;
	}

	bPassed &= TestModuleSnapshotMatches(
		*this,
		TEXT("Late AddFile()"),
		FirstSnapshot,
		*ModuleAfterLateAdd);

	const bool bSecondPreprocessSucceeded = Preprocessor.Preprocess();
	const TArray<TSharedRef<FAngelscriptModuleDesc>> ModulesAfterSecondPreprocess = Preprocessor.GetModulesToCompile();

	bPassed &= TestFalse(
		TEXT("The second Preprocess() call should fail once preprocessing has already completed"),
		bSecondPreprocessSucceeded);
	bPassed &= TestEqual(
		TEXT("The second Preprocess() call should keep the module count unchanged"),
		ModulesAfterSecondPreprocess.Num(),
		1);
	bPassed &= TestNull(
		TEXT("The second Preprocess() call should still keep the late-added second module absent"),
		FindModuleByName(ModulesAfterSecondPreprocess, SecondModuleName));

	const FAngelscriptModuleDesc* ModuleAfterSecondPreprocess = FindModuleByName(ModulesAfterSecondPreprocess, FirstModuleName);
	if (!TestNotNull(TEXT("The second Preprocess() call should keep the original module available"), ModuleAfterSecondPreprocess))
	{
		return false;
	}

	bPassed &= TestModuleSnapshotMatches(
		*this,
		TEXT("Second Preprocess()"),
		FirstSnapshot,
		*ModuleAfterSecondPreprocess);

	return bPassed;
}

#endif
