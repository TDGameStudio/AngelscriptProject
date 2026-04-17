#include "AngelscriptGASTestTypes.h"

#include "GameplayEffectComponents/TargetTagsGameplayEffectComponent.h"
#include "GameplayTagsManager.h"

namespace AngelscriptTest_Core_AngelscriptGASTestTypes_Private
{
	FGameplayTag FindAngelscriptGASTestCooldownTag()
	{
		FGameplayTagContainer AllTags;
		UGameplayTagsManager::Get().RequestAllGameplayTags(AllTags, false);

		TArray<FGameplayTag> TagArray;
		AllTags.GetGameplayTagArray(TagArray);

		for (const FGameplayTag& CandidateTag : TagArray)
		{
			if (CandidateTag.IsValid())
			{
				return CandidateTag;
			}
		}

		return FGameplayTag();
	}

	const FGameplayTagContainer& GetAngelscriptGASTestCooldownTags()
	{
		static FGameplayTagContainer CooldownTags;
		if (CooldownTags.Num() == 0)
		{
			const FGameplayTag CooldownTag = FindAngelscriptGASTestCooldownTag();
			if (CooldownTag.IsValid())
			{
				CooldownTags.AddTag(CooldownTag);
			}
		}

		return CooldownTags;
	}
}

using namespace AngelscriptTest_Core_AngelscriptGASTestTypes_Private;

void UAngelscriptGASTestAttributeSetListener::RecordAttributeSet(UAngelscriptAttributeSet* NewAttributeSet)
{
	++ReplayCount;
	LastRegisteredAttributeSet = NewAttributeSet;
}

void UAngelscriptGASTestAttributeChangedListener::RecordAttributeChanged(
	const FAngelscriptAttributeChangedData& AttributeChangeData)
{
	++CallbackCount;
	LastAttributeChangeData = AttributeChangeData;
	LastAttributeName = FName(*AttributeChangeData.WrappedData.Attribute.AttributeName);
	LastOldValue = AttributeChangeData.WrappedData.OldValue;
	LastNewValue = AttributeChangeData.WrappedData.NewValue;
}

void UAngelscriptGASTestModifiedAttributeListener::RecordModifiedAttribute(
	const FAngelscriptModifiedAttribute& AttributeChangeData)
{
	++BroadcastCount;
	LastAttributeName = AttributeChangeData.Name;
	LastOldValue = AttributeChangeData.OldValue;
	LastNewValue = AttributeChangeData.NewValue;
}

void UAngelscriptGASTestReplicatedAttributeSet::GetLifetimeReplicatedProps(TArray<FLifetimeProperty>& OutLifetimeProps) const
{
	Super::GetLifetimeReplicatedProps(OutLifetimeProps);
}

UAngelscriptGASTestAbility::UAngelscriptGASTestAbility()
{
	InstancingPolicy = EGameplayAbilityInstancingPolicy::InstancedPerActor;
}

void UAngelscriptGASTestAbility::ActivateAbility(
	const FGameplayAbilitySpecHandle Handle,
	const FGameplayAbilityActorInfo* ActorInfo,
	const FGameplayAbilityActivationInfo ActivationInfo,
	const FGameplayEventData* TriggerEventData)
{
	++ActivationCount;
}

void UAngelscriptGASTestAbility::EndAbility(
	const FGameplayAbilitySpecHandle Handle,
	const FGameplayAbilityActorInfo* ActorInfo,
	const FGameplayAbilityActivationInfo ActivationInfo,
	bool bReplicateEndAbility,
	bool bWasCancelled)
{
	++EndCount;
	Super::EndAbility(Handle, ActorInfo, ActivationInfo, bReplicateEndAbility, bWasCancelled);
}

bool UAngelscriptGASTestCooldownAbility::CanActivateAbility(
	const FGameplayAbilitySpecHandle Handle,
	const FGameplayAbilityActorInfo* ActorInfo,
	const FGameplayTagContainer* SourceTags,
	const FGameplayTagContainer* TargetTags,
	FGameplayTagContainer* OptionalRelevantTags) const
{
	return true;
}

const FGameplayTagContainer* UAngelscriptGASTestCooldownAbility::GetCooldownTags() const
{
	return &GetAngelscriptGASTestCooldownTags();
}

UAngelscriptGASTestCooldownEffect::UAngelscriptGASTestCooldownEffect()
{
	DurationPolicy = EGameplayEffectDurationType::HasDuration;
	DurationMagnitude = FGameplayEffectModifierMagnitude(FScalableFloat(1.f));
}

void UAngelscriptGASTestCooldownEffect::ConfigureGrantedTags(const FGameplayTagContainer& InGrantedTags)
{
	FInheritedTagContainer GrantedTagContainer;
	for (const FGameplayTag& GrantedTag : InGrantedTags)
	{
		GrantedTagContainer.AddTag(GrantedTag);
	}

	FindOrAddComponent<UTargetTagsGameplayEffectComponent>().SetAndApplyTargetTagChanges(GrantedTagContainer);
}

