#pragma once

#include "CoreMinimal.h"

#include "AngelscriptAttributeSet.h"

#include "GameplayEffect.h"
#include "GameplayEffectTypes.h"
#include "AbilitySystemComponent.h"

#include "AngelscriptAbilitySystemComponent.generated.h"

// @DEPRECATED - Part of the deprecated RegisterCallbackForAttribute API. Can remove this after Epic merges the exposed FOnAttributeChanged USTRUCT decorators...
USTRUCT(BlueprintType)
struct ANGELSCRIPTRUNTIME_API FAngelscriptModifiedAttribute
{
	GENERATED_BODY()

public:
	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Gameplay Effect Data")
	FName Name;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Gameplay Effect Data")
	float OldValue;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Gameplay Effect Data")
	float NewValue;

	FAngelscriptModifiedAttribute() : Name("Unnamed"), OldValue(0.0f), NewValue(0.0f) {}
	FAngelscriptModifiedAttribute(FName InName, float InOldValue, float InNewValue) : Name(InName), OldValue(InOldValue), NewValue(InNewValue) {}
};

// It's a shame we have to wrap. But it's not a hot path, and it's better than doing an engine mod. Best would of course be if AS type binds were made aware to UHT so binding worked here.
USTRUCT(BlueprintType)
struct ANGELSCRIPTRUNTIME_API FAngelscriptInputBindData
{
	GENERATED_BODY()

public:
	/** Defines command string that will be bound to Confirm Targeting */
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Input Bind Data")
	FName ConfirmTargetCommand;

	/** Defines command string that will be bound to Cancel Targeting */
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Input Bind Data")
	FName CancelTargetCommand;

	/** Returns enum to use for ability binds. E.g., "Ability1"-"Ability9" input commands will be bound to ability activations inside the AbiltiySystemComponent */
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Input Bind Data")
	FTopLevelAssetPath EnumName;

	/** If >=0, Confirm is bound to an entry in the enum */
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Input Bind Data")
	int32 ConfirmTargetInputID;

	/** If >=0, Cancel is bound to an entry in the enum */
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Input Bind Data")
	int32 CancelTargetInputID;

public:
	FAngelscriptInputBindData()
		: ConfirmTargetCommand(NAME_None)
		, CancelTargetCommand(NAME_None)
		, EnumName(nullptr)
		, ConfirmTargetInputID(-1)
		, CancelTargetInputID(-1)
	{
	}
};

// The RegisterAttributeChangedCallback functions use this as their parameter, not the wrapped one!
// Since no type checking occurs for delegates, this still works as the base offset of the wrapper and the wrapped are the same.
USTRUCT(BlueprintType)
struct ANGELSCRIPTRUNTIME_API FAngelscriptAttributeChangedData
{
	GENERATED_BODY()

public:
	FAngelscriptAttributeChangedData()
		: WrappedData()
		, SnapshotEffectSpec()
		, SnapshotEvaluatedData()
		, SnapshotTargetAbilitySystemComponent(nullptr)
	{
	}

	FAngelscriptAttributeChangedData(const FAngelscriptAttributeChangedData& Other)
		: WrappedData(Other.WrappedData)
		, SnapshotEffectSpec()
		, SnapshotEvaluatedData()
		, SnapshotTargetAbilitySystemComponent(nullptr)
	{
		CopyOrSnapshotGameplayEffectData(Other);
	}

	FAngelscriptAttributeChangedData& operator=(const FAngelscriptAttributeChangedData& Other)
	{
		if (this != &Other)
		{
			WrappedData = Other.WrappedData;
			CopyOrSnapshotGameplayEffectData(Other);
		}

		return *this;
	}

	FOnAttributeChangeData WrappedData;

	const FGameplayEffectSpec* GetStableEffectSpec() const
	{
		if (WrappedData.GEModData == GetSnapshotMarker())
		{
			return &SnapshotEffectSpec;
		}

		return WrappedData.GEModData ? &WrappedData.GEModData->EffectSpec : nullptr;
	}

	const FGameplayModifierEvaluatedData* GetStableGameplayModifierEvaluatedData() const
	{
		if (WrappedData.GEModData == GetSnapshotMarker())
		{
			return &SnapshotEvaluatedData;
		}

		return WrappedData.GEModData ? &WrappedData.GEModData->EvaluatedData : nullptr;
	}

