/**
 * @version v1
 * @summary An async save/load delegate harness. StartAsyncSave and StartAsyncLoad bind n"OnSaveComplete" / n"OnLoadComplete" and forward SlotName and UserIndex to UGameplayLibrary. Local construct has no pending async work.
 * @topic Feature
 */
/**
 * @version root
 * @summary An async save/load delegate harness. StartAsyncSave and StartAsyncLoad bind n"OnSaveComplete" / n"OnLoadComplete" and forward SlotName and UserIndex to UGameplayLibrary. Local construct has no pending async work.
 * @topic Baseline
 */
UCLASS()
class UAsyncSaveLoadScriptHarness : UObject
{
	/**
	 * Binds OnSaveComplete and starts an async save.
	 *
	 * @Covers Delegates.Async
	 * @Param SaveGameObject the save object
	 * @Param Receiver the object that owns OnSaveComplete
	 * @Param SlotName the slot name forwarded to UGameplayLibrary
	 * @Param UserIndex the user index forwarded to UGameplayLibrary
	 * @Inputs SaveGameObject, Receiver, SlotName, UserIndex
	 * @Return nothing; the library owns the async work
	 */
	UFUNCTION()
	void StartAsyncSave(USaveGame SaveGameObject, UObject Receiver, const FString&in SlotName, int32 UserIndex)
	{
		FAsyncSaveGameToSlotDynamicDelegate SaveDelegate;
		SaveDelegate.BindUFunction(Receiver, n"OnSaveComplete");
		UGameplayLibrary::AsyncSaveGameToSlot(SaveGameObject, SlotName, UserIndex, SaveDelegate);
	}

	/**
	 * Binds OnLoadComplete and starts an async load.
	 *
	 * @Covers Delegates.Async
	 * @Param Receiver the object that owns OnLoadComplete
	 * @Param SlotName the slot name forwarded to UGameplayLibrary
	 * @Param UserIndex the user index forwarded to UGameplayLibrary
	 * @Inputs Receiver, SlotName, UserIndex
	 * @Return nothing; the library owns the async work
	 */
	UFUNCTION()
	void StartAsyncLoad(UObject Receiver, const FString&in SlotName, int32 UserIndex)
	{
		FAsyncLoadGameFromSlotDynamicDelegate LoadDelegate;
		LoadDelegate.BindUFunction(Receiver, n"OnLoadComplete");
		UGameplayLibrary::AsyncLoadGameFromSlot(SlotName, UserIndex, LoadDelegate);
	}

	/**
	 * Observe a local construct of the harness.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Async
	 * @Inputs a local UAsyncSaveLoadScriptHarness
	 * @Return nothing; there is no pending async work
	 * @Boundary local construct
	 */
	UFUNCTION()
	void LocalConstruct()
	{
		UAsyncSaveLoadScriptHarness Harness;
	}

	/**
	 * Observe that two local harness handles are distinct and non-null.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Async
	 * @Inputs two local UAsyncSaveLoadScriptHarness values
	 * @Return true when both are non-null and they differ
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool TwoLocalsIndependent()
	{
		UAsyncSaveLoadScriptHarness First;
		UAsyncSaveLoadScriptHarness Second;
		if (First == nullptr)
		{
			return false;
		}
		if (Second == nullptr)
		{
			return false;
		}
		return First != Second;
	}
}
/** @end */
