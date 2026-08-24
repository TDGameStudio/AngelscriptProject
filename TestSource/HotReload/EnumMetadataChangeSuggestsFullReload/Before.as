// Theme: HotReload VersionPair Before. Alpha UMETA DisplayName Alpha.
// C++: AngelscriptHotReloadChangeClassificationTests.cpp::EnumMetadataChangeSuggestsFullReload
// Retained: EHotReloadChangeClassificationEnumMetadataState, Beta, carrier State default Alpha.
// Replaced after After.as: UMETA DisplayName "Alpha" -> "Alpha Reloaded".
// Oracle: FullReloadSuggested, bWantsFullReload true, bNeedsFullReload false.
// FixtureIsolated. Load Before then After in recorded order.

UENUM(BlueprintType)
enum class EHotReloadChangeClassificationEnumMetadataState : uint8
{
	Alpha UMETA(DisplayName="Alpha"),
	Beta
}

UCLASS()
class UHotReloadChangeClassificationEnumMetadataTarget : UObject
{
	UPROPERTY()
	EHotReloadChangeClassificationEnumMetadataState State;

	default State = EHotReloadChangeClassificationEnumMetadataState::Alpha;
}
