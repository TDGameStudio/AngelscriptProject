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

	UFUNCTION()
	int GetNativeValue() const
	{
		return NativeValue + 25;
	}

	UFUNCTION()
	void SetNativeMarker(FName Marker)
	{
		NativeMarker = n"Reloaded";
	}

	UFUNCTION()
	void AdjustNativeValue(int Delta, int& Value)
	{
		Value += Delta * 2;
	}
}
