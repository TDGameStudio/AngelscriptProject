#pragma once

#include "CoreMinimal.h"
#include "Abilities/GameplayAbilityTypes.h"
#include "GameFramework/Actor.h"
#include "GameplayEffect.h"
#include "GameplayCueNotify_Actor.h"
#include "GameplayCueNotify_Static.h"

#include "../../AngelscriptRuntime/Core/GAS/AngelscriptGASAbility.h"
#include "../../AngelscriptRuntime/Core/GAS/AngelscriptGASPawn.h"
#include "../../AngelscriptRuntime/Core/GAS/AngelscriptAbilityTask.h"
#include "../../AngelscriptRuntime/Core/GAS/AngelscriptAbilitySystemComponent.h"
#include "../../AngelscriptRuntime/Core/GAS/AngelscriptAttributeSet.h"

#include "AngelscriptGASTestTypes.generated.h"

UCLASS()
class ANGELSCRIPTTEST_API UAngelscriptGASTestAttributeSet : public UAngelscriptAttributeSet
{
	GENERATED_BODY()

public:
	UPROPERTY()
	FAngelscriptGameplayAttributeData Health;

	UPROPERTY()
	FAngelscriptGameplayAttributeData MaxHealth;
};

UCLASS()
class ANGELSCRIPTTEST_API UAngelscriptGASTestReplicatedAttributeSet : public UAngelscriptAttributeSet
{
	GENERATED_BODY()

public:
	UPROPERTY(Replicated)
	FAngelscriptGameplayAttributeData Health;

	UPROPERTY(Replicated)
	FAngelscriptGameplayAttributeData Mana;

	virtual void GetLifetimeReplicatedProps(TArray<FLifetimeProperty>& OutLifetimeProps) const override;
};

UCLASS()
class ANGELSCRIPTTEST_API UAngelscriptGASTestAttributeSetListener : public UObject
{
	GENERATED_BODY()

public:
	UPROPERTY()
	int32 ReplayCount = 0;

	UPROPERTY()
	TObjectPtr<UAngelscriptAttributeSet> LastRegisteredAttributeSet = nullptr;

	UFUNCTION()
	void RecordAttributeSet(UAngelscriptAttributeSet* NewAttributeSet);
};

UCLASS()
class ANGELSCRIPTTEST_API UAngelscriptGASTestAttributeChangedListener : public UObject
{
	GENERATED_BODY()

public:
	UPROPERTY()
	int32 CallbackCount = 0;

	FAngelscriptAttributeChangedData LastAttributeChangeData;

	UPROPERTY()
	FName LastAttributeName = NAME_None;

	UPROPERTY()
	float LastOldValue = 0.f;

	UPROPERTY()
	float LastNewValue = 0.f;

	UFUNCTION()
	void RecordAttributeChanged(const FAngelscriptAttributeChangedData& AttributeChangeData);
};

UCLASS()
class ANGELSCRIPTTEST_API UAngelscriptGASTestModifiedAttributeListener : public UObject
{
	GENERATED_BODY()

public:
	UPROPERTY()
	int32 BroadcastCount = 0;

	UPROPERTY()
	FName LastAttributeName = NAME_None;

	UPROPERTY()
	float LastOldValue = 0.f;

	UPROPERTY()
	float LastNewValue = 0.f;

	UFUNCTION()
	void RecordModifiedAttribute(const FAngelscriptModifiedAttribute& AttributeChangeData);
};

UCLASS()
class ANGELSCRIPTTEST_API UAngelscriptGASTestAbility : public UGameplayAbility
{
	GENERATED_BODY()

public:
	UAngelscriptGASTestAbility();

	UPROPERTY()
	int32 ActivationCount = 0;

	UPROPERTY()
	int32 EndCount = 0;

protected:
	virtual void ActivateAbility(
		const FGameplayAbilitySpecHandle Handle,
		const FGameplayAbilityActorInfo* ActorInfo,
		const FGameplayAbilityActivationInfo ActivationInfo,
		const FGameplayEventData* TriggerEventData) override;

	virtual void EndAbility(
		const FGameplayAbilitySpecHandle Handle,
		const FGameplayAbilityActorInfo* ActorInfo,
		const FGameplayAbilityActivationInfo ActivationInfo,
		bool bReplicateEndAbility,
		bool bWasCancelled) override;
};

