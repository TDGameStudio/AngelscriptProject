// Theme: HotReload VersionPair Version_01. Unrelated-module A before reload.
// C++: AngelscriptHotReloadPropertyTests.cpp::SoftReloadPreservesUnrelatedModuleExecution ScriptA
// Retained across the trio: module B GetValueB==20 (Version_02 is never reloaded).
// Replaced in Version_03: GetValueA 10 -> 11.
// Oracle Before: GetValueA==10.
// FixtureIsolated. Load Version_01 (A), Version_02 (B), then Version_03 (A v2).

int GetValueA()
{
	return 10;
}
