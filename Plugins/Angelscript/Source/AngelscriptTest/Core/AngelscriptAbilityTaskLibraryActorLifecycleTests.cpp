#include "AngelscriptGASTestTypes.h"
#include "Shared/AngelscriptTestMacros.h"

#define protected public
#include "Abilities/GameplayAbility.h"
#undef protected

#define protected public
#define private public
#include "../../AngelscriptRuntime/Core/AngelscriptAbilityTaskLibrary.h"
#undef private
#undef protected

#include "Abilities/GameplayAbilityTargetActor_Radius.h"
#include "Abilities/GameplayAbilityTargetTypes.h"
#include "Abilities/GameplayAbilityTypes.h"
#include "Components/ActorTestSpawner.h"
#include "GameFramework/Character.h"
#include "GameFramework/PlayerController.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"
#include "UObject/UnrealType.h"

#if WITH_DEV_AUTOMATION_TESTS

namespace AngelscriptTest_Core_AngelscriptAbilityTaskLibraryActorLifecycleTests_Private
{
	FGameplayAbilitySpec* FindAbilitySpec(
		UAngelscriptAbilitySystemComponent& AbilitySystemComponent,
		const FGameplayAbilitySpecHandle& Handle)
	{
		return AbilitySystemComponent.FindAbilitySpecFromHandle(Handle);
	}

	UAngelscriptGASTestAbility* GetPrimaryTestAbilityInstance(
		UAngelscriptAbilitySystemComponent& AbilitySystemComponent,
		const FGameplayAbilitySpecHandle& Handle)
	{
		FGameplayAbilitySpec* AbilitySpec = FindAbilitySpec(AbilitySystemComponent, Handle);
		if (AbilitySpec == nullptr)
		{
			return nullptr;
		}

		return Cast<UAngelscriptGASTestAbility>(AbilitySpec->GetPrimaryInstance());
	}

	bool InitializeControlledAbilityFixture(
		FAutomationTestBase& Test,
		FActorTestSpawner& Spawner,
		AAngelscriptGASTestPawn*& OutPawn,
		APlayerController*& OutPlayerController,
		UAngelscriptAbilitySystemComponent*& OutAbilitySystemComponent)
	{
		OutPawn = &Spawner.SpawnActor<AAngelscriptGASTestPawn>();
		if (!Test.TestNotNull(TEXT("ActorLifecycleWrappers should spawn a controlled pawn"), OutPawn))
		{
			return false;
		}

		OutAbilitySystemComponent = OutPawn->AbilitySystem;
		if (!Test.TestNotNull(TEXT("ActorLifecycleWrappers should expose an ability-system component"), OutAbilitySystemComponent))
		{
			return false;
		}

		OutPlayerController = Spawner.GetWorld().SpawnActor<APlayerController>();
		if (!Test.TestNotNull(TEXT("ActorLifecycleWrappers should spawn a player controller"), OutPlayerController))
		{
			return false;
		}

		OutPlayerController->Possess(OutPawn);
		if (!Test.TestTrue(TEXT("ActorLifecycleWrappers should possess the pawn with the spawned player controller"), OutPawn->GetController() == OutPlayerController))
		{
			return false;
		}

		OutAbilitySystemComponent->InitAbilityActorInfo(OutPlayerController, OutPawn);
		return true;
	}

	FGameplayAbilityTargetDataHandle MakeSingleTargetHitData(const FVector& HitLocation)
	{
		FGameplayAbilityTargetData_SingleTargetHit* TargetData = new FGameplayAbilityTargetData_SingleTargetHit();
		TargetData->HitResult.Location = HitLocation;
		TargetData->HitResult.ImpactPoint = HitLocation;

		FGameplayAbilityTargetDataHandle Handle;
		Handle.Add(TargetData);
		return Handle;
	}

