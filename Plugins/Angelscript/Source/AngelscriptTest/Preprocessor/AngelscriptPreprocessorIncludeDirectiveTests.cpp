#include "../Shared/AngelscriptTestEngineHelper.h"
#include "../Shared/AngelscriptTestMacros.h"

#include "Preprocessor/AngelscriptPreprocessor.h"

#include "HAL/FileManager.h"
#include "Misc/AutomationTest.h"
#include "Misc/FileHelper.h"
#include "Misc/Paths.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace AngelscriptTest_Preprocessor_AngelscriptPreprocessorIncludeDirectiveTests_Private
{
	static const FString ExpectedIncludeDiagnostic(TEXT("Unsupported preprocessor directive '#include'. Use import or automatic imports instead."));

	FString GetPreprocessorIncludeFixtureRoot()
	{
		return FPaths::Combine(FPaths::ProjectSavedDir(), TEXT("Automation"));
	}

	FString WritePreprocessorIncludeFixture(const FString& RelativeScriptPath, const FString& Contents)
	{
		const FString AbsolutePath = FPaths::Combine(GetPreprocessorIncludeFixtureRoot(), RelativeScriptPath);
		IFileManager::Get().MakeDirectory(*FPaths::GetPath(AbsolutePath), true);
		FFileHelper::SaveStringToFile(Contents, *AbsolutePath);
		return AbsolutePath;
	}

	const FAngelscriptEngine::FDiagnostic* FindDiagnosticContaining(
		const FAngelscriptEngine& Engine,
		const FString& AbsoluteFilename,
		const FString& Needle)
	{
		if (const FAngelscriptEngine::FDiagnostics* Diagnostics = Engine.Diagnostics.Find(AbsoluteFilename))
		{
			for (const FAngelscriptEngine::FDiagnostic& Diagnostic : Diagnostics->Diagnostics)
			{
				if (Diagnostic.Message.Contains(Needle))
				{
					return &Diagnostic;
				}
			}
		}

		return nullptr;
	}

}

using namespace AngelscriptTest_Preprocessor_AngelscriptPreprocessorIncludeDirectiveTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptPreprocessorIncludeDirectiveProducesDeterministicResultTest,
	"Angelscript.TestModule.Preprocessor.Directives.IncludeDirectiveProducesDeterministicResult",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptPreprocessorIncludeDirectiveProducesDeterministicResultTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	static const FName ModuleName(TEXT("Tests.Preprocessor.Directives.IncludeDirectiveProducesDeterministicResult"));
	const FString RelativeScriptPath = TEXT("Tests/Preprocessor/Directives/IncludeDirectiveProducesDeterministicResult.as");
	const FString ScriptSource = TEXT(
		"#include \"Shared.as\"\n"
		"int Entry()\n"
		"{\n"
		"    return 42;\n"
		"}\n");
	const FString AbsoluteScriptPath = WritePreprocessorIncludeFixture(RelativeScriptPath, ScriptSource);

	AddExpectedError(*ExpectedIncludeDiagnostic, EAutomationExpectedErrorFlags::Contains, 2);

	Engine.ResetDiagnostics();

	FAngelscriptPreprocessor Preprocessor;
	Preprocessor.AddFile(RelativeScriptPath, AbsoluteScriptPath);

	const bool bPreprocessSucceeded = Preprocessor.Preprocess();
	const FAngelscriptEngine::FDiagnostics* PreprocessDiagnostics = Engine.Diagnostics.Find(AbsoluteScriptPath);
	const FAngelscriptEngine::FDiagnostic* IncludePreprocessDiagnostic = FindDiagnosticContaining(
		Engine,
		AbsoluteScriptPath,
		ExpectedIncludeDiagnostic);

	bPassed &= TestFalse(
		TEXT("Unsupported #include should fail during preprocessing instead of flowing into later compilation"),
		bPreprocessSucceeded);
	bPassed &= TestNotNull(
		TEXT("Unsupported #include should record diagnostics on the source file"),
		PreprocessDiagnostics);
	if (PreprocessDiagnostics != nullptr)
	{
		bPassed &= TestEqual(
			TEXT("Unsupported #include should emit exactly one preprocessing diagnostic"),
			PreprocessDiagnostics->Diagnostics.Num(),
			1);
	}

	bPassed &= TestNotNull(
		TEXT("Unsupported #include should emit the dedicated include diagnostic"),
		IncludePreprocessDiagnostic);
	if (IncludePreprocessDiagnostic != nullptr)
	{
		bPassed &= TestTrue(
			TEXT("Unsupported #include should be reported as an error"),
			IncludePreprocessDiagnostic->bIsError);
		bPassed &= TestEqual(
			TEXT("Unsupported #include diagnostic should point at the directive line"),
			IncludePreprocessDiagnostic->Row,
			1);
	}

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
	const FAngelscriptEngine::FDiagnostic* IncludeCompileDiagnostic = FindDiagnosticContaining(
		Engine,
		AbsoluteScriptPath,
		ExpectedIncludeDiagnostic);

	bPassed &= TestFalse(
		TEXT("Unsupported #include should fail through the compile summary path as well"),
		bCompiled);
	bPassed &= TestTrue(
		TEXT("Unsupported #include compile summary should report that preprocessing was used"),
		Summary.bUsedPreprocessor);
	bPassed &= TestEqual(
		TEXT("Unsupported #include compile summary should end with an error result"),
		Summary.CompileResult,
		ECompileResult::Error);
	bPassed &= TestEqual(
		TEXT("Unsupported #include compile summary should not compile any module"),
		Summary.CompiledModuleCount,
		0);
	bPassed &= TestNotNull(
		TEXT("Unsupported #include compile summary should still leave the dedicated include diagnostic on the engine"),
		IncludeCompileDiagnostic);
	if (IncludeCompileDiagnostic != nullptr)
	{
		bPassed &= TestTrue(
			TEXT("Unsupported #include compile summary diagnostic should stay on the error path"),
			IncludeCompileDiagnostic->bIsError);
		bPassed &= TestEqual(
			TEXT("Unsupported #include compile summary diagnostic should point at the directive line"),
			IncludeCompileDiagnostic->Row,
			1);
	}

	ASTEST_END_SHARE_CLEAN

	return bPassed;
}

#endif
