// Theme: HotReload VersionPair After. Survivor module.
// C++: AngelscriptHotReloadFunctionTests.cpp::DiscardModule
// Retained: SurvivorEntry returns 99 before and after the discardable module is discarded.
// Replaced: UDiscardableObject from Before is removed; this global is a separate module, not a reload of that class.
// FixtureIsolated. C++ ExecuteIntFunction oracle is 99.

/** SurvivorEntry: exercises the survivor entry behaviour. */
int SurvivorEntry()
{
	return 99;
}
