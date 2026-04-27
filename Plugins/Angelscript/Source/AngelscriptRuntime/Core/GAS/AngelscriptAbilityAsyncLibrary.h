#pragma once

#include "CoreMinimal.h"

#include "Abilities/Async/AbilityAsync_WaitAttributeChanged.h"
#include "Abilities/Async/AbilityAsync_WaitGameplayEvent.h"
#include "Abilities/Async/AbilityAsync_WaitGameplayTag.h"
#include "Abilities/Async/AbilityAsync_WaitGameplayTagQuery.h"
#include "Kismet/BlueprintFunctionLibrary.h"

#include "AngelscriptAbilityAsyncLibrary.generated.h"

UCLASS()
class ANGELSCRIPTRUNTIME_API UAngelscriptAbilityAsyncLibrary : public UBlueprintFunctionLibrary
{
	GENERATED_BODY()
public:
	UFUNCTION(BlueprintCallable, Category = "Ability|Tasks")
	static UAbilityAsync_WaitAttributeChanged* WaitForAttributeChanged(
		AActor* TargetActor,
		const FGameplayAttribute& Attribute,
		const bool bTriggerOnce = false
	)
	{
		return UAbilityAsync_WaitAttributeChanged::WaitForAttributeChanged(TargetActor, Attribute, bTriggerOnce);
	}

	UFUNCTION(BlueprintCallable, Category = "Ability|Tasks")
	static UAbilityAsync_WaitGameplayEvent* WaitGameplayEventToActor(
		AActor* TargetActor,
		const FGameplayTag Tag,
		const bool bTriggerOnce = false,
		const bool bMatchExact = true)
	{
		return UAbilityAsync_WaitGameplayEvent::WaitGameplayEventToActor(TargetActor, Tag, bTriggerOnce, bMatchExact);
	}

	UFUNCTION(BlueprintCallable, Category = "Ability|Tasks")
	static UAbilityAsync_WaitGameplayTagAdded* WaitGameplayTagAddToActor(
		AActor* TargetActor,
		const FGameplayTag Tag,
		const bool bTriggerOnce = false
	)
	{
		return UAbilityAsync_WaitGameplayTagAdded::WaitGameplayTagAddToActor(TargetActor, Tag, bTriggerOnce);
	}

	UFUNCTION(BlueprintCallable, Category = "Ability|Tasks")
	static UAbilityAsync_WaitGameplayTagRemoved* WaitGameplayTagRemoveFromActor(
		AActor* TargetActor,
		const FGameplayTag Tag,
		const bool bTriggerOnce = false
	)
	{
		return UAbilityAsync_WaitGameplayTagRemoved::WaitGameplayTagRemoveFromActor(TargetActor, Tag, bTriggerOnce);
	}

	UFUNCTION(BlueprintCallable, Category = "Ability|Tasks")
	static UAbilityAsync_WaitGameplayTagQuery* WaitGameplayTagQueryOnActor(
		AActor* TargetActor, 
		const FGameplayTagQuery& Query, 
		const EWaitGameplayTagQueryTriggerCondition TriggerCondition = EWaitGameplayTagQueryTriggerCondition::WhenTrue,
		const bool bTriggerOnce = false
	)
	{
		return UAbilityAsync_WaitGameplayTagQuery::WaitGameplayTagQueryOnActor(TargetActor, Query, TriggerCondition, bTriggerOnce);
	}
};
