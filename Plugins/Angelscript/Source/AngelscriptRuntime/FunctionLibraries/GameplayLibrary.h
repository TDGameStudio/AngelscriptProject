#pragma once

#include "CoreMinimal.h"
#include "Kismet/GameplayStatics.h"

#include "GameplayLibrary.generated.h"

/** Delegate called from AsyncSaveGameToSlot. First two parameters are passed in SlotName and UserIndex, third
 * parameter is a bool indicating success (true) or failure (false).
 */
DECLARE_DYNAMIC_DELEGATE_ThreeParams(
	FAsyncSaveGameToSlotDynamicDelegate, const FString&, SlotName, const int32, UserIndex, bool, bSuccess);

/** Delegate called from AsyncLoadGameFromSlot. First two parameters are passed in SlotName and UserIndex, third
 * parameter is the returned SaveGame, or null if it failed to load.
 */
DECLARE_DYNAMIC_DELEGATE_ThreeParams(
	FAsyncLoadGameFromSlotDynamicDelegate, const FString&, SlotName, const int32, UserIndex, USaveGame*, SaveGameObject);

UCLASS(MinimalAPI)
class UGameplayLibrary : public UObject
{
	GENERATED_BODY()

public:
	/**
	 * Schedule an async save to a specific slot. UAsyncActionHandleSaveGame::AsyncSaveGameToSlot is the blueprint version of this.
	 * This will do the serialize on the game thread, the platform-specific write on a worker thread, then call the complete delegate on the game thread.
	 * The passed in delegate will be copied to a worker thread so make sure any payload is thread safe to copy by value.
	 *
	 * @param SaveGameObject	Object that contains data about the save game that we want to write out.
	 * @param SlotName			Name of the save game slot to load from.
	 * @param UserIndex			For some platforms, master user index to identify the user doing the loading.
	 * @param SavedDelegate		Delegate that will be called on game thread when save succeeds or fails.
	 */
	UFUNCTION(BlueprintCallable)
	static void AsyncSaveGameToSlot(USaveGame* SaveGameObject, const FString& SlotName, const int32 UserIndex,
		FAsyncSaveGameToSlotDynamicDelegate Delegate)
	{
		UGameplayStatics::AsyncSaveGameToSlot(SaveGameObject, SlotName, UserIndex,
			FAsyncSaveGameToSlotDelegate::CreateLambda(
				[Delegate](const FString& InSlotName, const int32 InUserIndex, bool bSuccess)
				{ Delegate.ExecuteIfBound(InSlotName, InUserIndex, bSuccess); }));
	}

	/**
	 * Schedule an async load of a specific slot. UAsyncActionHandleSaveGame::AsyncLoadGameFromSlot is the blueprint version of this.
	 * This will do the platform-specific read on a worker thread, the serialize and creation on the game thread, and then will call the passed in delegate
	 * The passed in delegate will be copied to a worker thread so make sure any payload is thread safe to copy by value
	 *
	 * @param SlotName			Name of the save game slot to load from.
	 * @param UserIndex			For some platforms, master user index to identify the user doing the loading.
	 * @param LoadedDelegate	Delegate that will be called on game thread when load succeeds or fails.
	 */
	UFUNCTION(BlueprintCallable)
	static void AsyncLoadGameFromSlot(const FString& SlotName, const int32 UserIndex,
		FAsyncLoadGameFromSlotDynamicDelegate Delegate)
	{
		UGameplayStatics::AsyncLoadGameFromSlot(SlotName, UserIndex,
			FAsyncLoadGameFromSlotDelegate::CreateLambda(
				[Delegate](const FString& InSlotName, const int32 InUserIndex, USaveGame* SaveGameObject)
				{ Delegate.ExecuteIfBound(InSlotName, InUserIndex, SaveGameObject); }));
	}
};
