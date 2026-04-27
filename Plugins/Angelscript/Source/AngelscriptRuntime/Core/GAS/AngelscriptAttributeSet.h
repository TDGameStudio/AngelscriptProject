#pragma once

#include "CoreMinimal.h"

#include "AttributeSet.h"
#include "GameplayEffect.h"
#include "GameplayEffectExtension.h"
#include "Abilities/GameplayAbilityTypes.h"

#include "AngelscriptAttributeSet.generated.h"

// We use this subtype to be able to reflect on the property it belongs to for replication etc.
USTRUCT(BlueprintType)
struct FAngelscriptGameplayAttributeData : public FGameplayAttributeData
{
	GENERATED_BODY()

public:
	UPROPERTY(BlueprintReadOnly, Category = "Attribute")
	FName AttributeName;

	FAngelscriptGameplayAttributeData() 
		: FGameplayAttributeData(0.0f)
	{
	}

	FAngelscriptGameplayAttributeData(float InitialValue) 
		: FGameplayAttributeData(InitialValue)
	{
	}
};

UCLASS()
class ANGELSCRIPTRUNTIME_API UAngelscriptAttributeSet : public UAttributeSet
{
	GENERATED_BODY()

public:
	// The default behavior of the attribute set is to replicate all attributes for the entire lifetime of the set. If you don't want an attribute to be replicated, add its name to this list.
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Replication", meta=(HideInDetailsView))
	TArray<FName> ReplicatedAttributeBlackList;
	
	UFUNCTION(BlueprintCallable, Category = "Replication")
	void OnRep_Attribute(FAngelscriptGameplayAttributeData& OldAttributeData);

public:
	// Return true if you could load the data. False if you want to use the default loading function
	UFUNCTION(BlueprintNativeEvent)
	bool BP_OnInitFromMetaDataTable(const UDataTable* DataTable);
	
	// Return true if you want to allow the effect to execute
	UFUNCTION(BlueprintNativeEvent)
	bool BP_PreGameplayEffectExecute(const FGameplayEffectSpec& EffectSpec, FGameplayModifierEvaluatedData& EvaluatedData, class UAngelscriptAbilitySystemComponent* AbilitySystemComponent);

	UFUNCTION(BlueprintImplementableEvent)
	void BP_PostGameplayEffectExecute(const FGameplayEffectSpec& EffectSpec, FGameplayModifierEvaluatedData& EvaluatedData, class UAngelscriptAbilitySystemComponent* AbilitySystemComponent);

	UFUNCTION(BlueprintImplementableEvent)
	void BP_PreAttributeChange(const FGameplayAttribute& Attribute, float& NewValue);

	UFUNCTION(BlueprintImplementableEvent)
	void BP_PostAttributeChange(const FGameplayAttribute& Attribute, float OldValue, float NewValue);

	UFUNCTION(BlueprintImplementableEvent)
	void BP_PreAttributeBaseChange(const FGameplayAttribute& Attribute, float& NewValue) const;

	UFUNCTION(BlueprintImplementableEvent)
	void BP_PostAttributeBaseChange(const FGameplayAttribute& Attribute, float OldValue, float NewValue) const;

	UFUNCTION(BlueprintPure, Category = "Attributes")
	AActor* BP_GetOwningActor();
	
	UFUNCTION(BlueprintPure, Category = "Attributes")
	class UAngelscriptAbilitySystemComponent* BP_GetOwningAbilitySystemComponent() const;
	
	UFUNCTION(BlueprintPure, Category = "Attributes")
	FGameplayAbilityActorInfo& BP_GetActorInfo() const;

	// Use these functions when you are not sure if the attribute you are trying to manipulate will exist on the set.
	UFUNCTION(BlueprintCallable, Category = "Attributes")
	bool TrySetAttributeBaseValue(FName AttributeName, float NewBaseValue);

	UFUNCTION(BlueprintPure, Category = "Attributes")
	bool TryGetAttributeCurrentValue(FName AttributeName, float& OutCurrentValue);

	UFUNCTION(BlueprintPure, Category = "Attributes")
	bool TryGetAttributeBaseValue(FName AttributeName, float& OutBaseValue);

public:
	// Get an attribute on an attribute set that you expects will exist and want to assert if it for whatever reason does not.
	UFUNCTION(BlueprintPure, Category = "Angelscript|Attributes")
	static FGameplayAttribute GetGameplayAttribute(TSubclassOf<UAngelscriptAttributeSet> AttributeSetClass, FName AttributeName);

	// Attempt to find a gameplay attribute. This is useful with for example dynamic attributes where you are not sure if the attribute exists.
	UFUNCTION(BlueprintPure, Category = "Angelscript|Attributes")
	static bool TryGetGameplayAttribute(TSubclassOf<UAngelscriptAttributeSet> AttributeSetClass, FName AttributeName, FGameplayAttribute& OutGameplayAttribute);

	// Comapre two gameplay attributes whether or not they are equal
	UFUNCTION(BlueprintPure, Category = "Angelscript|Attributes")
	static bool CompareGameplayAttributes(const FGameplayAttribute& First, const FGameplayAttribute& Second);

/************************************************************************/
/* AttributeSet                                                         */
/************************************************************************/
public:
	virtual bool PreGameplayEffectExecute(FGameplayEffectModCallbackData& Data) override;
	virtual void PostGameplayEffectExecute(const FGameplayEffectModCallbackData& Data) override;
	virtual void PreAttributeChange(const FGameplayAttribute& Attribute, float& NewValue) override;
	virtual void PostAttributeChange(const FGameplayAttribute& Attribute, float OldValue, float NewValue) override;
	virtual void PreAttributeBaseChange(const FGameplayAttribute& Attribute, float& NewValue) const override;
	virtual void PostAttributeBaseChange(const FGameplayAttribute& Attribute, float OldValue, float NewValue) const override;
	UFUNCTION(BlueprintCallable, Category = "Angelscript|Attributes")
	virtual void InitFromMetaDataTable(const UDataTable* DataTable) override;
	virtual void GetLifetimeReplicatedProps(TArray<FLifetimeProperty>& OutLifetimeProps) const override;
	virtual void PostInitProperties() override;
};
