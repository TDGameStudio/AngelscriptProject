// ============================================================================
// AngelscriptBlueprintCallableReflectiveFallbackTests.cpp
//
// Blueprint callable reflective fallback binding coverage — CQTest refactor.
// Automation ID:
//   Angelscript.TestModule.Bindings.BlueprintCallableReflectiveFallback.*
//
// Sections:
//   UMG                — Reflective fallback on UCheckBox methods
//   AIModule           — Reflective fallback on UPawnSensingComponent methods
//   GameplayTags       — Reflective fallback on BlueprintGameplayTagLibrary
//   Eligibility        — Eligibility enum rejection for interface/CustomThunk
//   EligibilityMatrix  — Full eligibility matrix validation
//
// CQTest adaptation notes:
//   Five original IMPLEMENT_SIMPLE_AUTOMATION_TEST classes merged into one
//   TEST_CLASS with five TEST_METHODs. The UMG/AI/GameplayTags tests use
//   FULL engine (class generation); Eligibility tests use SHARE_CLEAN.
// ============================================================================

#include "CQTest.h"
#include "Shared/AngelscriptTestMacros.h"
#include "Shared/AngelscriptTestUtilities.h"
#include "Shared/AngelscriptTestEngineHelper.h"
#include "Shared/AngelscriptBindingsCoverage.h"
#include "Shared/AngelscriptBindingsModuleBuilder.h"
#include "Shared/AngelscriptBindingsAssertions.h"
#include "AngelscriptBlueprintCallableReflectiveFallbackTestTypes.h"
#include "../../AngelscriptRuntime/Binds/BlueprintCallableReflectiveFallback.h"
#include "../../AngelscriptRuntime/Binds/Helper_FunctionSignature.h"

#include "GameplayTagsManager.h"
#include "BlueprintGameplayTagLibrary.h"
#include "GameplayTagAssetInterface.h"
#include "Kismet/KismetArrayLibrary.h"
#include "Perception/PawnSensingComponent.h"
#include "Components/CheckBox.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptTestBindings;
using namespace AngelscriptReflectiveAccess;

// ----------------------------------------------------------------------------
// Profile
// ----------------------------------------------------------------------------

static const FBindingsCoverageProfile GBPCallableProfile{
	TEXT("BPCallable"),          // Theme
	TEXT(""),                    // Variant
	TEXT("ASBPCallable"),        // ModulePrefix
	TEXT("BPCallable"),          // CasePrefix
	TEXT("BPCallableBindings"), // LogCategory
};

// ----------------------------------------------------------------------------
// Test class
// ----------------------------------------------------------------------------

