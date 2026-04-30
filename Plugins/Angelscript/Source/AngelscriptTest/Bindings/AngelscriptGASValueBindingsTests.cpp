// ============================================================================
// AngelscriptGASValueBindingsTests.cpp
//
// GAS value-type binding null-guard coverage — CQTest refactor. Automation IDs:
//   Angelscript.TestModule.Bindings.GASValue.FAngelscriptGASValueBindingsTest.*
//
// Sections:
//   GameplayEffectSpecNullDefGuard   — null UGameplayEffect should raise script exception
//   GameplayTagPropertyMapNullGuards — null Owner / null ASC should raise script exceptions
//
// CQTest adaptation notes:
//   Two IMPLEMENT_SIMPLE_AUTOMATION_TEST merged into one TEST_CLASS.
//   Exception tests use shared ExecuteFunctionExpectingScriptException from
//   AngelscriptBindingsAssertions.h for no-arg void functions.
//   Parameterised void functions (with &out / UObject args) use
//   FASGlobalFunctionInvoker with manual context execution for exception capture.
// ============================================================================

#include "CQTest.h"
#include "Shared/AngelscriptTestMacros.h"
#include "Shared/AngelscriptBindingsCoverage.h"
#include "Shared/AngelscriptBindingsModuleBuilder.h"
#include "Shared/AngelscriptBindingsAssertions.h"

#include "UObject/UObjectGlobals.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptTestBindings;
using namespace AngelscriptReflectiveAccess;

// ----------------------------------------------------------------------------
// Profile
// ----------------------------------------------------------------------------

static const FBindingsCoverageProfile GGASValueProfile{
	TEXT("GASValue"),              // Theme
	TEXT(""),                      // Variant
	TEXT("ASGASValue"),            // ModulePrefix
	TEXT("GASValue"),              // CasePrefix
	TEXT("GASValueBindings"),      // LogCategory
};

// ----------------------------------------------------------------------------
// Test class
// ----------------------------------------------------------------------------

