// Theme: HotReload VersionPair After. Same name as multicast event.
// C++: AngelscriptHotReloadChangeClassificationTests.cpp::DelegateKindChangeRequiresFullReload
// Retained: Signal UPROPERTY and type name.
// Replaced: unicast delegate -> event. FullReloadRequired.
// FixtureIsolated.

event void FHotReloadChangeClassificationDelegateKindSignal(int Value);

UCLASS()
class UHotReloadChangeClassificationDelegateKindTarget : UObject
{
	UPROPERTY()
	FHotReloadChangeClassificationDelegateKindSignal Signal;
}
