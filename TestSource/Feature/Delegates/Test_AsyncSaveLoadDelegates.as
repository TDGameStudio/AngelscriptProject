// Theme: Feature.Delegates. Positive async save/load delegate harness.
// C++: AngelscriptGameplayFunctionLibraryTests.cpp::AsyncSaveLoadDelegates
// sha256 from theme-refs TS-FEAT-0230; lines 171-191.
// Oracle: harness compiles; StartAsyncSave/StartAsyncLoad bind n"OnSaveComplete" /
// n"OnLoadComplete" and forward SlotName/UserIndex to UGameplayLibrary.
// Extra: local construct has no pending async work. DefaultSafe.
// Harness owns the delegate bind; Receiver owns the callback.

UCLASS()
class UAsyncSaveLoadScriptHarness : UObject
{
	UFUNCTION()
	void StartAsyncSave(USaveGame SaveGameObject, UObject Receiver, const FString& SlotName, int32 UserIndex)
	{
		FAsyncSaveGameToSlotDynamicDelegate SaveDelegate;
		SaveDelegate.BindUFunction(Receiver, n"OnSaveComplete");
		UGameplayLibrary::AsyncSaveGameToSlot(SaveGameObject, SlotName, UserIndex, SaveDelegate);
	}

	UFUNCTION()
	void StartAsyncLoad(UObject Receiver, const FString& SlotName, int32 UserIndex)
	{
		FAsyncLoadGameFromSlotDynamicDelegate LoadDelegate;
		LoadDelegate.BindUFunction(Receiver, n"OnLoadComplete");
		UGameplayLibrary::AsyncLoadGameFromSlot(SlotName, UserIndex, LoadDelegate);
	}
}

void Observe_AsyncSaveLoadHarness_LocalConstruct()
{
	UAsyncSaveLoadScriptHarness Harness;
}

bool Observe_AsyncSaveLoadHarness_TwoLocalsIndependent()
{
	UAsyncSaveLoadScriptHarness First;
	UAsyncSaveLoadScriptHarness Second;
	return First != nullptr && Second != nullptr && First != Second;
}
