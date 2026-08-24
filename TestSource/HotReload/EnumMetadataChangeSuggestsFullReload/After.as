// Theme: HotReload VersionPair After. Alpha UMETA DisplayName Alpha Reloaded.
// C++: AngelscriptHotReloadChangeClassificationTests.cpp::EnumMetadataChangeSuggestsFullReload
// Retained: enum members, carrier class, State default Alpha.
// Replaced: UMETA DisplayName. FullReloadSuggested.
// FixtureIsolated.

UENUM(BlueprintType)
enum class EHotReloadChangeClassificationEnumMetadataState : uint8
{
	Alpha UMETA(DisplayName="Alpha Reloaded"),
	Beta
}

UCLASS()
class UHotReloadChangeClassificationEnumMetadataTarget : UObject
{
	UPROPERTY()
	EHotReloadChangeClassificationEnumMetadataState State;

	default State = EHotReloadChangeClassificationEnumMetadataState::Alpha;
}
