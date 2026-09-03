// Theme: HotReload VersionPair Before. Unicast delegate Signal property.
// C++: AngelscriptHotReloadChangeClassificationTests.cpp::DelegateKindChangeRequiresFullReload
// Retained: FHotReloadChangeClassificationDelegateKindSignal name and UHotReloadChangeClassificationDelegateKindTarget.Signal.
// Replaced after After.as: delegate -> event (kind change).
// Oracle: FullReloadRequired, bWantsFullReload true, bNeedsFullReload true.
// FixtureIsolated. Load Before then After in recorded order.

/** Delegate FHotReloadChangeClassificationDelegateKindSignal: carries (int Value) for this reload scenario. */
delegate void FHotReloadChangeClassificationDelegateKindSignal(int Value);

UCLASS()
class UHotReloadChangeClassificationDelegateKindTarget : UObject
{
	UPROPERTY()
	FHotReloadChangeClassificationDelegateKindSignal Signal;
}
