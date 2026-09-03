// Theme: HotReload VersionPair Before. ComputeValue() returns int 1.
// C++: AngelscriptHotReloadChangeClassificationTests.cpp::FunctionSignatureChanged
// Retained: UReloadFunctionTarget and ComputeValue name.
// Replaced after After.as: signature int() -> float(float Scale).
// Oracle: FullReloadRequired; bWantsFullReload || bNeedsFullReload.
// FixtureIsolated. Load Before then After in recorded order.

UCLASS()
class UReloadFunctionTarget : UObject
{
	/** Computes the value and returns the result. */
	UFUNCTION()
	int ComputeValue()
	{
		return 1;
	}
}
