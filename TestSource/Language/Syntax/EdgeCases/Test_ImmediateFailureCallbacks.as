// Theme: Language.Syntax.EdgeCases. C++ compiles the harness then runs invalid save/load cases.
// CSV SourceShape NegativeDiagnostic is the callback-failure path, not a compile-fail of this class.
// C++: AngelscriptGameplayFunctionLibraryTests.cpp::ImmediateFailureCallbacks
// sha256=1f5361ffabc4ee844c9177471a79619f32ae5e1dfc6e6d0e42c940848da27f73; lines 335-355.
// Oracle: UAsyncSaveLoadImmediateFailureScriptHarness compiles; StartAsyncSave/StartAsyncLoad bind
// n"OnSaveComplete" / n"OnLoadComplete" and forward SlotName/UserIndex.
// Extra: local construct has no pending async work.
// DefaultSafe. Harness owns the delegate bind; Receiver owns the callback.

UCLASS()
class UAsyncSaveLoadImmediateFailureScriptHarness : UObject
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

void Observe_ImmediateFailureHarness_LocalConstruct()
{
	UAsyncSaveLoadImmediateFailureScriptHarness Harness;
}
