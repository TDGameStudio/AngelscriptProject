#include "AngelscriptGASTestTypes.h"
#include "Shared/AngelscriptTestMacros.h"

#include "Components/ActorTestSpawner.h"
#include "GameFramework/PlayerController.h"
#include "GameplayTagsManager.h"
#include "Misc/AutomationTest.h"

#if WITH_DEV_AUTOMATION_TESTS

namespace AngelscriptTest_Core_AngelscriptGASAbilitySystemLifecycleTests_Private
{
	bool AreIndependentGameplayTags(const FGameplayTag& Left, const FGameplayTag& Right)
	{
		return Left.IsValid() && Right.IsValid()
			&& Left != Right
			&& !Left.MatchesTag(Right)
			&& !Right.MatchesTag(Left);
	}

	bool GetGameplayTagsForMirrorQueries(
		FAutomationTestBase& Test,
		FGameplayTag& OutPrimaryTag,
		FGameplayTag& OutSecondaryTag,
		FGameplayTag& OutMissingTag)
	{
		FGameplayTagContainer AllTags;
		UGameplayTagsManager::Get().RequestAllGameplayTags(AllTags, false);

		TArray<FGameplayTag> AvailableTags;
		AllTags.GetGameplayTagArray(AvailableTags);

		for (int32 PrimaryIndex = 0; PrimaryIndex < AvailableTags.Num(); ++PrimaryIndex)
		{
			for (int32 SecondaryIndex = PrimaryIndex + 1; SecondaryIndex < AvailableTags.Num(); ++SecondaryIndex)
			{
				const FGameplayTag CandidatePrimary = AvailableTags[PrimaryIndex];
				const FGameplayTag CandidateSecondary = AvailableTags[SecondaryIndex];
				if (!AreIndependentGameplayTags(CandidatePrimary, CandidateSecondary))
				{
					continue;
				}

				OutPrimaryTag = CandidatePrimary;
				OutSecondaryTag = CandidateSecondary;
				OutMissingTag = FGameplayTag();

				for (int32 MissingIndex = 0; MissingIndex < AvailableTags.Num(); ++MissingIndex)
				{
					const FGameplayTag CandidateMissing = AvailableTags[MissingIndex];
					if (CandidateMissing == CandidatePrimary || CandidateMissing == CandidateSecondary)
					{
						continue;
					}

					if (AreIndependentGameplayTags(CandidateMissing, CandidatePrimary)
						&& AreIndependentGameplayTags(CandidateMissing, CandidateSecondary))
					{
						OutMissingTag = CandidateMissing;
						break;
					}
				}

				return true;
			}
		}

		return Test.AddError(TEXT("GAS actor-info lifecycle test requires two independent registered gameplay tags")), false;
	}

	bool InitializeActorFixture(
		FAutomationTestBase& Test,
		FActorTestSpawner& Spawner,
		const TCHAR* Context,
		AAngelscriptGASTestActor*& OutActor,
		UAngelscriptAbilitySystemComponent*& OutAbilitySystemComponent)
	{
		OutActor = &Spawner.SpawnActor<AAngelscriptGASTestActor>();
		if (!Test.TestNotNull(
				*FString::Printf(TEXT("%s should spawn a GAS actor fixture"), Context),
				OutActor))
		{
			return false;
		}

		OutAbilitySystemComponent = OutActor->AbilitySystemComponent;
		return Test.TestNotNull(
			*FString::Printf(TEXT("%s should expose an ability-system component"), Context),
			OutAbilitySystemComponent);
	}

	bool InitializeControlledPawnFixture(
		FAutomationTestBase& Test,
		FActorTestSpawner& Spawner,
		AAngelscriptGASTestPawn*& OutPawn,
		APlayerController*& OutPlayerController,
		UAngelscriptAbilitySystemComponent*& OutAbilitySystemComponent)
	{
		OutPawn = &Spawner.SpawnActor<AAngelscriptGASTestPawn>();
		if (!Test.TestNotNull(TEXT("Controlled GAS fixture should spawn a pawn"), OutPawn))
		{
			return false;
		}

		OutAbilitySystemComponent = OutPawn->AbilitySystem;
		if (!Test.TestNotNull(TEXT("Controlled GAS fixture should expose an ability-system component"), OutAbilitySystemComponent))
		{
			return false;
		}

		OutPlayerController = Spawner.GetWorld().SpawnActor<APlayerController>();
		if (!Test.TestNotNull(TEXT("Controlled GAS fixture should spawn a player controller"), OutPlayerController))
		{
			return false;
		}

		OutPlayerController->Possess(OutPawn);
		return Test.TestTrue(TEXT("Controlled GAS fixture should leave the spawned pawn possessed by the player controller"), OutPawn->GetController() == OutPlayerController);
	}
}

