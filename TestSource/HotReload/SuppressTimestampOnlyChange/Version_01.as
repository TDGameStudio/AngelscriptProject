// Theme: HotReload VersionPair Version_01. Source-provider timestamp-only churn.
// C++: AngelscriptHotReloadFunctionTests.cpp::SuppressTimestampOnlyChange
// Retained: Entry returns 41 for the whole scan. Timestamp-only QuerySourceState churn must not replace this body.
// Replaced: none. Content hash change queues a reload of the same source, not a second script version.
// FixtureIsolated.

int Entry()
{
	return 41;
}
