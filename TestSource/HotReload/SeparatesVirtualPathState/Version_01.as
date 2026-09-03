// Theme: HotReload VersionPair Version_01. Shared relative path, separate virtual paths.
// C++: AngelscriptHotReloadFunctionTests.cpp::SeparatesVirtualPathState
// Retained: Entry returns 1 for both Game and Plugin virtual paths that share Shared/State.as.
// Replaced: none. Hash state is keyed by virtual path, not by this body changing.
// FixtureIsolated.

/** Script entry point: runs the probe and returns its result. */
int Entry()
{
	return 1;
}
