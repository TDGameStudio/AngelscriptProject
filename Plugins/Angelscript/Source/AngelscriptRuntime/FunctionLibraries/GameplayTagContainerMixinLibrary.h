#pragma once

#include "CoreMinimal.h"
#include "GameplayTagContainer.h"

#include "GameplayTagContainerMixinLibrary.generated.h"

// FunctionLibraries cleanup note (mixin parity):
//
// The //UCLASS(Meta = (ScriptMixin = "FGameplayTagContainer")) line below is kept
// commented out as a Hazelight-parity anchor. This fork currently routes these
// helpers through UFUNCTION(BlueprintCallable) + BlueprintCallableReflectiveFallback
// instead of the dedicated mixin path in Helper_FunctionSignature.h. See
// Documents/Knowledges/ZH/Syntax_Mixin.md section 6 for the full background.

/**
 * ScriptMixin library to bind functions on FGameplayTagContainer
 * that are not BlueprintCallable by default.
 */
//UCLASS(Meta = (ScriptMixin = "FGameplayTagContainer"))
UCLASS()
class UGameplayTagContainerMixinLibrary : public UObject
{
	GENERATED_BODY()
public:
	UFUNCTION(BlueprintCallable)
	static void AddTag(FGameplayTagContainer& GameplayTagContainer, const FGameplayTag& TagToAdd)
	{
		GameplayTagContainer.AddTag(TagToAdd);
	}

	UFUNCTION(BlueprintCallable)
	static void AddTagFast(FGameplayTagContainer& GameplayTagContainer, const FGameplayTag& TagToAdd)
	{
		GameplayTagContainer.AddTagFast(TagToAdd);
	}

	UFUNCTION(BlueprintCallable)
	static void AddLeafTag(FGameplayTagContainer& GameplayTagContainer, const FGameplayTag& TagToAdd)
	{
		GameplayTagContainer.AddLeafTag(TagToAdd);
	}

	UFUNCTION(BlueprintCallable)
	static bool RemoveTag(FGameplayTagContainer& GameplayTagContainer, const FGameplayTag& TagToRemove)
	{
		return GameplayTagContainer.RemoveTag(TagToRemove);
	}

	UFUNCTION(BlueprintCallable)
	static void RemoveTags(FGameplayTagContainer& GameplayTagContainer, FGameplayTagContainer TagsToRemove)
	{
		GameplayTagContainer.RemoveTags(TagsToRemove);
	}

	UFUNCTION(BlueprintCallable)
	static bool HasTag(const FGameplayTagContainer& GameplayTagContainer, const FGameplayTag& TagToCheck)
	{
		return GameplayTagContainer.HasTag(TagToCheck);
	}

	UFUNCTION(BlueprintCallable)
	static bool HasTagExact(const FGameplayTagContainer& GameplayTagContainer, const FGameplayTag& TagToCheck)
	{
		return GameplayTagContainer.HasTagExact(TagToCheck);
	}

	UFUNCTION(BlueprintCallable)
	static bool HasAny(const FGameplayTagContainer& GameplayTagContainer, const FGameplayTagContainer& ContainerToCheck)
	{
		return GameplayTagContainer.HasAny(ContainerToCheck);
	}

	UFUNCTION(BlueprintCallable)
	static bool HasAnyExact(const FGameplayTagContainer& GameplayTagContainer, const FGameplayTagContainer& ContainerToCheck)
	{
		return GameplayTagContainer.HasAnyExact(ContainerToCheck);
	}

	UFUNCTION(BlueprintCallable)
	static bool HasAll(const FGameplayTagContainer& GameplayTagContainer, const FGameplayTagContainer& ContainerToCheck)
	{
		return GameplayTagContainer.HasAll(ContainerToCheck);
	}

	UFUNCTION(BlueprintCallable)
	static bool HasAllExact(const FGameplayTagContainer& GameplayTagContainer, const FGameplayTagContainer& ContainerToCheck)
	{
		return GameplayTagContainer.HasAllExact(ContainerToCheck);
	}

	UFUNCTION(BlueprintCallable)
	static int32 Num(const FGameplayTagContainer& GameplayTagContainer)
	{
		return GameplayTagContainer.Num();
	}

	UFUNCTION(BlueprintCallable)
	static bool IsValid(const FGameplayTagContainer& GameplayTagContainer)
	{
		return GameplayTagContainer.IsValid();
	}

	UFUNCTION(BlueprintCallable)
	static bool IsEmpty(const FGameplayTagContainer& GameplayTagContainer)
	{
		return GameplayTagContainer.IsEmpty();
	}

	UFUNCTION(BlueprintCallable)
	static FGameplayTagContainer GetGameplayTagParents(const FGameplayTagContainer& GameplayTagContainer)
	{
		return GameplayTagContainer.GetGameplayTagParents();
	}

	UFUNCTION(BlueprintCallable)
	static FGameplayTagContainer Filter(const FGameplayTagContainer& GameplayTagContainer, const FGameplayTagContainer& OtherContainer)
	{
		return GameplayTagContainer.Filter(OtherContainer);
	}

	UFUNCTION(BlueprintCallable)
	static FGameplayTagContainer FilterExact(const FGameplayTagContainer& GameplayTagContainer, const FGameplayTagContainer& OtherContainer)
	{
		return GameplayTagContainer.FilterExact(OtherContainer);
	}

	UFUNCTION(BlueprintCallable)
	static bool MatchesQuery(const FGameplayTagContainer& GameplayTagContainer, const FGameplayTagQuery& Query)
	{
		return GameplayTagContainer.MatchesQuery(Query);
	}

	UFUNCTION(BlueprintCallable)
	static FGameplayTag Last(const FGameplayTagContainer& GameplayTagContainer)
	{
		return GameplayTagContainer.Last();
	}

	UFUNCTION(BlueprintCallable)
	static FGameplayTag First(const FGameplayTagContainer& GameplayTagContainer)
	{
		return GameplayTagContainer.First();
	}
};