	template<typename TaskType>
	bool ExpectTaskOwnershipWithoutInstanceName(
		FAutomationTestBase& Test,
		const FString& Label,
		TaskType* Task,
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

	template<typename TaskType>
	bool ExpectTaskOwnership(
		FAutomationTestBase& Test,
		const FString& Label,
		TaskType* Task,
		UGameplayAbility* ExpectedAbility,
		UAbilitySystemComponent* ExpectedASC,
		const FGameplayAbilitySpecHandle& ExpectedHandle,
		const FName ExpectedInstanceName)
	{
		if (!ExpectTaskOwnershipWithoutInstanceName(Test, Label, Task, ExpectedAbility, ExpectedASC, ExpectedHandle))
		{
			return false;
		}

		Test.TestEqual(
			*FString::Printf(TEXT("%s should preserve the provided instance name"), *Label),
			Task->GetInstanceName(),
			ExpectedInstanceName);
		return true;
	}

	bool OverrideAbilityNetExecutionPolicy(
		FAutomationTestBase& Test,
		UGameplayAbility& AbilityCDO,
		const EGameplayAbilityNetExecutionPolicy::Type NewPolicy,
		uint8& OutOriginalPolicyValue)
	{
		FByteProperty* NetExecutionPolicyProperty =
			FindFProperty<FByteProperty>(UGameplayAbility::StaticClass(), TEXT("NetExecutionPolicy"));
		if (!Test.TestNotNull(TEXT("ActorLifecycleWrappers should reflect GameplayAbility::NetExecutionPolicy"), NetExecutionPolicyProperty))
		{
			return false;
		}

		OutOriginalPolicyValue = NetExecutionPolicyProperty->GetPropertyValue_InContainer(&AbilityCDO);
		NetExecutionPolicyProperty->SetPropertyValue_InContainer(&AbilityCDO, static_cast<uint8>(NewPolicy));
		return true;
	}

	void RestoreAbilityNetExecutionPolicy(
		UGameplayAbility& AbilityCDO,
		const uint8 OriginalPolicyValue)
	{
		if (FByteProperty* NetExecutionPolicyProperty =
				FindFProperty<FByteProperty>(UGameplayAbility::StaticClass(), TEXT("NetExecutionPolicy")))
		{
			NetExecutionPolicyProperty->SetPropertyValue_InContainer(&AbilityCDO, OriginalPolicyValue);
		}
	}

	bool OverrideActorReplicates(
		FAutomationTestBase& Test,
		AActor& ActorCDO,
		const bool bNewReplicates,
		bool& OutOriginalReplicates)
	{
		FBoolProperty* ReplicatesProperty = FindFProperty<FBoolProperty>(AActor::StaticClass(), TEXT("bReplicates"));
		if (!Test.TestNotNull(TEXT("ActorLifecycleWrappers should reflect AActor::bReplicates"), ReplicatesProperty))
		{
			return false;
		}

		OutOriginalReplicates = ReplicatesProperty->GetPropertyValue_InContainer(&ActorCDO);
		ReplicatesProperty->SetPropertyValue_InContainer(&ActorCDO, bNewReplicates);
		return true;
	}

	void RestoreActorReplicates(AActor& ActorCDO, const bool bOriginalReplicates)
	{
		if (FBoolProperty* ReplicatesProperty = FindFProperty<FBoolProperty>(AActor::StaticClass(), TEXT("bReplicates")))
		{
			ReplicatesProperty->SetPropertyValue_InContainer(&ActorCDO, bOriginalReplicates);
		}
	}
}

using namespace AngelscriptTest_Core_AngelscriptAbilityTaskLibraryActorLifecycleTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptAbilityTaskLibraryActorLifecycleWrappersTest,
	"Angelscript.TestModule.Engine.GASAbilityTaskLibrary.ActorSpawnWrappersPreserveTaskStateAndFinalizeActor",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptAbilityTaskLibraryActorLifecycleWrappersTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	UAngelscriptGASTestAbility* AbilityCDO = GetMutableDefault<UAngelscriptGASTestAbility>();
	uint8 OriginalNetExecutionPolicy = 0;
	if (!OverrideAbilityNetExecutionPolicy(
			*this,
			*AbilityCDO,
			EGameplayAbilityNetExecutionPolicy::ServerOnly,
			OriginalNetExecutionPolicy))
	{
		return false;
	}

	AGameplayAbilityTargetActor_Radius* VisualizeTargetActorCDO = GetMutableDefault<AGameplayAbilityTargetActor_Radius>();
	bool bOriginalVisualizeTargetReplicates = false;
	if (!OverrideActorReplicates(*this, *VisualizeTargetActorCDO, true, bOriginalVisualizeTargetReplicates))
	{
		return false;
	}

	ON_SCOPE_EXIT
	{
		RestoreAbilityNetExecutionPolicy(*AbilityCDO, OriginalNetExecutionPolicy);
		RestoreActorReplicates(*VisualizeTargetActorCDO, bOriginalVisualizeTargetReplicates);
	};

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();

	AAngelscriptGASTestPawn* ControlledPawn = nullptr;
	APlayerController* PlayerController = nullptr;
	UAngelscriptAbilitySystemComponent* AbilitySystemComponent = nullptr;
	if (!InitializeControlledAbilityFixture(*this, Spawner, ControlledPawn, PlayerController, AbilitySystemComponent))
	{
		return false;
	}

