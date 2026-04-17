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

namespace PreprocessorClassErrorTest
{
	static const TCHAR* UnknownSuperTypeMessage =
		TEXT("Class UUnknownSuperCarrier has an unknown super type UMissingBaseType.");

	FString GetFixtureRoot()
	{
		return FPaths::Combine(FPaths::ProjectSavedDir(), TEXT("Automation"), TEXT("PreprocessorClassErrorFixtures"));
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
}

using namespace PreprocessorClassErrorTest;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptPreprocessorUnknownSuperTypeReportsDiagnosticTest,
	"Angelscript.TestModule.Preprocessor.Classes.UnknownSuperTypeReportsDiagnostic",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptPreprocessorUnknownSuperTypeReportsDiagnosticTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	AddExpectedErrorPlain(
		PreprocessorClassErrorTest::UnknownSuperTypeMessage,
		EAutomationExpectedErrorFlags::Contains,
		1);

	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	Engine.ResetDiagnostics();
	Engine.LastEmittedDiagnostics.Empty();

	const FString RelativeScriptPath = TEXT("Tests/Preprocessor/Classes/UnknownSuperType.as");
	const FString AbsoluteScriptPath = PreprocessorClassErrorTest::WriteFixture(
		RelativeScriptPath,
		TEXT(
			"UCLASS()\n"
			"class UUnknownSuperCarrier : UMissingBaseType\n"
			"{\n"
			"}\n"));
	ON_SCOPE_EXIT
	{
		IFileManager::Get().Delete(*AbsoluteScriptPath, false, true);
	};

	FAngelscriptPreprocessor Preprocessor;
	Preprocessor.AddFile(RelativeScriptPath, AbsoluteScriptPath);

	const bool bPreprocessSucceeded = Preprocessor.Preprocess();
	const TArray<TSharedRef<FAngelscriptModuleDesc>> Modules = Preprocessor.GetModulesToCompile();
	const FAngelscriptEngine::FDiagnostics* Diagnostics = Engine.Diagnostics.Find(AbsoluteScriptPath);
	FAngelscriptModuleDesc* Module = PreprocessorClassErrorTest::FindModuleByName(
		Modules,
		TEXT("Tests.Preprocessor.Classes.UnknownSuperType"));

	bPassed &= TestFalse(
		TEXT("Unknown super type should fail during preprocessing"),
		bPreprocessSucceeded);
	bPassed &= TestEqual(
		TEXT("Unknown super type should keep exactly one module descriptor for inspection"),
		Modules.Num(),
		1);
	bPassed &= TestNotNull(
		TEXT("Unknown super type should emit diagnostics for the failing file"),
		Diagnostics);
	bPassed &= TestNotNull(
		TEXT("Unknown super type should preserve the module descriptor while failing closed"),
		Module);
	bPassed &= TestFalse(
		TEXT("Unknown super type should not leave behind compilable code after preprocessing fails"),
		PreprocessorClassErrorTest::ContainsCompilableCode(Modules));

	if (Diagnostics != nullptr && Diagnostics->Diagnostics.Num() > 0)
	{
		const FAngelscriptEngine::FDiagnostic& FirstDiagnostic = Diagnostics->Diagnostics[0];
		bPassed &= TestEqual(
			TEXT("Unknown super type should emit exactly one preprocessing error"),
			PreprocessorClassErrorTest::CountErrorDiagnostics(Diagnostics),
			1);
		bPassed &= TestEqual(
			TEXT("Unknown super type should keep the unknown-super diagnostic text stable"),
			FirstDiagnostic.Message,
			FString(PreprocessorClassErrorTest::UnknownSuperTypeMessage));
		bPassed &= TestEqual(
			TEXT("Unknown super type should pin the diagnostic row to the class declaration line"),
			FirstDiagnostic.Row,
			2);
		bPassed &= TestEqual(
			TEXT("Unknown super type should keep the diagnostic column at the class declaration start"),
			FirstDiagnostic.Column,
			1);
	}

	if (Module != nullptr)
	{
		bPassed &= TestEqual(
			TEXT("Unknown super type should not emit any processed code sections"),
			Module->Code.Num(),
			0);
		bPassed &= TestEqual(
			TEXT("Unknown super type should not keep any class descriptors in the module"),
			Module->Classes.Num(),
			0);
		bPassed &= TestNull(
			TEXT("Unknown super type should not leave a consumable class descriptor behind"),
			Module->GetClass(TEXT("UUnknownSuperCarrier")).Get());
	}

	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

#endif
