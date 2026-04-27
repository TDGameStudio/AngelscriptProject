#pragma once

#include "CoreMinimal.h"

#include "AbilitySystemGlobals.h"
#include "GameplayCueManager.h"
#include "GameplayCueSet.h"

#if WITH_EDITOR
#include "Engine/AssetManager.h"
#endif // WITH_EDITOR

#include "AngelscriptGameplayCueUtils.generated.h"

UCLASS()
class ANGELSCRIPTRUNTIME_API UAngelscriptGameplayCueUtils : public UBlueprintFunctionLibrary
{
	GENERATED_BODY()

public:
	UFUNCTION(BlueprintCallable, Category = "Angelscript|Gameplay Cues")
	static void AddLocalGameplayCue(AActor* TargetActor, FGameplayTag GameplayCueTag, const FGameplayCueParameters& Parameters)
	{
		if (TargetActor && UAbilitySystemGlobals::Get().GetGameplayCueManager())
		{
			UAbilitySystemGlobals::Get().GetGameplayCueManager()->HandleGameplayCue(TargetActor, GameplayCueTag, EGameplayCueEvent::Type::OnActive, Parameters);
			// Because if we don't call WhileActive UE4 won't treat the GC as fully handled and the cleanup won't run
			UAbilitySystemGlobals::Get().GetGameplayCueManager()->HandleGameplayCue(TargetActor, GameplayCueTag, EGameplayCueEvent::Type::WhileActive, Parameters);
		}
	}

	UFUNCTION(BlueprintCallable, Category = "Angelscript|Gameplay Cues")
	static void RemoveLocalGameplayCue(AActor* TargetActor, FGameplayTag GameplayCueTag, const FGameplayCueParameters& Parameters)
	{
		if (TargetActor && UAbilitySystemGlobals::Get().GetGameplayCueManager())
		{
			UAbilitySystemGlobals::Get().GetGameplayCueManager()->HandleGameplayCue(TargetActor, GameplayCueTag, EGameplayCueEvent::Type::Removed, Parameters);
		}
	}

	UFUNCTION(BlueprintCallable, Category = "Angelscript|Gameplay Cues")
	static void ExecuteLocalGameplayCue(AActor* TargetActor, FGameplayTag GameplayCueTag, const FGameplayCueParameters& Parameters)
	{
		if (TargetActor && UAbilitySystemGlobals::Get().GetGameplayCueManager())
		{
			UAbilitySystemGlobals::Get().GetGameplayCueManager()->HandleGameplayCue(TargetActor, GameplayCueTag, EGameplayCueEvent::Type::Executed, Parameters);
		}
	}

	//UFUNCTION(BlueprintCallable, Category = "Angelscript|Gameplay Cues")
	//static AGameplayCueNotify_Actor* FindInstancedCueActor(AActor* TargetActor, const FGameplayTag& Tag, AActor* InstigatorActor = nullptr, const UObject* SourceObj = nullptr)
	//{
	//	UGameplayCueManager* CueManager = UAbilitySystemGlobals::Get().GetGameplayCueManager();
	//	if (!CueManager)
	//	{
	//		return nullptr;
	//	}

	//	UGameplayCueSet* RuntimeSet = CueManager->GetRuntimeCueSet();
	//	if (!RuntimeSet)
	//	{
	//		return nullptr;
	//	}

	//	int32* CueDataIndex = RuntimeSet->GameplayCueDataMap.Find(Tag);
	//	if (!CueDataIndex)
	//	{
	//		return nullptr;
	//	}

	//	FGameplayCueNotifyData& CueData = RuntimeSet->GameplayCueData[*CueDataIndex];
	//	if (CueData.LoadedGameplayCueClass == nullptr)
	//	{
	//		return nullptr;
	//	}

	//	FGCNotifyActorKey Key(TargetActor, CueData.LoadedGameplayCueClass, InstigatorActor, SourceObj);
	//	if (TWeakObjectPtr<AGameplayCueNotify_Actor>* ActorPtr = CueManager->NotifyMapActor.Find(Key))
	//	{
	//		return ActorPtr->Get();
	//	}
	//}

#if WITH_EDITOR
	UFUNCTION(BlueprintCallable, Category = "Angelscript|Editor|Gameplay Cues")
	static UClass* FindCueLoadedClassInEditor(FGameplayTag GameplayCueTag)
	{
		UGameplayCueManager* CueManager = UAbilitySystemGlobals::Get().GetGameplayCueManager();
		if (CueManager)
		{
			FStreamableManager& StreamableManager = UAssetManager::Get().GetStreamableManager();
			TArray<UGameplayCueSet*> CueSets = CueManager->GetGlobalCueSets();
			for (UGameplayCueSet* CueSet : CueSets)
			{
				const int32* DataIdx = CueSet->GameplayCueDataMap.Find(GameplayCueTag);
				if (DataIdx)
				{
					FGameplayCueNotifyData& CueData = CueSet->GameplayCueData[*DataIdx];

					// Return class if it's already loaded
					if (CueData.LoadedGameplayCueClass)
						return CueData.LoadedGameplayCueClass;

					// Attempt to find class if it's loaded but not cached in the cue data
					UClass* AlreadyLoadedClass = FindObject<UClass>(nullptr, *CueData.GameplayCueNotifyObj.ToString());
					if (AlreadyLoadedClass)
					{
						CueData.LoadedGameplayCueClass = AlreadyLoadedClass;
					}
					// Otherwise synchronously load the cue class 
					else
					{
						CueData.LoadedGameplayCueClass = Cast<UClass>(StreamableManager.LoadSynchronous(CueData.GameplayCueNotifyObj, false));
					}

					return CueData.LoadedGameplayCueClass;
				}
			}
		}
		return nullptr;
	}
#endif // WITH_EDITOR
};
