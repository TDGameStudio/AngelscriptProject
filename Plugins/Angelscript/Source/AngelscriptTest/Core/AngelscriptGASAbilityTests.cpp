#include "../../AngelscriptRuntime/Core/AngelscriptGASAbility.h"
#include "AngelscriptGASTestTypes.h"
#include "Shared/AngelscriptTestEngineHelper.h"
#include "Shared/AngelscriptTestMacros.h"

#include "GameplayTagContainer.h"
#include "Misc/AutomationTest.h"
#include "UObject/UObjectGlobals.h"

#if WITH_DEV_AUTOMATION_TESTS

namespace AngelscriptTest_Core_AngelscriptGASAbilityTests_Private
{
	struct FGASAbilityOverrideFlagSnapshot
	{
		bool bRespondToEvent = false;
		bool bCanActivate = false;
		bool bActivate = false;
		bool bActivateFromEvent = false;
	};

	struct FGameplayAbilityOverrideFlagAccessor : UAngelscriptGASAbility
	{
		static bool UGameplayAbility::* RespondToEventMember()
		{
			return &FGameplayAbilityOverrideFlagAccessor::bHasBlueprintShouldAbilityRespondToEvent;
		}

		static bool UGameplayAbility::* CanActivateMember()
		{
			return &FGameplayAbilityOverrideFlagAccessor::bHasBlueprintCanUse;
		}

		static bool UGameplayAbility::* ActivateMember()
		{
			return &FGameplayAbilityOverrideFlagAccessor::bHasBlueprintActivate;
		}

		static bool UGameplayAbility::* ActivateFromEventMember()
		{
			return &FGameplayAbilityOverrideFlagAccessor::bHasBlueprintActivateFromEvent;
		}
	};

	FGASAbilityOverrideFlagSnapshot CaptureOverrideFlags(const UAngelscriptGASAbility& Ability)
	{
		FGASAbilityOverrideFlagSnapshot Snapshot;
		Snapshot.bRespondToEvent = Ability.*(FGameplayAbilityOverrideFlagAccessor::RespondToEventMember());
		Snapshot.bCanActivate = Ability.*(FGameplayAbilityOverrideFlagAccessor::CanActivateMember());
		Snapshot.bActivate = Ability.*(FGameplayAbilityOverrideFlagAccessor::ActivateMember());
		Snapshot.bActivateFromEvent = Ability.*(FGameplayAbilityOverrideFlagAccessor::ActivateFromEventMember());
		return Snapshot;
	}

	bool ExpectOverrideFlags(
		FAutomationTestBase& Test,
		const FString& Context,
		const FGASAbilityOverrideFlagSnapshot& Actual,
		const FGASAbilityOverrideFlagSnapshot& Expected)
	{
		bool bPassed = true;
		bPassed &= Test.TestEqual(*FString::Printf(TEXT("%s should match the RespondToEvent override-detection flag"), *Context), Actual.bRespondToEvent, Expected.bRespondToEvent);
		bPassed &= Test.TestEqual(*FString::Printf(TEXT("%s should match the CanActivate override-detection flag"), *Context), Actual.bCanActivate, Expected.bCanActivate);
		bPassed &= Test.TestEqual(*FString::Printf(TEXT("%s should match the Activate override-detection flag"), *Context), Actual.bActivate, Expected.bActivate);
		bPassed &= Test.TestEqual(*FString::Printf(TEXT("%s should match the ActivateFromEvent override-detection flag"), *Context), Actual.bActivateFromEvent, Expected.bActivateFromEvent);
		return bPassed;
	}

	UClass* FindGeneratedAbilityClass(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		FName GeneratedClassName)
	{
		UClass* GeneratedClass = AngelscriptTestSupport::FindGeneratedClass(&Engine, GeneratedClassName);
		Test.TestNotNull(*FString::Printf(TEXT("%s should resolve the generated GAS ability class"), *GeneratedClassName.ToString()), GeneratedClass);
		return GeneratedClass;
	}

	const UAngelscriptGASAbility* GetGeneratedAbilityDefaultObject(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		FName GeneratedClassName)
	{
		UClass* GeneratedClass = FindGeneratedAbilityClass(Test, Engine, GeneratedClassName);
		if (GeneratedClass == nullptr)
		{
			return nullptr;
		}

		const UAngelscriptGASAbility* AbilityCDO = Cast<UAngelscriptGASAbility>(GeneratedClass->GetDefaultObject());
		Test.TestNotNull(*FString::Printf(TEXT("%s should expose a generated GAS ability CDO through the runtime base class"), *GeneratedClassName.ToString()), AbilityCDO);
		return AbilityCDO;
	}

