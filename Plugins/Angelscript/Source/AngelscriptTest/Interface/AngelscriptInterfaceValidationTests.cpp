#include "Shared/AngelscriptTestEngineHelper.h"
#include "Shared/AngelscriptTestMacros.h"

#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace AngelscriptTest_Interface_AngelscriptInterfaceValidationTests_Private
{
	static const FName InterfaceValidationModuleName(TEXT("ScenarioInterfaceValidation"));
	static constexpr TCHAR InterfaceValidationFilename[] = TEXT("ScenarioInterfaceValidation.as");
	static constexpr TCHAR InvalidInterfaceClassName[] = TEXT("UIInvalidProperty");
	static constexpr TCHAR ExpectedDiagnosticFragment[] = TEXT("Interface UIInvalidProperty cannot declare property StoredValue.");

	const FAngelscriptCompileTraceDiagnosticSummary* FindErrorDiagnosticContaining(
		const TArray<FAngelscriptCompileTraceDiagnosticSummary>& Diagnostics,
		const FString& Fragment)
	{
		return Diagnostics.FindByPredicate(
			[&Fragment](const FAngelscriptCompileTraceDiagnosticSummary& Diagnostic)
			{
				return Diagnostic.bIsError && Diagnostic.Message.Contains(Fragment);
			});
	}
}

using namespace AngelscriptTest_Interface_AngelscriptInterfaceValidationTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptInterfaceRejectsPropertyDeclarationsTest,
	"Angelscript.TestModule.Interface.NoProperty.RejectsInterfacePropertyDeclarations",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptInterfaceRejectsPropertyDeclarationsTest::RunTest(const FString& Parameters)
{
	AddExpectedErrorPlain(ExpectedDiagnosticFragment, EAutomationExpectedErrorFlags::Contains, 1);

	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*InterfaceValidationModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	const FString ScriptSource = TEXT(R"AS(
UINTERFACE()
interface UIInvalidProperty
{
	UPROPERTY()
	int StoredValue = 0;

	void DoThing();
}
)AS");

	FAngelscriptCompileTraceSummary Summary;
	const bool bCompiled = CompileModuleWithSummary(
		&Engine,
		ECompileType::FullReload,
		InterfaceValidationModuleName,
		InterfaceValidationFilename,
		ScriptSource,
		true,
		Summary,
		true);

	if (!TestFalse(TEXT("Interface validation should reject UPROPERTY declarations inside UINTERFACE bodies"), bCompiled))
	{
		return false;
	}

	const FAngelscriptCompileTraceDiagnosticSummary* PropertyDiagnostic =
		FindErrorDiagnosticContaining(Summary.Diagnostics, ExpectedDiagnosticFragment);
	if (!TestEqual(TEXT("Interface validation should report an error compile result"), Summary.CompileResult, ECompileResult::Error)
		|| !TestTrue(TEXT("Interface validation should route annotated input through the preprocessor"), Summary.bUsedPreprocessor)
		|| !TestTrue(TEXT("Interface validation should capture at least one diagnostic"), Summary.Diagnostics.Num() > 0)
		|| !TestNotNull(TEXT("Interface validation should emit an interface-property diagnostic"), PropertyDiagnostic))
	{
		return false;
	}

	if (!TestEqual(TEXT("Interface validation should report the UPROPERTY line in diagnostics"), PropertyDiagnostic->Row, 5))
	{
		return false;
	}

	return TestNull(
		TEXT("Interface validation should not generate a class for an interface that declares a property"),
		FindGeneratedClass(&Engine, InvalidInterfaceClassName));
	ASTEST_END_SHARE_FRESH
}

#endif
