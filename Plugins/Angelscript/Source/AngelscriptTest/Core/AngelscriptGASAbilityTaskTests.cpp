#include "AngelscriptGASTestTypes.h"
#include "Shared/AngelscriptTestUtilities.h"

#include "Components/ActorTestSpawner.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace AngelscriptTest_Core_AngelscriptGASAbilityTaskTests_Private
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
}

using namespace AngelscriptTest_Core_AngelscriptGASAbilityTaskTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptGASAbilityTaskLifecycleTest,
	"Angelscript.TestModule.Engine.GAS.AbilityTask.CreateAndRunTaskInitializesLifecycle",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptGASAbilityTaskLifecycleTest::RunTest(const FString& Parameters)
{
	FAngelscriptTestFixture Fixture(*this, ETestEngineMode::IsolatedFull);
	if (!TestTrue(TEXT("GAS AbilityTask lifecycle test should acquire an isolated full engine"), Fixture.IsValid()))
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();

	AAngelscriptGASTestActor* TestActor = &Spawner.SpawnActor<AAngelscriptGASTestActor>();
	if (!TestNotNull(TEXT("GAS AbilityTask lifecycle test actor should spawn"), TestActor))
	{
		return false;
	}

	UAngelscriptAbilitySystemComponent* AbilitySystemComponent = TestActor->AbilitySystemComponent;
	if (!TestNotNull(TEXT("GAS AbilityTask lifecycle test actor should expose an ability-system component"), AbilitySystemComponent))
	{
		return false;
	}

	AbilitySystemComponent->InitAbilityActorInfo(TestActor, TestActor);

	const FGameplayAbilitySpecHandle AbilityHandle =
		AbilitySystemComponent->BP_GiveAbility(UAngelscriptGASTestAbility::StaticClass(), 1, 0, nullptr);
	if (!TestTrue(TEXT("GAS AbilityTask lifecycle test should grant a valid ability handle"), AbilityHandle.IsValid()))
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

	if (!TestTrue(
		TEXT("GAS AbilityTask lifecycle test should activate the granted ability"),
		AbilitySystemComponent->TryActivateAbilitySpec(AbilityHandle)))
	{
		return false;
	}

	UAngelscriptGASTestAbility* AbilityInstance =
		GetPrimaryTestAbilityInstance(*AbilitySystemComponent, AbilityHandle);
	if (!TestNotNull(TEXT("GAS AbilityTask lifecycle test should resolve the primary ability instance"), AbilityInstance))
	{
		return false;
	}

	UAngelscriptGASTestAbilityTaskRecorder* ManualTask =
		Cast<UAngelscriptGASTestAbilityTaskRecorder>(UAngelscriptAbilityTask::CreateAbilityTask(
			UAngelscriptGASTestAbilityTaskRecorder::StaticClass(),
			AbilityInstance,
			TEXT("ManualLifecycleTask")));
	if (!TestNotNull(TEXT("CreateAbilityTask should create the requested task subclass"), ManualTask))
	{
		return false;
	}

	TestTrue(
		TEXT("CreateAbilityTask should bind the task to the originating ability"),
		ManualTask->BP_GetAbility(false) == AbilityInstance);
	TestTrue(
		TEXT("CreateAbilityTask should bind the task to the originating ASC"),
		ManualTask->BP_GetAbilitySystemComponent() == AbilitySystemComponent);
	TestTrue(
		TEXT("CreateAbilityTask should preserve the originating ability spec handle"),
		ManualTask->BP_GetAbilitySpecHandle(false) == AbilityHandle);
	TestEqual(
		TEXT("CreateAbilityTask should preserve the provided instance name"),
		ManualTask->GetRecordedInstanceName(),
		FName(TEXT("ManualLifecycleTask")));
	TestEqual(
		TEXT("CreateAbilityTask should not activate the task before ReadyForActivation"),
		ManualTask->ActivationCallCount,
		0);

	ManualTask->SetIsTickingTask(true);
	ManualTask->SetIsPausable(true);
	ManualTask->SetIsSimulatedTask(true);
	TestTrue(
		TEXT("SetIsTickingTask should round-trip through GetIsTickingTask"),
		ManualTask->GetIsTickingTask());
	TestTrue(
		TEXT("SetIsPausable should round-trip through GetIsPausable"),
		ManualTask->GetIsPausable());
	TestTrue(
		TEXT("SetIsSimulatedTask should round-trip through GetIsSimulatedTask"),
		ManualTask->GetIsSimulatedTask());
	TestFalse(
		TEXT("GetIsSimulating should stay false before simulated task initialization"),
		ManualTask->GetIsSimulating());

	ManualTask->ReadyForActivation();
	TestEqual(
		TEXT("ReadyForActivation should activate a task created via CreateAbilityTask exactly once"),
		ManualTask->ActivationCallCount,
		1);

	ManualTask->TickTask(0.25f);
	TestEqual(
		TEXT("TickTask should record exactly one manual tick"),
		ManualTask->TickCallCount,
		1);
	TestTrue(
		TEXT("TickTask should preserve the forwarded delta time"),
		FMath::IsNearlyEqual(ManualTask->LastTickDeltaSeconds, 0.25f));

	ManualTask->EndTask();
	TestEqual(
		TEXT("EndTask should destroy the manually created task exactly once"),
		ManualTask->DestroyCallCount,
		1);
	TestFalse(
		TEXT("EndTask should forward bInOwnerFinished=false to OnDestroy"),
		ManualTask->bLastOwnerFinished);

	UAngelscriptGASTestAbilityTaskRecorder* ImmediateTask =
		Cast<UAngelscriptGASTestAbilityTaskRecorder>(UAngelscriptAbilityTask::CreateAbilityTaskAndRunIt(
			UAngelscriptGASTestAbilityTaskRecorder::StaticClass(),
			AbilityInstance,
			TEXT("ImmediateLifecycleTask")));
	if (!TestNotNull(TEXT("CreateAbilityTaskAndRunIt should create the requested task subclass"), ImmediateTask))
	{
		return false;
	}

	TestTrue(
		TEXT("CreateAbilityTaskAndRunIt should bind the immediate task to the originating ability"),
		ImmediateTask->BP_GetAbility(false) == AbilityInstance);
	TestTrue(
		TEXT("CreateAbilityTaskAndRunIt should preserve the originating ability spec handle"),
		ImmediateTask->BP_GetAbilitySpecHandle(false) == AbilityHandle);
	TestEqual(
		TEXT("CreateAbilityTaskAndRunIt should preserve the provided instance name"),
		ImmediateTask->GetRecordedInstanceName(),
		FName(TEXT("ImmediateLifecycleTask")));
	TestEqual(
		TEXT("CreateAbilityTaskAndRunIt should activate the task immediately"),
		ImmediateTask->ActivationCallCount,
		1);
	TestEqual(
		TEXT("CreateAbilityTaskAndRunIt should not tick before TickTask is invoked"),
		ImmediateTask->TickCallCount,
		0);

	ImmediateTask->EndTask();
	TestEqual(
		TEXT("EndTask should destroy the immediate task exactly once"),
		ImmediateTask->DestroyCallCount,
		1);
	TestFalse(
		TEXT("Immediate task destruction should also forward bInOwnerFinished=false"),
		ImmediateTask->bLastOwnerFinished);

	return true;
}

#endif