	UAngelscriptGASAbility* NewGeneratedAbilityInstance(
		FAutomationTestBase& Test,
		UClass* GeneratedClass)
	{
		if (GeneratedClass == nullptr)
		{
			return nullptr;
		}

		UAngelscriptGASAbility* Instance = NewObject<UAngelscriptGASAbility>(GetTransientPackage(), GeneratedClass);
		Test.TestNotNull(*FString::Printf(TEXT("%s should instantiate through the runtime base class"), *GeneratedClass->GetName()), Instance);
		return Instance;
	}

	FGameplayTag GetAngelscriptGASAbilityActorCueTag()
	{
		return FGameplayTag::RequestGameplayTag(FName(TEXT("GameplayCue.Angelscript.Tests.Ability.ActorWrapper")), false);
	}

	FGameplayTag GetAngelscriptGASAbilityStaticCueTag()
	{
		return FGameplayTag::RequestGameplayTag(FName(TEXT("GameplayCue.Angelscript.Tests.Ability.StaticWrapper")), false);
	}

	bool ExpectCueParametersMatch(
		FAutomationTestBase& Test,
		const FString& Context,
		const FGameplayCueParameters& Actual,
		const FGameplayCueParameters& Expected)
	{
		bool bPassed = true;
		bPassed &= Test.TestEqual(
			*FString::Printf(TEXT("%s should preserve the raw magnitude"), *Context),
			Actual.RawMagnitude,
			Expected.RawMagnitude);
		bPassed &= Test.TestTrue(
			*FString::Printf(TEXT("%s should preserve the instigator"), *Context),
			Actual.Instigator.Get() == Expected.Instigator.Get());
		bPassed &= Test.TestTrue(
			*FString::Printf(TEXT("%s should preserve the effect causer"), *Context),
			Actual.EffectCauser.Get() == Expected.EffectCauser.Get());
		bPassed &= Test.TestTrue(
			*FString::Printf(TEXT("%s should preserve the source object"), *Context),
			Actual.SourceObject.Get() == Expected.SourceObject.Get());
		return bPassed;
	}

	bool ExpectCueTagMatch(
		FAutomationTestBase& Test,
		const FString& Context,
		const FGameplayTag& Actual,
		const FGameplayTag& Expected)
	{
		return Test.TestTrue(
			*FString::Printf(TEXT("%s should preserve the cue tag"), *Context),
			Actual == Expected);
	}

	void ConfigureCueDefaultObject(UGameplayCueNotify_Static& CueDefaultObject, const FGameplayTag CueTag)
	{
		CueDefaultObject.GameplayCueTag = CueTag;
		CueDefaultObject.GameplayCueName = CueTag.GetTagName();
	}

	void ConfigureCueDefaultObject(AGameplayCueNotify_Actor& CueDefaultObject, const FGameplayTag CueTag)
	{
		CueDefaultObject.GameplayCueTag = CueTag;
		CueDefaultObject.GameplayCueName = CueTag.GetTagName();
	}
}

