#include "AngelscriptAbilitySystemComponent.h"
#include "AbilitySystemGlobals.h"
#include "AbilitySystemLog.h"
#include "GameplayCueManager.h"

UAngelscriptAbilitySystemComponent::UAngelscriptAbilitySystemComponent()
{
	ActiveGameplayEffects.OnActiveGameplayEffectRemovedDelegate.AddUObject(this, &UAngelscriptAbilitySystemComponent::OnGameplayEffectEnded);
}

void UAngelscriptAbilitySystemComponent::OnGameplayEffectEnded(const FActiveGameplayEffect& EndedGameplayEffect)
{
}

void UAngelscriptAbilitySystemComponent::OnAttributeChangedTrampoline(const FOnAttributeChangeData& AttributeChangeData)
{
	if (OnAttributeChanged.IsBound())
	{
		OnAttributeChanged.Broadcast(FAngelscriptModifiedAttribute(FName(*AttributeChangeData.Attribute.AttributeName), AttributeChangeData.OldValue, AttributeChangeData.NewValue));
	}
}

struct FOnAttributeSetRegisteredDynArgs
{
	UAngelscriptAttributeSet* AngelscriptAttributeSet;
};
void UAngelscriptAbilitySystemComponent::OnAttributeSetRegistered(UObject* InObject, FName InFunctionName)
{
	if (InObject == nullptr)
	{
		UE_LOG(LogTemp, Error, TEXT("Null object passed to AddUFunction."));
		return;
	}

	UFunction* CallFunction = InObject->FindFunction(InFunctionName);
	if (CallFunction == nullptr)
	{
		UE_LOG(LogTemp, Error, TEXT("Could not find function in object with this name. Is it declared UFUNCTION()?"));
		return;
	}

	FScriptDelegate InnerDelegate;
	InnerDelegate.BindUFunction(InObject, InFunctionName);

	OnAttributeSetRegisteredDelegate.AddUnique(InnerDelegate);

	if (InnerDelegate.IsBound())
	{
		// We already have registered sets, so we need to call this right away to notify this registration!
		for (UAttributeSet* AttributeSet : GetSpawnedAttributes())
		{
			UAngelscriptAttributeSet* AngelscriptAttributeSet = Cast<UAngelscriptAttributeSet>(AttributeSet);
			if (AngelscriptAttributeSet)
			{
				FOnAttributeSetRegisteredDynArgs Args;
				Args.AngelscriptAttributeSet = AngelscriptAttributeSet;
				InObject->ProcessEvent(CallFunction, &Args);
			}
		}
	}
}

UAngelscriptAttributeSet* UAngelscriptAbilitySystemComponent::RegisterAttributeSet(TSubclassOf<UAngelscriptAttributeSet> AttributeSetClass)
{
	for (UAttributeSet* AttributeSet : GetSpawnedAttributes())
	{
		if (AttributeSet->IsA(AttributeSetClass))
		{
			// Already had one.
			return (UAngelscriptAttributeSet*)AttributeSet;
		}
	}

	UAngelscriptAttributeSet* NewAttributeSetSubObject = NewObject<UAngelscriptAttributeSet>(GetOwner(), AttributeSetClass);
	if (NewAttributeSetSubObject)
	{
		AddSpawnedAttribute(NewAttributeSetSubObject);
	}
	
	OnAttributeSetRegisteredDelegate.Broadcast(NewAttributeSetSubObject);

	return NewAttributeSetSubObject;
}

void UAngelscriptAbilitySystemComponent::RegisterAttributeChangedCallback(TSubclassOf<UAngelscriptAttributeSet> AttributeSetClass, FName AttributeName, UObject* CallbackObject, FName CallbackFunctionName_FAngelscriptAttributeChangedData)
{
	const FGameplayAttribute Attribute = UAngelscriptAttributeSet::GetGameplayAttribute(AttributeSetClass, AttributeName);
	if (ensureMsgf(Attribute.IsValid(), TEXT("Must provide valid attribute data"))
		&& ensureMsgf(CallbackObject, TEXT("Must provide valid callback object"))
		&& ensureMsgf(CallbackFunctionName_FAngelscriptAttributeChangedData != NAME_None, TEXT("Must provide valid callback method name")))
	{
		FOnGameplayAttributeValueChange& AttributeChangeDelegate = ActiveGameplayEffects.GetGameplayAttributeValueChangeDelegate(Attribute);
		if (!AttributeChangeDelegate.IsBoundToObject(CallbackObject))
		{
			AttributeChangeDelegate.AddUFunction(CallbackObject, CallbackFunctionName_FAngelscriptAttributeChangedData);
		}
	}
}