TEST_CLASS_WITH_FLAGS(FAngelscriptBlueprintCallableReflectiveFallbackTest,
	"Angelscript.TestModule.Bindings.BlueprintCallableReflectiveFallback",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
	BEFORE_ALL()
	{
		ASTEST_CREATE_ENGINE();
	}

	AFTER_ALL()
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE();
		AngelscriptTestSupport::ResetSharedCloneEngine(Engine);
	}

	// ====================================================================
	// Section: UMG
	// ====================================================================

	TEST_METHOD(UMG)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_FULL();
		FAngelscriptEngineScope Scope(Engine);

		const bool bCompiled = CompileAnnotatedModuleFromMemory(
			&Engine,
			TEXT("ASReflectiveFallbackUMG"),
			TEXT("ASReflectiveFallbackUMG.as"),
			TEXT(R"(
UCLASS()
class UReflectiveCheckBoxBinding : UCheckBox
{
	UFUNCTION()
	int RunReflectiveFallback()
	{
		SetIsChecked(true);
		if (GetCheckedState() != ECheckBoxState::Checked)
			return 10;

		SetCheckedState(ECheckBoxState::Undetermined);
		return GetCheckedState() == ECheckBoxState::Undetermined ? 1 : 20;
	}
}
)"));
		ASSERT_THAT(IsTrue(bCompiled));

		UClass* RuntimeClass = FindGeneratedClass(&Engine, TEXT("UReflectiveCheckBoxBinding"));
		ASSERT_THAT(IsNotNull(RuntimeClass));

		UFunction* RunFunction = FindGeneratedFunction(RuntimeClass, TEXT("RunReflectiveFallback"));
		ASSERT_THAT(IsNotNull(RunFunction));

		UCheckBox* RuntimeObject = NewObject<UCheckBox>(GetTransientPackage(), RuntimeClass, TEXT("ReflectiveCheckBox"));
		ASSERT_THAT(IsNotNull(RuntimeObject));

		int32 Result = 0;
		ASSERT_THAT(IsTrue(ExecuteGeneratedIntEventOnGameThread(&Engine, RuntimeObject, RunFunction, Result)));
		TestRunner->TestEqual(TEXT("Reflective fallback should invoke unresolved UMG methods correctly"), Result, 1);
	}

	// ====================================================================
	// Section: AIModule
	// ====================================================================

	TEST_METHOD(AIModule)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_FULL();
		FAngelscriptEngineScope Scope(Engine);

		const bool bCompiled = CompileAnnotatedModuleFromMemory(
			&Engine,
			TEXT("ASReflectiveFallbackAI"),
			TEXT("ASReflectiveFallbackAI.as"),
			TEXT(R"(
UCLASS()
class UReflectivePawnSensingBinding : UPawnSensingComponent
{
	UFUNCTION()
	int RunReflectiveFallback()
	{
		SetPeripheralVisionAngle(42.0f);
		float CurrentAngle = GetPeripheralVisionAngle();
		if (CurrentAngle < 41.99f || CurrentAngle > 42.01f)
			return 10;

		SetSensingInterval(0.25f);
		return 1;
	}
}
)"));
		ASSERT_THAT(IsTrue(bCompiled));

		UClass* RuntimeClass = FindGeneratedClass(&Engine, TEXT("UReflectivePawnSensingBinding"));
		ASSERT_THAT(IsNotNull(RuntimeClass));

		UFunction* RunFunction = FindGeneratedFunction(RuntimeClass, TEXT("RunReflectiveFallback"));
		ASSERT_THAT(IsNotNull(RunFunction));

		UPawnSensingComponent* RuntimeObject = NewObject<UPawnSensingComponent>(GetTransientPackage(), RuntimeClass, TEXT("ReflectivePawnSensing"));
		ASSERT_THAT(IsNotNull(RuntimeObject));

		int32 Result = 0;
		ASSERT_THAT(IsTrue(ExecuteGeneratedIntEventOnGameThread(&Engine, RuntimeObject, RunFunction, Result)));
		TestRunner->TestEqual(TEXT("Reflective fallback should invoke unresolved AIModule methods correctly"), Result, 1);
	}

	// ====================================================================
	// Section: GameplayTags
	// ====================================================================

	TEST_METHOD(GameplayTags)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_FULL();
		FAngelscriptEngineScope Scope(Engine);

		FGameplayTagContainer AllTags;
		UGameplayTagsManager::Get().RequestAllGameplayTags(AllTags, false);
		ASSERT_THAT(IsTrue(AllTags.Num() > 0));

		const FString TagName = AllTags.First().ToString().ReplaceCharWithEscapedChar();
		TSharedPtr<FAngelscriptType> GameplayTagLibraryType = FAngelscriptType::GetByClass(UBlueprintGameplayTagLibrary::StaticClass());
		ASSERT_THAT(IsTrue(GameplayTagLibraryType.IsValid()));

		UFunction* GetTagNameFunction = UBlueprintGameplayTagLibrary::StaticClass()->FindFunctionByName(TEXT("GetTagName"));
		ASSERT_THAT(IsNotNull(GetTagNameFunction));

		const FString GameplayTagLibraryNamespace = FAngelscriptFunctionSignature::GetScriptNamespaceForClass(GameplayTagLibraryType.ToSharedRef(), GetTagNameFunction);
		const FString GameplayTagLibraryCallPrefix = GameplayTagLibraryNamespace.IsEmpty()
			? FString()
			: GameplayTagLibraryNamespace + TEXT("::");
		FString Script = FString::Printf(TEXT(R"(
int GameplayTagReflectiveVerify()
{
	FGameplayTag ValidTag = FGameplayTag::RequestGameplayTag(FName("%s"), true);
	if (!ValidTag.IsValid())
		return 10;

	FName ReflectedName = %sGetTagName(ValidTag);
	if (!(ReflectedName == ValidTag.GetTagName()))
		return 20;

	FGameplayTagContainer Container = %sMakeGameplayTagContainerFromTag(ValidTag);
	if (%sGetNumGameplayTagsInContainer(Container) != 1)
		return 30;

	return 1;
}
)"), *TagName, *GameplayTagLibraryCallPrefix, *GameplayTagLibraryCallPrefix, *GameplayTagLibraryCallPrefix);

		asIScriptModule* Module = BuildModule(*TestRunner, Engine, "ASReflectiveFallbackGameplayTags", Script);
		if (Module == nullptr) return;

		asIScriptFunction* Function = GetFunctionByDecl(*TestRunner, *Module, TEXT("int GameplayTagReflectiveVerify()"));
		if (Function == nullptr) return;

		int32 Result = 0;
		if (!ExecuteIntFunction(*TestRunner, Engine, *Function, Result)) return;

		TestRunner->TestEqual(TEXT("Reflective fallback should invoke unresolved GameplayTags library functions correctly"), Result, 1);
	}

	// ====================================================================
	// Section: Eligibility
	// ====================================================================

	TEST_METHOD(Eligibility)
	{
		const UFunction* InterfaceFunction = UGameplayTagAssetInterface::StaticClass()->FindFunctionByName(TEXT("HasMatchingGameplayTag"));
		ASSERT_THAT(IsNotNull(InterfaceFunction));

		const UFunction* CustomThunkFunction = UKismetArrayLibrary::StaticClass()->FindFunctionByName(TEXT("Array_Add"));
		ASSERT_THAT(IsNotNull(CustomThunkFunction));

		TestRunner->TestEqual(
			TEXT("Reflective fallback should reject interface-class functions explicitly"),
			EvaluateReflectiveFallbackEligibility(InterfaceFunction),
			EAngelscriptReflectiveFallbackEligibility::RejectedInterfaceClass);

		TestRunner->TestEqual(
			TEXT("Reflective fallback should reject CustomThunk functions explicitly"),
			EvaluateReflectiveFallbackEligibility(CustomThunkFunction),
			EAngelscriptReflectiveFallbackEligibility::RejectedCustomThunk);
	}

	// ====================================================================
	// Section: EligibilityMatrix
	// ====================================================================

	TEST_METHOD(EligibilityMatrix)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE();
		FAngelscriptEngineScope Scope(Engine);

		const UFunction* EligibleFunction = UAngelscriptBlueprintCallableReflectiveFallbackTestLibrary::StaticClass()->FindFunctionByName(TEXT("EligibleCallable"));
		const UFunction* TooManyArgumentsFunction = UAngelscriptBlueprintCallableReflectiveFallbackTestLibrary::StaticClass()->FindFunctionByName(TEXT("TooManyArgumentsCallable"));
		ASSERT_THAT(IsNotNull(EligibleFunction));
		ASSERT_THAT(IsNotNull(TooManyArgumentsFunction));

		UFunction* MissingOwningClassFunction = NewObject<UFunction>(GetTransientPackage(), NAME_None, RF_Transient);
		ASSERT_THAT(IsNotNull(MissingOwningClassFunction));

		auto CheckEligibility = [this](
			const UFunction* Function,
			EAngelscriptReflectiveFallbackEligibility ExpectedEligibility,
			bool bExpectedShouldBind,
			const TCHAR* Context) -> bool
		{
			const bool bEligibilityMatches = TestRunner->TestEqual(
				*FString::Printf(TEXT("%s should report the expected eligibility enum"), Context),
				EvaluateReflectiveFallbackEligibility(Function),
				ExpectedEligibility);
			const bool bShouldBindMatches = TestRunner->TestEqual(
				*FString::Printf(TEXT("%s should keep ShouldBindBlueprintCallableReflectiveFallback in sync with the eligibility enum"), Context),
				ShouldBindBlueprintCallableReflectiveFallback(Function),
				bExpectedShouldBind);
			return bEligibilityMatches && bShouldBindMatches;
		};

		CheckEligibility(
			EligibleFunction,
			EAngelscriptReflectiveFallbackEligibility::Eligible,
			true,
			TEXT("Reflective fallback eligibility matrix test eligible sample"));
		CheckEligibility(
			nullptr,
			EAngelscriptReflectiveFallbackEligibility::RejectedNullFunction,
			false,
			TEXT("Reflective fallback eligibility matrix test null sample"));
		CheckEligibility(
			MissingOwningClassFunction,
			EAngelscriptReflectiveFallbackEligibility::RejectedMissingOwningClass,
			false,
			TEXT("Reflective fallback eligibility matrix test missing-owning-class sample"));
		CheckEligibility(
			TooManyArgumentsFunction,
			EAngelscriptReflectiveFallbackEligibility::RejectedTooManyArguments,
			false,
			TEXT("Reflective fallback eligibility matrix test too-many-arguments sample"));
	}
};

#endif