	UAbilitySystemComponent* GetStableTargetAbilitySystemComponent() const
	{
		if (WrappedData.GEModData == GetSnapshotMarker())
		{
			return SnapshotTargetAbilitySystemComponent.Get();
		}

		return WrappedData.GEModData ? &WrappedData.GEModData->Target : nullptr;
	}

private:
	static const FGameplayEffectModCallbackData* GetSnapshotMarker()
	{
		return reinterpret_cast<const FGameplayEffectModCallbackData*>(UPTRINT(1));
	}

	void CopyOrSnapshotGameplayEffectData(const FAngelscriptAttributeChangedData& Other)
	{
		if (Other.WrappedData.GEModData == GetSnapshotMarker())
		{
			SnapshotEffectSpec = Other.SnapshotEffectSpec;
			SnapshotEvaluatedData = Other.SnapshotEvaluatedData;
			SnapshotTargetAbilitySystemComponent = Other.SnapshotTargetAbilitySystemComponent;
			return;
		}

		if (Other.WrappedData.GEModData)
		{
			SnapshotEffectSpec = Other.WrappedData.GEModData->EffectSpec;
			SnapshotEvaluatedData = Other.WrappedData.GEModData->EvaluatedData;
			SnapshotTargetAbilitySystemComponent = &Other.WrappedData.GEModData->Target;
			WrappedData.GEModData = GetSnapshotMarker();
			return;
		}

		SnapshotTargetAbilitySystemComponent.Reset();
	}

	FGameplayEffectSpec SnapshotEffectSpec;
	FGameplayModifierEvaluatedData SnapshotEvaluatedData;
	TWeakObjectPtr<UAbilitySystemComponent> SnapshotTargetAbilitySystemComponent;
};

//UCLASS(Meta = (ScriptMixin = "FAngelscriptAttributeChangedData"))
UCLASS()
class ANGELSCRIPTRUNTIME_API UAngelscriptAttributeChangedDataMixinLibrary : public UObject
{
	GENERATED_BODY()

public:
	UFUNCTION(BlueprintCallable)
	static const FGameplayAttribute& GetGameplayAttribute(const FAngelscriptAttributeChangedData& Data)
	{
		return Data.WrappedData.Attribute;
	}

	UFUNCTION(BlueprintCallable)
	static float GetNewValue(const FAngelscriptAttributeChangedData& Data)
	{
		return Data.WrappedData.NewValue;
	}

	UFUNCTION(BlueprintCallable)
	static float GetOldValue(const FAngelscriptAttributeChangedData& Data)
	{
		return Data.WrappedData.OldValue;
	}

	UFUNCTION(BlueprintCallable)
	static const FGameplayEffectSpec& GetEffectSpec(const FAngelscriptAttributeChangedData& Data, bool& bIsValid)
	{
		if (const FGameplayEffectSpec* EffectSpec = Data.GetStableEffectSpec())
		{
			bIsValid = true;
			return *EffectSpec;
		}

		static FGameplayEffectSpec Dummy;
		bIsValid = false;
		return Dummy;
	}

	UFUNCTION(BlueprintCallable)
	static const FGameplayModifierEvaluatedData& GetGameplayModifierEvaluatedData(const FAngelscriptAttributeChangedData& Data, bool& bIsValid)
	{
		if (const FGameplayModifierEvaluatedData* EvaluatedData = Data.GetStableGameplayModifierEvaluatedData())
		{
			bIsValid = true;
			return *EvaluatedData;
		}

		static FGameplayModifierEvaluatedData Dummy;
		bIsValid = false;
		return Dummy;
	}

	UFUNCTION(BlueprintCallable)
	static UAbilitySystemComponent* GetTargetAbilitySystemComponent(const FAngelscriptAttributeChangedData& Data)
	{
		return Data.GetStableTargetAbilitySystemComponent();
	}
};

