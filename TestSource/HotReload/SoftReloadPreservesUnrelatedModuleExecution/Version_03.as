// Theme: HotReload VersionPair Version_03. Unrelated-module A after soft reload.
// C++: AngelscriptHotReloadPropertyTests.cpp::SoftReloadPreservesUnrelatedModuleExecution ScriptAV2
// Retained: module B GetValueB==20 (Version_02).
// Replaced: GetValueA 10 -> 11.
// Oracle After: GetValueA==11; GetValueB still 20; SoftReloadOnly handled.
// FixtureIsolated. Load Version_01 (A), Version_02 (B), then Version_03 (A v2).

int GetValueA()
{
	return 11;
}
