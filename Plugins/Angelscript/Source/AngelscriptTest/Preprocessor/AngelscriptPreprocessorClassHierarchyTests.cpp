#include "../Shared/AngelscriptTestEngineHelper.h"
#include "../Shared/AngelscriptTestUtilities.h"

#include "Preprocessor/AngelscriptPreprocessor.h"

#include "HAL/FileManager.h"
#include "Misc/AutomationTest.h"
#include "Misc/FileHelper.h"
#include "Misc/Paths.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace PreprocessorClassHierarchyTest
{
	static const FName SeedModuleName(TEXT("Tests.Preprocessor.First"));
	static const FString SeedFilename(TEXT("Tests/Preprocessor/First.as"));
	static const FString FirstRelativeScriptPath(TEXT("Tests/Preprocessor/First.as"));
	static const FString SecondRelativeScriptPath(TEXT("Tests/Preprocessor/Second.as"));
	static const FString DuplicateClassName(TEXT("UDuplicateCarrier"));
	static const FString ExpectedDuplicateDiagnostic(
		TEXT("Cannot declare class UDuplicateCarrier in module Tests.Preprocessor.Second. A class with this name already exists in module Tests.Preprocessor.First."));

	FString GetFixtureRoot()
	{
		return FPaths::Combine(FPaths::ProjectSavedDir(), TEXT("Automation"), TEXT("PreprocessorClassHierarchyFixtures"));
	}

	FString WriteFixture(const FString& RelativeScriptPath, const FString& Contents)
	{
		const FString AbsolutePath = FPaths::Combine(GetFixtureRoot(), RelativeScriptPath);
		IFileManager::Get().MakeDirectory(*FPaths::GetPath(AbsolutePath), true);
		FFileHelper::SaveStringToFile(Contents, *AbsolutePath);
		return AbsolutePath;
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

	FAngelscriptModuleDesc* FindModuleByName(
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

	int32 CountModulesContainingClass(
		const TArray<TSharedRef<FAngelscriptModuleDesc>>& Modules,
		const FString& ClassName)
	{
		int32 Count = 0;
		for (const TSharedRef<FAngelscriptModuleDesc>& Module : Modules)
		{
			if (Module->GetClass(ClassName).IsValid())
			{
				++Count;
			}
		}
		return Count;
	}
}

using namespace PreprocessorClassHierarchyTest;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptPreprocessorDuplicateClassNameAcrossHotReloadBatchReportsConflictTest,
	"Angelscript.TestModule.Preprocessor.Classes.DuplicateClassNameAcrossHotReloadBatchReportsConflict",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptPreprocessorDuplicateClassNameAcrossHotReloadBatchReportsConflictTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	FAngelscriptTestFixture Fixture(*this, ETestEngineMode::IsolatedFull);
	if (!TestTrue(TEXT("Duplicate class name across hot reload batch should acquire an isolated full engine"), Fixture.IsValid()))
	{
		return false;
	}

	FAngelscriptEngine& Engine = Fixture.GetEngine();
	Engine.ResetDiagnostics();
	Engine.LastEmittedDiagnostics.Empty();

	FAngelscriptCompileTraceSummary SeedSummary;
	const bool bSeedCompiled = CompileModuleWithSummary(
		&Engine,
		ECompileType::FullReload,
		PreprocessorClassHierarchyTest::SeedModuleName,
		PreprocessorClassHierarchyTest::SeedFilename,
		TEXT(
			"UCLASS()\n"
			"class UDuplicateCarrier : UObject\n"
			"{\n"
			"    UFUNCTION()\n"
			"    int GetSeedValue()\n"
			"    {\n"
			"        return 1;\n"
			"    }\n"
			"}\n"),
		true,
		SeedSummary);
	if (!TestTrue(TEXT("Duplicate class name across hot reload batch should seed the first active module"), bSeedCompiled))
	{
		return false;
	}

	if (!TestEqual(TEXT("Duplicate class name across hot reload batch should seed exactly one compiled module"), SeedSummary.CompiledModuleCount, 1)
		|| !TestEqual(TEXT("Duplicate class name across hot reload batch should seed without diagnostics"), SeedSummary.Diagnostics.Num(), 0))
	{
		return false;
	}

	if (!TestNotNull(TEXT("Duplicate class name across hot reload batch should publish the seeded generated class"), FindGeneratedClass(&Engine, TEXT("UDuplicateCarrier"))))
	{
		return false;
	}

	Engine.ResetDiagnostics();
	Engine.LastEmittedDiagnostics.Empty();

	const FString FirstAbsoluteScriptPath = PreprocessorClassHierarchyTest::WriteFixture(
		PreprocessorClassHierarchyTest::FirstRelativeScriptPath,
		TEXT(
			"UCLASS()\n"
			"class UDuplicateCarrier : UObject\n"
			"{\n"
			"    UFUNCTION()\n"
			"    int GetHotReloadValue()\n"
			"    {\n"
			"        return 2;\n"
			"    }\n"
			"}\n"));
	const FString SecondAbsoluteScriptPath = PreprocessorClassHierarchyTest::WriteFixture(
		PreprocessorClassHierarchyTest::SecondRelativeScriptPath,
		TEXT(
			"UCLASS()\n"
			"class UDuplicateCarrier : UObject\n"
			"{\n"
			"}\n"));
	ON_SCOPE_EXIT
	{
		IFileManager::Get().Delete(*FirstAbsoluteScriptPath, false, true);
		IFileManager::Get().Delete(*SecondAbsoluteScriptPath, false, true);
	};

	AddExpectedErrorPlain(
		PreprocessorClassHierarchyTest::ExpectedDuplicateDiagnostic,
		EAutomationExpectedErrorFlags::Contains,
		1);

	FAngelscriptPreprocessor Preprocessor;
	Preprocessor.AddFile(PreprocessorClassHierarchyTest::FirstRelativeScriptPath, FirstAbsoluteScriptPath);
	Preprocessor.AddFile(PreprocessorClassHierarchyTest::SecondRelativeScriptPath, SecondAbsoluteScriptPath);

	const bool bPreprocessSucceeded = Preprocessor.Preprocess();
	const TArray<TSharedRef<FAngelscriptModuleDesc>> Modules = Preprocessor.GetModulesToCompile();
	const FAngelscriptEngine::FDiagnostics* FirstDiagnostics = Engine.Diagnostics.Find(FirstAbsoluteScriptPath);
	const FAngelscriptEngine::FDiagnostics* SecondDiagnostics = Engine.Diagnostics.Find(SecondAbsoluteScriptPath);
	FAngelscriptModuleDesc* FirstModule = PreprocessorClassHierarchyTest::FindModuleByName(
		Modules,
		TEXT("Tests.Preprocessor.First"));
	FAngelscriptModuleDesc* SecondModule = PreprocessorClassHierarchyTest::FindModuleByName(
		Modules,
		TEXT("Tests.Preprocessor.Second"));

	bPassed &= TestFalse(
		TEXT("Duplicate class name across hot reload batch should fail during preprocessing"),
		bPreprocessSucceeded);
	bPassed &= TestEqual(
		TEXT("Duplicate class name across hot reload batch should keep both module descriptors available for inspection"),
		Modules.Num(),
		2);
	bPassed &= TestNotNull(
		TEXT("Duplicate class name across hot reload batch should preserve the first module descriptor"),
		FirstModule);
	bPassed &= TestNotNull(
		TEXT("Duplicate class name across hot reload batch should preserve the second module descriptor"),
		SecondModule);
	bPassed &= TestNull(
		TEXT("Duplicate class name across hot reload batch should not emit diagnostics for the reloaded first file"),
		FirstDiagnostics);
	bPassed &= TestNotNull(
		TEXT("Duplicate class name across hot reload batch should emit diagnostics for the second file"),
		SecondDiagnostics);
	bPassed &= TestTrue(
		TEXT("Duplicate class name across hot reload batch should not leave duplicate class descriptors across modules"),
		PreprocessorClassHierarchyTest::CountModulesContainingClass(Modules, PreprocessorClassHierarchyTest::DuplicateClassName) < 2);

	if (SecondDiagnostics != nullptr && SecondDiagnostics->Diagnostics.Num() > 0)
	{
		const FAngelscriptEngine::FDiagnostic& FirstDiagnostic = SecondDiagnostics->Diagnostics[0];
		bPassed &= TestEqual(
			TEXT("Duplicate class name across hot reload batch should emit exactly one preprocessing error on the second file"),
			PreprocessorClassHierarchyTest::CountErrorDiagnostics(SecondDiagnostics),
			1);
		bPassed &= TestEqual(
			TEXT("Duplicate class name across hot reload batch should keep the duplicate-class diagnostic text stable"),
			FirstDiagnostic.Message,
			PreprocessorClassHierarchyTest::ExpectedDuplicateDiagnostic);
		bPassed &= TestEqual(
			TEXT("Duplicate class name across hot reload batch should pin the diagnostic row to the duplicate declaration line"),
			FirstDiagnostic.Row,
			2);
		bPassed &= TestEqual(
			TEXT("Duplicate class name across hot reload batch should keep the diagnostic column at the class declaration start"),
			FirstDiagnostic.Column,
			1);
	}

	if (SecondModule != nullptr)
	{
		bPassed &= TestTrue(
			TEXT("Duplicate class name across hot reload batch should not leave a consumable duplicate class descriptor in the second module"),
			SecondModule->GetClass(PreprocessorClassHierarchyTest::DuplicateClassName).Get() == nullptr);
	}

	return bPassed;
}

#endif
