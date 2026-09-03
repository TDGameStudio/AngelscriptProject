// Theme: HotReload VersionPair After. First compile of EHotReloadCreatedState (not a warmup reload).
// C++: AngelscriptHotReloadEnumDelegateTests.cpp::BroadcastEnumCreatedOnFirstCompile
// Retained: warmup module identity from Before; initial compile already finished.
// Replaced: this module adds enum class EHotReloadCreatedState Alpha/Beta and RunCreatedEnumProbe.
// Oracle: OnEnumCreated once, OnEnumChanged 0; RunCreatedEnumProbe -> 2. FixtureIsolated.

UENUM(BlueprintType)
enum class EHotReloadCreatedState : uint8
{
	Alpha,
	Beta
}

/** Runs the created enum probe path and returns the observed result. */
int RunCreatedEnumProbe()
{
	EHotReloadCreatedState State = EHotReloadCreatedState::Beta;
	int Result = State == EHotReloadCreatedState::Beta ? 2 : 0;
	Log(n"HotReloadEnumDelegateTests", "Created V1 RunCreatedEnumProbe State=Beta Result=" + Result);
	return Result;
}