void UAngelscriptGASTestAbilityGivenListener::RecordAbilityGiven(const FGameplayAbilitySpec& AbilitySpec)
{
	++BroadcastCount;
	LastHandle = AbilitySpec.Handle;
	LastLevel = AbilitySpec.Level;
	LastInputID = AbilitySpec.InputID;
	LastSourceObject = AbilitySpec.SourceObject.Get();
	LastAbilityClass = AbilitySpec.Ability != nullptr ? AbilitySpec.Ability->GetClass() : nullptr;
}

void UAngelscriptGASTestInitAbilityActorInfoListener::RecordInitAbilityActorInfo(
	AActor* InOwnerActor,
	AActor* InAvatarActor)
{
	++BroadcastCount;
	LastOwnerActor = InOwnerActor;
	LastAvatarActor = InAvatarActor;
}

void UAngelscriptGASTestOwnedTagListener::RecordOwnedTagUpdated(const FGameplayTag& Tag, bool bTagExists)
{
	++BroadcastCount;
	RecordedTags.Add(Tag);
	RecordedTagExistsStates.Add(bTagExists);
}

void UAngelscriptGASTestAsyncListener::HandleTriggered()
{
	++TriggerCount;
}

void UAngelscriptGASTestAbilityCallbackListener::RecordAbility(UGameplayAbility* ActivatedAbility)
{
	++CallbackCount;
	LastAbility = ActivatedAbility;
}

void UAngelscriptGASTestAsyncAttributeListener::RecordAttributeChanged(
	FGameplayAttribute Attribute,
	float NewValue,
	float OldValue)
{
	++CallbackCount;
	LastAttributeName = FName(*Attribute.GetName());
	LastNewValue = NewValue;
	LastOldValue = OldValue;
}

void UAngelscriptGASTestGameplayEventListener::RecordGameplayEvent(FGameplayEventData Payload)
{
	++TriggerCount;
	LastEventTag = Payload.EventTag;
	LastEventMagnitude = Payload.EventMagnitude;
}

void UAngelscriptGASTestGameplayEffectRemovedListener::RecordRemoved(const FGameplayEffectRemovalInfo& RemovalInfo)
{
	++CallbackCount;
	bLastPrematureRemoval = RemovalInfo.bPrematureRemoval;
	LastStackCount = RemovalInfo.StackCount;
}

void UAngelscriptGASTestGameplayEffectStackChangeListener::RecordStackChange(
	FActiveGameplayEffectHandle Handle,
	int32 NewCount,
	int32 OldCount)
{
	++CallbackCount;
	LastHandle = Handle;
	LastNewCount = NewCount;
	LastOldCount = OldCount;
}

void UAngelscriptGASTestAttributeThresholdListener::RecordThresholdChange(
	bool bMatchesComparison,
	float CurrentValue)
{
	++CallbackCount;
	bLastMatchesComparison = bMatchesComparison;
	LastValue = CurrentValue;
}

void UAngelscriptGASTestAttributeRatioListener::RecordRatioChange(
	bool bMatchesComparison,
	float CurrentRatio)
{
	++CallbackCount;
	bLastMatchesComparison = bMatchesComparison;
	LastRatio = CurrentRatio;
}

void UAngelscriptGASTestSpawnedActorListener::RecordSpawnedActor(AActor* Actor)
{
	++CallbackCount;
	LastActor = Actor;
}

void UAngelscriptGASTestTargetDataListener::RecordTargetData(const FGameplayAbilityTargetDataHandle& TargetData)
{
	++CallbackCount;
	LastTargetData = TargetData;
}

FName UAngelscriptGASTestAbilityTaskRecorder::GetRecordedInstanceName() const
{
	return InstanceName;
}

void UAngelscriptGASTestAbilityTaskRecorder::Activate()
{
	Super::Activate();
	++ActivationCallCount;
}

void UAngelscriptGASTestAbilityTaskRecorder::TickTask(float DeltaTime)
{
	Super::TickTask(DeltaTime);
	++TickCallCount;
	LastTickDeltaSeconds = DeltaTime;
}

void UAngelscriptGASTestAbilityTaskRecorder::OnDestroy(bool bInOwnerFinished)
{
	++DestroyCallCount;
	bLastOwnerFinished = bInOwnerFinished;
	Super::OnDestroy(bInOwnerFinished);
}

void UAngelscriptGASTestGameplayCueRecorder::ResetRecords()
{
	RecordedEventTypes.Reset();
	RecordedRawMagnitudes.Reset();
	RecordedTargets.Reset();
	RecordedInstigators.Reset();
}

