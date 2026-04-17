#include "AngelscriptGASTestTypes.h"
#include "Shared/AngelscriptTestMacros.h"

#define protected public
#define private public
#include "../../AngelscriptRuntime/Core/AngelscriptAbilityTaskLibrary.h"
#undef private
#undef protected

#include "Components/ActorTestSpawner.h"
#include "GameplayTagsManager.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

namespace AngelscriptTest_Core_AngelscriptAbilityTaskLibraryObserverTests_Private
{
	FGameplayAbilitySpec* FindAbilitySpec(
		UAngelscriptAbilitySystemComponent& AbilitySystemComponent,
		const FGameplayAbilitySpecHandle& Handle)
	{
		return AbilitySystemComponent.FindAbilitySpecFromHandle(Handle);
	}

	template <typename TAbility>
	TAbility* GetPrimaryTestAbilityInstance(
		UAngelscriptAbilitySystemComponent& AbilitySystemComponent,
		const FGameplayAbilitySpecHandle& Handle)
	{
		FGameplayAbilitySpec* AbilitySpec = FindAbilitySpec(AbilitySystemComponent, Handle);
		if (AbilitySpec == nullptr)
		{
			return nullptr;
		}

		return Cast<TAbility>(AbilitySpec->GetPrimaryInstance());
	}

	bool FindUnrelatedAbilityTags(
		FAutomationTestBase& Test,
		FGameplayTag& OutPrimaryTag,
		FGameplayTag& OutSecondaryTag)
	{
		FGameplayTagContainer AllTags;
		UGameplayTagsManager::Get().RequestAllGameplayTags(AllTags, false);

		TArray<FGameplayTag> TagArray;
		AllTags.GetGameplayTagArray(TagArray);

		for (const FGameplayTag& CandidatePrimaryTag : TagArray)
		{
			if (!CandidatePrimaryTag.IsValid())
			{
				continue;
			}

			for (const FGameplayTag& CandidateSecondaryTag : TagArray)
			{
				if (!CandidateSecondaryTag.IsValid() || CandidateSecondaryTag == CandidatePrimaryTag)
				{
					continue;
				}

				if (CandidatePrimaryTag.MatchesTag(CandidateSecondaryTag)
					|| CandidateSecondaryTag.MatchesTag(CandidatePrimaryTag))
				{
					continue;
				}

				OutPrimaryTag = CandidatePrimaryTag;
				OutSecondaryTag = CandidateSecondaryTag;
				return true;
			}
		}

		Test.AddError(TEXT("AbilityTaskLibrary observer test requires two unrelated gameplay tags"));
		return false;
	}

	FGameplayTagContainer MakeSingleTagContainer(const FGameplayTag& Tag)
	{
		FGameplayTagContainer TagContainer;
		if (Tag.IsValid())
		{
			TagContainer.AddTag(Tag);
		}

		return TagContainer;
	}

	FGameplayTagContainer& GetMutableAbilityAssetTags(UGameplayAbility& Ability)
	{
#if WITH_EDITOR
		return Ability.EditorGetAssetTags();
#else
PRAGMA_DISABLE_DEPRECATION_WARNINGS
		return Ability.AbilityTags;
PRAGMA_ENABLE_DEPRECATION_WARNINGS
#endif
	}

	template <typename TTaskType>
	bool ExpectTaskOwnership(
		FAutomationTestBase& Test,
		const FString& Label,
		TTaskType* Task,
		UGameplayAbility* ExpectedAbility,
		UAbilitySystemComponent* ExpectedASC,
		const FGameplayAbilitySpecHandle& ExpectedHandle)
	{
		if (!Test.TestNotNull(*FString::Printf(TEXT("%s should return a task"), *Label), Task))
		{
			return false;
		}

		Test.TestTrue(
			*FString::Printf(TEXT("%s should keep the owning ability"), *Label),
			Task->Ability == ExpectedAbility);
		Test.TestTrue(
			*FString::Printf(TEXT("%s should keep the owner ASC"), *Label),
			Task->AbilitySystemComponent.Get() == ExpectedASC);
		Test.TestTrue(
			*FString::Printf(TEXT("%s should preserve the granted ability spec handle"), *Label),
			Task->GetAbilitySpecHandle() == ExpectedHandle);
		return true;
	}

}

