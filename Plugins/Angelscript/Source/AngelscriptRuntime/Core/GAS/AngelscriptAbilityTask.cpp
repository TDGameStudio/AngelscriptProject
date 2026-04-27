#include "AngelscriptAbilityTask.h"

UAngelscriptAbilityTask::UAngelscriptAbilityTask(const FObjectInitializer& ObjectInitializer)
	: Super(ObjectInitializer)
{
}

bool UAngelscriptAbilityTask::GetIsTickingTask()
{
	return bTickingTask;
}
void UAngelscriptAbilityTask::SetIsTickingTask(bool bNewState)
{
	bTickingTask = bNewState;
}

bool UAngelscriptAbilityTask::GetIsPausable()
{
	return bIsPausable;
}
void UAngelscriptAbilityTask::SetIsPausable(bool bNewState)
{
	bIsPausable = bNewState;
}

bool UAngelscriptAbilityTask::GetIsSimulatedTask()
{
	return bSimulatedTask;
}
void UAngelscriptAbilityTask::SetIsSimulatedTask(bool bNewState)
{
	bSimulatedTask = bNewState;
}

bool UAngelscriptAbilityTask::GetIsSimulating()
{
	return bIsSimulating;
}

void UAngelscriptAbilityTask::Activate()
{
	Super::Activate();
	BP_Activate();
}

void UAngelscriptAbilityTask::TickTask(float DeltaTime)
{
	Super::TickTask(DeltaTime);
	BP_TickTask(DeltaTime);
}

void UAngelscriptAbilityTask::OnDestroy(bool bInOwnerFinished)
{
	BP_OnDestroy(bInOwnerFinished);
	Super::OnDestroy(bInOwnerFinished);
}

void UAngelscriptAbilityTask::InitSimulatedTask(UGameplayTasksComponent& InGameplayTasksComponent)
{
	Super::InitSimulatedTask(InGameplayTasksComponent);
	BP_InitSimulatedTask(&InGameplayTasksComponent);
}

bool UAngelscriptAbilityTask::IsWaitingOnRemotePlayerdata() const
{
	return BP_IsWaitingOnRemotePlayerdata();
}

bool UAngelscriptAbilityTask::IsWaitingOnAvatar() const
{
	return BP_IsWaitingOnAvatar();
}

bool UAngelscriptAbilityTask::BP_IsWaitingOnRemotePlayerdata_Implementation() const
{
	return Super::IsWaitingOnRemotePlayerdata();
}

bool UAngelscriptAbilityTask::BP_IsWaitingOnAvatar_Implementation() const
{
	return Super::IsWaitingOnAvatar();
}

///////////////////////////////////////////////////////////////////////

void UAngelscriptAbilityTask::BP_SetAbilitySystemComponent(UAbilitySystemComponent* InAbilitySystemComponent)
{
	SetAbilitySystemComponent(InAbilitySystemComponent);
}

UAbilitySystemComponent* UAngelscriptAbilityTask::BP_GetAbilitySystemComponent()
{
	return AbilitySystemComponent.Get();
}

FGameplayAbilitySpecHandle UAngelscriptAbilityTask::BP_GetAbilitySpecHandle(bool bInOwnerFinished) const
{
	return GetAbilitySpecHandle();
}

UGameplayAbility* UAngelscriptAbilityTask::BP_GetAbility(bool bInOwnerFinished) const
{
	return Ability;
}

bool UAngelscriptAbilityTask::BP_IsPredictingClient() const
{
	return IsPredictingClient();
}

bool UAngelscriptAbilityTask::BP_IsForRemoteClient() const
{
	return IsForRemoteClient();
}

bool UAngelscriptAbilityTask::BP_IsLocallyControlled() const
{
	return IsLocallyControlled();
}

bool UAngelscriptAbilityTask::BP_ShouldBroadcastAbilityTaskDelegates() const
{
	return ShouldBroadcastAbilityTaskDelegates();
}

void UAngelscriptAbilityTask::BP_SetWaitingOnRemotePlayerData()
{
	SetWaitingOnRemotePlayerData();
}

void UAngelscriptAbilityTask::BP_ClearWaitingOnRemotePlayerData()
{
	ClearWaitingOnRemotePlayerData();
}

void UAngelscriptAbilityTask::BP_SetWaitingOnAvatar()
{
	SetWaitingOnAvatar();
}

void UAngelscriptAbilityTask::BP_ClearWaitingOnAvatar()
{
	ClearWaitingOnAvatar();
}

UAngelscriptAbilityTask* UAngelscriptAbilityTask::CreateAbilityTask(TSubclassOf<UAngelscriptAbilityTask> TaskType, UGameplayAbility* ThisAbility, FName NewInstanceName)
{
	ensureMsgf(TaskType.Get(), TEXT("Must use valid task type!"));
	ensureMsgf(ThisAbility, TEXT("Must have source ability!"));

	UAngelscriptAbilityTask* NewTask = NewObject<UAngelscriptAbilityTask>(GetTransientPackage(), TaskType.Get());
	ensureMsgf(NewTask, TEXT("Could not create task!"));

	NewTask->InitTask(*ThisAbility, ThisAbility->GetGameplayTaskDefaultPriority());
	NewTask->InstanceName = NewInstanceName;
	return NewTask;
}

UAngelscriptAbilityTask* UAngelscriptAbilityTask::CreateAbilityTaskAndRunIt(TSubclassOf<UAngelscriptAbilityTask> TaskType, UGameplayAbility* ThisAbility, FName NewInstanceName)
{
	UAngelscriptAbilityTask* NewTask = CreateAbilityTask(TaskType, ThisAbility, NewInstanceName);
	if (NewTask)
	{
		NewTask->ReadyForActivation();
	}

	return NewTask;
}
