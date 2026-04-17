#include "AngelscriptGASTestTypes.h"
#include "Shared/AngelscriptTestMacros.h"

#define protected public
#define private public
#include "../../AngelscriptRuntime/Core/AngelscriptAbilityTaskLibrary.h"
#undef private
#undef protected

#include "Abilities/GameplayAbilityTargetTypes.h"
#include "Components/ActorTestSpawner.h"
#include "Components/CapsuleComponent.h"
#include "GameFramework/Character.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

namespace AngelscriptTest_Core_AngelscriptAbilityTaskLibraryStateOverlapTests_Private
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

	UPrimitiveComponent* ResolveRootPrimitive(
		FAutomationTestBase& Test,
		AActor& Actor,
		const TCHAR* ContextLabel)
	{
		UPrimitiveComponent* Primitive = Cast<UPrimitiveComponent>(Actor.GetRootComponent());
		Test.TestNotNull(
			*FString::Printf(TEXT("%s should expose a root primitive component"), ContextLabel),
			Primitive);
		return Primitive;
	}

	FHitResult MakeOverlapHit(AActor& OtherActor, UPrimitiveComponent& OtherComponent)
	{
		return FHitResult(
			&OtherActor,
			&OtherComponent,
			OtherActor.GetActorLocation(),
			FVector::UpVector);
	}
}