DECLARE_DYNAMIC_MULTICAST_DELEGATE_TwoParams(FInitAbilityActorInfoDelegate, AActor*, InOwnerActor, AActor*, InAvatarActor);
DECLARE_DYNAMIC_MULTICAST_DELEGATE_OneParam(FAbilityGivenDelegate, const FGameplayAbilitySpec&, AbilitySpec);
DECLARE_DYNAMIC_MULTICAST_DELEGATE_OneParam(FAbilityRemovedDelegate, const FGameplayAbilitySpec&, AbilitySpec);
DECLARE_DYNAMIC_MULTICAST_DELEGATE_OneParam(FAttributeChangedDelegate, const FAngelscriptModifiedAttribute&, AttributeChangeData);
DECLARE_DYNAMIC_MULTICAST_DELEGATE_OneParam(FAttributeSetRegisteredDelegate, class UAngelscriptAttributeSet*, NewAttributeSet);
DECLARE_DYNAMIC_MULTICAST_DELEGATE_TwoParams(FOwnedTagUpdatedDelegate, const FGameplayTag&, Tag, bool, TagExists);

UCLASS()
class ANGELSCRIPTRUNTIME_API UAngelscriptAbilitySystemComponent : public UAbilitySystemComponent
{
	GENERATED_BODY()

public:
	UFUNCTION(BlueprintPure, Category = "AbilitySystem")
	FGameplayAbilityActorInfo& GetAbilityActorInfo() const;

	UFUNCTION(BlueprintPure, Category = "AbilitySystem")
	AActor* GetAvatar() const;

	UFUNCTION(BlueprintPure, Category = "AbilitySystem")
	APlayerController* GetPlayerController() const;
	
	// Adds the attribute set type to the actor that owns this component. Ensures that attribute sets are never added twice.
	UFUNCTION(BlueprintCallable, Category = "Attribute Callbacks")
	UAngelscriptAttributeSet* RegisterAttributeSet(TSubclassOf<UAngelscriptAttributeSet> AttributeSetClass);
	
	// This could be called multiple times if we register attribute sets late. This needs to be a function so we can handle late adds.
	UFUNCTION(BlueprintCallable, Category = "Attribute Callbacks")
	void OnAttributeSetRegistered(UObject* InObject, FName InFunctionName);

	// Use these to register callbacks to individual attributes. As the CallbackFunctionName_FAngelscriptAttributeChangedData parameter name suggests, the callback function should take a single FAngelscriptAttributeChangedData as its parameter to bind correctly.
	UFUNCTION(BlueprintCallable, Category = "Attribute Callbacks")
	void RegisterAttributeChangedCallback(TSubclassOf<UAngelscriptAttributeSet> AttributeSetClass, FName AttributeName, UObject* CallbackObject, FName CallbackFunctionName_FAngelscriptAttributeChangedData);

	UFUNCTION(BlueprintCallable, Category = "Attribute Callbacks")
	void GetAndRegisterAttributeChangedCallback(TSubclassOf<UAngelscriptAttributeSet> AttributeSetClass, FName AttributeName, UObject* CallbackObject, FName CallbackFunctionName_FAngelscriptAttributeChangedData, float& OutCurrentValue);

	UE_DEPRECATED(4.26, "Use RegisterAttributeChangedCallback instead")
	UFUNCTION(BlueprintCallable, Category = "Attribute Callbacks")
	void RegisterCallbackForAttribute(TSubclassOf<UAngelscriptAttributeSet> AttributeSetClass, FName AttributeName);

	UE_DEPRECATED(4.26, "Use RegisterAttributeChangedCallback instead")
	UFUNCTION(BlueprintCallable, Category = "Attribute Callbacks")
	void GetAndRegisterCallbackForAttribute(TSubclassOf<UAngelscriptAttributeSet> AttributeSetClass, FName AttributeName, float& OutCurrentValue);
	
	UFUNCTION(BlueprintCallable, Category = "Attributes")
	void BP_InitAbilityActorInfo(AActor* InOwnerActor, AActor* InAvatarActor);
	
	// This function will apply an attribute change without invoking all the callbacks! Do not use unless you have to and know what you are doing! It can be useful for clamping attribute values to max values for example. For all other scenarios, use the SetAttribute set of functions!
	UFUNCTION(BlueprintCallable, Category = "Attributes")
	void ModAttributeUnsafe(FGameplayAttribute GameplayAttribute, TEnumAsByte<EGameplayModOp::Type> ModifierOp, float ModifierMagnitude);

	// Requires the attribute to actually exist
	UFUNCTION(BlueprintCallable, Category = "Attributes")
	void SetAttributeBaseValue(TSubclassOf<UAngelscriptAttributeSet> AttributeSetClass, FName AttributeName, float NewBaseValue);