UCLASS()
class ANGELSCRIPTTEST_API UAngelscriptGASTestCooldownAbility : public UAngelscriptGASTestAbility
{
	GENERATED_BODY()

public:
	virtual bool CanActivateAbility(
		const FGameplayAbilitySpecHandle Handle,
		const FGameplayAbilityActorInfo* ActorInfo,
		const FGameplayTagContainer* SourceTags = nullptr,
		const FGameplayTagContainer* TargetTags = nullptr,
		FGameplayTagContainer* OptionalRelevantTags = nullptr) const override;

	virtual const FGameplayTagContainer* GetCooldownTags() const override;
};

UCLASS()
class ANGELSCRIPTTEST_API UAngelscriptGASTestPrimaryTagAbility : public UAngelscriptGASTestAbility
{
	GENERATED_BODY()
};

UCLASS()
class ANGELSCRIPTTEST_API UAngelscriptGASTestSecondaryTagAbility : public UAngelscriptGASTestAbility
{
	GENERATED_BODY()
};

UCLASS()
class ANGELSCRIPTTEST_API UAngelscriptGASTestCooldownEffect : public UGameplayEffect
{
	GENERATED_BODY()

public:
	UAngelscriptGASTestCooldownEffect();

	void ConfigureGrantedTags(const FGameplayTagContainer& GrantedTags);
};

UCLASS()
class ANGELSCRIPTTEST_API UAngelscriptGASTestAbilityGivenListener : public UObject
{
	GENERATED_BODY()

public:
	UPROPERTY()
	int32 BroadcastCount = 0;

	UPROPERTY()
	FGameplayAbilitySpecHandle LastHandle;

	UPROPERTY()
	int32 LastLevel = INDEX_NONE;

	UPROPERTY()
	int32 LastInputID = INDEX_NONE;

	UPROPERTY()
	TObjectPtr<UObject> LastSourceObject = nullptr;

	UPROPERTY()
	TSubclassOf<UGameplayAbility> LastAbilityClass = nullptr;

	UFUNCTION()
	void RecordAbilityGiven(const FGameplayAbilitySpec& AbilitySpec);
};

UCLASS()
class ANGELSCRIPTTEST_API UAngelscriptGASTestInitAbilityActorInfoListener : public UObject
{
	GENERATED_BODY()

public:
	int32 BroadcastCount = 0;
	TWeakObjectPtr<AActor> LastOwnerActor;
	TWeakObjectPtr<AActor> LastAvatarActor;

	UFUNCTION()
	void RecordInitAbilityActorInfo(AActor* InOwnerActor, AActor* InAvatarActor);
};

UCLASS()
class ANGELSCRIPTTEST_API UAngelscriptGASTestOwnedTagListener : public UObject
{
	GENERATED_BODY()

public:
	int32 BroadcastCount = 0;
	TArray<FGameplayTag> RecordedTags;
	TArray<bool> RecordedTagExistsStates;

	UFUNCTION()
	void RecordOwnedTagUpdated(const FGameplayTag& Tag, bool bTagExists);
};

UCLASS()
class ANGELSCRIPTTEST_API UAngelscriptGASTestSourceObject : public UObject
{
	GENERATED_BODY()
};

UCLASS()
class ANGELSCRIPTTEST_API UAngelscriptGASTestAsyncListener : public UObject
{
	GENERATED_BODY()

public:
	UPROPERTY()
	int32 TriggerCount = 0;

	UFUNCTION()
	void HandleTriggered();
};

UCLASS()
class ANGELSCRIPTTEST_API UAngelscriptGASTestAbilityCallbackListener : public UObject
{
	GENERATED_BODY()

public:
	UPROPERTY()
	int32 CallbackCount = 0;

	UPROPERTY()
	TObjectPtr<UGameplayAbility> LastAbility = nullptr;

	UFUNCTION()
	void RecordAbility(UGameplayAbility* ActivatedAbility);
};

UCLASS()
class ANGELSCRIPTTEST_API UAngelscriptGASTestAsyncAttributeListener : public UObject
{
	GENERATED_BODY()

public:
	UPROPERTY()
	int32 CallbackCount = 0;