void UAngelscriptAbilitySystemComponent::GetAndRegisterAttributeChangedCallback(TSubclassOf<UAngelscriptAttributeSet> AttributeSetClass, FName AttributeName, UObject* CallbackObject, FName CallbackFunctionName_FAngelscriptAttributeChangedData, float& OutCurrentValue)
{
	const FGameplayAttribute Attribute = UAngelscriptAttributeSet::GetGameplayAttribute(AttributeSetClass, AttributeName);
	if (ensureMsgf(Attribute.IsValid(), TEXT("Must provide valid attribute data"))
		&& ensureMsgf(CallbackObject, TEXT("Must provide valid callback object"))
		&& ensureMsgf(CallbackFunctionName_FAngelscriptAttributeChangedData != NAME_None, TEXT("Must provide valid callback method name")))
	{
		FOnGameplayAttributeValueChange& AttributeChangeDelegate = ActiveGameplayEffects.GetGameplayAttributeValueChangeDelegate(Attribute);
		if (!AttributeChangeDelegate.IsBoundToObject(CallbackObject))
		{
			AttributeChangeDelegate.AddUFunction(CallbackObject, CallbackFunctionName_FAngelscriptAttributeChangedData);
		}
		OutCurrentValue = GetNumericAttribute(Attribute);
	}
}

void UAngelscriptAbilitySystemComponent::RegisterCallbackForAttribute(TSubclassOf<UAngelscriptAttributeSet> AttributeSetClass, FName AttributeName)
{
	FGameplayAttribute Attribute = UAngelscriptAttributeSet::GetGameplayAttribute(AttributeSetClass, AttributeName);
	FOnGameplayAttributeValueChange& AttributeChangeDelegate = ActiveGameplayEffects.GetGameplayAttributeValueChangeDelegate(Attribute);

	// Make sure we haven't already bound this object to listen to changes for the specified attribute
	// Note that this assumes that the 'this' is only used to bind to the OnAttributeChangedTrampoline function
	if (!AttributeChangeDelegate.IsBoundToObject(this))
	{
		AttributeChangeDelegate.AddUObject(this, &UAngelscriptAbilitySystemComponent::OnAttributeChangedTrampoline);
	}
}

void UAngelscriptAbilitySystemComponent::GetAndRegisterCallbackForAttribute(TSubclassOf<UAngelscriptAttributeSet> AttributeSetClass, FName AttributeName, float& OutCurrentValue)
{
	FGameplayAttribute Attribute = UAngelscriptAttributeSet::GetGameplayAttribute(AttributeSetClass, AttributeName);
	FOnGameplayAttributeValueChange& AttributeChangeDelegate = ActiveGameplayEffects.GetGameplayAttributeValueChangeDelegate(Attribute);

	// Make sure we haven't already bound this object to listen to changes for the specified attribute
	// Note that this assumes that the 'this' is only used to bind to the OnAttributeChangedTrampoline function
	if (!AttributeChangeDelegate.IsBoundToObject(this))
	{
		AttributeChangeDelegate.AddUObject(this, &UAngelscriptAbilitySystemComponent::OnAttributeChangedTrampoline);
	}
	OutCurrentValue = GetNumericAttribute(Attribute);
}

void UAngelscriptAbilitySystemComponent::BP_InitAbilityActorInfo(AActor* InOwnerActor, AActor* InAvatarActor) 
{ 
	return InitAbilityActorInfo(InOwnerActor, InAvatarActor); 
}

void UAngelscriptAbilitySystemComponent::ModAttributeUnsafe(FGameplayAttribute GameplayAttribute, TEnumAsByte<EGameplayModOp::Type> ModifierOp, float ModifierMagnitude)
{
	ApplyModToAttributeUnsafe(GameplayAttribute, ModifierOp, ModifierMagnitude);
}

void UAngelscriptAbilitySystemComponent::SetAttributeBaseValue(TSubclassOf<UAngelscriptAttributeSet> AttributeSetClass, FName AttributeName, float NewBaseValue)
{
	ensureMsgf(TrySetAttributeBaseValue(AttributeSetClass, AttributeName, NewBaseValue), TEXT("Could not set attribute base value for attribute <%s>"), *AttributeName.ToString());
}