	const FGameplayAbilitySpecHandle AbilityHandle =
		AbilitySystemComponent->BP_GiveAbility(UAngelscriptGASTestAbility::StaticClass(), 1, 0, nullptr);
	if (!TestTrue(TEXT("ActorLifecycleWrappers should grant a valid ability handle"), AbilityHandle.IsValid()))
	{
		return false;
	}

	ON_SCOPE_EXIT
	{
		if (AbilitySystemComponent != nullptr && AbilityHandle.IsValid())
		{
			AbilitySystemComponent->CancelAbilityByHandle(AbilityHandle);
		}
	};

	if (!TestTrue(TEXT("ActorLifecycleWrappers should activate the granted ability"), AbilitySystemComponent->TryActivateAbilitySpec(AbilityHandle)))
	{
		return false;
	}

	UAngelscriptGASTestAbility* AbilityInstance = GetPrimaryTestAbilityInstance(*AbilitySystemComponent, AbilityHandle);
	if (!TestNotNull(TEXT("ActorLifecycleWrappers should resolve the primary ability instance"), AbilityInstance))
	{
		return false;
	}

	TestEqual(TEXT("ActorLifecycleWrappers should activate the ability exactly once"), AbilityInstance->ActivationCount, 1);

	const FVector ExpectedSpawnLocation(120.f, 30.f, 50.f);
	const FGameplayAbilityTargetDataHandle TargetData = MakeSingleTargetHitData(ExpectedSpawnLocation);
	const TSubclassOf<AActor> SpawnedActorClass = ACharacter::StaticClass();

	UAbilityTask_SpawnActor* SpawnActorTask =
		UAngelscriptAbilityTaskLibrary::SpawnActor(AbilityInstance, TargetData, SpawnedActorClass);
	if (!ExpectTaskOwnershipWithoutInstanceName(*this, TEXT("SpawnActor"), SpawnActorTask, AbilityInstance, AbilitySystemComponent, AbilityHandle))
	{
		return false;
	}

	TestTrue(TEXT("SpawnActor should return the native spawn-actor task class"), SpawnActorTask->GetClass() == UAbilityTask_SpawnActor::StaticClass());
	TestEqual(TEXT("SpawnActor should preserve a single cached target-data entry"), SpawnActorTask->CachedTargetDataHandle.Num(), 1);
	TestTrue(TEXT("SpawnActor should keep the target-data location payload"), SpawnActorTask->CachedTargetDataHandle.Get(0)->GetHitResult()->Location == ExpectedSpawnLocation);

	UAngelscriptGASTestSpawnedActorListener* SpawnSuccessListener =
		NewObject<UAngelscriptGASTestSpawnedActorListener>(ControlledPawn, TEXT("SpawnActorSuccessListener"));
	UAngelscriptGASTestSpawnedActorListener* SpawnFailureListener =
		NewObject<UAngelscriptGASTestSpawnedActorListener>(ControlledPawn, TEXT("SpawnActorFailureListener"));
	if (!TestNotNull(TEXT("SpawnActor should create a success listener"), SpawnSuccessListener) ||
		!TestNotNull(TEXT("SpawnActor should create a failure listener"), SpawnFailureListener))
	{
		return false;
	}

	SpawnActorTask->Success.AddDynamic(SpawnSuccessListener, &UAngelscriptGASTestSpawnedActorListener::RecordSpawnedActor);
	SpawnActorTask->DidNotSpawn.AddDynamic(SpawnFailureListener, &UAngelscriptGASTestSpawnedActorListener::RecordSpawnedActor);

	AActor* SpawnedActor = nullptr;
	if (!TestTrue(TEXT("SpawnActor BeginSpawningActor should succeed on the authority fixture"), SpawnActorTask->BeginSpawningActor(AbilityInstance, TargetData, SpawnedActorClass, SpawnedActor)) ||
		!TestNotNull(TEXT("SpawnActor BeginSpawningActor should create a deferred actor"), SpawnedActor))
	{
		return false;
	}

	if (!TestNotNull(TEXT("SpawnActor should spawn the requested actor class"), Cast<ACharacter>(SpawnedActor)))
	{
		return false;
	}

	SpawnActorTask->FinishSpawningActor(AbilityInstance, TargetData, SpawnedActor);

