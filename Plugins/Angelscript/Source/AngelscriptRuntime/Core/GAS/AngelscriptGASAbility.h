#pragma once

#include "CoreMinimal.h"

#include "Abilities/GameplayAbility.h"

#include "AngelscriptGASAbility.generated.h"

class AGameplayCueNotify_Actor;
class AGameplayCueNotify_Static;

UCLASS(abstract, Blueprintable)
class ANGELSCRIPTRUNTIME_API UAngelscriptGASAbility : public UGameplayAbility
{
	GENERATED_BODY()

public:
	/** Invoke a gameplay cue on the ability owner */
	UFUNCTION(BlueprintCallable, Category = Ability, meta = (GameplayTagFilter = "GameplayCue"), DisplayName = "Execute GameplayCue On Owner (_Actor)", meta = (ScriptName = "ExecuteGameplayCue_Actor"))
	virtual void K2_ExecuteGameplayCue_Actor(TSubclassOf<AGameplayCueNotify_Actor> GameplayCue, FGameplayEffectContextHandle Context);

	/** Invoke a gameplay cue on the ability owner, with extra parameters */
	UFUNCTION(BlueprintCallable, Category = Ability, meta = (GameplayTagFilter = "GameplayCue"), DisplayName = "Execute GameplayCueWithParams On Owner (_Actor)", meta = (ScriptName = "ExecuteGameplayCueWithParams_Actor"))
	virtual void K2_ExecuteGameplayCueWithParams_Actor(TSubclassOf<AGameplayCueNotify_Actor> GameplayCue, const FGameplayCueParameters& GameplayCueParameters);

	/** Adds a persistent gameplay cue to the ability owner. Optionally will remove if ability ends */
	UFUNCTION(BlueprintCallable, Category = Ability, meta = (GameplayTagFilter = "GameplayCue"), DisplayName = "Add GameplayCue To Owner (_Actor)", meta = (ScriptName = "AddGameplayCue_Actor"))
	virtual void K2_AddGameplayCue_Actor(TSubclassOf<AGameplayCueNotify_Actor> GameplayCue, FGameplayEffectContextHandle Context, bool bRemoveOnAbilityEnd = true);

	/** Adds a persistent gameplay cue to the ability owner. Optionally will remove if ability ends */
	UFUNCTION(BlueprintCallable, Category = Ability, meta = (GameplayTagFilter = "GameplayCue"), DisplayName = "Add GameplayCueWithParams To Owner (_Actor)", meta = (ScriptName = "AddGameplayCueWithParams_Actor"))
	virtual void K2_AddGameplayCueWithParams_Actor(TSubclassOf<AGameplayCueNotify_Actor> GameplayCue, const FGameplayCueParameters& GameplayCueParameter, bool bRemoveOnAbilityEnd = true);

	/** Removes a persistent gameplay cue from the ability owner */
	UFUNCTION(BlueprintCallable, Category = Ability, meta = (GameplayTagFilter = "GameplayCue"), DisplayName = "Remove GameplayCue From Owner (_Actor)", meta = (ScriptName = "RemoveGameplayCue_Actor"))
	virtual void K2_RemoveGameplayCue_Actor(TSubclassOf<AGameplayCueNotify_Actor> GameplayCue);

public:
	/** Invoke a gameplay cue on the ability owner */
	UFUNCTION(BlueprintCallable, Category = Ability, meta = (GameplayTagFilter = "GameplayCue"), DisplayName = "Execute GameplayCue On Owner (_Static)", meta = (ScriptName = "ExecuteGameplayCue_Static"))
	virtual void K2_ExecuteGameplayCue_Static(TSubclassOf<UGameplayCueNotify_Static> GameplayCue, FGameplayEffectContextHandle Context);

	/** Invoke a gameplay cue on the ability owner, with extra parameters */
	UFUNCTION(BlueprintCallable, Category = Ability, meta = (GameplayTagFilter = "GameplayCue"), DisplayName = "Execute GameplayCueWithParams On Owner (_Static)", meta = (ScriptName = "ExecuteGameplayCueWithParams_Static"))
	virtual void K2_ExecuteGameplayCueWithParams_Static(TSubclassOf<UGameplayCueNotify_Static> GameplayCue, const FGameplayCueParameters& GameplayCueParameters);

	/** Adds a persistent gameplay cue to the ability owner. Optionally will remove if ability ends */
	UFUNCTION(BlueprintCallable, Category = Ability, meta = (GameplayTagFilter = "GameplayCue"), DisplayName = "Add GameplayCue To Owner (_Static)", meta = (ScriptName = "AddGameplayCue_Static"))
	virtual void K2_AddGameplayCue_Static(TSubclassOf<UGameplayCueNotify_Static> GameplayCue, FGameplayEffectContextHandle Context, bool bRemoveOnAbilityEnd = true);

	/** Adds a persistent gameplay cue to the ability owner. Optionally will remove if ability ends */
	UFUNCTION(BlueprintCallable, Category = Ability, meta = (GameplayTagFilter = "GameplayCue"), DisplayName = "Add GameplayCueWithParams To Owner (_Static)", meta = (ScriptName = "AddGameplayCueWithParams_Static"))
	virtual void K2_AddGameplayCueWithParams_Static(TSubclassOf<UGameplayCueNotify_Static> GameplayCue, const FGameplayCueParameters& GameplayCueParameter, bool bRemoveOnAbilityEnd = true);

	/** Removes a persistent gameplay cue from the ability owner */
	UFUNCTION(BlueprintCallable, Category = Ability, meta = (GameplayTagFilter = "GameplayCue"), DisplayName = "Remove GameplayCue From Owner (_Static)", meta = (ScriptName = "RemoveGameplayCue_Static"))
	virtual void K2_RemoveGameplayCue_Static(TSubclassOf<UGameplayCueNotify_Static> GameplayCue);

public:
	UAngelscriptGASAbility(const FObjectInitializer& ObjectInitializer = FObjectInitializer::Get());
};
