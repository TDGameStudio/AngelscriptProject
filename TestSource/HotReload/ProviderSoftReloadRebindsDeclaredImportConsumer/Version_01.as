// Theme: HotReload VersionPair Version_01. Provider module SharedValue 11.
// C++: AngelscriptHotReloadDependencyTests.cpp::ProviderSoftReloadRebindsDeclaredImportConsumer
// Retained: SharedValue declaration imported by Version_03 consumer.
// Replaced in Version_02: return 11 -> 29. Oracle: consumer Entry() == 11 before provider reload.
// FixtureIsolated. Provider file, not the consumer.

/** SharedValue: exercises the shared value behaviour. */
int SharedValue()
{
	return 11;
}
