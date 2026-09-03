// Theme: HotReload VersionPair After. Native parent-interface dispatch V2.
// C++: AngelscriptHotReloadInterfaceTests.cpp::NativeInterfaceDispatchUsesReloadedSoftBody
// Retained: same UClass, NativeValue=10, interface implement, live actor instance.
// Replaced: GetNativeValue NativeValue+25; SetNativeMarker ignores Marker and writes n"Reloaded"; AdjustNativeValue uses Delta*2.
// FixtureIsolated. C++ Execute_ oracles: GetNativeValue 35, Adjust 5+3*2=11, marker Reloaded.

UCLASS()
class AHotReloadInterfaceNativeBridgeActor : AActor, UAngelscriptNativeParentInterface
{
	UPROPERTY()
	int NativeValue = 10;

	UPROPERTY()
	FName NativeMarker = NAME_None;

	/** Returns the native value. */
	UFUNCTION()
	int GetNativeValue() const
	{
		return NativeValue + 25;
	}

	/** Assigns the native marker. */
	UFUNCTION()
	void SetNativeMarker(FName Marker)
	{
		NativeMarker = n"Reloaded";
	}

	/** Adjusts the native value in place. */
	UFUNCTION()
	void AdjustNativeValue(int Delta, int&inout Value)
	{
		Value += Delta * 2;
	}
}
