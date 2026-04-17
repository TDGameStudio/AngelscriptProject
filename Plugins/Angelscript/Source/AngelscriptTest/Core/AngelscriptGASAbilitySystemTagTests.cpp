#include "AngelscriptGASTestTypes.h"
#include "Shared/AngelscriptTestMacros.h"

#include "Components/ActorTestSpawner.h"
#include "GameplayTagsManager.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

namespace AngelscriptTest_Core_AngelscriptGASAbilitySystemTagTests_Private
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

	bool FindUnrelatedAbilityTags(FGameplayTag& OutPrimaryTag, FGameplayTag& OutSecondaryTag)
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
}

using namespace AngelscriptTest_Core_AngelscriptGASAbilitySystemTagTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptGASAbilitySystemTagQueryActivationAndCancelTest,
	"Angelscript.TestModule.Engine.GAS.AbilitySystem.TagQueriesActivateAndCancelMatchingAbilities",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptGASAbilitySystemTagQueryActivationAndCancelTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();

	AAngelscriptGASTestActor* TestActor = &Spawner.SpawnActor<AAngelscriptGASTestActor>();
	if (!TestNotNull(TEXT("GAS tag query test actor should spawn"), TestActor))
	{
		return false;
	}

	UAngelscriptAbilitySystemComponent* AbilitySystemComponent = TestActor->AbilitySystemComponent;
	if (!TestNotNull(TEXT("GAS tag query test actor should expose an ability-system component"), AbilitySystemComponent))
	{
		return false;
	}

	AbilitySystemComponent->InitAbilityActorInfo(TestActor, TestActor);

	FGameplayTag PrimaryTag;
	FGameplayTag SecondaryTag;
	if (!TestTrue(TEXT("GAS tag query test requires two unrelated gameplay tags"), FindUnrelatedAbilityTags(PrimaryTag, SecondaryTag)))
	{
		return false;
	}

	UAngelscriptGASTestPrimaryTagAbility* PrimaryAbilityCDO = GetMutableDefault<UAngelscriptGASTestPrimaryTagAbility>();
	UAngelscriptGASTestSecondaryTagAbility* SecondaryAbilityCDO = GetMutableDefault<UAngelscriptGASTestSecondaryTagAbility>();
	if (!TestNotNull(TEXT("GAS tag query test should resolve the primary test ability CDO"), PrimaryAbilityCDO)
		|| !TestNotNull(TEXT("GAS tag query test should resolve the secondary test ability CDO"), SecondaryAbilityCDO))
	{
		return false;
	}

	const FGameplayTagContainer OriginalPrimaryTags = GetMutableAbilityAssetTags(*PrimaryAbilityCDO);
	const FGameplayTagContainer OriginalSecondaryTags = GetMutableAbilityAssetTags(*SecondaryAbilityCDO);
	const FGameplayTagContainer PrimaryTagContainer = MakeSingleTagContainer(PrimaryTag);
	const FGameplayTagContainer SecondaryTagContainer = MakeSingleTagContainer(SecondaryTag);

	GetMutableAbilityAssetTags(*PrimaryAbilityCDO) = PrimaryTagContainer;
	GetMutableAbilityAssetTags(*SecondaryAbilityCDO) = SecondaryTagContainer;

	const FGameplayAbilitySpecHandle PrimaryHandle =
		AbilitySystemComponent->BP_GiveAbility(UAngelscriptGASTestPrimaryTagAbility::StaticClass(), 1, 0, nullptr);
	const FGameplayAbilitySpecHandle SecondaryHandle =
		AbilitySystemComponent->BP_GiveAbility(UAngelscriptGASTestSecondaryTagAbility::StaticClass(), 1, 1, nullptr);
	if (!TestTrue(TEXT("GAS tag query test should grant a valid primary ability handle"), PrimaryHandle.IsValid())
		|| !TestTrue(TEXT("GAS tag query test should grant a valid secondary ability handle"), SecondaryHandle.IsValid()))
	{
		return false;
	}

	ON_SCOPE_EXIT
	{
		GetMutableAbilityAssetTags(*PrimaryAbilityCDO) = OriginalPrimaryTags;
		GetMutableAbilityAssetTags(*SecondaryAbilityCDO) = OriginalSecondaryTags;

		if (AbilitySystemComponent != nullptr)
		{
			if (PrimaryHandle.IsValid())
			{
				AbilitySystemComponent->CancelAbilityByHandle(PrimaryHandle);
				AbilitySystemComponent->ClearAbility(PrimaryHandle);
			}

			if (SecondaryHandle.IsValid())
			{
				AbilitySystemComponent->CancelAbilityByHandle(SecondaryHandle);
				AbilitySystemComponent->ClearAbility(SecondaryHandle);
			}
		}
	};

	TArray<UGameplayAbility*> PrimaryActiveAbilities;
	TArray<UGameplayAbility*> SecondaryActiveAbilities;
	AbilitySystemComponent->GetActiveAbilitiesWithTags(PrimaryTagContainer, PrimaryActiveAbilities);
	AbilitySystemComponent->GetActiveAbilitiesWithTags(SecondaryTagContainer, SecondaryActiveAbilities);

	TestEqual(
		TEXT("GetActiveAbilitiesWithTags should report no primary ability instances before activation"),
		PrimaryActiveAbilities.Num(),
		0);
	TestEqual(
		TEXT("GetActiveAbilitiesWithTags should report no secondary ability instances before activation"),
		SecondaryActiveAbilities.Num(),
		0);

	if (!TestTrue(
		TEXT("ActivateAbilitiesUsingTags should activate the primary matching ability"),
		AbilitySystemComponent->ActivateAbilitiesUsingTags(PrimaryTagContainer)))
	{
		return false;
	}

	PrimaryActiveAbilities.Reset();
	SecondaryActiveAbilities.Reset();
	AbilitySystemComponent->GetActiveAbilitiesWithTags(PrimaryTagContainer, PrimaryActiveAbilities);
	AbilitySystemComponent->GetActiveAbilitiesWithTags(SecondaryTagContainer, SecondaryActiveAbilities);

	UAngelscriptGASTestPrimaryTagAbility* PrimaryAbilityInstance =
		GetPrimaryTestAbilityInstance<UAngelscriptGASTestPrimaryTagAbility>(*AbilitySystemComponent, PrimaryHandle);
	if (!TestNotNull(TEXT("Primary activation should resolve the primary ability instance"), PrimaryAbilityInstance))
	{
		return false;
	}

	TestTrue(
		TEXT("ActivateAbilitiesUsingTags should mark the primary ability active"),
		AbilitySystemComponent->IsAbilityActive(UAngelscriptGASTestPrimaryTagAbility::StaticClass()));
	TestFalse(
		TEXT("ActivateAbilitiesUsingTags should leave the secondary ability inactive"),
		AbilitySystemComponent->IsAbilityActive(UAngelscriptGASTestSecondaryTagAbility::StaticClass()));
	TestEqual(TEXT("The primary ability instance should record exactly one activation"), PrimaryAbilityInstance->ActivationCount, 1);
	TestEqual(TEXT("Primary tag query should return exactly one active primary ability instance"), PrimaryActiveAbilities.Num(), 1);
	TestEqual(TEXT("Secondary tag query should still return zero active instances before activation"), SecondaryActiveAbilities.Num(), 0);
	TestTrue(
		TEXT("Primary tag query should return the primary tagged ability instance"),
		PrimaryActiveAbilities.Num() == 1 && PrimaryActiveAbilities[0] == PrimaryAbilityInstance);

	if (!TestTrue(
		TEXT("ActivateAbilitiesUsingTags should activate the secondary matching ability"),
		AbilitySystemComponent->ActivateAbilitiesUsingTags(SecondaryTagContainer)))
	{
		return false;
	}

	PrimaryActiveAbilities.Reset();
	SecondaryActiveAbilities.Reset();
	AbilitySystemComponent->GetActiveAbilitiesWithTags(PrimaryTagContainer, PrimaryActiveAbilities);
	AbilitySystemComponent->GetActiveAbilitiesWithTags(SecondaryTagContainer, SecondaryActiveAbilities);

	UAngelscriptGASTestSecondaryTagAbility* SecondaryAbilityInstance =
		GetPrimaryTestAbilityInstance<UAngelscriptGASTestSecondaryTagAbility>(*AbilitySystemComponent, SecondaryHandle);
	if (!TestNotNull(TEXT("Secondary tag activation should resolve the secondary ability instance"), SecondaryAbilityInstance))
	{
		return false;
	}

	TestTrue(
		TEXT("Secondary tag activation should mark the secondary ability active"),
		AbilitySystemComponent->IsAbilityActive(UAngelscriptGASTestSecondaryTagAbility::StaticClass()));
	TestEqual(TEXT("The secondary ability instance should record exactly one activation"), SecondaryAbilityInstance->ActivationCount, 1);
	TestEqual(TEXT("Primary tag query should still return exactly one active instance after secondary activation"), PrimaryActiveAbilities.Num(), 1);
	TestEqual(TEXT("Secondary tag query should return exactly one active secondary ability instance"), SecondaryActiveAbilities.Num(), 1);
	TestTrue(
		TEXT("Secondary tag query should return the secondary tagged ability instance"),
		SecondaryActiveAbilities.Num() == 1 && SecondaryActiveAbilities[0] == SecondaryAbilityInstance);

	const FGameplayTagContainer EmptyWithoutTags;
	AbilitySystemComponent->CancelAbilitiesByTags(PrimaryTagContainer, EmptyWithoutTags, nullptr);

	PrimaryActiveAbilities.Reset();
	SecondaryActiveAbilities.Reset();
	AbilitySystemComponent->GetActiveAbilitiesWithTags(PrimaryTagContainer, PrimaryActiveAbilities);
	AbilitySystemComponent->GetActiveAbilitiesWithTags(SecondaryTagContainer, SecondaryActiveAbilities);

	TestFalse(
		TEXT("CancelAbilitiesByTags should deactivate the primary tagged ability"),
		AbilitySystemComponent->IsAbilityActive(UAngelscriptGASTestPrimaryTagAbility::StaticClass()));
	TestTrue(
		TEXT("CancelAbilitiesByTags should leave the secondary tagged ability active"),
		AbilitySystemComponent->IsAbilityActive(UAngelscriptGASTestSecondaryTagAbility::StaticClass()));
	TestEqual(TEXT("CancelAbilitiesByTags should end the primary tagged ability exactly once"), PrimaryAbilityInstance->EndCount, 1);
	TestEqual(TEXT("CancelAbilitiesByTags should not end the secondary tagged ability"), SecondaryAbilityInstance->EndCount, 0);
	TestEqual(TEXT("Primary tag query should be empty after cancelling the primary tagged ability"), PrimaryActiveAbilities.Num(), 0);
	TestEqual(TEXT("Secondary tag query should keep the secondary tagged ability active after primary cancellation"), SecondaryActiveAbilities.Num(), 1);
	TestTrue(
		TEXT("Secondary tag query should still return the secondary tagged ability instance after primary cancellation"),
		SecondaryActiveAbilities.Num() == 1 && SecondaryActiveAbilities[0] == SecondaryAbilityInstance);

	ASTEST_END_SHARE_CLEAN
	return true;
}

#endif