	UFUNCTION(BlueprintPure, Category = "Attributes")
	float GetAttributeCurrentValueChecked(TSubclassOf<UAngelscriptAttributeSet> AttributeSetClass, FName AttributeName) const;

	UFUNCTION(BlueprintPure, Category = "Attributes")
	float GetAttributeBaseValueChecked(TSubclassOf<UAngelscriptAttributeSet> AttributeSetClass, FName AttributeName) const;

	// If attribute doesn't exist will return DefaultValue(which is by default 0.f)
	UFUNCTION(BlueprintPure, Category = "Attributes")
	float GetAttributeCurrentValue(TSubclassOf<UAngelscriptAttributeSet> AttributeSetClass, FName AttributeName, float DefaultValue = 0.f) const;

	// If attribute doesn't exist will return DefaultValue(which is by default 0.f)
	UFUNCTION(BlueprintPure, Category = "Attributes")
	float GetAttributeBaseValue(TSubclassOf<UAngelscriptAttributeSet> AttributeSetClass, FName AttributeName, float DefaultValue = 0.f) const;

	// Use these functions when you are not sure if the attribute exists
	UFUNCTION(BlueprintCallable, Category = "Attributes")
	bool TrySetAttributeBaseValue(TSubclassOf<UAngelscriptAttributeSet> AttributeSetClass, FName AttributeName, float NewBaseValue);

	UFUNCTION(BlueprintPure, Category = "Attributes")
	bool TryGetAttributeCurrentValue(TSubclassOf<UAngelscriptAttributeSet> AttributeSetClass, FName AttributeName, float& OutCurrentValue) const;

	UFUNCTION(BlueprintPure, Category = "Attributes")
	bool TryGetAttributeBaseValue(TSubclassOf<UAngelscriptAttributeSet> AttributeSetClass, FName AttributeName, float& OutBaseValue) const;

	// Ability functions
	UFUNCTION(BlueprintCallable, Category = "Abilities", meta = (DisplayName = "Give Ability", ScriptName = "GiveAbility"))
	FGameplayAbilitySpecHandle BP_GiveAbility(TSubclassOf<UGameplayAbility> InAbilityClass, int32 Level = 1, int32 OptionalInputID = -1, UObject* OptionalSourceObject = nullptr);

	UFUNCTION(BlueprintCallable, Category = "Abilities", meta = (DisplayName = "Give Ability And Activate Once", ScriptName = "GiveAbilityAndActivateOnce"))
	FGameplayAbilitySpecHandle BP_GiveAbilityAndActivateOnce(TSubclassOf<UGameplayAbility> InAbilityClass, int32 Level = 1, int32 OptionalInputID = -1, UObject* OptionalSourceObject = nullptr);

	UFUNCTION(BlueprintCallable, Category = "Abilities")
	void BP_SetRemoveAbilityOnEnd(FGameplayAbilitySpecHandle AbilitySpecHandle);

	UFUNCTION(BlueprintCallable, Category = "Abilities")
	bool TryActivateAbilitySpec(const FGameplayAbilitySpecHandle& Handle, bool bAllowRemoteActivation = true);

	UFUNCTION(BlueprintCallable, Category = "Abilities")
	void CancelAbility(TSubclassOf<UGameplayAbility> InAbilityClass);

	UFUNCTION(BlueprintCallable, Category = "Abilities")
	void CancelAbilitiesByTags(const FGameplayTagContainer& WithTags, const FGameplayTagContainer& WithoutTags, UGameplayAbility* Ignore = nullptr);

	UFUNCTION(BlueprintCallable, Category = "Abilities")
	void CancelAbilityByHandle(const FGameplayAbilitySpecHandle& AbilityHandle);

	UFUNCTION(BlueprintPure, Category = "Abilities")
	bool IsAbilityActive(TSubclassOf<UGameplayAbility> InAbilityClass) const;
	
	UFUNCTION(BlueprintPure, Category = "Abilities")
	void GetActiveAbilitiesWithTags(const FGameplayTagContainer& GameplayTagContainer, TArray<UGameplayAbility*>& ActiveAbilities) const;

	UFUNCTION(BlueprintCallable, Category = "Abilities")
	bool ActivateAbilitiesUsingTags(const FGameplayTagContainer& GameplayTagContainer, bool bAllowRemoteActivation = true);

