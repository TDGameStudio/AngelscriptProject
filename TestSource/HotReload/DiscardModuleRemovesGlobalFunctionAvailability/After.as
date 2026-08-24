// Theme: HotReload VersionPair After. Second global-function module, same Entry signature.
// C++: AngelscriptHotReloadFunctionTests.cpp::DiscardModuleRemovesGlobalFunctionAvailability
// Retained: this Entry returns 2 after the first module is discarded; a failed re-discard of the old module must not remove it.
// Replaced: Before Entry=1 is no longer callable.
// FixtureIsolated. C++ ExecuteIntFunction oracle is 2.

int Entry()
{
	return 2;
}
