// Theme: HotReload VersionPair After. Beta enumerator value becomes 7.
// C++: AngelscriptHotReloadChangeClassificationTests.cpp::EnumValueChange
// Retained: Alpha=1, carrier class, State default Alpha.
// Replaced: Beta 4 -> 7. FullReloadSuggested, not required.
// FixtureIsolated.

UENUM(BlueprintType)
enum class EReloadAnalysisState : uint16
{
	Alpha = 1,
	Beta = 7
}

UCLASS()
class UReloadEnumValueCarrier : UObject
{
	UPROPERTY()
	EReloadAnalysisState State;

	default State = EReloadAnalysisState::Alpha;
}
