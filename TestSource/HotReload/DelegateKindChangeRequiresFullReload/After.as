// Theme: HotReload VersionPair After. Same name as multicast event.
// C++: AngelscriptHotReloadChangeClassificationTests.cpp::DelegateKindChangeRequiresFullReload
// Retained: Signal UPROPERTY and type name.
// Replaced: unicast delegate -> event. FullReloadRequired.
// FixtureIsolated.

/** Event FHotReloadChangeClassificationDelegateKindSignal: carries (int Value) for this reload scenario. */
event void FHotReloadChangeClassificationDelegateKindSignal(int Value);

UCLASS()
class UHotReloadChangeClassificationDelegateKindTarget : UObject
{
	UPROPERTY()
	FHotReloadChangeClassificationDelegateKindSignal Signal;
}
