// Theme: HotReload VersionPair Before. EReloadAnalysisState Alpha=1, Beta=4.
// C++: AngelscriptHotReloadChangeClassificationTests.cpp::EnumValueChange
// Retained: enum name, Alpha=1, UReloadEnumValueCarrier, State default Alpha.
// Replaced after After.as: Beta enumerator value 4 -> 7.
// Oracle: FullReloadSuggested; bWantsFullReload true; bNeedsFullReload false.
// FixtureIsolated. Load Before then After in recorded order.

UENUM(BlueprintType)
enum class EReloadAnalysisState : uint16
{
	Alpha = 1,
	Beta = 4
}

UCLASS()
class UReloadEnumValueCarrier : UObject
{
	UPROPERTY()
	EReloadAnalysisState State;

	default State = EReloadAnalysisState::Alpha;
}