using namespace AngelscriptTest_Core_AngelscriptGASAbilitySystemLifecycleTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptGASActorInfoAndOwnedTagMirrorTest,
	"Angelscript.TestModule.Engine.GAS.AbilitySystem.ActorInfoAndOwnedTagMirrorsStayInSync",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptGASActorInfoAndOwnedTagMirrorTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();

	FGameplayTag PrimaryTag;
	FGameplayTag SecondaryTag;
	FGameplayTag MissingTag;
	if (!GetGameplayTagsForMirrorQueries(*this, PrimaryTag, SecondaryTag, MissingTag))
	{
		return false;
	}

	AAngelscriptGASTestActor* TestActor = nullptr;
	UAngelscriptAbilitySystemComponent* AbilitySystemComponent = nullptr;
	if (!InitializeActorFixture(
			*this,
			Spawner,
			TEXT("Actor-info mirror fixture"),
			TestActor,
			AbilitySystemComponent))
	{
		return false;
	}

	UAngelscriptGASTestInitAbilityActorInfoListener* InitListener =
		NewObject<UAngelscriptGASTestInitAbilityActorInfoListener>(TestActor, TEXT("InitAbilityActorInfoListener"));
	UAngelscriptGASTestOwnedTagListener* OwnedTagListener =
		NewObject<UAngelscriptGASTestOwnedTagListener>(TestActor, TEXT("OwnedTagUpdatedListener"));
	if (!TestNotNull(TEXT("Actor-info mirror fixture should create an init listener"), InitListener)
		|| !TestNotNull(TEXT("Actor-info mirror fixture should create an owned-tag listener"), OwnedTagListener))
	{
		return false;
	}

	AbilitySystemComponent->OnInitAbilityActorInfo.AddDynamic(
		InitListener,
		&UAngelscriptGASTestInitAbilityActorInfoListener::RecordInitAbilityActorInfo);
	AbilitySystemComponent->OnOwnedTagUpdated.AddDynamic(
		OwnedTagListener,
		&UAngelscriptGASTestOwnedTagListener::RecordOwnedTagUpdated);

	AbilitySystemComponent->InitAbilityActorInfo(TestActor, TestActor);

	const FGameplayAbilityActorInfo& ActorInfo = AbilitySystemComponent->GetAbilityActorInfo();
	TestTrue(TEXT("GetAbilityActorInfo should keep the owner actor passed to InitAbilityActorInfo"), ActorInfo.OwnerActor.Get() == TestActor);
	TestTrue(TEXT("GetAbilityActorInfo should keep the avatar actor passed to InitAbilityActorInfo"), ActorInfo.AvatarActor.Get() == TestActor);
	TestTrue(TEXT("GetAvatar should return the avatar actor used for initialization"), AbilitySystemComponent->GetAvatar() == TestActor);
	TestTrue(TEXT("GetPlayerController should stay null when initializing with a plain actor owner/avatar"), AbilitySystemComponent->GetPlayerController() == nullptr);
	TestEqual(TEXT("OnInitAbilityActorInfo should broadcast exactly once for the actor fixture"), InitListener->BroadcastCount, 1);
	TestTrue(TEXT("OnInitAbilityActorInfo should report the actor owner that was passed to InitAbilityActorInfo"), InitListener->LastOwnerActor.Get() == TestActor);
	TestTrue(TEXT("OnInitAbilityActorInfo should report the actor avatar that was passed to InitAbilityActorInfo"), InitListener->LastAvatarActor.Get() == TestActor);

	AbilitySystemComponent->AddLooseGameplayTag(PrimaryTag);
	AbilitySystemComponent->AddLooseGameplayTag(SecondaryTag);

	FGameplayTagContainer RequiredTags;
	RequiredTags.AddTag(PrimaryTag);
	RequiredTags.AddTag(SecondaryTag);

	FGameplayTagContainer AnyTags;
	if (MissingTag.IsValid())
	{
		AnyTags.AddTag(MissingTag);
	}
	AnyTags.AddTag(SecondaryTag);

	FGameplayTagContainer SecondaryOnlyTags;
	SecondaryOnlyTags.AddTag(SecondaryTag);

	TestTrue(TEXT("HasGameplayTag should mirror loose gameplay tags added to the ability-system component"), AbilitySystemComponent->HasGameplayTag(PrimaryTag));
	TestTrue(TEXT("HasAllGameplayTags should report true once both required loose gameplay tags are present"), AbilitySystemComponent->HasAllGameplayTags(RequiredTags));
	TestTrue(TEXT("HasAnyGameplayTags should report true when at least one queried loose gameplay tag is owned"), AbilitySystemComponent->HasAnyGameplayTags(AnyTags));
	TestEqual(TEXT("OnOwnedTagUpdated should fire once per added loose gameplay tag"), OwnedTagListener->BroadcastCount, 2);
	TestTrue(
		TEXT("OnOwnedTagUpdated should report the first added primary tag with TagExists=true"),
		OwnedTagListener->RecordedTags.IsValidIndex(0)
			&& OwnedTagListener->RecordedTags[0].MatchesTagExact(PrimaryTag)
			&& OwnedTagListener->RecordedTagExistsStates.IsValidIndex(0)
			&& OwnedTagListener->RecordedTagExistsStates[0]);
	TestTrue(
		TEXT("OnOwnedTagUpdated should report the second added secondary tag with TagExists=true"),
		OwnedTagListener->RecordedTags.IsValidIndex(1)
			&& OwnedTagListener->RecordedTags[1].MatchesTagExact(SecondaryTag)
			&& OwnedTagListener->RecordedTagExistsStates.IsValidIndex(1)
			&& OwnedTagListener->RecordedTagExistsStates[1]);

	AbilitySystemComponent->RemoveLooseGameplayTag(SecondaryTag);

	TestEqual(TEXT("Removing a loose gameplay tag should append exactly one owned-tag removal broadcast"), OwnedTagListener->BroadcastCount, 3);
	TestTrue(
		TEXT("Removing the secondary loose gameplay tag should broadcast TagExists=false for that tag"),
		OwnedTagListener->RecordedTags.IsValidIndex(2)
			&& OwnedTagListener->RecordedTags[2].MatchesTagExact(SecondaryTag)
			&& OwnedTagListener->RecordedTagExistsStates.IsValidIndex(2)
			&& !OwnedTagListener->RecordedTagExistsStates[2]);
	TestFalse(TEXT("HasAllGameplayTags should report false once one of the required loose gameplay tags is removed"), AbilitySystemComponent->HasAllGameplayTags(RequiredTags));
	TestFalse(TEXT("HasAnyGameplayTags should report false once the only owned tag in the query container is removed"), AbilitySystemComponent->HasAnyGameplayTags(SecondaryOnlyTags));

	AAngelscriptGASTestPawn* ControlledPawn = nullptr;
	APlayerController* PlayerController = nullptr;
	UAngelscriptAbilitySystemComponent* ControlledAbilitySystemComponent = nullptr;
	if (!InitializeControlledPawnFixture(
			*this,
			Spawner,
			ControlledPawn,
			PlayerController,
			ControlledAbilitySystemComponent))
	{
		return false;
	}

	UAngelscriptGASTestInitAbilityActorInfoListener* ControlledInitListener =
		NewObject<UAngelscriptGASTestInitAbilityActorInfoListener>(ControlledPawn, TEXT("ControlledInitAbilityActorInfoListener"));
	if (!TestNotNull(TEXT("Controlled GAS fixture should create an init listener"), ControlledInitListener))
	{
		return false;
	}

	ControlledAbilitySystemComponent->OnInitAbilityActorInfo.AddDynamic(
		ControlledInitListener,
		&UAngelscriptGASTestInitAbilityActorInfoListener::RecordInitAbilityActorInfo);

	ControlledAbilitySystemComponent->InitAbilityActorInfo(PlayerController, ControlledPawn);

	const FGameplayAbilityActorInfo& ControlledActorInfo = ControlledAbilitySystemComponent->GetAbilityActorInfo();
	TestTrue(TEXT("Controlled actor-info fixture should keep the player controller as owner actor"), ControlledActorInfo.OwnerActor.Get() == PlayerController);
	TestTrue(TEXT("Controlled actor-info fixture should keep the pawn as avatar actor"), ControlledActorInfo.AvatarActor.Get() == ControlledPawn);
	TestTrue(TEXT("GetAvatar should return the possessed pawn in the controller-owned fixture"), ControlledAbilitySystemComponent->GetAvatar() == ControlledPawn);
	TestTrue(TEXT("GetPlayerController should return the controlling player controller after InitAbilityActorInfo"), ControlledAbilitySystemComponent->GetPlayerController() == PlayerController);
	TestEqual(TEXT("Controlled actor-info fixture should broadcast OnInitAbilityActorInfo exactly once"), ControlledInitListener->BroadcastCount, 1);
	TestTrue(TEXT("Controlled actor-info fixture should report the same player controller through OnInitAbilityActorInfo"), ControlledInitListener->LastOwnerActor.Get() == PlayerController);
	TestTrue(TEXT("Controlled actor-info fixture should report the same pawn through OnInitAbilityActorInfo"), ControlledInitListener->LastAvatarActor.Get() == ControlledPawn);

	ASTEST_END_SHARE_CLEAN
	return true;
}

#endif
