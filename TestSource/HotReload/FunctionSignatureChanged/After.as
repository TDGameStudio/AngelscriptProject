// Theme: HotReload VersionPair After. ComputeValue(float Scale) returns Scale.
// C++: AngelscriptHotReloadChangeClassificationTests.cpp::FunctionSignatureChanged
// Retained: UReloadFunctionTarget and ComputeValue name.
// Replaced: return type and parameter list. FullReloadRequired.
// FixtureIsolated.

UCLASS()
class UReloadFunctionTarget : UObject
{
	/** Computes the value and returns the result. */
	UFUNCTION()
	float ComputeValue(float Scale)
	{
		return Scale;
	}
}