using namespace AngelscriptTest_Core_AngelscriptGASAbilityTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptGASAbilityOverrideDetectionFlagsTest,
	"Angelscript.TestModule.Engine.GAS.Ability.OverrideDetectionFlagsTrackASImplementedHooks",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptGASAbilityOverrideDetectionFlagsTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	static const FName ModuleName(TEXT("AutomationGASAbilityOverrideFlags"));
	static const FName FullClassName(TEXT("UAutomationASGASAbilityAllHooks"));
	static const FName PartialClassName(TEXT("UAutomationASGASAbilityPartialHooks"));

	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
	};

	const FGASAbilityOverrideFlagSnapshot NoHooksExpected = {};
	const FGASAbilityOverrideFlagSnapshot AllHooksExpected = { true, true, true, true };
	const FGASAbilityOverrideFlagSnapshot PartialHooksExpected = { true, false, false, true };

	const UAngelscriptGASAbility* NativeAccessCDO = GetDefault<UAngelscriptGASAbility>();
	if (!TestNotNull(TEXT("GAS ability override-detection test should resolve the native GAS ability CDO"), NativeAccessCDO))
	{
		return false;
	}

	if (!ExpectOverrideFlags(
		*this,
		TEXT("Native access shim CDO"),
		CaptureOverrideFlags(*NativeAccessCDO),
		NoHooksExpected))
	{
		return false;
	}

	const bool bCompiled = AngelscriptTestSupport::CompileAnnotatedModuleFromMemory(
		&Engine,
		ModuleName,
		TEXT("AutomationGASAbilityOverrideFlags.as"),
		TEXT(R"AS(
UCLASS()
class UAutomationASGASAbilityAllHooks : UAngelscriptGASAbility
{
	UFUNCTION(BlueprintOverride)
	bool ShouldAbilityRespondToEvent(FGameplayAbilityActorInfo ActorInfo, FGameplayEventData Payload) const
	{
		return true;
	}

	UFUNCTION(BlueprintOverride)
	bool CanActivateAbility(FGameplayAbilityActorInfo ActorInfo, const FGameplayAbilitySpecHandle Handle, FGameplayTagContainer& RelevantTags) const
	{
		return true;
	}

	UFUNCTION(BlueprintOverride)
	void ActivateAbility()
	{
	}

	UFUNCTION(BlueprintOverride)
	void ActivateAbilityFromEvent(const FGameplayEventData& EventData)
	{
	}
}

UCLASS()
class UAutomationASGASAbilityPartialHooks : UAngelscriptGASAbility
{
	UFUNCTION(BlueprintOverride)
	bool ShouldAbilityRespondToEvent(FGameplayAbilityActorInfo ActorInfo, FGameplayEventData Payload) const
	{
		return false;
	}

	UFUNCTION(BlueprintOverride)
	void ActivateAbilityFromEvent(const FGameplayEventData& EventData)
	{
	}
}
)AS"));
	if (!TestTrue(TEXT("GAS ability override-detection test should compile the annotated script ability module"), bCompiled))
	{
		return false;
	}

	const UAngelscriptGASAbility* FullHooksCDO = GetGeneratedAbilityDefaultObject(*this, Engine, FullClassName);
	if (FullHooksCDO == nullptr)
	{
		return false;
	}

	if (!ExpectOverrideFlags(
		*this,
		TEXT("Full-hook generated GAS ability CDO"),
		CaptureOverrideFlags(*FullHooksCDO),
		AllHooksExpected))
	{
		return false;
	}

	UClass* FullHooksClass = FindGeneratedAbilityClass(*this, Engine, FullClassName);
	UAngelscriptGASAbility* FullHooksInstance = NewGeneratedAbilityInstance(*this, FullHooksClass);
	if (FullHooksInstance == nullptr)
	{
		return false;
	}

	if (!ExpectOverrideFlags(
		*this,
		TEXT("Full-hook generated GAS ability instance"),
		CaptureOverrideFlags(*FullHooksInstance),
		AllHooksExpected))
	{
		return false;
	}

	const UAngelscriptGASAbility* PartialHooksCDO = GetGeneratedAbilityDefaultObject(*this, Engine, PartialClassName);
	if (PartialHooksCDO == nullptr)
	{
		return false;
	}

	if (!ExpectOverrideFlags(
		*this,
		TEXT("Partial-hook generated GAS ability CDO"),
		CaptureOverrideFlags(*PartialHooksCDO),
		PartialHooksExpected))
	{
		return false;
	}

	UClass* PartialHooksClass = FindGeneratedAbilityClass(*this, Engine, PartialClassName);
	UAngelscriptGASAbility* PartialHooksInstance = NewGeneratedAbilityInstance(*this, PartialHooksClass);
	if (PartialHooksInstance == nullptr)
	{
		return false;
	}

	if (!ExpectOverrideFlags(
		*this,
		TEXT("Partial-hook generated GAS ability instance"),
		CaptureOverrideFlags(*PartialHooksInstance),
		PartialHooksExpected))
	{
		return false;
	}

	ASTEST_END_SHARE_CLEAN
	return true;
}

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptGASAbilityCueWrappersForwardTagAndGuardNullTest,
	"Angelscript.TestModule.Engine.GAS.Ability.CueWrappersForwardTagAndGuardNull",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptGASAbilityCueWrappersForwardTagAndGuardNullTest::RunTest(const FString& Parameters)
{
	UAngelscriptGASTestCueForwardingAbility* Ability = NewObject<UAngelscriptGASTestCueForwardingAbility>(GetTransientPackage());
	if (!TestNotNull(TEXT("Cue wrapper test should create a forwarding recorder ability"), Ability))
	{
		return false;
	}

	AAngelscriptGASTestGameplayCueActorMarker* ActorCueCDO = GetMutableDefault<AAngelscriptGASTestGameplayCueActorMarker>();
	UAngelscriptGASTestGameplayCueStaticMarker* StaticCueCDO = GetMutableDefault<UAngelscriptGASTestGameplayCueStaticMarker>();
	AAngelscriptGASTestActor* InstigatorActor = GetMutableDefault<AAngelscriptGASTestActor>();
	UAngelscriptGASTestSourceObject* SourceObject = GetMutableDefault<UAngelscriptGASTestSourceObject>();
	if (!TestNotNull(TEXT("Cue wrapper test should resolve the actor cue default object"), ActorCueCDO)
		|| !TestNotNull(TEXT("Cue wrapper test should resolve the static cue default object"), StaticCueCDO)
		|| !TestNotNull(TEXT("Cue wrapper test should resolve the instigator actor default object"), InstigatorActor)
		|| !TestNotNull(TEXT("Cue wrapper test should resolve the source object default object"), SourceObject))
	{
		return false;
	}

	const FGameplayTag ActorCueTag = GetAngelscriptGASAbilityActorCueTag();
	const FGameplayTag StaticCueTag = GetAngelscriptGASAbilityStaticCueTag();
	if (!TestTrue(TEXT("GAS ability cue-wrapper test tags should be registered from config"), ActorCueTag.IsValid() && StaticCueTag.IsValid()))
	{
		return false;
	}

	const FGameplayTag OriginalActorCueTag = ActorCueCDO->GameplayCueTag;
	const FName OriginalActorCueName = ActorCueCDO->GameplayCueName;
	const FGameplayTag OriginalStaticCueTag = StaticCueCDO->GameplayCueTag;
	const FName OriginalStaticCueName = StaticCueCDO->GameplayCueName;
	ConfigureCueDefaultObject(*ActorCueCDO, ActorCueTag);
	ConfigureCueDefaultObject(*StaticCueCDO, StaticCueTag);
	ON_SCOPE_EXIT
	{
		ActorCueCDO->GameplayCueTag = OriginalActorCueTag;
		ActorCueCDO->GameplayCueName = OriginalActorCueName;
		StaticCueCDO->GameplayCueTag = OriginalStaticCueTag;
		StaticCueCDO->GameplayCueName = OriginalStaticCueName;
	};

	FGameplayCueParameters ActorCueParameters;
	ActorCueParameters.RawMagnitude = 37.5f;
	ActorCueParameters.Instigator = InstigatorActor;
	ActorCueParameters.EffectCauser = InstigatorActor;
	ActorCueParameters.SourceObject = SourceObject;

	FGameplayCueParameters StaticCueParameters;
	StaticCueParameters.RawMagnitude = 12.25f;
	StaticCueParameters.Instigator = InstigatorActor;
	StaticCueParameters.EffectCauser = InstigatorActor;
	StaticCueParameters.SourceObject = SourceObject;

	Ability->ResetCueRecords();
	Ability->K2_ExecuteGameplayCue_Actor(AAngelscriptGASTestGameplayCueActorMarker::StaticClass(), FGameplayEffectContextHandle());
	Ability->K2_ExecuteGameplayCueWithParams_Actor(AAngelscriptGASTestGameplayCueActorMarker::StaticClass(), ActorCueParameters);
	Ability->K2_AddGameplayCue_Actor(AAngelscriptGASTestGameplayCueActorMarker::StaticClass(), FGameplayEffectContextHandle(), true);
	Ability->K2_AddGameplayCueWithParams_Actor(AAngelscriptGASTestGameplayCueActorMarker::StaticClass(), ActorCueParameters, false);
	Ability->K2_RemoveGameplayCue_Actor(AAngelscriptGASTestGameplayCueActorMarker::StaticClass());

	bool bPassed = true;
	bPassed &= TestEqual(TEXT("Actor cue wrappers should forward ExecuteGameplayCue exactly once"), Ability->ExecuteCueCallCount, 1);
	bPassed &= TestEqual(TEXT("Actor cue wrappers should forward ExecuteGameplayCueWithParams exactly once"), Ability->ExecuteCueWithParamsCallCount, 1);
	bPassed &= TestEqual(TEXT("Actor cue wrappers should forward AddGameplayCue exactly once"), Ability->AddCueCallCount, 1);
	bPassed &= TestEqual(TEXT("Actor cue wrappers should forward AddGameplayCueWithParams exactly once"), Ability->AddCueWithParamsCallCount, 1);
	bPassed &= TestEqual(TEXT("Actor cue wrappers should forward RemoveGameplayCue exactly once"), Ability->RemoveCueCallCount, 1);
	bPassed &= ExpectCueTagMatch(*this, TEXT("Actor ExecuteGameplayCue wrapper"), Ability->LastExecuteCueTag, ActorCueTag);
	bPassed &= ExpectCueTagMatch(*this, TEXT("Actor ExecuteGameplayCueWithParams wrapper"), Ability->LastExecuteCueWithParamsTag, ActorCueTag);
	bPassed &= ExpectCueParametersMatch(*this, TEXT("Actor ExecuteGameplayCueWithParams wrapper"), Ability->LastExecuteCueWithParams, ActorCueParameters);
	bPassed &= ExpectCueTagMatch(*this, TEXT("Actor AddGameplayCue wrapper"), Ability->LastAddCueTag, ActorCueTag);
	bPassed &= TestEqual(TEXT("Actor AddGameplayCue wrapper should preserve the remove-on-end flag"), Ability->bLastAddCueRemoveOnAbilityEnd, true);
	bPassed &= ExpectCueTagMatch(*this, TEXT("Actor AddGameplayCueWithParams wrapper"), Ability->LastAddCueWithParamsTag, ActorCueTag);
	bPassed &= ExpectCueParametersMatch(*this, TEXT("Actor AddGameplayCueWithParams wrapper"), Ability->LastAddCueWithParams, ActorCueParameters);
	bPassed &= TestEqual(TEXT("Actor AddGameplayCueWithParams wrapper should preserve the remove-on-end flag"), Ability->bLastAddCueWithParamsRemoveOnAbilityEnd, false);
	bPassed &= ExpectCueTagMatch(*this, TEXT("Actor RemoveGameplayCue wrapper"), Ability->LastRemoveCueTag, ActorCueTag);
	if (!bPassed)
	{
		return false;
	}

	Ability->ResetCueRecords();
	Ability->K2_ExecuteGameplayCue_Static(UAngelscriptGASTestGameplayCueStaticMarker::StaticClass(), FGameplayEffectContextHandle());
	Ability->K2_ExecuteGameplayCueWithParams_Static(UAngelscriptGASTestGameplayCueStaticMarker::StaticClass(), StaticCueParameters);
	Ability->K2_AddGameplayCue_Static(UAngelscriptGASTestGameplayCueStaticMarker::StaticClass(), FGameplayEffectContextHandle(), false);
	Ability->K2_AddGameplayCueWithParams_Static(UAngelscriptGASTestGameplayCueStaticMarker::StaticClass(), StaticCueParameters, true);
	Ability->K2_RemoveGameplayCue_Static(UAngelscriptGASTestGameplayCueStaticMarker::StaticClass());

	bPassed = true;
	bPassed &= TestEqual(TEXT("Static cue wrappers should forward ExecuteGameplayCue exactly once"), Ability->ExecuteCueCallCount, 1);
	bPassed &= TestEqual(TEXT("Static cue wrappers should forward ExecuteGameplayCueWithParams exactly once"), Ability->ExecuteCueWithParamsCallCount, 1);
	bPassed &= TestEqual(TEXT("Static cue wrappers should forward AddGameplayCue exactly once"), Ability->AddCueCallCount, 1);
	bPassed &= TestEqual(TEXT("Static cue wrappers should forward AddGameplayCueWithParams exactly once"), Ability->AddCueWithParamsCallCount, 1);
	bPassed &= TestEqual(TEXT("Static cue wrappers should forward RemoveGameplayCue exactly once"), Ability->RemoveCueCallCount, 1);
	bPassed &= ExpectCueTagMatch(*this, TEXT("Static ExecuteGameplayCue wrapper"), Ability->LastExecuteCueTag, StaticCueTag);
	bPassed &= ExpectCueTagMatch(*this, TEXT("Static ExecuteGameplayCueWithParams wrapper"), Ability->LastExecuteCueWithParamsTag, StaticCueTag);
	bPassed &= ExpectCueParametersMatch(*this, TEXT("Static ExecuteGameplayCueWithParams wrapper"), Ability->LastExecuteCueWithParams, StaticCueParameters);
	bPassed &= ExpectCueTagMatch(*this, TEXT("Static AddGameplayCue wrapper"), Ability->LastAddCueTag, StaticCueTag);
	bPassed &= TestEqual(TEXT("Static AddGameplayCue wrapper should preserve the remove-on-end flag"), Ability->bLastAddCueRemoveOnAbilityEnd, false);
	bPassed &= ExpectCueTagMatch(*this, TEXT("Static AddGameplayCueWithParams wrapper"), Ability->LastAddCueWithParamsTag, StaticCueTag);
	bPassed &= ExpectCueParametersMatch(*this, TEXT("Static AddGameplayCueWithParams wrapper"), Ability->LastAddCueWithParams, StaticCueParameters);
	bPassed &= TestEqual(TEXT("Static AddGameplayCueWithParams wrapper should preserve the remove-on-end flag"), Ability->bLastAddCueWithParamsRemoveOnAbilityEnd, true);
	bPassed &= ExpectCueTagMatch(*this, TEXT("Static RemoveGameplayCue wrapper"), Ability->LastRemoveCueTag, StaticCueTag);
	if (!bPassed)
	{
		return false;
	}

	const int32 ExecuteCueCallCountBeforeNull = Ability->ExecuteCueCallCount;
	const int32 ExecuteCueWithParamsCallCountBeforeNull = Ability->ExecuteCueWithParamsCallCount;
	const int32 AddCueCallCountBeforeNull = Ability->AddCueCallCount;
	const int32 AddCueWithParamsCallCountBeforeNull = Ability->AddCueWithParamsCallCount;
	const int32 RemoveCueCallCountBeforeNull = Ability->RemoveCueCallCount;

	AddExpectedErrorPlain(TEXT("Ensure condition failed: GameplayCue != nullptr"), EAutomationExpectedErrorFlags::Contains, 10);
	AddExpectedErrorPlain(TEXT("LogOutputDevice:"), EAutomationExpectedErrorFlags::Contains, 0);

	Ability->K2_ExecuteGameplayCue_Actor(nullptr, FGameplayEffectContextHandle());
	Ability->K2_ExecuteGameplayCueWithParams_Actor(nullptr, ActorCueParameters);
	Ability->K2_AddGameplayCue_Actor(nullptr, FGameplayEffectContextHandle(), true);
	Ability->K2_AddGameplayCueWithParams_Actor(nullptr, ActorCueParameters, false);
	Ability->K2_RemoveGameplayCue_Actor(nullptr);
	Ability->K2_ExecuteGameplayCue_Static(nullptr, FGameplayEffectContextHandle());
	Ability->K2_ExecuteGameplayCueWithParams_Static(nullptr, StaticCueParameters);
	Ability->K2_AddGameplayCue_Static(nullptr, FGameplayEffectContextHandle(), false);
	Ability->K2_AddGameplayCueWithParams_Static(nullptr, StaticCueParameters, true);
	Ability->K2_RemoveGameplayCue_Static(nullptr);

	bPassed = true;
	bPassed &= TestEqual(TEXT("Null cue wrappers should not append ExecuteGameplayCue forwards"), Ability->ExecuteCueCallCount, ExecuteCueCallCountBeforeNull);
	bPassed &= TestEqual(TEXT("Null cue wrappers should not append ExecuteGameplayCueWithParams forwards"), Ability->ExecuteCueWithParamsCallCount, ExecuteCueWithParamsCallCountBeforeNull);
	bPassed &= TestEqual(TEXT("Null cue wrappers should not append AddGameplayCue forwards"), Ability->AddCueCallCount, AddCueCallCountBeforeNull);
	bPassed &= TestEqual(TEXT("Null cue wrappers should not append AddGameplayCueWithParams forwards"), Ability->AddCueWithParamsCallCount, AddCueWithParamsCallCountBeforeNull);
	bPassed &= TestEqual(TEXT("Null cue wrappers should not append RemoveGameplayCue forwards"), Ability->RemoveCueCallCount, RemoveCueCallCountBeforeNull);
	return bPassed;
}

#endif
