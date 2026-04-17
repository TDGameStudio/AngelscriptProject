#include "../Shared/AngelscriptTestUtilities.h"
#include "../Shared/AngelscriptTestMacros.h"

#include "Preprocessor/AngelscriptPreprocessor.h"

#include "HAL/FileManager.h"
#include "Misc/AutomationTest.h"
#include "Misc/FileHelper.h"
#include "Misc/Paths.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace AngelscriptTest_Preprocessor_AngelscriptPreprocessorDirectiveErrorTests_Private
{
	struct FDirectiveErrorScenario
	{
		const TCHAR* Label;
		const TCHAR* RelativeScriptPath;
		const TCHAR* ScriptSource;
		const TCHAR* ExpectedMessage;
		int32 ExpectedRow;
	};

	FString GetPreprocessorDirectiveErrorFixtureRoot()
	{
		return FPaths::Combine(FPaths::ProjectSavedDir(), TEXT("Automation"), TEXT("PreprocessorDirectiveErrorFixtures"));
	}

	FString WritePreprocessorDirectiveErrorFixture(const FString& RelativeScriptPath, const FString& Contents)
	{
		const FString AbsolutePath = FPaths::Combine(GetPreprocessorDirectiveErrorFixtureRoot(), RelativeScriptPath);
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

	bool RunDirectiveErrorScenario(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		const FDirectiveErrorScenario& Scenario)
	{
		Engine.ResetDiagnostics();
		Engine.LastEmittedDiagnostics.Empty();

		const FString AbsoluteScriptPath = WritePreprocessorDirectiveErrorFixture(
			Scenario.RelativeScriptPath,
			Scenario.ScriptSource);

		FAngelscriptPreprocessor Preprocessor;
		Preprocessor.AddFile(Scenario.RelativeScriptPath, AbsoluteScriptPath);

		const bool bPreprocessSucceeded = Preprocessor.Preprocess();
		const TArray<TSharedRef<FAngelscriptModuleDesc>> Modules = Preprocessor.GetModulesToCompile();
		const FAngelscriptEngine::FDiagnostics* Diagnostics = Engine.Diagnostics.Find(AbsoluteScriptPath);

		if (!Test.TestFalse(
				FString::Printf(TEXT("%s should fail preprocessing on structural directive errors"), Scenario.Label),
				bPreprocessSucceeded))
		{
			return false;
		}

		if (!Test.TestNotNull(
				FString::Printf(TEXT("%s should record diagnostics for the failing file"), Scenario.Label),
				Diagnostics))
		{
			return false;
		}

		const FAngelscriptEngine::FDiagnostic& FirstDiagnostic = Diagnostics->Diagnostics[0];

		return Test.TestEqual(
				FString::Printf(TEXT("%s should emit exactly one error diagnostic"), Scenario.Label),
				CountErrorDiagnostics(Diagnostics),
				1)
			&& Test.TestEqual(
				FString::Printf(TEXT("%s should report the expected structural directive error text"), Scenario.Label),
				FirstDiagnostic.Message,
				FString(Scenario.ExpectedMessage))
			&& Test.TestEqual(
				FString::Printf(TEXT("%s should pin the error row to the failing directive line"), Scenario.Label),
				FirstDiagnostic.Row,
				Scenario.ExpectedRow)
			&& Test.TestEqual(
				FString::Printf(TEXT("%s should keep the error column stable at the directive start"), Scenario.Label),
				FirstDiagnostic.Column,
				1)
			&& Test.TestFalse(
				FString::Printf(TEXT("%s should not leave behind any compilable code sections after preprocessing fails"), Scenario.Label),
				ContainsCompilableCode(Modules));
	}
}

using namespace AngelscriptTest_Preprocessor_AngelscriptPreprocessorDirectiveErrorTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptPreprocessorStructuralErrorsReportStableDiagnosticsTest,
	"Angelscript.TestModule.Preprocessor.Directives.StructuralErrorsReportStableDiagnostics",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptPreprocessorStructuralErrorsReportStableDiagnosticsTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	AddExpectedError(TEXT("Invalid #elif, no matching #if found."), EAutomationExpectedErrorFlags::Contains, 1);
	AddExpectedError(TEXT("Invalid #else, no matching #if found."), EAutomationExpectedErrorFlags::Contains, 1);
	AddExpectedError(TEXT("Invalid #endif, no matching #if found."), EAutomationExpectedErrorFlags::Contains, 1);
	AddExpectedError(TEXT("Preceding preprocessor #if/#ifdef/#else was not closed, missing #endif."), EAutomationExpectedErrorFlags::Contains, 1);
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	const TArray<FDirectiveErrorScenario> Scenarios = {
		{
			TEXT("Isolated #elif"),
			TEXT("Tests/Preprocessor/DirectiveErrors/InvalidElif.as"),
			TEXT(
				"#elif EDITOR\n"
				"int Value = 1;\n"),
			TEXT("Invalid #elif, no matching #if found."),
			1
		},
		{
			TEXT("Isolated #else"),
			TEXT("Tests/Preprocessor/DirectiveErrors/InvalidElse.as"),
			TEXT(
				"#else\n"
				"int Value = 1;\n"),
			TEXT("Invalid #else, no matching #if found."),
			1
		},
		{
			TEXT("Isolated #endif"),
			TEXT("Tests/Preprocessor/DirectiveErrors/InvalidEndif.as"),
			TEXT(
				"#endif\n"
				"int Value = 1;\n"),
			TEXT("Invalid #endif, no matching #if found."),
			1
		},
		{
			TEXT("Missing #endif"),
			TEXT("Tests/Preprocessor/DirectiveErrors/MissingEndif.as"),
			TEXT(
				"#if EDITOR\n"
				"int Value = 1;\n"),
			TEXT("Preceding preprocessor #if/#ifdef/#else was not closed, missing #endif."),
			1
		}
	};

	for (const FDirectiveErrorScenario& Scenario : Scenarios)
	{
		bPassed &= RunDirectiveErrorScenario(*this, Engine, Scenario);
	}

	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

#endif