	TestEqual(TEXT("SpawnActor should broadcast success exactly once after FinishSpawningActor"), SpawnSuccessListener->CallbackCount, 1);
	TestTrue(TEXT("SpawnActor success delegate should report the spawned actor"), SpawnSuccessListener->LastActor.Get() == SpawnedActor);
	TestEqual(TEXT("SpawnActor should not broadcast DidNotSpawn on the success path"), SpawnFailureListener->CallbackCount, 0);
	TestEqual(TEXT("SpawnActor should finish the deferred actor at the target-data hit location"), SpawnedActor->GetActorLocation(), ExpectedSpawnLocation);
	TestTrue(TEXT("SpawnActor should finish the task after FinishSpawningActor"), SpawnActorTask->IsFinished());

	const FName VisualizeTaskName(TEXT("ClassVisualizeTask"));
	UAbilityTask_VisualizeTargeting* VisualizeTask =
		UAngelscriptAbilityTaskLibrary::VisualizeTargeting(
			AbilityInstance,
			AGameplayAbilityTargetActor_Radius::StaticClass(),
			VisualizeTaskName,
			0.05f);
	if (!ExpectTaskOwnership(*this, TEXT("VisualizeTargeting"), VisualizeTask, AbilityInstance, AbilitySystemComponent, AbilityHandle, VisualizeTaskName))
	{
		return false;
	}

	TestTrue(TEXT("VisualizeTargeting should return the native visualize-targeting task class"), VisualizeTask->GetClass() == UAbilityTask_VisualizeTargeting::StaticClass());
	TestTrue(TEXT("VisualizeTargeting should preserve the provided target class"), VisualizeTask->TargetClass == AGameplayAbilityTargetActor_Radius::StaticClass());
	TestFalse(TEXT("VisualizeTargeting should start without a spawned target actor"), VisualizeTask->TargetActor.IsValid());
	TestTrue(TEXT("VisualizeTargeting should schedule its duration timer at creation time"), Spawner.GetWorld().GetTimerManager().IsTimerActive(VisualizeTask->TimerHandle_OnTimeElapsed));

	AGameplayAbilityTargetActor* VisualizedTargetActorBase = nullptr;
	if (!TestTrue(TEXT("VisualizeTargeting BeginSpawningActor should succeed on the locally controlled fixture"), VisualizeTask->BeginSpawningActor(AbilityInstance, AGameplayAbilityTargetActor_Radius::StaticClass(), VisualizedTargetActorBase)) ||
		!TestNotNull(TEXT("VisualizeTargeting BeginSpawningActor should create a deferred targeting actor"), VisualizedTargetActorBase))
	{
		return false;
	}

	AGameplayAbilityTargetActor_Radius* VisualizedTargetActor = Cast<AGameplayAbilityTargetActor_Radius>(VisualizedTargetActorBase);
	if (!TestNotNull(TEXT("VisualizeTargeting BeginSpawningActor should spawn the requested targeting actor subclass"), VisualizedTargetActor))
	{
		return false;
	}

	TestTrue(TEXT("VisualizeTargeting BeginSpawningActor should initialize PrimaryPC before finish"), VisualizedTargetActor->PrimaryPC == PlayerController);

	TWeakObjectPtr<AGameplayAbilityTargetActor> VisualizedTargetActorWeak = VisualizedTargetActor;
	VisualizeTask->FinishSpawningActor(AbilityInstance, VisualizedTargetActor);

	TestTrue(TEXT("VisualizeTargeting should preserve the spawned target actor"), VisualizeTask->TargetActor.Get() == VisualizedTargetActor);
	TestTrue(TEXT("VisualizeTargeting should keep PrimaryPC on the spawned target actor"), VisualizedTargetActor->PrimaryPC == PlayerController);
	TestTrue(TEXT("VisualizeTargeting should start targeting with the owning ability"), VisualizedTargetActor->OwningAbility == AbilityInstance);
	if (!TestTrue(TEXT("VisualizeTargeting should register the spawned target actor on the ASC"), AbilitySystemComponent->SpawnedTargetActors.Num() > 0))
	{
		return false;
	}
	TestTrue(TEXT("VisualizeTargeting should push the spawned target actor to the ASC stack"), AbilitySystemComponent->SpawnedTargetActors.Last() == VisualizedTargetActor);

	VisualizeTask->EndTask();
	TestTrue(TEXT("VisualizeTargeting should finish immediately after EndTask"), VisualizeTask->IsFinished());
	CollectGarbage(RF_NoFlags, true);

	TestFalse(TEXT("VisualizeTargeting EndTask should destroy the spawned target actor"), VisualizedTargetActorWeak.IsValid());
	TestFalse(TEXT("VisualizeTargeting EndTask should clear the duration timer"), Spawner.GetWorld().GetTimerManager().IsTimerActive(VisualizeTask->TimerHandle_OnTimeElapsed));

	ASTEST_END_SHARE_CLEAN
	return true;
}

#endif
