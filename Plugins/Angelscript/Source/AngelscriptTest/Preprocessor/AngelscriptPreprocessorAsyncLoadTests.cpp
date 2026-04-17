#include "../Shared/AngelscriptTestUtilities.h"

#include "Preprocessor/AngelscriptPreprocessor.h"

#include "HAL/FileManager.h"
#include "Misc/AutomationTest.h"
#include "Misc/FileHelper.h"
#include "Misc/Paths.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace AngelscriptTest_Preprocessor_AngelscriptPreprocessorAsyncLoadTests_Private
{
	FString GetPreprocessorAsyncLoadFixtureRoot()
	{
		return FPaths::Combine(FPaths::ProjectSavedDir(), TEXT("Automation"), TEXT("PreprocessorAsyncLoadFixtures"));
	}

	FString WritePreprocessorAsyncLoadFixture(const FString& RelativeScriptPath, const FString& Contents)
	{
		const FString AbsolutePath = FPaths::Combine(GetPreprocessorAsyncLoadFixtureRoot(), RelativeScriptPath);
		IFileManager::Get().MakeDirectory(*FPaths::GetPath(AbsolutePath), true);
		FFileHelper::SaveStringToFile(Contents, *AbsolutePath);
		return AbsolutePath;
	}

	FString MakeAsyncLoadPadding(const int32 RepeatCount)
	{
		FString Padding;
		Padding.Reserve(RepeatCount * 64);

		for (int32 Index = 0; Index < RepeatCount; ++Index)
		{
			Padding += FString::Printf(TEXT("// AsyncLoadPadding_%05d_abcdefghijklmnopqrstuvwxyz0123456789\n"), Index);
		}

		return Padding;
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

	TArray<FModuleSnapshot> CaptureModuleSnapshot(const TArray<TSharedRef<FAngelscriptModuleDesc>>& Modules)
	{
		TArray<FModuleSnapshot> Snapshots;
		Snapshots.Reserve(Modules.Num());

		for (const TSharedRef<FAngelscriptModuleDesc>& Module : Modules)
		{
			FModuleSnapshot Snapshot;
			Snapshot.ModuleName = Module->ModuleName;
			Snapshot.ImportedModules = Module->ImportedModules;
			Snapshot.CodeHash = Module->CodeHash;
			Snapshot.CodeSections.Reserve(Module->Code.Num());

			for (const FAngelscriptModuleDesc::FCodeSection& Section : Module->Code)
			{
				FCodeSectionSnapshot SectionSnapshot;
				SectionSnapshot.RelativeFilename = Section.RelativeFilename;
				SectionSnapshot.AbsoluteFilename = Section.AbsoluteFilename;
				SectionSnapshot.Code = Section.Code;
				SectionSnapshot.CodeHash = Section.CodeHash;
				Snapshot.CodeSections.Add(MoveTemp(SectionSnapshot));
			}

			Snapshots.Add(MoveTemp(Snapshot));
		}

		return Snapshots;
	}

	bool TestModuleSnapshotsMatch(
		FAutomationTestBase& Test,
		const TArray<FModuleSnapshot>& ExpectedModules,
		const TArray<FModuleSnapshot>& ActualModules)
	{
		bool bMatched = true;

		if (!Test.TestEqual(
			TEXT("Async preprocessor path should emit the same module count as the synchronous path"),
			ActualModules.Num(),
			ExpectedModules.Num()))
		{
			return false;
		}

		for (int32 ModuleIndex = 0; ModuleIndex < ExpectedModules.Num(); ++ModuleIndex)
		{
			const FModuleSnapshot& ExpectedModule = ExpectedModules[ModuleIndex];
			const FModuleSnapshot& ActualModule = ActualModules[ModuleIndex];

			bMatched &= Test.TestEqual(
				*FString::Printf(TEXT("Module[%d] name should match between sync and async preprocess"), ModuleIndex),
				ActualModule.ModuleName,
				ExpectedModule.ModuleName);

			bMatched &= Test.TestEqual(
				*FString::Printf(TEXT("Module[%d] imported-module count should match between sync and async preprocess"), ModuleIndex),
				ActualModule.ImportedModules.Num(),
				ExpectedModule.ImportedModules.Num());

			const int32 ComparedImportCount = FMath::Min(ExpectedModule.ImportedModules.Num(), ActualModule.ImportedModules.Num());
			for (int32 ImportIndex = 0; ImportIndex < ComparedImportCount; ++ImportIndex)
			{
				bMatched &= Test.TestEqual(
					*FString::Printf(TEXT("Module[%d] import[%d] should keep the same dependency order"), ModuleIndex, ImportIndex),
					ActualModule.ImportedModules[ImportIndex],
					ExpectedModule.ImportedModules[ImportIndex]);
			}

			bMatched &= Test.TestEqual(
				*FString::Printf(TEXT("Module[%d] code section count should match between sync and async preprocess"), ModuleIndex),
				ActualModule.CodeSections.Num(),
				ExpectedModule.CodeSections.Num());

			bMatched &= Test.TestEqual(
				*FString::Printf(TEXT("Module[%d] aggregate code hash should match between sync and async preprocess"), ModuleIndex),
				ActualModule.CodeHash,
				ExpectedModule.CodeHash);

			const int32 ComparedSectionCount = FMath::Min(ExpectedModule.CodeSections.Num(), ActualModule.CodeSections.Num());
			for (int32 SectionIndex = 0; SectionIndex < ComparedSectionCount; ++SectionIndex)
			{
				const FCodeSectionSnapshot& ExpectedSection = ExpectedModule.CodeSections[SectionIndex];
				const FCodeSectionSnapshot& ActualSection = ActualModule.CodeSections[SectionIndex];

				bMatched &= Test.TestEqual(
					*FString::Printf(TEXT("Module[%d] section[%d] relative filename should match"), ModuleIndex, SectionIndex),
					ActualSection.RelativeFilename,
					ExpectedSection.RelativeFilename);

				bMatched &= Test.TestEqual(
					*FString::Printf(TEXT("Module[%d] section[%d] absolute filename should match"), ModuleIndex, SectionIndex),
					ActualSection.AbsoluteFilename,
					ExpectedSection.AbsoluteFilename);

				bMatched &= Test.TestEqual(
					*FString::Printf(TEXT("Module[%d] section[%d] code hash should match"), ModuleIndex, SectionIndex),
					ActualSection.CodeHash,
					ExpectedSection.CodeHash);

				bMatched &= Test.TestTrue(
					*FString::Printf(TEXT("Module[%d] section[%d] processed code should match exactly"), ModuleIndex, SectionIndex),
					ActualSection.Code == ExpectedSection.Code);
			}
		}

		return bMatched;
	}
}

using namespace AngelscriptTest_Preprocessor_AngelscriptPreprocessorAsyncLoadTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptPreprocessorAsyncMatchesSynchronousPreprocessTest,
	"Angelscript.TestModule.Preprocessor.AsyncLoad.AsyncMatchesSynchronousPreprocess",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptPreprocessorAsyncMatchesSynchronousPreprocessTest::RunTest(const FString& Parameters)
{
	FAngelscriptTestFixture Fixture(*this);
	if (!TestTrue(TEXT("Async-load preprocessor test should acquire a clean engine fixture"), Fixture.IsValid()))
	{
		return false;
	}

	FAngelscriptEngine& Engine = Fixture.GetEngine();
	TGuardValue<bool> AutomaticImportGuard(Engine.bUseAutomaticImportMethod, false);

	const FString SharedPadding = MakeAsyncLoadPadding(60000);
	const FString ProviderRelativePath = TEXT("Tests/Preprocessor/AsyncLoad/Provider.as");
	const FString ProviderContents =
		FString(TEXT("const int ProviderMultiplier = 3;\n"))
		+ TEXT("int ProvideValue()\n")
		+ TEXT("{\n")
		+ TEXT("    return 7;\n")
		+ TEXT("}\n")
		+ SharedPadding;
	const FString ProviderAbsolutePath = WritePreprocessorAsyncLoadFixture(
		ProviderRelativePath,
		ProviderContents);

	const FString ConsumerRelativePath = TEXT("Tests/Preprocessor/AsyncLoad/Consumer.as");
	const FString ConsumerContents =
		FString(TEXT("import Tests.Preprocessor.AsyncLoad.Provider;\n"))
		+ TEXT("class AAsyncLoadMacroActor : AActor\n")
		+ TEXT("{\n")
		+ TEXT("    UPROPERTY(EditAnywhere, BlueprintReadWrite)\n")
		+ TEXT("    int StoredValue = ProviderMultiplier;\n")
		+ TEXT("}\n")
		+ TEXT("int UseProvider()\n")
		+ TEXT("{\n")
		+ TEXT("    return ProvideValue() * ProviderMultiplier;\n")
		+ TEXT("}\n")
		+ SharedPadding;
	const FString ConsumerAbsolutePath = WritePreprocessorAsyncLoadFixture(
		ConsumerRelativePath,
		ConsumerContents);

	auto RunPreprocess = [this, &Engine](
		const bool bLoadAsynchronous,
		const FString& InProviderRelativePath,
		const FString& InProviderAbsolutePath,
		const FString& InConsumerRelativePath,
		const FString& InConsumerAbsolutePath,
		TArray<FModuleSnapshot>& OutModules,
		TArray<FString>& OutDiagnostics,
		int32& OutErrorCount) -> bool
	{
		Engine.ResetDiagnostics();

		FAngelscriptPreprocessor Preprocessor;
		Preprocessor.AddFile(InProviderRelativePath, InProviderAbsolutePath, bLoadAsynchronous);
		Preprocessor.AddFile(InConsumerRelativePath, InConsumerAbsolutePath, bLoadAsynchronous);

		const bool bSucceeded = Preprocessor.Preprocess();
		OutModules = CaptureModuleSnapshot(Preprocessor.GetModulesToCompile());
		OutDiagnostics = CollectDiagnosticMessages(
			Engine,
			{InProviderAbsolutePath, InConsumerAbsolutePath},
			OutErrorCount);
		return bSucceeded;
	};

	TArray<FModuleSnapshot> SynchronousModules;
	TArray<FString> SynchronousDiagnostics;
	int32 SynchronousErrorCount = 0;
	const bool bSynchronousSucceeded = RunPreprocess(
		false,
		ProviderRelativePath,
		ProviderAbsolutePath,
		ConsumerRelativePath,
		ConsumerAbsolutePath,
		SynchronousModules,
		SynchronousDiagnostics,
		SynchronousErrorCount);

	TArray<FModuleSnapshot> AsynchronousModules;
	TArray<FString> AsynchronousDiagnostics;
	int32 AsynchronousErrorCount = 0;
	const bool bAsynchronousSucceeded = RunPreprocess(
		true,
		ProviderRelativePath,
		ProviderAbsolutePath,
		ConsumerRelativePath,
		ConsumerAbsolutePath,
		AsynchronousModules,
		AsynchronousDiagnostics,
		AsynchronousErrorCount);

	const bool bSyncSucceeded = TestTrue(
		TEXT("Synchronous preprocess should succeed for the async-load comparison fixture"),
		bSynchronousSucceeded);
	const bool bAsyncSucceeded = TestTrue(
		TEXT("Asynchronous preprocess should succeed for the async-load comparison fixture"),
		bAsynchronousSucceeded);
	const bool bSyncDiagnosticsEmpty = TestEqual(
		TEXT("Synchronous preprocess should not emit diagnostics for the async-load comparison fixture"),
		SynchronousDiagnostics.Num(),
		0);
	const bool bAsyncDiagnosticsEmpty = TestEqual(
		TEXT("Asynchronous preprocess should not emit diagnostics for the async-load comparison fixture"),
		AsynchronousDiagnostics.Num(),
		0);
	const bool bSyncErrorCountZero = TestEqual(
		TEXT("Synchronous preprocess should not emit errors for the async-load comparison fixture"),
		SynchronousErrorCount,
		0);
	const bool bAsyncErrorCountZero = TestEqual(
		TEXT("Asynchronous preprocess should not emit errors for the async-load comparison fixture"),
		AsynchronousErrorCount,
		0);

	if (!bSyncSucceeded || !bAsyncSucceeded || !bSyncDiagnosticsEmpty || !bAsyncDiagnosticsEmpty || !bSyncErrorCountZero || !bAsyncErrorCountZero)
	{
		return false;
	}

	return TestModuleSnapshotsMatch(*this, SynchronousModules, AsynchronousModules);
}

#endif