	// Check if ability of class can be activated
	UFUNCTION(BlueprintPure, Category = "Abilities")
	bool CanActivateAbilityByClass(TSubclassOf<UGameplayAbility> InAbilityToActivate) const;

	// Check if ability can be activated
	UFUNCTION(BlueprintPure, Category = "Abilities")
	bool CanActivateAbilitySpec(FGameplayAbilitySpecHandle AbilitySpecHandle) const;

	UFUNCTION(BlueprintCallable, Category = "Abilities")
	void SetAbilitySpecSourceObject(FGameplayAbilitySpecHandle AbilitySpecHandle, UObject* NewSourceObject);

	UFUNCTION(BlueprintPure, Category = "Abilities")
	UObject* GetAbilitySpecSourceObject(FGameplayAbilitySpecHandle AbilitySpecHandle);

	UFUNCTION(BlueprintPure, Category = "Abilities")
	bool HasAbility(TSubclassOf<UGameplayAbility> InAbilityClass) const;

	UFUNCTION(BlueprintPure, Category = "Abilities")
	float GetCooldownTimeRemaining(TSubclassOf<UGameplayAbility> InAbilityClass) const;

	UFUNCTION(BlueprintCallable, Category = "Ability Input Binding")
	void BindInput(UInputComponent* InputComponent, FAngelscriptInputBindData BindData);

	// Tag functions
	UFUNCTION(BlueprintPure, Category = "Gameplay Tags")
	bool HasGameplayTag(FGameplayTag TagToCheck) const;

	// HasAllMatchingGameplayTags, but cannot have the same name so adding "Owned"
	UFUNCTION(BlueprintPure, Category = "Gameplay Tags")
	bool HasAllGameplayTags(const FGameplayTagContainer& TagContainer) const;

	// HasAnyMatchingGameplayTags, but cannot have the same name so adding "Owned"
	UFUNCTION(BlueprintPure, Category = "Gameplay Tags")
	bool HasAnyGameplayTags(const FGameplayTagContainer& TagContainer) const;

	// Override base so we can inject our delegate in there
	virtual void InitAbilityActorInfo(AActor* InOwnerActor, AActor* InAvatarActor) override;
	virtual void OnTagUpdated(const FGameplayTag& Tag, bool TagExists) override;
	virtual void OnGiveAbility(FGameplayAbilitySpec& AbilitySpec) override;
	virtual void OnRemoveAbility(FGameplayAbilitySpec& AbilitySpec) override;

/************************************************************************/
/* Events                                                               */
/************************************************************************/
public:
	// Called for all changes occurring on self
	
	UPROPERTY(BlueprintAssignable, Category = "Ability System Callbacks")
	FInitAbilityActorInfoDelegate OnInitAbilityActorInfo;
	
	UPROPERTY(BlueprintAssignable, Category = "Ability System Callbacks")
	FAbilityGivenDelegate OnAbilityGiven;

	UPROPERTY(BlueprintAssignable, Category = "Ability System Callbacks")
	FAbilityRemovedDelegate OnAbilityRemoved;

	UPROPERTY(BlueprintAssignable, Category = "Ability System Callbacks")
	FAttributeChangedDelegate OnAttributeChanged;

	UPROPERTY(BlueprintAssignable, Category = "Gameplay Tag Callbacks")
	FOwnedTagUpdatedDelegate OnOwnedTagUpdated;

public:
	UAngelscriptAbilitySystemComponent();

protected:
	virtual FGameplayAbilitySpecHandle GiveAbility_Internal(TSubclassOf<UGameplayAbility> InAbilityClass, int32 Level, int32 OptionalInputID, UObject* OptionalSourceObject);
	virtual FGameplayAbilitySpecHandle GiveAbilityAndActivateOnce_Internal(TSubclassOf<UGameplayAbility> InAbilityClass, int32 Level, int32 OptionalInputID, UObject* OptionalSourceObject);
	virtual void ClearAbility_Internal(const FGameplayAbilitySpecHandle& AbilitySpecHandle);
	virtual void OnGameplayEffectEnded(const FActiveGameplayEffect& EndedGameplayEffect);

private:
	// For registrators that bind after we already initialized, we want to be able to call the callback instantly instead. So this should be private.
	FAttributeSetRegisteredDelegate OnAttributeSetRegisteredDelegate;

	void OnAttributeChangedTrampoline(const FOnAttributeChangeData& AttributeChangeData);
};