float UAngelscriptAbilitySystemComponent::GetAttributeCurrentValueChecked(TSubclassOf<UAngelscriptAttributeSet> AttributeSetClass, FName AttributeName) const
{
	float OutCurrentValue = 0.f;
	ensureMsgf(TryGetAttributeCurrentValue(AttributeSetClass, AttributeName, OutCurrentValue), TEXT("Could not set attribute base value for attribute <%s>"), *AttributeName.ToString());
	return OutCurrentValue;
}

float UAngelscriptAbilitySystemComponent::GetAttributeBaseValueChecked(TSubclassOf<UAngelscriptAttributeSet> AttributeSetClass, FName AttributeName) const
{
	float OutBaseValue = 0.f;
	ensureMsgf(TryGetAttributeBaseValue(AttributeSetClass, AttributeName, OutBaseValue), TEXT("Could not set attribute base value for attribute <%s>"), *AttributeName.ToString());
	return OutBaseValue;
}

float UAngelscriptAbilitySystemComponent::GetAttributeCurrentValue(TSubclassOf<UAngelscriptAttributeSet> AttributeSetClass, FName AttributeName, float DefaultValue) const
{
	float OutCurrentValue = DefaultValue;
	TryGetAttributeCurrentValue(AttributeSetClass, AttributeName, OutCurrentValue);
	return OutCurrentValue;
}

float UAngelscriptAbilitySystemComponent::GetAttributeBaseValue(TSubclassOf<UAngelscriptAttributeSet> AttributeSetClass, FName AttributeName, float DefaultValue) const
{
	float OutBaseValue = DefaultValue;
	TryGetAttributeBaseValue(AttributeSetClass, AttributeName, OutBaseValue);
	return OutBaseValue;
}

bool UAngelscriptAbilitySystemComponent::TrySetAttributeBaseValue(TSubclassOf<UAngelscriptAttributeSet> AttributeSetClass, FName AttributeName, float NewBaseValue)
{
	FGameplayAttribute Attribute;
	const UAttributeSet* AttributeSet = GetAttributeSubobject(AttributeSetClass);
	if (AttributeSet && ensureMsgf(
		UAngelscriptAttributeSet::TryGetGameplayAttribute(AttributeSetClass, AttributeName, Attribute), 
		TEXT("Attribute <%s> doesn't exist inside the attribute set <%s>"), *AttributeName.ToString(), *AttributeSetClass->GetName()
	))
	{
		SetNumericAttributeBase(Attribute, NewBaseValue);
		return true;
	}

	return false;
}

bool UAngelscriptAbilitySystemComponent::TryGetAttributeCurrentValue(TSubclassOf<UAngelscriptAttributeSet> AttributeSetClass, FName AttributeName, float& OutCurrentValue) const
{
	FGameplayAttribute Attribute;
	const UAttributeSet* AttributeSet = GetAttributeSubobject(AttributeSetClass);
	if (AttributeSet && ensureMsgf(
		UAngelscriptAttributeSet::TryGetGameplayAttribute(AttributeSetClass, AttributeName, Attribute),
		TEXT("Attribute <%s> doesn't exist inside the attribute set <%s>"), *AttributeName.ToString(), *AttributeSetClass->GetName()
	))
	{
		OutCurrentValue = Attribute.GetNumericValue(AttributeSet);
		return true;
	}

	return false;
}