void UAngelscriptGASTestGameplayCueRecorder::Record(
	const EGameplayCueEvent::Type EventType,
	AActor* MyTarget,
	const FGameplayCueParameters& Parameters) const
{
	RecordedEventTypes.Add(static_cast<uint8>(EventType));
	RecordedRawMagnitudes.Add(Parameters.RawMagnitude);
	RecordedTargets.Add(MyTarget);
	RecordedInstigators.Add(Parameters.Instigator.Get());
}

bool UAngelscriptGASTestGameplayCueRecorder::OnExecute_Implementation(
	AActor* MyTarget,
	const FGameplayCueParameters& Parameters) const
{
	Record(EGameplayCueEvent::Executed, MyTarget, Parameters);
	return true;
}

bool UAngelscriptGASTestGameplayCueRecorder::OnActive_Implementation(
	AActor* MyTarget,
	const FGameplayCueParameters& Parameters) const
{
	Record(EGameplayCueEvent::OnActive, MyTarget, Parameters);
	return true;
}

bool UAngelscriptGASTestGameplayCueRecorder::WhileActive_Implementation(
	AActor* MyTarget,
	const FGameplayCueParameters& Parameters) const
{
	Record(EGameplayCueEvent::WhileActive, MyTarget, Parameters);
	return true;
}

bool UAngelscriptGASTestGameplayCueRecorder::OnRemove_Implementation(
	AActor* MyTarget,
	const FGameplayCueParameters& Parameters) const
{
	Record(EGameplayCueEvent::Removed, MyTarget, Parameters);
	return true;
}

void UAngelscriptGASTestCueForwardingAbility::ResetCueRecords()
{
	ExecuteCueCallCount = 0;
	ExecuteCueWithParamsCallCount = 0;
	AddCueCallCount = 0;
	AddCueWithParamsCallCount = 0;
	RemoveCueCallCount = 0;

	LastExecuteCueTag = FGameplayTag();
	LastExecuteCueWithParamsTag = FGameplayTag();
	LastAddCueTag = FGameplayTag();
	LastAddCueWithParamsTag = FGameplayTag();
	LastRemoveCueTag = FGameplayTag();

	LastExecuteCueWithParams = FGameplayCueParameters();
	LastAddCueWithParams = FGameplayCueParameters();

	bLastAddCueRemoveOnAbilityEnd = false;
	bLastAddCueWithParamsRemoveOnAbilityEnd = false;
}

void UAngelscriptGASTestCueForwardingAbility::K2_ExecuteGameplayCue(
	FGameplayTag GameplayCueTag,
	FGameplayEffectContextHandle Context)
{
	++ExecuteCueCallCount;
	LastExecuteCueTag = GameplayCueTag;
}

void UAngelscriptGASTestCueForwardingAbility::K2_ExecuteGameplayCueWithParams(
	FGameplayTag GameplayCueTag,
	const FGameplayCueParameters& GameplayCueParameters)
{
	++ExecuteCueWithParamsCallCount;
	LastExecuteCueWithParamsTag = GameplayCueTag;
	LastExecuteCueWithParams = GameplayCueParameters;
}

void UAngelscriptGASTestCueForwardingAbility::K2_AddGameplayCue(
	FGameplayTag GameplayCueTag,
	FGameplayEffectContextHandle Context,
	bool bRemoveOnAbilityEnd)
{
	++AddCueCallCount;
	LastAddCueTag = GameplayCueTag;
	bLastAddCueRemoveOnAbilityEnd = bRemoveOnAbilityEnd;
}

void UAngelscriptGASTestCueForwardingAbility::K2_AddGameplayCueWithParams(
	FGameplayTag GameplayCueTag,
	const FGameplayCueParameters& GameplayCueParameter,
	bool bRemoveOnAbilityEnd)
{
	++AddCueWithParamsCallCount;
	LastAddCueWithParamsTag = GameplayCueTag;
	LastAddCueWithParams = GameplayCueParameter;
	bLastAddCueWithParamsRemoveOnAbilityEnd = bRemoveOnAbilityEnd;
}

void UAngelscriptGASTestCueForwardingAbility::K2_RemoveGameplayCue(FGameplayTag GameplayCueTag)
{
	++RemoveCueCallCount;
	LastRemoveCueTag = GameplayCueTag;
}

AAngelscriptGASTestActor::AAngelscriptGASTestActor(const FObjectInitializer& ObjectInitializer)
	: Super(ObjectInitializer)
{
	AbilitySystemComponent = CreateDefaultSubobject<UAngelscriptAbilitySystemComponent>(TEXT("AbilitySystemComponent"));
}

AAngelscriptGASTestPawn::AAngelscriptGASTestPawn(const FObjectInitializer& ObjectInitializer)
	: Super(ObjectInitializer)
{
}
