#include "Shared/AngelscriptTestEngineHelper.h"
#include "Shared/AngelscriptTestMacros.h"

#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace AngelscriptTest_ClassGenerator_AngelscriptComponentMetadataValidationTests_Private
{
	static const FName ComponentMetadataValidationModuleName(TEXT("ASComponentInvalidAttachParent"));
	static constexpr TCHAR ComponentMetadataValidationFilename[] = TEXT("ComponentInvalidAttachParent.as");
	static const FName InvalidAttachParentClassName(TEXT("AComponentInvalidAttachParent"));
	static const FString InvalidAttachParentDiagnosticFragment(
		TEXT("Attach parent MissingParent does not exist for DefaultComponent Billboard."));
	static const FName MissingOverrideTargetModuleName(TEXT("ASComponentMissingOverrideTarget"));
	static constexpr TCHAR MissingOverrideTargetFilename[] = TEXT("ComponentMissingOverrideTarget.as");
	static const FName MissingOverrideTargetBaseClassName(TEXT("ABaseOverrideMissing"));
	static const FName MissingOverrideTargetDerivedClassName(TEXT("ADerivedOverrideMissing"));
	static const FString MissingOverrideTargetDiagnosticFragment(
		TEXT("OverrideComponent ADerivedOverrideMissing::ReplacementRoot could not find component MissingScene in base class to override."));

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

	FString BuildInvalidAttachParentScript()
	{
		return TEXT(R"AS(
UCLASS()
class UComponentInvalidAttachParentRoot : USceneComponent
{
}

UCLASS()
class AComponentInvalidAttachParent : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UComponentInvalidAttachParentRoot RootScene;

	UPROPERTY(DefaultComponent, Attach = MissingParent)
	UBillboardComponent Billboard;
}
)AS");
	}

	FString BuildMissingOverrideTargetScript()
	{
		return TEXT(R"AS(
UCLASS()
class UBaseOverrideMissingRoot : USceneComponent
{
}

UCLASS()
class UDerivedOverrideMissingRoot : UBaseOverrideMissingRoot
{
}

UCLASS()
class ABaseOverrideMissing : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UBaseOverrideMissingRoot RootScene;
}

UCLASS()
class ADerivedOverrideMissing : ABaseOverrideMissing
{
	UPROPERTY(OverrideComponent = MissingScene)
	UDerivedOverrideMissingRoot ReplacementRoot;
}
)AS");
	}
}

