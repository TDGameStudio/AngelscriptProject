#include "../Shared/AngelscriptTestUtilities.h"

#include "Preprocessor/AngelscriptPreprocessor.h"

#include "HAL/FileManager.h"
#include "Misc/AutomationTest.h"
#include "Misc/Guid.h"
#include "Misc/Paths.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptPreprocessorAsyncZeroByteFileMatchesSyncPathTest,
	"Angelscript.TestModule.Preprocessor.Api.AsyncZeroByteFileMatchesSyncPath",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

namespace AngelscriptTest_Preprocessor_AngelscriptPreprocessorAsyncTests_Private
{
	struct FPreprocessorCodeSectionSnapshot
	{
		FString RelativeFilename;
		FString AbsoluteFilename;
		FString Code;
		int64 CodeHash = 0;
	};

	struct FPreprocessorModuleSnapshot
	{
		FString ModuleName;
		TArray<FString> ImportedModules;
		TArray<FPreprocessorCodeSectionSnapshot> CodeSections;
		int64 CodeHash = 0;
	};

	FString GetPreprocessorAsyncZeroByteFixtureRoot()
	{
		return FPaths::Combine(FPaths::ProjectSavedDir(), TEXT("Automation"), TEXT("PreprocessorAsyncZeroByteFixtures"));
	}

	bool CreateZeroByteFixtureFile(FAutomationTestBase& Test, const FString& RelativeScriptPath, FString& OutAbsolutePath)
	{
		OutAbsolutePath = FPaths::Combine(GetPreprocessorAsyncZeroByteFixtureRoot(), RelativeScriptPath);
		IFileManager::Get().MakeDirectory(*FPaths::GetPath(OutAbsolutePath), true);

		FArchive* Writer = IFileManager::Get().CreateFileWriter(*OutAbsolutePath);
		if (!Test.TestNotNull(TEXT("Zero-byte async preprocessor fixture should create a writable file handle"), Writer))
		{
			return false;
		}

		Writer->Close();
		delete Writer;
		return true;
	}

