// Theme: HotReload VersionPair After. Isolated failing program: unknown MissingType.
// C++: AngelscriptHotReloadEventTests.cpp::FailedReloadDoesNotBroadcastReloadDelegates
// Expected diagnostic: MissingType is not a known type (compile failure).
// Retained last-good: Before GetValue 5, same UClass object, no post/class/full reload broadcasts.
// Replaced: GetValue return type and local Value as MissingType. Do not add declarations that would compile.
// FixtureIsolated.

UCLASS()
class UFailedReloadEventTarget : UObject
{
	UFUNCTION()
	MissingType GetValue()
	{
		MissingType Value;
		return Value;
	}
}
