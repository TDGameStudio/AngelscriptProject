/**
 * @version v1
 * @summary The script harness for immediate save/load failure callbacks: two starters that bind completion delegates by name and forward the slot arguments. The failure cases belong to the C++ runner; this class only supplies the.
 * @topic Language
 */
/**
 * @version root
 * @summary The script harness for immediate save/load failure callbacks: two starters that bind completion delegates by name and forward the slot arguments. The failure cases belong to the C++ runner; this class only supplies the.
 * @topic Baseline
 */
UCLASS()
class UAsyncSaveLoadImmediateFailureScriptHarness : UObject
{
	/**
	 * Starts an async save bound to the receiver's completion callback.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the save object, receiver, slot name and user index
	 * @Return nothing; the delegate is bound and the save started
	 * @Param SaveGameObject the object being saved
	 * @Param Receiver the object owning the completion callback
	 * @Param SlotName the slot to save into
	 * @Param UserIndex the platform user index
	 */
	UFUNCTION()
	void StartAsyncSave(USaveGame SaveGameObject, UObject Receiver, const FString&in SlotName, int32 UserIndex)
	{
		FAsyncSaveGameToSlotDynamicDelegate SaveDelegate;
		SaveDelegate.BindUFunction(Receiver, n"OnSaveComplete");
		UGameplayLibrary::AsyncSaveGameToSlot(SaveGameObject, SlotName, UserIndex, SaveDelegate);
	}

	/**
	 * Starts an async load bound to the receiver's completion callback.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the receiver, slot name and user index
	 * @Return nothing; the delegate is bound and the load started
	 * @Param Receiver the object owning the completion callback
	 * @Param SlotName the slot to load from
	 * @Param UserIndex the platform user index
	 */
	UFUNCTION()
	void StartAsyncLoad(UObject Receiver, const FString&in SlotName, int32 UserIndex)
	{
		FAsyncLoadGameFromSlotDynamicDelegate LoadDelegate;
		LoadDelegate.BindUFunction(Receiver, n"OnLoadComplete");
		UGameplayLibrary::AsyncLoadGameFromSlot(SlotName, UserIndex, LoadDelegate);
	}

	/**
	 * Observe that the harness constructs with no pending async work.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a locally constructed harness
	 * @Return true once construction completes
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool ImmediateFailureHarnessConstructs()
	{
		UAsyncSaveLoadImmediateFailureScriptHarness Harness;
		return true;
	}
}
/** @end */