using namespace AngelscriptTest_Core_AngelscriptAbilityTaskLibraryObserverTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptAbilityTaskLibraryObserverWrappersTest,
	"Angelscript.TestModule.Engine.GASAbilityTaskLibrary.ActivateAndCommitWrappersHonorFilters",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptAbilityTaskLibraryObserverWrappersTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();

	AAngelscriptGASTestActor* TestActor = &Spawner.SpawnActor<AAngelscriptGASTestActor>();
	if (!TestNotNull(TEXT("AbilityTaskLibrary observer test actor should spawn"), TestActor))
	{
		return false;
	}

	UAngelscriptAbilitySystemComponent* AbilitySystemComponent = TestActor->AbilitySystemComponent;
	if (!TestNotNull(TEXT("AbilityTaskLibrary observer test actor should expose an ability-system component"), AbilitySystemComponent))
	{
		return false;
	}

	AbilitySystemComponent->InitAbilityActorInfo(TestActor, TestActor);

	FGameplayTag MatchTag;
	FGameplayTag OtherTag;
	if (!FindUnrelatedAbilityTags(*this, MatchTag, OtherTag))
	{
		return false;
	}

	const FGameplayTagContainer MatchTagContainer = MakeSingleTagContainer(MatchTag);
	const FGameplayTagContainer OtherTagContainer = MakeSingleTagContainer(OtherTag);
	const FGameplayTagQuery MatchQuery = FGameplayTagQuery::MakeQuery_MatchTag(MatchTag);
	if (!TestFalse(TEXT("AbilityTaskLibrary observer query should not be empty"), MatchQuery.IsEmpty()))
	{
		return false;
	}

	FGameplayTagRequirements MatchRequirements;
	MatchRequirements.RequireTags.AddTag(MatchTag);

	UAngelscriptGASTestPrimaryTagAbility* MatchAbilityCDO = GetMutableDefault<UAngelscriptGASTestPrimaryTagAbility>();
	UAngelscriptGASTestSecondaryTagAbility* OtherAbilityCDO = GetMutableDefault<UAngelscriptGASTestSecondaryTagAbility>();
	if (!TestNotNull(TEXT("AbilityTaskLibrary observer test should resolve the match ability CDO"), MatchAbilityCDO)
		|| !TestNotNull(TEXT("AbilityTaskLibrary observer test should resolve the non-match ability CDO"), OtherAbilityCDO))
	{
		return false;
	}

	const FGameplayTagContainer OriginalMatchTags = GetMutableAbilityAssetTags(*MatchAbilityCDO);
	const FGameplayTagContainer OriginalOtherTags = GetMutableAbilityAssetTags(*OtherAbilityCDO);
	GetMutableAbilityAssetTags(*MatchAbilityCDO) = MatchTagContainer;
	GetMutableAbilityAssetTags(*OtherAbilityCDO) = OtherTagContainer;

	const FGameplayAbilitySpecHandle ObserverHandle =
		AbilitySystemComponent->BP_GiveAbility(UAngelscriptGASTestAbility::StaticClass(), 1, 0, nullptr);
	const FGameplayAbilitySpecHandle MatchHandle =
		AbilitySystemComponent->BP_GiveAbility(UAngelscriptGASTestPrimaryTagAbility::StaticClass(), 1, 1, nullptr);
	const FGameplayAbilitySpecHandle OtherHandle =
		AbilitySystemComponent->BP_GiveAbility(UAngelscriptGASTestSecondaryTagAbility::StaticClass(), 1, 2, nullptr);
	if (!TestTrue(TEXT("AbilityTaskLibrary observer test should grant a valid observer handle"), ObserverHandle.IsValid())
		|| !TestTrue(TEXT("AbilityTaskLibrary observer test should grant a valid match handle"), MatchHandle.IsValid())
		|| !TestTrue(TEXT("AbilityTaskLibrary observer test should grant a valid non-match handle"), OtherHandle.IsValid()))
	{
		return false;
	}

	ON_SCOPE_EXIT
	{
		GetMutableAbilityAssetTags(*MatchAbilityCDO) = OriginalMatchTags;
		GetMutableAbilityAssetTags(*OtherAbilityCDO) = OriginalOtherTags;

		if (AbilitySystemComponent != nullptr)
		{
			for (const FGameplayAbilitySpecHandle Handle : { ObserverHandle, MatchHandle, OtherHandle })
			{
				if (Handle.IsValid())
				{
					AbilitySystemComponent->CancelAbilityByHandle(Handle);
					AbilitySystemComponent->ClearAbility(Handle);
				}
			}
		}
	};

	if (!TestTrue(TEXT("AbilityTaskLibrary observer test should create the non-match primary instance"), AbilitySystemComponent->TryActivateAbilitySpec(OtherHandle)))
	{
		return false;
	}

	UAngelscriptGASTestSecondaryTagAbility* OtherAbility =
		GetPrimaryTestAbilityInstance<UAngelscriptGASTestSecondaryTagAbility>(*AbilitySystemComponent, OtherHandle);
	if (!TestNotNull(TEXT("AbilityTaskLibrary observer test should resolve the non-match primary instance"), OtherAbility))
	{
		return false;
	}

	GetMutableAbilityAssetTags(*OtherAbility) = OtherTagContainer;
	TestEqual(TEXT("The non-match primary instance should inherit the non-match asset tag"), OtherAbility->GetAssetTags(), OtherTagContainer);
	AbilitySystemComponent->CancelAbilityByHandle(OtherHandle);

	if (!TestTrue(TEXT("AbilityTaskLibrary observer test should create the match primary instance"), AbilitySystemComponent->TryActivateAbilitySpec(MatchHandle)))
	{
		return false;
	}

	UAngelscriptGASTestPrimaryTagAbility* MatchAbility =
		GetPrimaryTestAbilityInstance<UAngelscriptGASTestPrimaryTagAbility>(*AbilitySystemComponent, MatchHandle);
	if (!TestNotNull(TEXT("AbilityTaskLibrary observer test should resolve the match primary instance"), MatchAbility))
	{
		return false;
	}

	GetMutableAbilityAssetTags(*MatchAbility) = MatchTagContainer;
	TestEqual(TEXT("The match primary instance should inherit the match asset tag"), MatchAbility->GetAssetTags(), MatchTagContainer);
	AbilitySystemComponent->CancelAbilityByHandle(MatchHandle);

	if (!TestTrue(TEXT("AbilityTaskLibrary observer test should activate the observer ability"), AbilitySystemComponent->TryActivateAbilitySpec(ObserverHandle)))
	{
		return false;
	}

	UAngelscriptGASTestAbility* ObserverAbility =
		GetPrimaryTestAbilityInstance<UAngelscriptGASTestAbility>(*AbilitySystemComponent, ObserverHandle);
	if (!TestNotNull(TEXT("AbilityTaskLibrary observer test should resolve the observer ability instance"), ObserverAbility))
	{
		return false;
	}

	TestTrue(TEXT("AbilityTaskLibrary observer task owner should stay active"), ObserverAbility->IsActive());

	UAbilityTask_WaitAbilityActivate* MatchActivateTask =
		UAngelscriptAbilityTaskLibrary::WaitForAbilityActivate(ObserverAbility, MatchTag, FGameplayTag(), false, true);
	UAbilityTask_WaitAbilityActivate* QueryActivateTask =
		UAngelscriptAbilityTaskLibrary::WaitForAbilityActivateQuery(ObserverAbility, MatchQuery, false, true);
	UAbilityTask_WaitAbilityActivate* RequirementsActivateTask =
		UAngelscriptAbilityTaskLibrary::WaitForAbilityActivateWithTagRequirements(ObserverAbility, MatchRequirements, false, true);
	UAbilityTask_WaitAbilityCommit* MatchCommitTask =
		UAngelscriptAbilityTaskLibrary::WaitForNewAbilityCommit(ObserverAbility, MatchTag, FGameplayTag(), true);
	UAbilityTask_WaitAbilityCommit* QueryCommitTask =
		UAngelscriptAbilityTaskLibrary::WaitForNewAbilityCommitQuery(ObserverAbility, MatchQuery, true);

	if (!ExpectTaskOwnership(*this, TEXT("WaitForAbilityActivate"), MatchActivateTask, ObserverAbility, AbilitySystemComponent, ObserverHandle)
		|| !ExpectTaskOwnership(*this, TEXT("WaitForAbilityActivateQuery"), QueryActivateTask, ObserverAbility, AbilitySystemComponent, ObserverHandle)
		|| !ExpectTaskOwnership(*this, TEXT("WaitForAbilityActivateWithTagRequirements"), RequirementsActivateTask, ObserverAbility, AbilitySystemComponent, ObserverHandle)
		|| !ExpectTaskOwnership(*this, TEXT("WaitForNewAbilityCommit"), MatchCommitTask, ObserverAbility, AbilitySystemComponent, ObserverHandle)
		|| !ExpectTaskOwnership(*this, TEXT("WaitForNewAbilityCommitQuery"), QueryCommitTask, ObserverAbility, AbilitySystemComponent, ObserverHandle))
	{
		return false;
	}

	TestEqual(TEXT("WaitForAbilityActivate should preserve the match tag filter"), MatchActivateTask->WithTag, MatchTag);
	TestFalse(TEXT("WaitForAbilityActivate should leave the exclusion tag invalid"), MatchActivateTask->WithoutTag.IsValid());
	TestFalse(TEXT("WaitForAbilityActivate should preserve include-triggered false"), MatchActivateTask->IncludeTriggeredAbilities);
	TestTrue(TEXT("WaitForAbilityActivate should preserve trigger-once true"), MatchActivateTask->TriggerOnce);
	TestTrue(TEXT("WaitForAbilityActivate should leave tag requirements empty"), MatchActivateTask->TagRequirements.IsEmpty());
	TestTrue(TEXT("WaitForAbilityActivate should leave the query empty"), MatchActivateTask->Query.IsEmpty());

	TestFalse(TEXT("WaitForAbilityActivateQuery should leave WithTag invalid"), QueryActivateTask->WithTag.IsValid());
	TestFalse(TEXT("WaitForAbilityActivateQuery should leave WithoutTag invalid"), QueryActivateTask->WithoutTag.IsValid());
	TestFalse(TEXT("WaitForAbilityActivateQuery should preserve include-triggered false"), QueryActivateTask->IncludeTriggeredAbilities);
	TestTrue(TEXT("WaitForAbilityActivateQuery should preserve trigger-once true"), QueryActivateTask->TriggerOnce);
	TestTrue(TEXT("WaitForAbilityActivateQuery should leave tag requirements empty"), QueryActivateTask->TagRequirements.IsEmpty());
	TestEqual(TEXT("WaitForAbilityActivateQuery should preserve the query"), QueryActivateTask->Query, MatchQuery);

	TestFalse(TEXT("WaitForAbilityActivateWithTagRequirements should leave WithTag invalid"), RequirementsActivateTask->WithTag.IsValid());
	TestFalse(TEXT("WaitForAbilityActivateWithTagRequirements should leave WithoutTag invalid"), RequirementsActivateTask->WithoutTag.IsValid());
	TestFalse(TEXT("WaitForAbilityActivateWithTagRequirements should preserve include-triggered false"), RequirementsActivateTask->IncludeTriggeredAbilities);
	TestTrue(TEXT("WaitForAbilityActivateWithTagRequirements should preserve trigger-once true"), RequirementsActivateTask->TriggerOnce);
	TestEqual(TEXT("WaitForAbilityActivateWithTagRequirements should preserve required tags"), RequirementsActivateTask->TagRequirements.RequireTags, MatchRequirements.RequireTags);
	TestEqual(TEXT("WaitForAbilityActivateWithTagRequirements should preserve ignored tags"), RequirementsActivateTask->TagRequirements.IgnoreTags, MatchRequirements.IgnoreTags);
	TestTrue(TEXT("WaitForAbilityActivateWithTagRequirements should leave the query empty"), RequirementsActivateTask->Query.IsEmpty());

	TestEqual(TEXT("WaitForNewAbilityCommit should preserve the match tag filter"), MatchCommitTask->WithTag, MatchTag);
	TestFalse(TEXT("WaitForNewAbilityCommit should leave the exclusion tag invalid"), MatchCommitTask->WithoutTag.IsValid());
	TestTrue(TEXT("WaitForNewAbilityCommit should preserve trigger-once true"), MatchCommitTask->TriggerOnce);
	TestTrue(TEXT("WaitForNewAbilityCommit should leave the query empty"), MatchCommitTask->Query.IsEmpty());

	TestFalse(TEXT("WaitForNewAbilityCommitQuery should leave WithTag invalid"), QueryCommitTask->WithTag.IsValid());
	TestFalse(TEXT("WaitForNewAbilityCommitQuery should leave WithoutTag invalid"), QueryCommitTask->WithoutTag.IsValid());
	TestTrue(TEXT("WaitForNewAbilityCommitQuery should preserve trigger-once true"), QueryCommitTask->TriggerOnce);
	TestEqual(TEXT("WaitForNewAbilityCommitQuery should preserve the query"), QueryCommitTask->Query, MatchQuery);

	UAngelscriptGASTestAbilityCallbackListener* MatchActivateListener =
		NewObject<UAngelscriptGASTestAbilityCallbackListener>(TestActor, TEXT("MatchActivateListener"));
	UAngelscriptGASTestAbilityCallbackListener* QueryActivateListener =
		NewObject<UAngelscriptGASTestAbilityCallbackListener>(TestActor, TEXT("QueryActivateListener"));
	UAngelscriptGASTestAbilityCallbackListener* RequirementsActivateListener =
		NewObject<UAngelscriptGASTestAbilityCallbackListener>(TestActor, TEXT("RequirementsActivateListener"));
	UAngelscriptGASTestAbilityCallbackListener* MatchCommitListener =
		NewObject<UAngelscriptGASTestAbilityCallbackListener>(TestActor, TEXT("MatchCommitListener"));
	UAngelscriptGASTestAbilityCallbackListener* QueryCommitListener =
		NewObject<UAngelscriptGASTestAbilityCallbackListener>(TestActor, TEXT("QueryCommitListener"));
	if (!TestNotNull(TEXT("WaitForAbilityActivate should create a match listener"), MatchActivateListener)
		|| !TestNotNull(TEXT("WaitForAbilityActivateQuery should create a query listener"), QueryActivateListener)
		|| !TestNotNull(TEXT("WaitForAbilityActivateWithTagRequirements should create a requirements listener"), RequirementsActivateListener)
		|| !TestNotNull(TEXT("WaitForNewAbilityCommit should create a match listener"), MatchCommitListener)
		|| !TestNotNull(TEXT("WaitForNewAbilityCommitQuery should create a query listener"), QueryCommitListener))
	{
		return false;
	}

	MatchActivateTask->OnActivate.AddDynamic(MatchActivateListener, &UAngelscriptGASTestAbilityCallbackListener::RecordAbility);
	QueryActivateTask->OnActivate.AddDynamic(QueryActivateListener, &UAngelscriptGASTestAbilityCallbackListener::RecordAbility);
	RequirementsActivateTask->OnActivate.AddDynamic(RequirementsActivateListener, &UAngelscriptGASTestAbilityCallbackListener::RecordAbility);
	MatchCommitTask->OnCommit.AddDynamic(MatchCommitListener, &UAngelscriptGASTestAbilityCallbackListener::RecordAbility);
	QueryCommitTask->OnCommit.AddDynamic(QueryCommitListener, &UAngelscriptGASTestAbilityCallbackListener::RecordAbility);

	MatchActivateTask->ReadyForActivation();
	QueryActivateTask->ReadyForActivation();
	RequirementsActivateTask->ReadyForActivation();
	MatchCommitTask->ReadyForActivation();
	QueryCommitTask->ReadyForActivation();

	TestEqual(TEXT("Ability activate listeners should stay idle before non-match activity"), MatchActivateListener->CallbackCount, 0);
	TestEqual(TEXT("Ability activate query listener should stay idle before non-match activity"), QueryActivateListener->CallbackCount, 0);
	TestEqual(TEXT("Ability activate requirements listener should stay idle before non-match activity"), RequirementsActivateListener->CallbackCount, 0);
	TestEqual(TEXT("Ability commit listener should stay idle before non-match activity"), MatchCommitListener->CallbackCount, 0);
	TestEqual(TEXT("Ability commit query listener should stay idle before non-match activity"), QueryCommitListener->CallbackCount, 0);

	AbilitySystemComponent->NotifyAbilityActivated(OtherHandle, OtherAbility);

	TestEqual(TEXT("Ability activate listener should ignore the non-match ability"), MatchActivateListener->CallbackCount, 0);
	TestEqual(TEXT("Ability activate query listener should ignore the non-match ability"), QueryActivateListener->CallbackCount, 0);
	TestEqual(TEXT("Ability activate requirements listener should ignore the non-match ability"), RequirementsActivateListener->CallbackCount, 0);

	AbilitySystemComponent->NotifyAbilityCommit(OtherAbility);

	TestEqual(TEXT("Ability commit listener should ignore the non-match ability"), MatchCommitListener->CallbackCount, 0);
	TestEqual(TEXT("Ability commit query listener should ignore the non-match ability"), QueryCommitListener->CallbackCount, 0);

	AbilitySystemComponent->NotifyAbilityActivated(MatchHandle, MatchAbility);

	TestEqual(TEXT("WaitForAbilityActivate should fire once for the match ability"), MatchActivateListener->CallbackCount, 1);
	TestEqual(TEXT("WaitForAbilityActivateQuery should fire once for the match ability"), QueryActivateListener->CallbackCount, 1);
	TestEqual(TEXT("WaitForAbilityActivateWithTagRequirements should fire once for the match ability"), RequirementsActivateListener->CallbackCount, 1);
	TestTrue(TEXT("WaitForAbilityActivate should report the match ability instance"), MatchActivateListener->LastAbility == MatchAbility);
	TestTrue(TEXT("WaitForAbilityActivateQuery should report the match ability instance"), QueryActivateListener->LastAbility == MatchAbility);
	TestTrue(TEXT("WaitForAbilityActivateWithTagRequirements should report the match ability instance"), RequirementsActivateListener->LastAbility == MatchAbility);

	AbilitySystemComponent->NotifyAbilityCommit(MatchAbility);

	TestEqual(TEXT("WaitForNewAbilityCommit should fire once for the match ability"), MatchCommitListener->CallbackCount, 1);
	TestEqual(TEXT("WaitForNewAbilityCommitQuery should fire once for the match ability"), QueryCommitListener->CallbackCount, 1);
	TestTrue(TEXT("WaitForNewAbilityCommit should report the match ability instance"), MatchCommitListener->LastAbility == MatchAbility);
	TestTrue(TEXT("WaitForNewAbilityCommitQuery should report the match ability instance"), QueryCommitListener->LastAbility == MatchAbility);

	AbilitySystemComponent->CancelAbilityByHandle(MatchHandle);

	if (!TestTrue(TEXT("AbilityTaskLibrary observer test should reactivate the match ability after cancel"), AbilitySystemComponent->TryActivateAbilitySpec(MatchHandle)))
	{
		return false;
	}

	MatchAbility = GetPrimaryTestAbilityInstance<UAngelscriptGASTestPrimaryTagAbility>(*AbilitySystemComponent, MatchHandle);
	if (!TestNotNull(TEXT("AbilityTaskLibrary observer test should resolve the reactivated match ability instance"), MatchAbility))
	{
		return false;
	}

	GetMutableAbilityAssetTags(*MatchAbility) = MatchTagContainer;
	AbilitySystemComponent->NotifyAbilityActivated(MatchHandle, MatchAbility);
	AbilitySystemComponent->NotifyAbilityCommit(MatchAbility);

	TestEqual(TEXT("WaitForAbilityActivate should stay one-shot after the second match activation"), MatchActivateListener->CallbackCount, 1);
	TestEqual(TEXT("WaitForAbilityActivateQuery should stay one-shot after the second match activation"), QueryActivateListener->CallbackCount, 1);
	TestEqual(TEXT("WaitForAbilityActivateWithTagRequirements should stay one-shot after the second match activation"), RequirementsActivateListener->CallbackCount, 1);
	TestEqual(TEXT("WaitForNewAbilityCommit should stay one-shot after the second match commit"), MatchCommitListener->CallbackCount, 1);
	TestEqual(TEXT("WaitForNewAbilityCommitQuery should stay one-shot after the second match commit"), QueryCommitListener->CallbackCount, 1);

	ASTEST_END_SHARE_CLEAN
	return true;
}

#endif