using namespace AngelscriptTest_ClassGenerator_AngelscriptComponentMetadataValidationTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptComponentInvalidAttachParentFailsClosedTest,
	"Angelscript.TestModule.ClassGenerator.Component.InvalidAttachParentFailsClosed",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptComponentInvalidAttachParentFailsClosedTest::RunTest(const FString& Parameters)
{
	bool bPassed = false;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ComponentMetadataValidationModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	FAngelscriptCompileTraceSummary Summary;
	const bool bCompiled = CompileModuleWithSummary(
		&Engine,
		ECompileType::FullReload,
		ComponentMetadataValidationModuleName,
		ComponentMetadataValidationFilename,
		BuildInvalidAttachParentScript(),
		true,
		Summary,
		true);

	const FAngelscriptCompileTraceDiagnosticSummary* MissingParentDiagnostic =
		FindErrorDiagnosticContaining(Summary.Diagnostics, InvalidAttachParentDiagnosticFragment);
	const TSharedPtr<FAngelscriptModuleDesc> FailedModuleRecord =
		Engine.GetModuleByModuleName(ComponentMetadataValidationModuleName.ToString());

	const bool bCompileFailed = TestFalse(
		TEXT("Invalid attach-parent metadata should fail compilation instead of silently succeeding"),
		bCompiled);
	const bool bReportedErrorResult = TestEqual(
		TEXT("Invalid attach-parent metadata should surface an error compile result"),
		Summary.CompileResult,
		ECompileResult::Error);
	const bool bUsedPreprocessor = TestTrue(
		TEXT("Invalid attach-parent metadata should compile through the annotated preprocessor path"),
		Summary.bUsedPreprocessor);
	const bool bCapturedDiagnostics = TestTrue(
		TEXT("Invalid attach-parent metadata should emit at least one diagnostic"),
		Summary.Diagnostics.Num() > 0);
	const bool bReportedMissingParentDiagnostic = TestNotNull(
		TEXT("Invalid attach-parent metadata should report the missing attach-parent diagnostic"),
		MissingParentDiagnostic);
	const bool bNoGeneratedClass = TestNull(
		TEXT("Invalid attach-parent metadata should not publish the generated actor class after failure"),
		FindGeneratedClass(&Engine, InvalidAttachParentClassName));
	const bool bNoModuleRecord = TestTrue(
		TEXT("Invalid attach-parent metadata should not publish a module record after failure"),
		!FailedModuleRecord.IsValid());

	bPassed = bCompileFailed
		&& bReportedErrorResult
		&& bUsedPreprocessor
		&& bCapturedDiagnostics
		&& bReportedMissingParentDiagnostic
		&& bNoGeneratedClass
		&& bNoModuleRecord;

	ASTEST_END_SHARE_FRESH
	return bPassed;
}

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptComponentMissingOverrideTargetFailsClosedTest,
	"Angelscript.TestModule.ClassGenerator.Component.MissingOverrideTargetFailsClosed",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptComponentMissingOverrideTargetFailsClosedTest::RunTest(const FString& Parameters)
{
	bool bPassed = false;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*MissingOverrideTargetModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	FAngelscriptCompileTraceSummary Summary;
	const bool bCompiled = CompileModuleWithSummary(
		&Engine,
		ECompileType::FullReload,
		MissingOverrideTargetModuleName,
		MissingOverrideTargetFilename,
		BuildMissingOverrideTargetScript(),
		true,
		Summary,
		true);

	const FAngelscriptCompileTraceDiagnosticSummary* MissingOverrideTargetDiagnostic =
		FindErrorDiagnosticContaining(Summary.Diagnostics, MissingOverrideTargetDiagnosticFragment);
	const TSharedPtr<FAngelscriptModuleDesc> FailedModuleRecord =
		Engine.GetModuleByModuleName(MissingOverrideTargetModuleName.ToString());

	const bool bCompileFailed = TestFalse(
		TEXT("Missing override-target metadata should fail compilation instead of silently succeeding"),
		bCompiled);
	const bool bReportedErrorResult = TestEqual(
		TEXT("Missing override-target metadata should surface an error compile result"),
		Summary.CompileResult,
		ECompileResult::Error);
	const bool bUsedPreprocessor = TestTrue(
		TEXT("Missing override-target metadata should compile through the annotated preprocessor path"),
		Summary.bUsedPreprocessor);
	const bool bCapturedDiagnostics = TestTrue(
		TEXT("Missing override-target metadata should emit at least one diagnostic"),
		Summary.Diagnostics.Num() > 0);
	const bool bReportedMissingOverrideDiagnostic = TestNotNull(
		TEXT("Missing override-target metadata should report the missing base-component diagnostic"),
		MissingOverrideTargetDiagnostic);
	const bool bNoGeneratedDerivedClass = TestNull(
		TEXT("Missing override-target metadata should not publish the derived actor class after failure"),
		FindGeneratedClass(&Engine, MissingOverrideTargetDerivedClassName));
	const bool bNoModuleRecord = TestTrue(
		TEXT("Missing override-target metadata should not publish a live module record after failure"),
		!FailedModuleRecord.IsValid());
	const bool bNoSilentSuccess = TestTrue(
		TEXT("Missing override-target metadata should not silently publish the broken derived class"),
		FindGeneratedClass(&Engine, MissingOverrideTargetBaseClassName) == nullptr
			|| FindGeneratedClass(&Engine, MissingOverrideTargetDerivedClassName) == nullptr);

	bPassed = bCompileFailed
		&& bReportedErrorResult
		&& bUsedPreprocessor
		&& bCapturedDiagnostics
		&& bReportedMissingOverrideDiagnostic
		&& bNoGeneratedDerivedClass
		&& bNoModuleRecord
		&& bNoSilentSuccess;

	ASTEST_END_SHARE_FRESH
	return bPassed;
}

#endif