	UPROPERTY()
	FName LastAttributeName = NAME_None;

	UPROPERTY()
	float LastNewValue = 0.f;

	UPROPERTY()
	float LastOldValue = 0.f;

	UFUNCTION()
	void RecordAttributeChanged(FGameplayAttribute Attribute, float NewValue, float OldValue);
};

UCLASS()
class ANGELSCRIPTTEST_API UAngelscriptGASTestGameplayEventListener : public UObject
{
	GENERATED_BODY()

public:
	UPROPERTY()
	int32 TriggerCount = 0;

	UPROPERTY()
	FGameplayTag LastEventTag;

	UPROPERTY()
	float LastEventMagnitude = 0.f;

	UFUNCTION()
	void RecordGameplayEvent(FGameplayEventData Payload);
};

UCLASS()
class ANGELSCRIPTTEST_API UAngelscriptGASTestGameplayEffectRemovedListener : public UObject
{
	GENERATED_BODY()

public:
	UPROPERTY()
	int32 CallbackCount = 0;

	UPROPERTY()
	bool bLastPrematureRemoval = false;

	UPROPERTY()
	int32 LastStackCount = 0;

	UFUNCTION()
	void RecordRemoved(const FGameplayEffectRemovalInfo& RemovalInfo);
};

UCLASS()
class ANGELSCRIPTTEST_API UAngelscriptGASTestGameplayEffectStackChangeListener : public UObject
{
	GENERATED_BODY()

public:
	UPROPERTY()
	int32 CallbackCount = 0;

	UPROPERTY()
	FActiveGameplayEffectHandle LastHandle;

	UPROPERTY()
	int32 LastNewCount = INDEX_NONE;

	UPROPERTY()
	int32 LastOldCount = INDEX_NONE;

	UFUNCTION()
	void RecordStackChange(FActiveGameplayEffectHandle Handle, int32 NewCount, int32 OldCount);
};

UCLASS()
class ANGELSCRIPTTEST_API UAngelscriptGASTestAttributeThresholdListener : public UObject
{
	GENERATED_BODY()

public:
	UPROPERTY()
	int32 CallbackCount = 0;

	UPROPERTY()
	bool bLastMatchesComparison = false;

	UPROPERTY()
	float LastValue = 0.f;

	UFUNCTION()
	void RecordThresholdChange(bool bMatchesComparison, float CurrentValue);
};

UCLASS()
class ANGELSCRIPTTEST_API UAngelscriptGASTestAttributeRatioListener : public UObject
{
	GENERATED_BODY()

public:
	UPROPERTY()
	int32 CallbackCount = 0;

	UPROPERTY()
	bool bLastMatchesComparison = false;

	UPROPERTY()
	float LastRatio = 0.f;

	UFUNCTION()
	void RecordRatioChange(bool bMatchesComparison, float CurrentRatio);
};

UCLASS()
class ANGELSCRIPTTEST_API UAngelscriptGASTestSpawnedActorListener : public UObject
{
	GENERATED_BODY()

public:
	UPROPERTY()
	int32 CallbackCount = 0;

	UPROPERTY()
	TWeakObjectPtr<AActor> LastActor;

	UFUNCTION()
	void RecordSpawnedActor(AActor* Actor);
};

UCLASS()
class ANGELSCRIPTTEST_API UAngelscriptGASTestTargetDataListener : public UObject
{
	GENERATED_BODY()

public:
	UPROPERTY()
	int32 CallbackCount = 0;

	FGameplayAbilityTargetDataHandle LastTargetData;

	UFUNCTION()
	void RecordTargetData(const FGameplayAbilityTargetDataHandle& TargetData);
};

UCLASS()
class ANGELSCRIPTTEST_API UAngelscriptGASTestAbilityTaskRecorder : public UAngelscriptAbilityTask
{
	GENERATED_BODY()

public:
	int32 ActivationCallCount = 0;
	int32 TickCallCount = 0;
	float LastTickDeltaSeconds = 0.f;
	int32 DestroyCallCount = 0;
	bool bLastOwnerFinished = false;

