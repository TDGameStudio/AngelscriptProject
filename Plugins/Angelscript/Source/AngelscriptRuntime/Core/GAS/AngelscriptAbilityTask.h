#pragma once

#include "CoreMinimal.h"

#include "Abilities/Tasks/AbilityTask.h"

#include "AngelscriptAbilityTask.generated.h"

UCLASS()
class ANGELSCRIPTRUNTIME_API UAngelscriptAbilityTask : public UAbilityTask
{
	GENERATED_BODY()

public:
	UFUNCTION(BlueprintPure, Category = "Ability Task")
	bool GetIsTickingTask();
	UFUNCTION(BlueprintCallable, Category = "Ability Task")
	void SetIsTickingTask(bool bNewState);

	UFUNCTION(BlueprintPure, Category = "Ability Task")
	bool GetIsPausable();
	UFUNCTION(BlueprintCallable, Category = "Ability Task")
	void SetIsPausable(bool bNewState);

	UFUNCTION(BlueprintPure, Category = "Ability Task")
	bool GetIsSimulatedTask();
	UFUNCTION(BlueprintCallable, Category = "Ability Task")
	void SetIsSimulatedTask(bool bNewState);

	UFUNCTION(BlueprintPure, Category = "Ability Task")
	bool GetIsSimulating();

	UFUNCTION(BlueprintImplementableEvent, Category = "Ability Task Callbacks")
	void BP_Activate();

	UFUNCTION(BlueprintImplementableEvent, Category = "Ability Task Callbacks")
	void BP_TickTask(float DeltaTimeSecs);

	UFUNCTION(BlueprintImplementableEvent, Category = "Ability Task Callbacks")
	void BP_OnDestroy(bool bInOwnerFinished);

	UFUNCTION(BlueprintImplementableEvent, Category = "Ability Task Callbacks")
	void BP_InitSimulatedTask(UGameplayTasksComponent* InGameplayTasksComponent);

	UFUNCTION(BlueprintNativeEvent, Category = "Ability Task Callbacks")
	bool BP_IsWaitingOnRemotePlayerdata() const;

	UFUNCTION(BlueprintNativeEvent, Category = "Ability Task Callbacks")
	bool BP_IsWaitingOnAvatar() const;

public:
	UFUNCTION(BlueprintCallable, Category = "Ability Task")
	void BP_SetAbilitySystemComponent(UAbilitySystemComponent* InAbilitySystemComponent);
	UFUNCTION(BlueprintPure, Category = "Ability Task")
	UAbilitySystemComponent* BP_GetAbilitySystemComponent();

	UFUNCTION(BlueprintPure, Category = "Ability Task")
	FGameplayAbilitySpecHandle BP_GetAbilitySpecHandle(bool bInOwnerFinished) const;

	UFUNCTION(BlueprintPure, Category = "Ability Task")
	UGameplayAbility* BP_GetAbility(bool bInOwnerFinished) const;

	UFUNCTION(BlueprintPure, Category = "Ability Task")
	bool BP_IsPredictingClient() const;

	UFUNCTION(BlueprintPure, Category = "Ability Task")
	bool BP_IsForRemoteClient() const;

	UFUNCTION(BlueprintPure, Category = "Ability Task")
	bool BP_IsLocallyControlled() const;

	UFUNCTION(BlueprintPure, Category = "Ability Task")
	bool BP_ShouldBroadcastAbilityTaskDelegates() const;

	UFUNCTION(BlueprintCallable, Category = "Ability Task")
	void BP_SetWaitingOnRemotePlayerData();
	UFUNCTION(BlueprintCallable, Category = "Ability Task")
	void BP_ClearWaitingOnRemotePlayerData();

	UFUNCTION(BlueprintCallable, Category = "Ability Task")
	void BP_SetWaitingOnAvatar();
	UFUNCTION(BlueprintCallable, Category = "Ability Task")
	void BP_ClearWaitingOnAvatar();

public:
	// If you create a task using this function from AS, you must start it manually using ReadyForActivation. This is useful if you want to set up properties on the task before you run it.
	UFUNCTION(BlueprintCallable, Category = "Ability Task")
	static UAngelscriptAbilityTask* CreateAbilityTask(TSubclassOf<UAngelscriptAbilityTask> TaskType, UGameplayAbility* ThisAbility, FName NewInstanceName = NAME_None);

	// This method will both create the task and call ReadyForActivation on it for you immediately.
	UFUNCTION(BlueprintCallable, Category = "Ability Task")
	static UAngelscriptAbilityTask* CreateAbilityTaskAndRunIt(TSubclassOf<UAngelscriptAbilityTask> TaskType, UGameplayAbility* ThisAbility, FName NewInstanceName = NAME_None);

public:
	UAngelscriptAbilityTask(const FObjectInitializer& ObjectInitializer);

/************************************************************************/
/* UAbilityTask                                                         */
/************************************************************************/
public:
	virtual void TickTask(float DeltaTime) override;
	virtual void InitSimulatedTask(UGameplayTasksComponent& InGameplayTasksComponent) override;
	virtual bool IsWaitingOnRemotePlayerdata() const override;
	virtual bool IsWaitingOnAvatar() const override;

protected:
	virtual void Activate() override;
	virtual void OnDestroy(bool bInOwnerFinished) override;
};
