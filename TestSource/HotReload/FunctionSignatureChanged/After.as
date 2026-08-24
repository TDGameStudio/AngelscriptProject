// Theme: HotReload VersionPair After. ComputeValue(float Scale) returns Scale.
// C++: AngelscriptHotReloadChangeClassificationTests.cpp::FunctionSignatureChanged
// Retained: UReloadFunctionTarget and ComputeValue name.
// Replaced: return type and parameter list. FullReloadRequired.
// FixtureIsolated.

UCLASS()
class UReloadFunctionTarget : UObject
{
	UFUNCTION()
	float ComputeValue(float Scale)
	{
		return Scale;
	}
}