	FName GetRecordedInstanceName() const;
	virtual void TickTask(float DeltaTime) override;

protected:
	virtual void Activate() override;
	virtual void OnDestroy(bool bInOwnerFinished) override;
};

UCLASS()
class ANGELSCRIPTTEST_API UAngelscriptGASTestGameplayCueRecorder : public UGameplayCueNotify_Static
{
	GENERATED_BODY()

public:
	mutable TArray<uint8> RecordedEventTypes;

	mutable TArray<float> RecordedRawMagnitudes;

	mutable TArray<TWeakObjectPtr<AActor>> RecordedTargets;

	mutable TArray<TWeakObjectPtr<AActor>> RecordedInstigators;

	virtual bool OnExecute_Implementation(AActor* MyTarget, const FGameplayCueParameters& Parameters) const override;

	virtual bool OnActive_Implementation(AActor* MyTarget, const FGameplayCueParameters& Parameters) const override;

	virtual bool WhileActive_Implementation(AActor* MyTarget, const FGameplayCueParameters& Parameters) const override;

	virtual bool OnRemove_Implementation(AActor* MyTarget, const FGameplayCueParameters& Parameters) const override;

	void ResetRecords();

private:
	void Record(EGameplayCueEvent::Type EventType, AActor* MyTarget, const FGameplayCueParameters& Parameters) const;
};

UCLASS()
class ANGELSCRIPTTEST_API UAngelscriptGASTestCueForwardingAbility : public UAngelscriptGASAbility
{
	GENERATED_BODY()

public:
	int32 ExecuteCueCallCount = 0;
	int32 ExecuteCueWithParamsCallCount = 0;
	int32 AddCueCallCount = 0;
	int32 AddCueWithParamsCallCount = 0;
	int32 RemoveCueCallCount = 0;

	FGameplayTag LastExecuteCueTag;
	FGameplayTag LastExecuteCueWithParamsTag;
	FGameplayTag LastAddCueTag;
	FGameplayTag LastAddCueWithParamsTag;
	FGameplayTag LastRemoveCueTag;

	FGameplayCueParameters LastExecuteCueWithParams;
	FGameplayCueParameters LastAddCueWithParams;

	bool bLastAddCueRemoveOnAbilityEnd = false;
	bool bLastAddCueWithParamsRemoveOnAbilityEnd = false;

	void ResetCueRecords();

	virtual void K2_ExecuteGameplayCue(FGameplayTag GameplayCueTag, FGameplayEffectContextHandle Context) override;
	virtual void K2_ExecuteGameplayCueWithParams(FGameplayTag GameplayCueTag, const FGameplayCueParameters& GameplayCueParameters) override;
	virtual void K2_AddGameplayCue(FGameplayTag GameplayCueTag, FGameplayEffectContextHandle Context, bool bRemoveOnAbilityEnd = true) override;
	virtual void K2_AddGameplayCueWithParams(FGameplayTag GameplayCueTag, const FGameplayCueParameters& GameplayCueParameter, bool bRemoveOnAbilityEnd = true) override;
	virtual void K2_RemoveGameplayCue(FGameplayTag GameplayCueTag) override;
};

UCLASS()
class ANGELSCRIPTTEST_API AAngelscriptGASTestGameplayCueActorMarker : public AGameplayCueNotify_Actor
{
	GENERATED_BODY()
};

UCLASS()
class ANGELSCRIPTTEST_API UAngelscriptGASTestGameplayCueStaticMarker : public UGameplayCueNotify_Static
{
	GENERATED_BODY()
};

UCLASS()
class ANGELSCRIPTTEST_API AAngelscriptGASTestActor : public AActor
{
	GENERATED_BODY()

public:
	AAngelscriptGASTestActor(const FObjectInitializer& ObjectInitializer = FObjectInitializer::Get());

	UPROPERTY(VisibleAnywhere)
	TObjectPtr<UAngelscriptAbilitySystemComponent> AbilitySystemComponent = nullptr;
};

UCLASS()
class ANGELSCRIPTTEST_API AAngelscriptGASTestPawn : public AAngelscriptGASPawn
{
	GENERATED_BODY()

public:
	AAngelscriptGASTestPawn(const FObjectInitializer& ObjectInitializer = FObjectInitializer::Get());
};