TEST_CLASS_WITH_FLAGS(FAngelscriptGASValueBindingsTest,
	"Angelscript.TestModule.Bindings.GASValue",
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
	// Section: GameplayEffectSpecNullDefGuard
	// ====================================================================

	TEST_METHOD(GameplayEffectSpecNullDefGuard)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE();
		FAngelscriptEngineScope Scope(Engine);

		TestRunner->AddExpectedError(TEXT("GameplayEffect was null."), EAutomationExpectedErrorFlags::Contains, 1);
		TestRunner->AddExpectedError(TEXT("ASGASValue_EffectSpecNullDef"), EAutomationExpectedErrorFlags::Contains, 1);
		TestRunner->AddExpectedError(TEXT("void TriggerNullEffectSpec() | Line 7 | Col 2"), EAutomationExpectedErrorFlags::Contains, 1);

		FCoverageModuleScope Mod(*TestRunner, Engine, GGASValueProfile, TEXT("EffectSpecNullDef"), TEXT(R"(
void TriggerNullEffectSpec()
{
	TSubclassOf<UGameplayEffect> EmptyEffectClass;
	UGameplayEffect NullEffect = EmptyEffectClass.GetDefaultObject();
	FGameplayEffectContextHandle Context;
	FGameplayEffectSpec Spec(NullEffect, Context, 1.0f);
}
)"));
		if (!Mod.IsValid()) return;
		auto& M = Mod.GetModule();

		AngelscriptTestBindings::ExecuteFunctionExpectingScriptException(
			*TestRunner, Engine, M, GGASValueProfile,
			TEXT("void TriggerNullEffectSpec()"),
			TEXT("FGameplayEffectSpec null-def constructor should raise exception"),
			TEXT("GameplayEffect was null."));
	}

	// ====================================================================
	// Section: GameplayTagPropertyMapNullGuards
	// ====================================================================

	TEST_METHOD(GameplayTagPropertyMapNullGuards)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE();
		FAngelscriptEngineScope Scope(Engine);

		TestRunner->AddExpectedError(TEXT("GameplayTagBlueprintPropertyMap.Initialize received a null Owner."), EAutomationExpectedErrorFlags::Contains, 0);
		TestRunner->AddExpectedError(TEXT("GameplayTagBlueprintPropertyMap.Initialize received a null AbilitySystemComponent."), EAutomationExpectedErrorFlags::Contains, 0);
		TestRunner->AddExpectedError(TEXT("ASGASValue_TagPropMapNullGuards"), EAutomationExpectedErrorFlags::Contains, 0);
		TestRunner->AddExpectedError(TEXT("TriggerNullOwnerAndASC"), EAutomationExpectedErrorFlags::Contains, 0, false);
		TestRunner->AddExpectedError(TEXT("TriggerNullASC"), EAutomationExpectedErrorFlags::Contains, 0, false);

		FCoverageModuleScope Mod(*TestRunner, Engine, GGASValueProfile, TEXT("TagPropMapNullGuards"), TEXT(R"(
void TriggerNullOwnerAndASC(int& OutStep)
{
	OutStep = 1;
	FGameplayTagBlueprintPropertyMap Map;
	UObject NullOwner;
	UAbilitySystemComponent NullASC;
	Map.Initialize(NullOwner, NullASC);
	OutStep = 2;
	Map.ApplyCurrentTags();
	OutStep = 3;
}

void TriggerNullASC(UObject Owner, int& OutStep)
{
	OutStep = 1;
	FGameplayTagBlueprintPropertyMap Map;
	UAbilitySystemComponent NullASC;
	Map.Initialize(Owner, NullASC);
	OutStep = 2;
	Map.ApplyCurrentTags();
	OutStep = 3;
}
)"));
		if (!Mod.IsValid()) return;
		auto& M = Mod.GetModule();

		// --- Test null Owner and null ASC ---
		{
			int32 NullOwnerStep = 0;
			FASGlobalFunctionInvoker NullOwnerInvoker(*TestRunner, Engine, M,
				TEXT("void TriggerNullOwnerAndASC(int& OutStep)"));
			if (!NullOwnerInvoker.IsValid()) return;

			NullOwnerInvoker.AddArgRef(NullOwnerStep);

			// Expect exception — call via raw context
			asIScriptContext* Ctx = NullOwnerInvoker.GetContext();
			const int ExecResult = Ctx->Execute();
			const FString ExceptionString = UTF8_TO_TCHAR(
				Ctx->GetExceptionString() != nullptr ? Ctx->GetExceptionString() : "");

			TestRunner->TestEqual(
				TEXT("GameplayTagBlueprintPropertyMap.Initialize(null, null) should raise exception"),
				ExecResult, static_cast<int32>(asEXECUTION_EXCEPTION));
			TestRunner->TestEqual(
				TEXT("GameplayTagBlueprintPropertyMap.Initialize(null, null) should surface the owner guard message"),
				ExceptionString,
				FString(TEXT("GameplayTagBlueprintPropertyMap.Initialize received a null Owner.")));
			TestRunner->TestEqual(
				TEXT("GameplayTagBlueprintPropertyMap.Initialize(null, null) should stop before post-initialize code runs"),
				NullOwnerStep, 1);
		}

		// --- Test valid Owner with null ASC ---
		{
			UObject* Owner = GetTransientPackage();
			if (!TestRunner->TestNotNull(TEXT("GameplayTagBlueprintPropertyMap.Initialize(this, null) should have a non-null owner fixture"), Owner))
			{
				return;
			}

			int32 NullASCStep = 0;
			FASGlobalFunctionInvoker NullASCInvoker(*TestRunner, Engine, M,
				TEXT("void TriggerNullASC(UObject Owner, int& OutStep)"));
			if (!NullASCInvoker.IsValid()) return;

			NullASCInvoker.AddArgObject(Owner);
			NullASCInvoker.AddArgRef(NullASCStep);

			asIScriptContext* Ctx = NullASCInvoker.GetContext();
			const int ExecResult = Ctx->Execute();
			const FString ExceptionString = UTF8_TO_TCHAR(
				Ctx->GetExceptionString() != nullptr ? Ctx->GetExceptionString() : "");

			TestRunner->TestEqual(
				TEXT("GameplayTagBlueprintPropertyMap.Initialize(this, null) should raise exception"),
				ExecResult, static_cast<int32>(asEXECUTION_EXCEPTION));
			TestRunner->TestEqual(
				TEXT("GameplayTagBlueprintPropertyMap.Initialize(this, null) should surface the ASC guard message"),
				ExceptionString,
				FString(TEXT("GameplayTagBlueprintPropertyMap.Initialize received a null AbilitySystemComponent.")));
			TestRunner->TestEqual(
				TEXT("GameplayTagBlueprintPropertyMap.Initialize(this, null) should stop before ApplyCurrentTags runs"),
				NullASCStep, 1);
		}
	}
};

#endif
