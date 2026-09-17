/**
 * @version v1
 * @summary HotReload VersionPair Before. Native parent-interface dispatch V1.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. Native parent-interface dispatch V1.
 * @topic Baseline
 */
// Retained after soft reload: AHotReloadInterfaceNativeBridgeActor UClass identity, NativeValue=10, NativeMarker storage, interface implement.
// Replaced in After: GetNativeValue +1 -> +25; SetNativeMarker writes n"Reloaded"; AdjustNativeValue Delta -> Delta*2.
// FixtureIsolated. C++ Execute_ oracles: GetNativeValue 11, Adjust 5+3=8, marker BeforeReload.

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
		return NativeValue + 1;
	}

	/** Assigns the native marker. */
	UFUNCTION()
	void SetNativeMarker(FName Marker)
	{
		NativeMarker = Marker;
	}

	/** Adjusts the native value in place. */
	UFUNCTION()
	void AdjustNativeValue(int Delta, int&inout Value)
	{
		Value += Delta;
	}
}
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. Native parent-interface dispatch V2.
 * @topic HotReload
 */
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
/** @end */