	TArray<FString> CollectDiagnosticMessages(
		const FAngelscriptEngine& Engine,
		const FString& AbsoluteFilename,
		int32& OutErrorCount)
	{
		TArray<FString> Messages;
		OutErrorCount = 0;

		const FAngelscriptEngine::FDiagnostics* Diagnostics = Engine.Diagnostics.Find(AbsoluteFilename);
		if (Diagnostics == nullptr)
		{
			return Messages;
		}

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

	bool CaptureSingleModuleSnapshot(
		FAutomationTestBase& Test,
		const TArray<TSharedRef<FAngelscriptModuleDesc>>& Modules,
		FPreprocessorModuleSnapshot& OutSnapshot,
		const TCHAR* ContextLabel)
	{
		if (!Test.TestEqual(
				*FString::Printf(TEXT("%s should produce exactly one module"), ContextLabel),
				Modules.Num(),
				1))
		{
			return false;
		}

		const FAngelscriptModuleDesc& Module = Modules[0].Get();
		OutSnapshot.ModuleName = Module.ModuleName;
		OutSnapshot.ImportedModules = Module.ImportedModules;
		OutSnapshot.CodeHash = Module.CodeHash;
		OutSnapshot.CodeSections.Reserve(Module.Code.Num());

		for (const FAngelscriptModuleDesc::FCodeSection& Section : Module.Code)
		{
			FPreprocessorCodeSectionSnapshot SectionSnapshot;
			SectionSnapshot.RelativeFilename = Section.RelativeFilename;
			SectionSnapshot.AbsoluteFilename = Section.AbsoluteFilename;
			SectionSnapshot.Code = Section.Code;
			SectionSnapshot.CodeHash = Section.CodeHash;
			OutSnapshot.CodeSections.Add(MoveTemp(SectionSnapshot));
		}

		return true;
	}

	bool RunPreprocessForSnapshot(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		const bool bLoadAsynchronous,
		const FString& RelativeFilename,
		const FString& AbsoluteFilename,
		FPreprocessorModuleSnapshot& OutSnapshot,
		TArray<FString>& OutDiagnostics,
		int32& OutErrorCount)
	{
		Engine.ResetDiagnostics();

		FAngelscriptPreprocessor Preprocessor;
		Preprocessor.AddFile(RelativeFilename, AbsoluteFilename, bLoadAsynchronous);
		const bool bSucceeded = Preprocessor.Preprocess();

		if (!CaptureSingleModuleSnapshot(
				Test,
				Preprocessor.GetModulesToCompile(),
				OutSnapshot,
				bLoadAsynchronous
					? TEXT("Asynchronous zero-byte preprocess")
					: TEXT("Synchronous zero-byte preprocess")))
		{
			return false;
		}

		OutDiagnostics = CollectDiagnosticMessages(Engine, AbsoluteFilename, OutErrorCount);
		return bSucceeded;
	}

	bool CompareSnapshots(
		FAutomationTestBase& Test,
		const FPreprocessorModuleSnapshot& ExpectedSnapshot,
		const FPreprocessorModuleSnapshot& ActualSnapshot)
	{
		bool bMatched = true;

		bMatched &= Test.TestEqual(
			TEXT("Async zero-byte preprocess should keep the same module name as the sync path"),
			ActualSnapshot.ModuleName,
			ExpectedSnapshot.ModuleName);

		bMatched &= Test.TestEqual(
			TEXT("Async zero-byte preprocess should keep the same imported-module count as the sync path"),
			ActualSnapshot.ImportedModules.Num(),
			ExpectedSnapshot.ImportedModules.Num());

		bMatched &= Test.TestEqual(
			TEXT("Async zero-byte preprocess should keep the same code section count as the sync path"),
			ActualSnapshot.CodeSections.Num(),
			ExpectedSnapshot.CodeSections.Num());

		bMatched &= Test.TestEqual(
			TEXT("Synchronous zero-byte preprocess should keep a zero aggregate code hash"),
			ExpectedSnapshot.CodeHash,
			0ll);

		bMatched &= Test.TestEqual(
			TEXT("Async zero-byte preprocess should keep the same aggregate code hash as the sync path"),
			ActualSnapshot.CodeHash,
			ExpectedSnapshot.CodeHash);

		bMatched &= Test.TestEqual(
			TEXT("Synchronous zero-byte preprocess should keep zero imported modules"),
			ExpectedSnapshot.ImportedModules.Num(),
			0);

		const int32 ComparedSectionCount = FMath::Min(ExpectedSnapshot.CodeSections.Num(), ActualSnapshot.CodeSections.Num());
		for (int32 SectionIndex = 0; SectionIndex < ComparedSectionCount; ++SectionIndex)
		{
			const FPreprocessorCodeSectionSnapshot& ExpectedSection = ExpectedSnapshot.CodeSections[SectionIndex];
			const FPreprocessorCodeSectionSnapshot& ActualSection = ActualSnapshot.CodeSections[SectionIndex];

			bMatched &= Test.TestEqual(
				*FString::Printf(TEXT("Code section[%d] relative filename should match between sync and async zero-byte preprocess"), SectionIndex),
				ActualSection.RelativeFilename,
				ExpectedSection.RelativeFilename);

			bMatched &= Test.TestEqual(
				*FString::Printf(TEXT("Code section[%d] absolute filename should match between sync and async zero-byte preprocess"), SectionIndex),
				ActualSection.AbsoluteFilename,
				ExpectedSection.AbsoluteFilename);

			bMatched &= Test.TestEqual(
				*FString::Printf(TEXT("Code section[%d] hash should match between sync and async zero-byte preprocess"), SectionIndex),
				ActualSection.CodeHash,
				ExpectedSection.CodeHash);

			bMatched &= Test.TestEqual(
				*FString::Printf(TEXT("Synchronous zero-byte preprocess should keep code section[%d] hash at zero"), SectionIndex),
				ExpectedSection.CodeHash,
				0ll);

			bMatched &= Test.TestTrue(
				*FString::Printf(TEXT("Synchronous zero-byte preprocess should keep code section[%d] empty"), SectionIndex),
				ExpectedSection.Code.IsEmpty());

			bMatched &= Test.TestTrue(
				*FString::Printf(TEXT("Code section[%d] processed code should match exactly between sync and async zero-byte preprocess"), SectionIndex),
				ActualSection.Code == ExpectedSection.Code);

			bMatched &= Test.TestTrue(
				*FString::Printf(TEXT("Asynchronous zero-byte preprocess should keep code section[%d] empty"), SectionIndex),
				ActualSection.Code.IsEmpty());
		}

		return bMatched;
	}
}

using namespace AngelscriptTest_Preprocessor_AngelscriptPreprocessorAsyncTests_Private;

bool FAngelscriptPreprocessorAsyncZeroByteFileMatchesSyncPathTest::RunTest(const FString& Parameters)
{
	FAngelscriptTestFixture Fixture(*this);
	if (!TestTrue(TEXT("Async zero-byte preprocessor test should acquire a clean engine fixture"), Fixture.IsValid()))
	{
		return false;
	}

	FAngelscriptEngine& Engine = Fixture.GetEngine();
	TGuardValue<bool> AutomaticImportGuard(Engine.bUseAutomaticImportMethod, false);

	const FString RelativeFilename = TEXT("Tests/Preprocessor/AsyncZeroByte/ZeroByte.as");
	FString AbsoluteFilename;
	if (!CreateZeroByteFixtureFile(*this, RelativeFilename, AbsoluteFilename))
	{
		return false;
	}

	ON_SCOPE_EXIT
	{
		IFileManager::Get().Delete(*AbsoluteFilename, false, true, true);
	};

	if (!TestEqual(
			TEXT("Async zero-byte preprocessor fixture should stay at file size 0"),
			IFileManager::Get().FileSize(*AbsoluteFilename),
			0ll))
	{
		return false;
	}

	FPreprocessorModuleSnapshot SyncSnapshot;
	TArray<FString> SyncDiagnostics;
	int32 SyncErrorCount = 0;
	const bool bSyncSucceeded = RunPreprocessForSnapshot(
		*this,
		Engine,
		false,
		RelativeFilename,
		AbsoluteFilename,
		SyncSnapshot,
		SyncDiagnostics,
		SyncErrorCount);

	FPreprocessorModuleSnapshot AsyncSnapshot;
	TArray<FString> AsyncDiagnostics;
	int32 AsyncErrorCount = 0;
	const bool bAsyncSucceeded = RunPreprocessForSnapshot(
		*this,
		Engine,
		true,
		RelativeFilename,
		AbsoluteFilename,
		AsyncSnapshot,
		AsyncDiagnostics,
		AsyncErrorCount);

	const bool bSyncReturned = TestTrue(
		TEXT("Synchronous zero-byte preprocess should return success"),
		bSyncSucceeded);
	const bool bAsyncReturned = TestTrue(
		TEXT("Asynchronous zero-byte preprocess should return success"),
		bAsyncSucceeded);
	const bool bSyncDiagnosticsEmpty = TestEqual(
		TEXT("Synchronous zero-byte preprocess should not emit diagnostics"),
		SyncDiagnostics.Num(),
		0);
	const bool bAsyncDiagnosticsEmpty = TestEqual(
		TEXT("Asynchronous zero-byte preprocess should not emit diagnostics"),
		AsyncDiagnostics.Num(),
		0);
	const bool bSyncErrorCountZero = TestEqual(
		TEXT("Synchronous zero-byte preprocess should not emit errors"),
		SyncErrorCount,
		0);
	const bool bAsyncErrorCountZero = TestEqual(
		TEXT("Asynchronous zero-byte preprocess should not emit errors"),
		AsyncErrorCount,
		0);

	if (!bSyncReturned || !bAsyncReturned || !bSyncDiagnosticsEmpty || !bAsyncDiagnosticsEmpty || !bSyncErrorCountZero || !bAsyncErrorCountZero)
	{
		return false;
	}

	return CompareSnapshots(*this, SyncSnapshot, AsyncSnapshot);
}

#endif
