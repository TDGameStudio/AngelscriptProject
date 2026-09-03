// Theme: HotReload VersionPair After. GetValue body returns 2.
// C++: AngelscriptHotReloadChangeClassificationTests.cpp::SoftReloadRequirement
// Retained: class and GetValue signature.
// Replaced: function body 1 -> 2. SoftReload only.
// FixtureIsolated.

UCLASS()
class UReloadSoftRequirementTarget : UObject
{
	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		return 2;
	}
}