using namespace AngelscriptTest_Core_AngelscriptAbilityTaskLibraryStateOverlapTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptAbilityTaskLibraryStateAndOverlapWrappersTest,
	"Angelscript.TestModule.Engine.GASAbilityTaskLibrary.StateAndOverlapWrappersDriveDelegatesCorrectly",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptAbilityTaskLibraryStateAndOverlapWrappersTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();

	AAngelscriptGASTestActor* OwnerActor = &Spawner.SpawnActor<AAngelscriptGASTestActor>();
	ACharacter* AvatarActor = &Spawner.SpawnActor<ACharacter>();
	ACharacter* OverlapTargetActor = &Spawner.SpawnActor<ACharacter>();
	if (!TestNotNull(TEXT("StateAndOverlapWrappers should spawn an owner actor"), OwnerActor) ||
		!TestNotNull(TEXT("StateAndOverlapWrappers should spawn an avatar actor"), AvatarActor) ||
		!TestNotNull(TEXT("StateAndOverlapWrappers should spawn an overlap target actor"), OverlapTargetActor))
	{
		return false;
	}

	UAngelscriptAbilitySystemComponent* OwnerASC = OwnerActor->AbilitySystemComponent;
	if (!TestNotNull(TEXT("StateAndOverlapWrappers should expose an owner ASC"), OwnerASC))
	{
		return false;
	}

	OwnerASC->InitAbilityActorInfo(OwnerActor, AvatarActor);

	const FGameplayAbilitySpecHandle AbilityHandle =
		OwnerASC->BP_GiveAbility(UAngelscriptGASTestAbility::StaticClass(), 1, 0, nullptr);
	if (!TestTrue(TEXT("StateAndOverlapWrappers should grant a valid ability handle"), AbilityHandle.IsValid()))
	{
		return false;
	}

	ON_SCOPE_EXIT
	{
		if (OwnerASC != nullptr && AbilityHandle.IsValid())
		{
			OwnerASC->CancelAbilityByHandle(AbilityHandle);
		}
	};

	if (!TestTrue(TEXT("StateAndOverlapWrappers should activate the granted ability"), OwnerASC->TryActivateAbilitySpec(AbilityHandle)))
	{
		return false;
	}

	UAngelscriptGASTestAbility* AbilityInstance = GetPrimaryTestAbilityInstance(*OwnerASC, AbilityHandle);
	if (!TestNotNull(TEXT("StateAndOverlapWrappers should resolve the primary ability instance"), AbilityInstance))
	{
		return false;
	}

	const FName CastingStateName(TEXT("Casting"));
	UAbilityTask_StartAbilityState* CastingTask =
		UAngelscriptAbilityTaskLibrary::StartAbilityState(AbilityInstance, CastingStateName, false);
	if (!ExpectTaskOwnership(*this, TEXT("StartAbilityState(Casting)"), CastingTask, AbilityInstance, OwnerASC, AbilityHandle, CastingStateName))
	{
		return false;
	}

	TestEqual(TEXT("StartAbilityState(Casting) should return the native start-state task class"), CastingTask->GetClass(), UAbilityTask_StartAbilityState::StaticClass());
	TestEqual(TEXT("StartAbilityState(Casting) should expose the expected debug string"), CastingTask->GetDebugString(), FString(TEXT("Casting (AbilityState)")));

	UAngelscriptGASTestAsyncListener* CastingEndedListener =
		NewObject<UAngelscriptGASTestAsyncListener>(OwnerActor, TEXT("StateEndedListener"));
	UAngelscriptGASTestAsyncListener* CastingInterruptedListener =
		NewObject<UAngelscriptGASTestAsyncListener>(OwnerActor, TEXT("StateInterruptedListener"));
	if (!TestNotNull(TEXT("StartAbilityState(Casting) should create an end listener"), CastingEndedListener) ||
		!TestNotNull(TEXT("StartAbilityState(Casting) should create an interrupt listener"), CastingInterruptedListener))
	{
		return false;
	}

	CastingTask->OnStateEnded.AddDynamic(CastingEndedListener, &UAngelscriptGASTestAsyncListener::HandleTriggered);
	CastingTask->OnStateInterrupted.AddDynamic(CastingInterruptedListener, &UAngelscriptGASTestAsyncListener::HandleTriggered);
	CastingTask->ReadyForActivation();

	TestTrue(TEXT("StartAbilityState(Casting) should register an ability-state end callback after activation"), AbilityInstance->OnGameplayAbilityStateEnded.IsBound());
	TestTrue(TEXT("StartAbilityState(Casting) should register an ability-cancel callback after activation"), AbilityInstance->OnGameplayAbilityCancelled.IsBound());

	AbilityInstance->OnGameplayAbilityStateEnded.Broadcast(CastingStateName);
	TestEqual(TEXT("StartAbilityState(Casting) should end exactly once on matching state end"), CastingEndedListener->TriggerCount, 1);
	TestEqual(TEXT("StartAbilityState(Casting) should not report interruption on matching state end"), CastingInterruptedListener->TriggerCount, 0);
	TestTrue(TEXT("StartAbilityState(Casting) should finish after the matching state end broadcast"), CastingTask->IsFinished());
	TestFalse(TEXT("StartAbilityState(Casting) should unbind the state-end callback after finishing"), AbilityInstance->OnGameplayAbilityStateEnded.IsBound());
	TestFalse(TEXT("StartAbilityState(Casting) should unbind the cancel callback after finishing"), AbilityInstance->OnGameplayAbilityCancelled.IsBound());

	AbilityInstance->OnGameplayAbilityStateEnded.Broadcast(CastingStateName);
	AbilityInstance->OnGameplayAbilityCancelled.Broadcast();
	TestEqual(TEXT("StartAbilityState(Casting) should ignore further end broadcasts after finishing"), CastingEndedListener->TriggerCount, 1);
	TestEqual(TEXT("StartAbilityState(Casting) should ignore later cancel broadcasts after finishing"), CastingInterruptedListener->TriggerCount, 0);

	const FName InterruptedStateName(TEXT("Interrupted"));
	UAbilityTask_StartAbilityState* InterruptedTask =
		UAngelscriptAbilityTaskLibrary::StartAbilityState(AbilityInstance, InterruptedStateName, true);
	if (!ExpectTaskOwnership(*this, TEXT("StartAbilityState(Interrupted)"), InterruptedTask, AbilityInstance, OwnerASC, AbilityHandle, InterruptedStateName))
	{
		return false;
	}

	UAngelscriptGASTestAsyncListener* InterruptedEndedListener =
		NewObject<UAngelscriptGASTestAsyncListener>(OwnerActor, TEXT("InterruptedStateEndedListener"));
	UAngelscriptGASTestAsyncListener* InterruptedListener =
		NewObject<UAngelscriptGASTestAsyncListener>(OwnerActor, TEXT("InterruptedStateInterruptedListener"));
	if (!TestNotNull(TEXT("StartAbilityState(Interrupted) should create an end listener"), InterruptedEndedListener) ||
		!TestNotNull(TEXT("StartAbilityState(Interrupted) should create an interrupt listener"), InterruptedListener))
	{
		return false;
	}

	InterruptedTask->OnStateEnded.AddDynamic(InterruptedEndedListener, &UAngelscriptGASTestAsyncListener::HandleTriggered);
	InterruptedTask->OnStateInterrupted.AddDynamic(InterruptedListener, &UAngelscriptGASTestAsyncListener::HandleTriggered);
	InterruptedTask->ReadyForActivation();

	TestTrue(TEXT("StartAbilityState(Interrupted) should register a state-end callback after activation"), AbilityInstance->OnGameplayAbilityStateEnded.IsBound());
	TestTrue(TEXT("StartAbilityState(Interrupted) should register a cancel callback after activation"), AbilityInstance->OnGameplayAbilityCancelled.IsBound());

	InterruptedTask->ExternalCancel();
	TestEqual(TEXT("StartAbilityState(Interrupted) should not report a normal end when externally cancelled"), InterruptedEndedListener->TriggerCount, 0);
	TestEqual(TEXT("StartAbilityState(Interrupted) should report interruption exactly once when externally cancelled"), InterruptedListener->TriggerCount, 1);
	TestTrue(TEXT("StartAbilityState(Interrupted) should finish after external cancellation"), InterruptedTask->IsFinished());
	TestFalse(TEXT("StartAbilityState(Interrupted) should unbind the state-end callback after external cancellation"), AbilityInstance->OnGameplayAbilityStateEnded.IsBound());
	TestFalse(TEXT("StartAbilityState(Interrupted) should unbind the cancel callback after external cancellation"), AbilityInstance->OnGameplayAbilityCancelled.IsBound());

	AbilityInstance->OnGameplayAbilityStateEnded.Broadcast(InterruptedStateName);
	AbilityInstance->OnGameplayAbilityCancelled.Broadcast();
	TestEqual(TEXT("StartAbilityState(Interrupted) should ignore later end broadcasts after finishing"), InterruptedEndedListener->TriggerCount, 0);
	TestEqual(TEXT("StartAbilityState(Interrupted) should ignore later cancel broadcasts after finishing"), InterruptedListener->TriggerCount, 1);

	UPrimitiveComponent* AvatarPrimitive = ResolveRootPrimitive(*this, *AvatarActor, TEXT("WaitForOverlap"));
	UPrimitiveComponent* TargetPrimitive = ResolveRootPrimitive(*this, *OverlapTargetActor, TEXT("WaitForOverlap target"));
	if (AvatarPrimitive == nullptr || TargetPrimitive == nullptr)
	{
		return false;
	}

	UAbilityTask_WaitOverlap* WaitOverlapTask = UAngelscriptAbilityTaskLibrary::WaitForOverlap(AbilityInstance);
	if (!ExpectTaskOwnershipWithoutInstanceName(*this, TEXT("WaitForOverlap"), WaitOverlapTask, AbilityInstance, OwnerASC, AbilityHandle))
	{
		return false;
	}

	TestEqual(TEXT("WaitForOverlap should return the native overlap task class"), WaitOverlapTask->GetClass(), UAbilityTask_WaitOverlap::StaticClass());
	TestFalse(TEXT("WaitForOverlap should not be waiting on avatar before activation"), WaitOverlapTask->IsWaitingOnAvatar());
	TestFalse(TEXT("WaitForOverlap should not bind the avatar hit callback before activation"), AvatarPrimitive->OnComponentHit.IsAlreadyBound(WaitOverlapTask, &UAbilityTask_WaitOverlap::OnHitCallback));

	UAngelscriptGASTestTargetDataListener* OverlapListener =
		NewObject<UAngelscriptGASTestTargetDataListener>(OwnerActor, TEXT("OverlapTargetDataListener"));
	if (!TestNotNull(TEXT("WaitForOverlap should create a target-data listener"), OverlapListener))
	{
		return false;
	}

	WaitOverlapTask->OnOverlap.AddDynamic(OverlapListener, &UAngelscriptGASTestTargetDataListener::RecordTargetData);
	WaitOverlapTask->ReadyForActivation();

	TestTrue(TEXT("WaitForOverlap should enter the waiting-on-avatar state after activation"), WaitOverlapTask->IsWaitingOnAvatar());
	TestTrue(TEXT("WaitForOverlap should bind the avatar hit callback after activation"), AvatarPrimitive->OnComponentHit.IsAlreadyBound(WaitOverlapTask, &UAbilityTask_WaitOverlap::OnHitCallback));

	const FHitResult OverlapHit = MakeOverlapHit(*OverlapTargetActor, *TargetPrimitive);
	AvatarPrimitive->OnComponentHit.Broadcast(AvatarPrimitive, OverlapTargetActor, TargetPrimitive, FVector::ZeroVector, OverlapHit);

	TestEqual(TEXT("WaitForOverlap should broadcast exactly once on the first hit"), OverlapListener->CallbackCount, 1);
	TestEqual(TEXT("WaitForOverlap should capture exactly one target-data entry"), OverlapListener->LastTargetData.Num(), 1);

	const FGameplayAbilityTargetData_SingleTargetHit* SingleTargetHit =
		static_cast<const FGameplayAbilityTargetData_SingleTargetHit*>(OverlapListener->LastTargetData.Get(0));
	if (!TestNotNull(TEXT("WaitForOverlap should package the hit as FGameplayAbilityTargetData_SingleTargetHit"), SingleTargetHit))
	{
		return false;
	}

	if (!TestNotNull(TEXT("WaitForOverlap should keep a hit result payload"), SingleTargetHit->GetHitResult()))
	{
		return false;
	}

	TestTrue(TEXT("WaitForOverlap should report the overlapped actor in the hit target data"), SingleTargetHit->GetHitResult()->GetActor() == OverlapTargetActor);
	TestTrue(TEXT("WaitForOverlap should finish itself after the first overlap"), WaitOverlapTask->IsFinished());
	TestFalse(TEXT("WaitForOverlap should remove the avatar hit callback after finishing"), AvatarPrimitive->OnComponentHit.IsAlreadyBound(WaitOverlapTask, &UAbilityTask_WaitOverlap::OnHitCallback));

	AvatarPrimitive->OnComponentHit.Broadcast(AvatarPrimitive, OverlapTargetActor, TargetPrimitive, FVector::ZeroVector, OverlapHit);
	TestEqual(TEXT("WaitForOverlap should ignore later hits after the task has finished"), OverlapListener->CallbackCount, 1);

	ASTEST_END_SHARE_CLEAN
	return true;
}

#endif