bool UAngelscriptAbilitySystemComponent::TryGetAttributeBaseValue(TSubclassOf<UAngelscriptAttributeSet> AttributeSetClass, FName AttributeName, float& OutBaseValue) const
{
	FGameplayAttribute Attribute;
	const UAttributeSet* AttributeSet = GetAttributeSubobject(AttributeSetClass);
	if (AttributeSet && ensureMsgf(
		UAngelscriptAttributeSet::TryGetGameplayAttribute(AttributeSetClass, AttributeName, Attribute),
		TEXT("Attribute <%s> doesn't exist inside the attribute set <%s>"), *AttributeName.ToString(), *AttributeSetClass->GetName()
	))
	{
		OutBaseValue = GetNumericAttributeBase(Attribute);
		return true;
	}

	return false;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void UAngelscriptAbilitySystemComponent::ClearAbility_Internal(const FGameplayAbilitySpecHandle& AbilitySpecHandle)
{
	Super::ClearAbility(AbilitySpecHandle);
}

void UAngelscriptAbilitySystemComponent::GetActiveAbilitiesWithTags(const FGameplayTagContainer& GameplayTagContainer, TArray<UGameplayAbility*>& ActiveAbilities) const
{
	TArray<FGameplayAbilitySpec*> AbilitiesToActivate;
	GetActivatableGameplayAbilitySpecsByAllMatchingTags(GameplayTagContainer, AbilitiesToActivate, false);

	// Iterate the list of all ability specs
	for (FGameplayAbilitySpec* Spec : AbilitiesToActivate)
	{
		// Iterate all instances on this ability spec
		TArray<UGameplayAbility*> AbilityInstances = Spec->GetAbilityInstances();

		for (UGameplayAbility* ActiveAbility : AbilityInstances)
		{
			if (ActiveAbility != nullptr && ActiveAbility->IsActive())
			{
				ActiveAbilities.Add(ActiveAbility);
			}
		}
	}
}

bool UAngelscriptAbilitySystemComponent::ActivateAbilitiesUsingTags(const FGameplayTagContainer& GameplayTagContainer, bool bAllowRemoteActivation)
{
	return TryActivateAbilitiesByTag(GameplayTagContainer, bAllowRemoteActivation);
}

bool UAngelscriptAbilitySystemComponent::CanActivateAbilityByClass(TSubclassOf<UGameplayAbility> InAbilityToActivate) const
{
	if (InAbilityToActivate.Get() == nullptr)
	{
		ABILITY_LOG(Warning, TEXT("CanActivateAbilityByClass failed because InAbilityToActivate was invalid"));
		return false;
	}

	bool bSuccess = false;
	const UGameplayAbility* const InAbilityCDO = InAbilityToActivate.GetDefaultObject();
	const FGameplayAbilityActorInfo* ActorInfo = AbilityActorInfo.Get();

	for (const FGameplayAbilitySpec& Spec : ActivatableAbilities.Items)
	{
		if (Spec.Ability == InAbilityCDO)
		{
			bSuccess = Spec.Ability->CanActivateAbility(Spec.Handle, ActorInfo, nullptr, nullptr, nullptr);
			break;
		}
	}

	return bSuccess;
}

bool UAngelscriptAbilitySystemComponent::CanActivateAbilitySpec(FGameplayAbilitySpecHandle AbilitySpecHandle) const
{
	FGameplayAbilitySpec* Spec = FindAbilitySpecFromHandle(AbilitySpecHandle);
	if (!Spec)
	{
		ABILITY_LOG(Warning, TEXT("CanActivateAbilitySpec called with invalid Handle"));
		return false;
	}

	UGameplayAbility* Ability = Spec->Ability;
	return Ability && Ability->CanActivateAbility(AbilitySpecHandle, AbilityActorInfo.Get());
}

void UAngelscriptAbilitySystemComponent::SetAbilitySpecSourceObject(FGameplayAbilitySpecHandle AbilitySpecHandle, UObject* NewSourceObject)
{
	FGameplayAbilitySpec* Spec = FindAbilitySpecFromHandle(AbilitySpecHandle);
	if (!Spec)
	{
		ABILITY_LOG(Warning, TEXT("SetAbilitySpecSourceObject called with invalid Handle"));
		return;
	}

	Spec->SourceObject = NewSourceObject;
}

UObject* UAngelscriptAbilitySystemComponent::GetAbilitySpecSourceObject(FGameplayAbilitySpecHandle AbilitySpecHandle)
{
	FGameplayAbilitySpec* Spec = FindAbilitySpecFromHandle(AbilitySpecHandle);
	if (!Spec)
	{
		ABILITY_LOG(Warning, TEXT("GetAbilitySpecSourceObject called with invalid Handle"));
		return nullptr;
	}

	return Spec->SourceObject.Get();
}

FGameplayAbilitySpecHandle UAngelscriptAbilitySystemComponent::BP_GiveAbility(TSubclassOf<UGameplayAbility> InAbilityClass, int32 Level, int32 OptionalInputID, UObject* OptionalSourceObject)
{
	return GiveAbility_Internal(InAbilityClass, Level, OptionalInputID, OptionalSourceObject);
}
FGameplayAbilitySpecHandle UAngelscriptAbilitySystemComponent::BP_GiveAbilityAndActivateOnce(TSubclassOf<UGameplayAbility> InAbilityClass, int32 Level, int32 OptionalInputID, UObject* OptionalSourceObject)
{
	return GiveAbilityAndActivateOnce_Internal(InAbilityClass, Level, OptionalInputID, OptionalSourceObject);
}
void UAngelscriptAbilitySystemComponent::BP_SetRemoveAbilityOnEnd(FGameplayAbilitySpecHandle AbilitySpecHandle)
{
	return SetRemoveAbilityOnEnd(AbilitySpecHandle);
}

bool UAngelscriptAbilitySystemComponent::TryActivateAbilitySpec(const FGameplayAbilitySpecHandle& Handle, bool bAllowRemoteActivation)
{
	return TryActivateAbility(Handle, bAllowRemoteActivation);
}

FGameplayAbilitySpecHandle UAngelscriptAbilitySystemComponent::GiveAbility_Internal(TSubclassOf<UGameplayAbility> InAbilityClass, int32 Level, int32 OptionalInputID, UObject* OptionalSourceObject)
{
	ensureMsgf(InAbilityClass != nullptr, TEXT("Please provide a valid InAbilityClass to GiveAbility()"));

	// Don't allow crashing
	if (InAbilityClass)
	{
		FGameplayAbilitySpec AbilitySpec = FGameplayAbilitySpec(InAbilityClass, Level);
		AbilitySpec.SourceObject = OptionalSourceObject;
		AbilitySpec.InputID = OptionalInputID;
		return Super::GiveAbility(AbilitySpec);
	}

	return FGameplayAbilitySpecHandle();
}
FGameplayAbilitySpecHandle UAngelscriptAbilitySystemComponent::GiveAbilityAndActivateOnce_Internal(TSubclassOf<UGameplayAbility> InAbilityClass, int32 Level, int32 OptionalInputID, UObject* OptionalSourceObject)
{
	ensureMsgf(InAbilityClass != nullptr, TEXT("Please provide a valid InAbilityClass to GiveAbilityAndActivateOnce()"));

	// Don't allow crashing
	if (InAbilityClass)
	{
		FGameplayAbilitySpec AbilitySpec = FGameplayAbilitySpec(InAbilityClass, Level);
		AbilitySpec.SourceObject = OptionalSourceObject;
		AbilitySpec.InputID = OptionalInputID;
		return Super::GiveAbilityAndActivateOnce(AbilitySpec);
	}

	return FGameplayAbilitySpecHandle();
}

void UAngelscriptAbilitySystemComponent::CancelAbility(TSubclassOf<UGameplayAbility> InAbilityClass)
{
	ensureMsgf(InAbilityClass != nullptr, TEXT("Please provide a valid InAbilityClass to CancelAbility()"));

	// Don't allow crashing
	if (InAbilityClass)
	{
		Super::CancelAbility(InAbilityClass.GetDefaultObject());
	}
}

bool UAngelscriptAbilitySystemComponent::IsAbilityActive(TSubclassOf<UGameplayAbility> InAbilityClass) const
{
	ensureMsgf(InAbilityClass != nullptr, TEXT("Please provide a valid InAbilityClass to IsAbilityActive()"));

	if (InAbilityClass)
	{
		const UGameplayAbility* Ability = InAbilityClass.GetDefaultObject();

		for (const FGameplayAbilitySpec& Spec : ActivatableAbilities.Items)
		{
			if (Spec.Ability == Ability)
			{
				return Spec.IsActive();
			}
		}
	}

	return false;
}

void UAngelscriptAbilitySystemComponent::CancelAbilitiesByTags(const FGameplayTagContainer& WithTags, const FGameplayTagContainer& WithoutTags, UGameplayAbility* Ignore)
{
	CancelAbilities(&WithTags, &WithoutTags, Ignore);
}

void UAngelscriptAbilitySystemComponent::CancelAbilityByHandle(const FGameplayAbilitySpecHandle& AbilityHandle)
{
	CancelAbilityHandle(AbilityHandle);
}

FGameplayAbilityActorInfo& UAngelscriptAbilitySystemComponent::GetAbilityActorInfo() const
{
	check(AbilityActorInfo.IsValid());
	return *AbilityActorInfo;
}

AActor* UAngelscriptAbilitySystemComponent::GetAvatar() const
{
	return GetAvatarActor();
}

APlayerController* UAngelscriptAbilitySystemComponent::GetPlayerController() const
{
	check(AbilityActorInfo.IsValid());
	return AbilityActorInfo->PlayerController.Get();
}

void UAngelscriptAbilitySystemComponent::BindInput(UInputComponent* InputComponent, FAngelscriptInputBindData BindData)
{
	FGameplayAbilityInputBinds InputBinds(BindData.ConfirmTargetCommand.ToString(), BindData.CancelTargetCommand.ToString(), BindData.EnumName, BindData.ConfirmTargetInputID, BindData.CancelTargetInputID);
	BindAbilityActivationToInputComponent(InputComponent, InputBinds);
}

bool UAngelscriptAbilitySystemComponent::HasGameplayTag(FGameplayTag TagToCheck) const
{
	return HasMatchingGameplayTag(TagToCheck);
}

bool UAngelscriptAbilitySystemComponent::HasAllGameplayTags(const FGameplayTagContainer& TagContainer) const
{
	return HasAllMatchingGameplayTags(TagContainer);
}

bool UAngelscriptAbilitySystemComponent::HasAnyGameplayTags(const FGameplayTagContainer& TagContainer) const
{
	return HasAnyMatchingGameplayTags(TagContainer);
}

bool UAngelscriptAbilitySystemComponent::HasAbility(TSubclassOf<UGameplayAbility> InAbilityClass) const
{
	ensureMsgf(InAbilityClass != nullptr, TEXT("Please provide a valid InAbilityClass to HasAbility()"));

	if (InAbilityClass)
	{
		const UGameplayAbility* Ability = InAbilityClass.GetDefaultObject();

		return ActivatableAbilities.Items.ContainsByPredicate(
			[Ability](const FGameplayAbilitySpec& Spec) -> bool { return Spec.Ability == Ability; });
	}

	return false;
}

void UAngelscriptAbilitySystemComponent::InitAbilityActorInfo(AActor* InOwnerActor, AActor* InAvatarActor)
{
	Super::InitAbilityActorInfo(InOwnerActor, InAvatarActor);

	if (OnInitAbilityActorInfo.IsBound())
	{
		OnInitAbilityActorInfo.Broadcast(InOwnerActor, InAvatarActor);
	}
}

void UAngelscriptAbilitySystemComponent::OnTagUpdated(const FGameplayTag& Tag, bool TagExists)
{
	Super::OnTagUpdated(Tag, TagExists);

	if (OnOwnedTagUpdated.IsBound())
	{
		OnOwnedTagUpdated.Broadcast(Tag, TagExists);
	}
}

void UAngelscriptAbilitySystemComponent::OnGiveAbility(FGameplayAbilitySpec& AbilitySpec)
{
	Super::OnGiveAbility(AbilitySpec);

	if (OnAbilityGiven.IsBound())
	{
		OnAbilityGiven.Broadcast(AbilitySpec);
	}
}

void UAngelscriptAbilitySystemComponent::OnRemoveAbility(FGameplayAbilitySpec& AbilitySpec)
{
	Super::OnRemoveAbility(AbilitySpec);

	if (OnAbilityRemoved.IsBound())
	{
		OnAbilityRemoved.Broadcast(AbilitySpec);
	}
}

float UAngelscriptAbilitySystemComponent::GetCooldownTimeRemaining(TSubclassOf<UGameplayAbility> InAbilityClass) const
{
	if (ensure(HasAbility(InAbilityClass)))
	{
		const UGameplayAbility* GameplayAbilityCDO = InAbilityClass.GetDefaultObject();
		const FGameplayTagContainer* CooldownTags =  GameplayAbilityCDO->GetCooldownTags();
		if (CooldownTags && CooldownTags->Num() > 0)
		{
			FGameplayEffectQuery const Query = FGameplayEffectQuery::MakeQuery_MatchAnyOwningTags(*CooldownTags);
			TArray<float> Durations = GetActiveEffectsTimeRemaining(Query);
			if (Durations.Num() > 0)
			{
				Durations.Sort();
				return Durations[Durations.Num() - 1];
			}
		}
		return 0.f;
	}
	return -1.f;
}
