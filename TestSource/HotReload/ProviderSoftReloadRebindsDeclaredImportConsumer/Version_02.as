// Theme: HotReload VersionPair Version_02. Provider body-only soft reload.
// C++: AngelscriptHotReloadDependencyTests.cpp::ProviderSoftReloadRebindsDeclaredImportConsumer
// Retained: SharedValue name and consumer import slot / source module.
// Replaced: return 11 -> 29. Oracle: consumer Entry() == 29 after provider-only reload.
// FixtureIsolated. Provider file, pairs with Version_01.

/** SharedValue: exercises the shared value behaviour. */
int SharedValue()
{
	return 29;
}
